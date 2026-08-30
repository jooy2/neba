/**
 * The standalone stylesheet — `neba/styles.css`.
 *
 * Every other file in `test/` runs with no CSS at all, on purpose: the suite
 * tests the components' behaviour, and Base UI's own styling is not this
 * library's to verify. This file is the exception, because the thing under test
 * *is* a stylesheet — the promise that a project which installs `neba` and
 * nothing else, and imports one file, gets styled components. That promise is
 * made of parts that can each break silently: the reset, the compiled
 * utilities, and the tokens the utilities read.
 *
 * What is loaded here is `src/standalone.css`, the same entry
 * `scripts/build-styles.mjs` compiles into `dist/styles.css`, through Vite and
 * the repository's own PostCSS config — so it is the same input and the same
 * compiler, without the test needing a build to have run first.
 *
 * The assertions stay off the design: no shade, no radius value, no height from
 * the size ladder. Those belong to the design language and move with it. What
 * is asserted is only that each layer arrived and that they compose — a
 * `border-radius` that is *not zero*, a background that is *not transparent*.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Checkbox, Chip, List, ListItem, Switch, Typography } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';
import pkg from '../../package.json';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** Resolved value of a custom property, from wherever it inherits. */
function token(element: Element, name: string): string {
  return getComputedStyle(element).getPropertyValue(name).trim();
}

/**
 * How big the box a pointer is actually tested against is, in CSS pixels.
 *
 * A pseudo element has no rect to measure, so `.neba-hit`'s `::before` is
 * reconstructed from its insets — which are resolved against the host's
 * *padding* box, not its border box. What a press lands on is the union of that
 * and the element itself, since the element is still there underneath.
 */
function targetSize(element: Element): { width: number; height: number } {
  const own = element.getBoundingClientRect();
  const styles = getComputedStyle(element);
  const before = getComputedStyle(element, '::before');
  const px = (declaration: CSSStyleDeclaration, name: string) =>
    parseFloat(declaration.getPropertyValue(name)) || 0;

  /** One axis, in the element's own border-box coordinates. */
  const axis = (start: string, end: string, border: number, inner: number, extent: number) => {
    const from = Math.min(0, border + px(before, start));
    const to = Math.max(extent, border + inner - px(before, end));

    return to - from;
  };

  return {
    width: axis('left', 'right', px(styles, 'border-left-width'), element.clientWidth, own.width),
    height: axis('top', 'bottom', px(styles, 'border-top-width'), element.clientHeight, own.height)
  };
}

