/**
 * The adapter, driven the way an agent drives it.
 *
 * Every other test in `test/package/` checks the catalog as *data*: the keys,
 * the names, the refs. This one is the only thing in the repository that finds
 * out whether an agent's JSON actually becomes Neba components — the schemas
 * are derived at runtime, so a prop misspelled in `components.tsx` type-checks
 * against nothing at all and fails for the first person to render a surface.
 *
 * The messages below are the ones an agent sends, in the shape it sends them.
 */
import { describe, expect, it, vi } from 'vitest';
import type { z } from 'zod';
import { flushSync } from 'react-dom';
import { createRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { BASIC_FUNCTIONS, MessageProcessor } from '@a2ui/web_core/v0_9';
import { A2uiSurface } from '@a2ui/react/v0_9';
import { createNebaCatalog, nebaCatalogId } from '../../src/a2ui/index.js';
import { componentSchema, type CatalogSchema } from '../../src/a2ui/schema.js';
import catalog from '../../src/a2ui/catalog.json';

const SURFACE = 'test-surface';

type Message = Parameters<MessageProcessor<never>['processMessages']>[0] extends (infer M)[]
  ? M
  : never;

/** A processor fed a surface, a component tree and a data model. */
function surfaceOf(
  components: readonly Record<string, unknown>[],
  data: Record<string, unknown> = {},
  onAction?: (action: unknown) => void
) {
  const processor = new MessageProcessor(
    [createNebaCatalog()],
    onAction === undefined ? undefined : (action) => onAction(action)
  );

  processor.processMessages([
    { version: 'v0.9', createSurface: { surfaceId: SURFACE, catalogId: nebaCatalogId } },
    { version: 'v0.9', updateComponents: { surfaceId: SURFACE, components } },
    { version: 'v0.9', updateDataModel: { surfaceId: SURFACE, path: '/', value: data } }
  ] as Message[]);

  const surface = processor.model.surfacesMap.get(SURFACE);

  if (!surface) {
    throw new Error('the processor refused the surface');
  }

  return { processor, surface };
}

describe('the A2UI adapter', () => {
  describe('covers the catalog', () => {
    it('implements every component the catalog declares, and no others', () => {
      const registered = [...createNebaCatalog().components.keys()].sort();

      expect(registered).toEqual(Object.keys(catalog.components).sort());
    });

    // Declaring a function is a claim the renderer runs it. `web_core` already
    // implements the protocol's own, and a second implementation of
    // `formatCurrency` is a second chance to disagree with the agent.
    it('finds an implementation for every function the catalog declares', () => {
      const implemented = new Set(BASIC_FUNCTIONS.map((one) => one.name));
      const missing = Object.keys(catalog.functions).filter((name) => !implemented.has(name));

      expect(missing).toEqual([]);
      expect([...createNebaCatalog().functions.keys()].sort()).toEqual(
        Object.keys(catalog.functions).sort()
      );
    });

    /*
     * The converter throws on anything it has not met rather than returning
     * `z.any()`, so this is where a construct added to the catalog stops the
     * build — instead of quietly leaving a prop unvalidated in a consumer's
     * renderer.
     */
    it('converts every component in the catalog without meeting anything it cannot', () => {
      for (const [name, definition] of Object.entries(catalog.components)) {
        expect(() => componentSchema(name, definition as CatalogSchema), name).not.toThrow();
      }
    });

    // A keyword the converter passed over would be a prop the agent is told is
    // bounded and the renderer takes unbounded.
    it('throws on a keyword it does not know', () => {
      const unknown = (definition: unknown) => () =>
        componentSchema('Made', definition as CatalogSchema);

      expect(
        unknown({ type: 'object', properties: { name: { type: 'string', maxLength: 3 } } })
      ).toThrow(/maxLength/);
      expect(unknown({ type: 'object', properties: {}, patternProperties: {} })).toThrow(
        /patternProperties/
      );
    });

    it('holds a number to the type and the minimum the catalog gives it', () => {
      const schema = componentSchema(
        'Typography',
        catalog.components.Typography as CatalogSchema
      ) as z.AnyZodObject;

      expect(schema.shape.lines.safeParse(2).success).toBe(true);
      expect(schema.shape.lines.safeParse(0).success).toBe(false);
      expect(schema.shape.lines.safeParse(1.5).success).toBe(false);
    });

    // Every value the agent is told it may write has to be one the renderer
    // takes. `z.enum` refuses numbers, so an `elevation` of `0` to `3` was a
    // prop no agent could set without the whole message being dropped.
    it('accepts every value of every enum in the catalog', () => {
      for (const [name, definition] of Object.entries(catalog.components)) {
        const schema = componentSchema(name, definition as CatalogSchema) as z.AnyZodObject;
        const parts = (definition as CatalogSchema).allOf ?? [definition as CatalogSchema];

        for (const part of parts) {
          for (const [prop, property] of Object.entries(part.properties ?? {})) {
            for (const value of property.enum ?? []) {
              expect(
                schema.shape[prop].safeParse(value).success,
                `${name}.${prop} = ${value}`
              ).toBe(true);
            }
          }
        }
      }
    });
  });

  describe('keeps its defaults', () => {
    /*
     * A `default` in the catalog is a claim about what the renderer does when
     * the prop is left out, and the model reads it as one. So each is drawn
     * twice, once written out and once not, and the two have to be the same
     * markup. The fixtures hold only what each component requires.
     */
    const fixtures: Record<string, Record<string, unknown>> = {
      Flex: { children: [] },
      Card: {},
      Divider: {},
      Typography: { text: 'Words' },
      Image: { src: '/sample.png', alt: 'Sample' },
      Chip: { text: 'Tag' },
      Avatar: { name: 'Ada Lovelace' },
      Statistic: { label: 'Visits', value: '42' },
      DataList: { items: [{ label: 'Region', value: 'Seoul' }] },
      Alert: { title: 'Heads up' },
      Button: { text: 'Go', action: { event: { name: 'go' } } },
      TextField: { label: 'Name' },
      NumberField: { label: 'Count' },
      Checkbox: { label: 'Agree' },
      Switch: { label: 'On' },
      RadioGroup: { label: 'Env', options: [{ label: 'Staging', value: 'staging' }] },
      Select: { label: 'Env', options: [{ label: 'Staging', value: 'staging' }] },
      Slider: { label: 'Volume' }
    };

    /**
     * The surface's first render, into a box of its own, with the ids React
     * makes up taken out: they count up across renders, so the same tree drawn
     * twice would never compare equal otherwise.
     */
    function markup(node: Record<string, unknown>) {
      const { surface } = surfaceOf([{ id: 'root', ...node }]);
      const host = document.createElement('div');
      const root = createRoot(host);

      flushSync(() => root.render(<A2uiSurface surface={surface} />));

      const html = host.innerHTML.replace(/_r_[0-9a-z]+_|«[^»]*»|:r[0-9a-z]+:/g, 'ID');
      root.unmount();

      return html;
    }

    /*
     * Written out, these two add a class that says what the browser already
     * does with nothing: `flex-start` and `stretch` are what a flex container's
     * `normal` means on each axis.
     */
    const sameInEffect = new Set(['Flex.justifyContent', 'Flex.alignItems']);

    it('draws what leaving a prop out draws, for every default in the catalog', () => {
      expect(Object.keys(fixtures).sort()).toEqual(Object.keys(catalog.components).sort());

      const differ: string[] = [];

      for (const [name, definition] of Object.entries(catalog.components)) {
        const parts = (definition as CatalogSchema).allOf ?? [definition as CatalogSchema];
        const base = { component: name, ...fixtures[name] };
        const bare = markup(base);

        for (const part of parts) {
          for (const [prop, property] of Object.entries(part.properties ?? {})) {
            if (property.default === undefined || sameInEffect.has(`${name}.${prop}`)) continue;

            if (markup({ ...base, [prop]: property.default }) !== bare) {
              differ.push(`${name}.${prop} = ${JSON.stringify(property.default)}`);
            }
          }
        }
      }

      expect(differ).toEqual([]);
    });
  });

  describe('draws what the agent wrote', () => {
    it('turns a component tree into Neba components', async () => {
      const { surface } = surfaceOf([
        {
          id: 'root',
          component: 'Flex',
          direction: 'vertical',
          spacing: 4,
          children: ['title', 'note']
        },
        { id: 'title', component: 'Typography', level: 'h3', text: 'Deploy finished' },
        { id: 'note', component: 'Typography', text: 'Seoul is back on the previous build.' }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect
        .element(screen.getByRole('heading', { name: 'Deploy finished' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByText('Seoul is back on the previous build.'))
        .toBeInTheDocument();
    });

    it('resolves a value the agent bound to the data model', async () => {
      const { surface } = surfaceOf(
        [{ id: 'root', component: 'Typography', text: { path: '/headline' } }],
        { headline: 'Bound, not written' }
      );

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('Bound, not written')).toBeInTheDocument();
    });

    // A `Card` takes one child by id, which is the shape of every container in
    // the catalog. If `componentId()` were a bare string the node layer would
    // never resolve it and the card would come up empty.
    it('resolves a child reference', async () => {
      const { surface } = surfaceOf([
        { id: 'root', component: 'Card', title: 'Region', child: 'body' },
        { id: 'body', component: 'Typography', text: 'Seoul' }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('Region')).toBeInTheDocument();
      await expect.element(screen.getByText('Seoul')).toBeInTheDocument();
    });

    it('draws a card at the elevation the agent asked for', async () => {
      const { surface } = surfaceOf([
        { id: 'root', component: 'Card', title: 'Lifted', elevation: 2, child: 'body' },
        {
          id: 'body',
          component: 'Button',
          text: 'Open',
          action: { event: { name: 'open' } },
          elevation: 1
        }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('Lifted')).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Open' })).toBeInTheDocument();
    });

    it('draws a list of facts', async () => {
      const { surface } = surfaceOf([
        {
          id: 'root',
          component: 'DataList',
          items: [
            { label: 'Region', value: 'Seoul' },
            { label: 'Build', value: '4c1f92a' }
          ]
        }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('Region')).toBeInTheDocument();
      await expect.element(screen.getByText('4c1f92a')).toBeInTheDocument();
    });

    it('draws a choice as a real radio group', async () => {
      const { surface } = surfaceOf([
        {
          id: 'root',
          component: 'RadioGroup',
          label: 'Environment',
          value: 'staging',
          options: [
            { label: 'Staging', value: 'staging' },
            { label: 'Production', value: 'production' }
          ]
        }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByRole('radio', { name: 'Staging' })).toBeChecked();
      await expect.element(screen.getByRole('radio', { name: 'Production' })).toBeInTheDocument();
    });
  });

  describe('writes back', () => {
    it('puts what was typed into the data model', async () => {
      const { surface } = surfaceOf(
        [{ id: 'root', component: 'TextField', label: 'Region', value: { path: '/region' } }],
        { region: 'Seoul' }
      );

      const screen = await render(<A2uiSurface surface={surface} />);
      const field = screen.getByRole('textbox', { name: 'Region' });

      await expect.element(field).toHaveValue('Seoul');

      await field.fill('Tokyo');

      // The binder's setter is the whole of two-way binding, and the surface's
      // data model is what is sent back to the agent.
      await expect.poll(() => surface.dataModel.get('/region')).toBe('Tokyo');
    });

    it('reports an action to the handler the host gave it', async () => {
      const onAction = vi.fn();
      const { surface } = surfaceOf(
        [
          {
            id: 'root',
            component: 'Button',
            text: 'Roll back',
            action: { event: { name: 'rollback' } }
          }
        ],
        {},
        onAction
      );

      const screen = await render(<A2uiSurface surface={surface} />);

      await screen.getByRole('button', { name: 'Roll back' }).click();

      expect(onAction).toHaveBeenCalled();
    });
  });

  describe('runs the checks the agent wrote', () => {
    /*
     * `checks` is in the schema through the catalog's `Checkable`, and the
     * binder evaluates it reactively. A field whose check fails draws the
     * message as its own error rather than as a component beside it, which is
     * what the catalog's instructions tell the model.
     */
    it('draws a failed check as the field’s own error', async () => {
      const { surface } = surfaceOf(
        [
          {
            id: 'root',
            component: 'TextField',
            label: 'Email',
            value: { path: '/email' },
            checks: [
              {
                condition: { call: 'email', args: { value: { path: '/email' } } },
                message: 'That is not an address'
              }
            ]
          }
        ],
        { email: 'not-an-address' }
      );

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('That is not an address')).toBeInTheDocument();
    });
  });
});
