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
import type { z } from 'zod/v3';
import { flushSync } from 'react-dom';
import { createRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { BASIC_FUNCTIONS, MessageProcessor } from '@a2ui/web_core/v0_9';
import { A2uiSurface } from '@a2ui/react/v0_9';
import { createNebaCatalog, nebaCatalogId } from '../../src/a2ui/index.js';
import { componentSchema, type CatalogSchema } from '../../src/a2ui/schema.js';
import catalog from '../../src/a2ui/catalog.json';

const SURFACE = 'test-surface';

/** The views, as text: what each one reads is only visible in its source. */
const views = Object.values(
  import.meta.glob('../../src/a2ui/components.tsx', {
    query: '?raw',
    import: 'default',
    eager: true
  })
)[0] as string;

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
     * The catalog is what the agent writes calls from, and `web_core`'s schema
     * is what then parses them. `formatDate` declared a `dateStyle` it drops,
     * `pluralize` a `count` it never reads and `formatNumber` two fraction
     * digits it does not know, so all three came back wrong; `length`, `and`
     * and `or` were declared looser than the implementation, which refuses the
     * call outright. Both directions are checked: every argument declared is
     * one the implementation knows, and the least the catalog allows parses.
     */
    describe('agrees with the implementations about arguments', () => {
      type ArgSchema = {
        properties: Record<string, { $ref?: string; type?: string; minItems?: number }>;
        required?: string[];
        anyOf?: { required: string[] }[];
      };
      const functions = createNebaCatalog().functions;
      const known = (schema: z.ZodTypeAny): string[] => {
        const def = schema._def as { shape?: () => Record<string, unknown>; schema?: z.ZodTypeAny };

        return def.shape ? Object.keys(def.shape()) : def.schema ? known(def.schema) : [];
      };
      const sample = (
        name: string,
        key: string,
        prop: ArgSchema['properties'][string]
      ): unknown => {
        if (key === 'url') return 'https://example.com';
        if (key === 'currency') return 'USD';
        if (key === 'pattern') return '.*';
        if (name === 'formatDate' && key === 'format') return 'yyyy';
        // A field's text, which `numeric` checks is a number.
        if (name === 'numeric' && key === 'value') return '3';
        if (prop.type === 'array') return Array.from({ length: prop.minItems ?? 1 }, () => true);
        if (prop.$ref?.endsWith('DynamicNumber') || prop.type === 'number') return 3;
        if (prop.$ref?.endsWith('DynamicBoolean') || prop.type === 'boolean') return true;
        return 'x';
      };

      for (const [name, definition] of Object.entries(catalog.functions)) {
        const args = (definition as { properties: { args: ArgSchema } }).properties.args;

        it(`${name}: declares only arguments the implementation takes`, () => {
          const implementation = functions.get(name)!;

          expect(known(implementation.schema).sort()).toEqual(
            expect.arrayContaining(Object.keys(args.properties).sort())
          );
        });

        it(`${name}: the fewest arguments the catalog allows are enough`, () => {
          const needed = [...(args.required ?? []), ...(args.anyOf?.[0]?.required ?? [])];
          const call = Object.fromEntries(
            needed.map((key) => [key, sample(name, key, args.properties[key])])
          );

          expect(functions.get(name)!.schema.safeParse(call).success).toBe(true);
        });
      }
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

    /*
     * A key the catalog does not declare is stripped, not refused, because a
     * refusal drops the whole message. `Checkable` is built by `web_core`'s Zod,
     * which under a project's Zod 4 is a copy of its own; merged in last, its
     * `ZodNever` was one this copy's `instanceof` did not recognise, and the
     * component refused every stray key. Only the run with Zod 4 installed can
     * fail this, so both orders are checked rather than the catalog's one.
     */
    it('strips an undeclared key wherever `Checkable` sits in the composition', () => {
      const definition = catalog.components.TextField as CatalogSchema;
      const orders = [definition.allOf!, [...definition.allOf!].reverse()];

      for (const allOf of orders) {
        const parsed = componentSchema('TextField', { allOf }).safeParse({
          label: 'Name',
          stray: 1
        });

        expect(parsed.success).toBe(true);
        expect(parsed.data).toEqual({ label: 'Name' });
      }
    });

    /*
     * The schema takes a prop whether or not the view does anything with it,
     * so a prop the catalog offers and the view never reads is one the agent
     * sets and nothing changes. Read off the source, since the props arrive
     * as one untyped object.
     */
    it('reads every prop the catalog declares', () => {
      const unread: string[] = [];

      for (const [name, definition] of Object.entries(catalog.components)) {
        const start = views.indexOf(`implement('${name}'`);
        const next = views.indexOf("implement('", start + 1);
        const body = views.slice(start, next === -1 ? undefined : next);
        const parts = (definition as CatalogSchema).allOf ?? [definition as CatalogSchema];

        expect(start, name).toBeGreaterThan(-1);

        for (const part of parts) {
          for (const prop of Object.keys(part.properties ?? {})) {
            if (prop !== 'component' && !new RegExp(`\\b(?:p|props)\\.${prop}\\b`).test(body)) {
              unread.push(`${name}.${prop}`);
            }
          }
        }
      }

      expect(unread).toEqual([]);
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

  describe('speaks the language it is given', () => {
    // The components follow a `NebaProvider`; the formatting functions follow
    // whatever the catalog was built with, and the two have to agree.
    it('formats numbers and plurals in the locale the catalog was built for', async () => {
      const processor = new MessageProcessor([createNebaCatalog({ locale: 'de' })]);

      processor.processMessages([
        { version: 'v0.9', createSurface: { surfaceId: SURFACE, catalogId: nebaCatalogId } },
        {
          version: 'v0.9',
          updateComponents: {
            surfaceId: SURFACE,
            components: [
              {
                id: 'root',
                component: 'Typography',
                text: { call: 'formatNumber', args: { value: 1234.5 }, returnType: 'string' }
              }
            ]
          }
        }
      ] as Message[]);

      const surface = processor.model.surfacesMap.get(SURFACE);

      if (!surface) {
        throw new Error('the processor refused the surface');
      }

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('1.234,5')).toBeInTheDocument();
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

    // Every schema accepted `accessibility` and no view read it, so an agent
    // that named a group of controls named nothing.
    it('names the roots that have no name of their own, and describes them', async () => {
      const { surface } = surfaceOf(
        [
          {
            id: 'root',
            component: 'Flex',
            children: ['card', 'photo'],
            accessibility: { label: 'Order', description: { path: '/note' } }
          },
          {
            id: 'card',
            component: 'Card',
            child: 'go',
            accessibility: { label: 'Shipping' }
          },
          {
            id: 'go',
            component: 'Button',
            text: 'Pay',
            action: { event: { name: 'pay' } },
            accessibility: { label: 'Ignored' }
          },
          {
            id: 'photo',
            component: 'Image',
            src: '/samples/photos/a.jpg',
            alt: 'A parcel on a doorstep',
            accessibility: { label: 'Ignored', description: 'Left by the courier at 9:40' }
          }
        ],
        { note: 'Three items, arriving Friday' }
      );

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect
        .element(screen.getByRole('group', { name: 'Order' }))
        .toHaveAccessibleDescription('Three items, arriving Friday');
      await expect.element(screen.getByRole('group', { name: 'Shipping' })).toBeInTheDocument();
      // A button with text on it keeps the text as its name.
      await expect.element(screen.getByRole('button', { name: 'Pay' })).toBeInTheDocument();
      // Its `alt` is required, so it already has a name, and keeps it.
      await expect
        .element(screen.getByRole('img', { name: 'A parcel on a doorstep' }))
        .toHaveAccessibleDescription('Left by the courier at 9:40');
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

    // The catalog types `value` as a string and a Statistic draws a delta only
    // from a number, so `previousValue` drew nothing unless the value happened
    // to be bound to a number in the data model.
    it('draws a Statistic\u2019s delta from a value written as digits', async () => {
      const { surface } = surfaceOf([
        {
          id: 'root',
          component: 'Flex',
          children: ['visits', 'revenue']
        },
        { id: 'visits', component: 'Statistic', label: 'Visits', value: '120', previousValue: 100 },
        { id: 'revenue', component: 'Statistic', label: 'Revenue', value: '4.2M', previousValue: 4 }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByText('+20%')).toBeInTheDocument();
      // Written out rather than as digits, so it is drawn as it came.
      await expect.element(screen.getByText('4.2M')).toBeInTheDocument();
      expect(screen.getByText(/%$/).elements()).toHaveLength(1);
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

  describe('keeps what is on screen', () => {
    // A child put in front of the others is a new node, and nothing else is.
    it('keeps a field being typed in when a sibling is put before it', async () => {
      const { processor, surface } = surfaceOf(
        [
          { id: 'root', component: 'Flex', direction: 'vertical', children: ['note', 'region'] },
          { id: 'note', component: 'Typography', text: 'Where should it deploy?' },
          { id: 'region', component: 'TextField', label: 'Region', value: { path: '/region' } }
        ],
        { region: '' }
      );

      const screen = await render(<A2uiSurface surface={surface} />);
      const field = screen.getByRole('textbox', { name: 'Region' });

      await field.click();
      const element = field.element();

      expect(document.activeElement).toBe(element);

      processor.processMessages([
        {
          version: 'v0.9',
          updateComponents: {
            surfaceId: SURFACE,
            components: [
              {
                id: 'root',
                component: 'Flex',
                direction: 'vertical',
                children: ['heading', 'note', 'region']
              },
              { id: 'heading', component: 'Typography', level: 'h3', text: 'Deploy' }
            ]
          }
        }
      ] as Message[]);

      await expect.element(screen.getByRole('heading', { name: 'Deploy' })).toBeInTheDocument();
      expect(element.isConnected).toBe(true);
      expect(document.activeElement).toBe(element);
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

    // The views are controlled and the setter does nothing without a path, so
    // a field written as a literal, or with no value at all, could not change.
    it('lets a reader change a field that is not bound to the data model', async () => {
      const { surface } = surfaceOf([
        { id: 'root', component: 'Flex', children: ['city', 'terms'] },
        { id: 'city', component: 'TextField', label: 'City', value: 'Seoul' },
        { id: 'terms', component: 'Checkbox', label: 'I agree' }
      ]);

      const screen = await render(<A2uiSurface surface={surface} />);
      const field = screen.getByRole('textbox', { name: 'City' });
      const tick = screen.getByRole('checkbox', { name: 'I agree' });

      await field.fill('Tokyo');
      await screen.getByText('I agree').click();

      await expect.element(field).toHaveValue('Tokyo');
      await expect.element(tick).toBeChecked();
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

  // `openUrl` is declared as needing a user activation and nothing enforced
  // it: a call written into any string ran when the component bound, and a
  // surface could open a page the moment it was drawn.
  describe('opens an address only when the reader acts', () => {
    it('does not open one from a binding', async () => {
      // A press earlier in the run leaves the page activated for a few seconds,
      // which is exactly the window this has to be outside of.
      await expect.poll(() => navigator.userActivation.isActive, { timeout: 8000 }).toBe(false);

      const open = vi.spyOn(window, 'open').mockReturnValue(null);

      try {
        const { surface } = surfaceOf([
          {
            id: 'root',
            component: 'Typography',
            text: { call: 'openUrl', args: { url: 'https://example.com/' }, returnType: 'void' }
          }
        ]);

        await render(<A2uiSurface surface={surface} />);
        await new Promise((resolve) => setTimeout(resolve, 50));

        expect(open).not.toHaveBeenCalled();
      } finally {
        open.mockRestore();
      }
    });

    it('opens one from a button the reader presses', async () => {
      const open = vi.spyOn(window, 'open').mockReturnValue(null);

      try {
        const { surface } = surfaceOf([
          {
            id: 'root',
            component: 'Button',
            text: 'Read more',
            action: {
              functionCall: {
                call: 'openUrl',
                args: { url: 'https://example.com/' },
                returnType: 'void'
              }
            }
          }
        ]);

        const screen = await render(<A2uiSurface surface={surface} />);

        await screen.getByRole('button', { name: 'Read more' }).click();

        await expect.poll(() => open.mock.calls.length).toBe(1);
      } finally {
        open.mockRestore();
      }
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

    // v1.0 lets a check leave its message out and v0.9's schema refused it,
    // and the refusal took every component in the batch with it.
    it('draws a field whose check has no message', async () => {
      const { surface } = surfaceOf(
        [
          {
            id: 'root',
            component: 'TextField',
            label: 'Email',
            value: { path: '/email' },
            checks: [{ condition: { call: 'email', args: { value: { path: '/email' } } } }]
          }
        ],
        { email: 'not-an-address' }
      );

      const screen = await render(<A2uiSurface surface={surface} />);

      await expect.element(screen.getByRole('textbox', { name: 'Email' })).toBeInTheDocument();
      await expect.element(screen.getByText('Validation failed')).toBeInTheDocument();
    });
  });
});