describe('neba/styles.css', () => {
  describe('the file is self-contained', () => {
    it('carries the compiled utilities, not just the tokens', () => {
      // A class the components spell out, in its resolved form. If the scan
      // ever stops finding `src/`, the tokens still ship and every assertion
      // about a custom property still passes — this is what would not.
      expect(standaloneCss).toContain('.inline-flex');
      expect(standaloneCss).toContain('--neba-radius-md');
      expect(standaloneCss).toContain('.neba-glow');
    });

    it('leaves nothing for a consumer build to resolve', () => {
      // `@source` is an instruction to Tailwind. Reaching the output would mean
      // the file had not been compiled — and a browser would ignore it, so the
      // failure would show up as unstyled components rather than as an error.
      expect(standaloneCss).not.toContain('@source');
      expect(standaloneCss).not.toContain('@tailwind');
    });

    it('is exported under both names the package promises', () => {
      expect(pkg.exports['./styles.css']).toBe('./dist/styles.css');
      expect(pkg.exports['./tailwind.css']).toBe('./dist/tailwind.css');
    });
  });

  describe('the reset', () => {
    it('puts padding and border inside a control box', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();

      expect(getComputedStyle(element).boxSizing).toBe('border-box');
    });

    it('takes the markers, the indent and the margins off a list element', async () => {
      // `render={<ul />}` is the documented way to get real list markup out of
      // List, and nothing in the component takes the UA's list styling off it —
      // an unstyled `<ul>` is what the design assumes underneath, exactly as it
      // is under Tailwind's own Preflight. `dividers` is the variant that adds
      // no padding of its own, so what is measured here is only the reset.
      const screen = await render(
        <List render={<ul />} dividers>
          <ListItem>Production</ListItem>
        </List>
      );
      const styles = getComputedStyle(screen.getByRole('list').element());

      expect(styles.listStyleType).toBe('none');
      expect(styles.paddingInlineStart).toBe('0px');
      expect(styles.marginBlockStart).toBe('0px');
    });

    it('leaves flow content to be spaced by the component around it', async () => {
      const screen = await render(<Typography>Body copy</Typography>);
      const styles = getComputedStyle(screen.getByText('Body copy').element());

      expect(styles.marginBlockStart).toBe('0px');
      expect(styles.marginBlockEnd).toBe('0px');
    });

    it('loses to a single type selector from the page', async () => {
      // The whole reason every rule in `reset.css` is wrapped in `:where()`.
      // A consumer's own stylesheet outranks it without needing `!important`,
      // a layer, or a particular import order.
      const page = document.createElement('style');
      page.textContent = 'ul { list-style: square; }';
      document.head.append(page);

      try {
        const screen = await render(
          <List render={<ul />} dividers>
            <ListItem>Production</ListItem>
          </List>
        );

        expect(getComputedStyle(screen.getByRole('list').element()).listStyleType).toBe('square');
      } finally {
        page.remove();
      }
    });
  });

  describe('the utilities', () => {
    it('style a control that would otherwise be a bare button', async () => {
      const screen = await render(<Button>Save</Button>);
      const styles = getComputedStyle(screen.getByRole('button').element());

      expect(styles.display).toBe('inline-flex');
      expect(styles.borderRadius).not.toBe('0px');
      expect(parseFloat(styles.paddingLeft)).toBeGreaterThan(0);
      expect(parseFloat(styles.height)).toBeGreaterThan(0);
    });

    it('outrank the reset where the two meet', async () => {
      // `reset.css` zeroes the padding of every `<ul>`; a List without dividers
      // then pads its own, so a hovered row does not run into the sheet's edge.
      // A utility is one class and the reset is none, so this only holds while
      // the reset stays inside `:where()`.
      const screen = await render(
        <List render={<ul />}>
          <ListItem>Production</ListItem>
        </List>
      );
      const padding = getComputedStyle(screen.getByRole('list').element()).paddingLeft;

      expect(parseFloat(padding)).toBeGreaterThan(0);
    });
  });

  describe('the target under a small control', () => {
    /*
     * WCAG 2.5.8 asks a target to be 24 CSS pixels in both directions. A tick,
     * a switch and the × on a Chip are all sized against the text beside them,
     * which is smaller than that at every step of the ladder — so `.neba-hit`
     * grows the box that is pressed without touching the one that is drawn.
     *
     * The number is a conformance floor rather than a design value, which is
     * why it is asserted here at all: nothing about it moves when the design
     * language does.
     */
    it('gives a bare tick something a finger can hit', async () => {
      const screen = await render(<Checkbox aria-label="Ship it" />);
      const element = screen.getByRole('checkbox').element();
      const target = targetSize(element);

      expect(element.getBoundingClientRect().width).toBeLessThan(24);
      expect(target.width).toBeGreaterThanOrEqual(24);
      expect(target.height).toBeGreaterThanOrEqual(24);
    });

    it('grows only the axis that is short of it', async () => {
      // A switch is wide and flat: the width is already past the minimum at
      // every step, and growing it as well would push the target out over
      // whatever the switch happens to be sitting next to.
      const screen = await render(<Switch aria-label="Notify me" />);
      const element = screen.getByRole('switch').element();
      const drawn = element.getBoundingClientRect();
      const target = targetSize(element);

      expect(drawn.width).toBeGreaterThanOrEqual(24);
      expect(drawn.height).toBeLessThan(24);
      expect(Math.round(target.width)).toBe(Math.round(drawn.width));
      expect(target.height).toBeGreaterThanOrEqual(24);
    });

    it('reaches the × that removes a chip', async () => {
      const screen = await render(
        <Chip onDelete={() => {}} deleteLabel="Remove">
          Draft
        </Chip>
      );
      const target = targetSize(screen.getByRole('button', { name: 'Remove' }).element());

      expect(target.width).toBeGreaterThanOrEqual(24);
      expect(target.height).toBeGreaterThanOrEqual(24);
    });
  });

  describe('the tokens', () => {
    it('resolve through the utilities into a painted surface', async () => {
      // The full chain: a `color` prop picks a family, the component writes it
      // into an `--n-*` slot, a utility reads the slot, and the slot resolves
      // to a token declared on `:root`. Any link missing leaves this
      // transparent.
      const screen = await render(<Button color="primary">Save</Button>);
      const background = getComputedStyle(screen.getByRole('button').element()).backgroundColor;

      expect(background).not.toBe('transparent');
      expect(background).not.toBe('rgba(0, 0, 0, 0)');
    });

    it('answer to a forced theme without any further setup', async () => {
      const screen = await render(<Button>Save</Button>);
      const element = screen.getByRole('button').element();
      const light = token(element, '--neba-surface');

      document.documentElement.setAttribute('data-theme', 'dark');

      try {
        expect(token(element, '--neba-surface')).not.toBe(light);
      } finally {
        document.documentElement.removeAttribute('data-theme');
      }
    });
  });
});
