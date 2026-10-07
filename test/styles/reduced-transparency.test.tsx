/**
 * The reduced-transparency block, checked against the rules it has to beat and,
 * in Chromium, under the preference itself.
 *
 * The blur is declared on three theme roots, one of them at three classes'
 * weight, and the backing has to be set on every root a surface colour is
 * declared on, since `var(--neba-surface)` resolves where it is written. A rule
 * that missed one of them would leave the acrylic on, or lay a `.dark` box's
 * sheets on the light page's white, in exactly the subtree nobody looks at.
 *
 * Only Chromium can be told a reader asked for less transparency; Firefox keeps
 * the media feature behind a flag and WebKit has none. Every engine runs the
 * rule checks.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { cdp, server } from 'vitest/browser';
// Where the provider gives `cdp()` its `send`; the test config names only the
// provider's context, which leaves the session's type empty.
import type {} from '@vitest/browser-playwright';
import { Button, Card, Pill, Switch } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

interface PlacedRule {
  rule: CSSStyleRule;
  /** Where the rule's outermost container sits in the sheet. */
  index: number;
}

/** Every style rule in the sheet, however deeply nested, with its top-level position. */
function allRules(): PlacedRule[] {
  const collect = (rules: CSSRuleList, index: number): PlacedRule[] =>
    [...rules].flatMap((rule) =>
      rule instanceof CSSStyleRule
        ? [{ rule, index }]
        : rule instanceof CSSGroupingRule
          ? collect(rule.cssRules, index)
          : []
    );

  return [...(sheet.sheet?.cssRules ?? [])].flatMap((rule, index) =>
    rule instanceof CSSStyleRule
      ? [{ rule, index }]
      : rule instanceof CSSGroupingRule
        ? collect(rule.cssRules, index)
        : []
  );
}

/**
 * The token block. Not the first rule under the condition: a component's own
 * utility can sit under it too, as a text Pill's wash does.
 */
function reducedBlockIndex(): number {
  return [...(sheet.sheet?.cssRules ?? [])].findIndex(
    (rule) =>
      rule instanceof CSSMediaRule &&
      rule.conditionText.includes('prefers-reduced-transparency') &&
      [...rule.cssRules].some(
        (inner) =>
          inner instanceof CSSStyleRule && inner.style.getPropertyValue('--neba-backing') !== ''
      )
  );
}

function selectors(rule: CSSStyleRule): string[] {
  return rule.selectorText.split(',').map((selector) => selector.trim());
}

/** The alpha of a computed colour: `rgb()`, `rgba()` or `color(srgb …)`. */
function alpha(color: string): number {
  const match = /\/\s*([\d.]+)\s*\)$/.exec(color) ?? /^rgba\(.*,\s*([\d.]+)\)$/.exec(color);

  return match ? Number(match[1]) : 1;
}

/** One element per kind of theme root, attached to the page while `run` runs. */
function withThemeRoots(run: (roots: Element[]) => void) {
  const roots = ['dark', 'light'].flatMap((theme) => {
    const byClass = document.createElement('div');
    const byAttribute = document.createElement('div');

    byClass.className = theme;
    byAttribute.setAttribute('data-theme', theme);

    return [byClass, byAttribute];
  });

  document.body.append(...roots);

  try {
    run([document.documentElement, ...roots]);
  } finally {
    roots.forEach((root) => root.remove());
  }
}

describe('prefers-reduced-transparency', () => {
  it('takes the blur off every root that declares it, at its weight and after it', () => {
    const block = reducedBlockIndex();
    const placed = allRules();
    const inside = placed.filter(({ index }) => index === block).map(({ rule }) => rule);
    const outside = placed.filter(
      ({ index, rule }) => index !== block && rule.style.getPropertyValue('--neba-blur') !== ''
    );

    expect(block).toBeGreaterThan(-1);
    expect(outside.length).toBeGreaterThan(0);

    for (const { rule, index } of outside) {
      expect(index, rule.selectorText).toBeLessThan(block);

      for (const selector of selectors(rule)) {
        expect(
          inside.some(
            (candidate) =>
              selectors(candidate).includes(selector) &&
              candidate.style.getPropertyValue('--neba-blur').trim() === 'none'
          ),
          selector
        ).toBe(true);
      }
    }
  });

  it('lays the sheets on the surface of every theme root', () => {
    const block = reducedBlockIndex();
    const backing = allRules()
      .filter(({ index }) => index === block)
      .map(({ rule }) => rule)
      .filter(
        (rule) => rule.style.getPropertyValue('--neba-backing').trim() === 'var(--neba-surface)'
      );

    expect(backing.length).toBeGreaterThan(0);

    withThemeRoots((roots) => {
      for (const root of roots) {
        expect(
          backing.some((rule) => root.matches(rule.selectorText)),
          root.outerHTML.slice(0, 60)
        ).toBe(true);
      }
    });
  });

  it('screens the highlight a placeholder sweeps, so it only lightens what it crosses', () => {
    // The panel colour a Skeleton sweeps in is laid on the surface under the
    // preference, which in the dark theme is darker than the placeholder.
    const screened = [...(sheet.sheet?.cssRules ?? [])]
      .filter(
        (rule): rule is CSSMediaRule =>
          rule instanceof CSSMediaRule &&
          rule.conditionText.includes('prefers-reduced-transparency')
      )
      .flatMap((rule) => [...rule.cssRules])
      .filter(
        (rule): rule is CSSStyleRule =>
          rule instanceof CSSStyleRule && rule.selectorText === '.neba-skeleton::after'
      );

    expect(screened.map((rule) => rule.style.mixBlendMode)).toEqual(['screen']);
  });

  // The fills and the panels are mixed into the backing, so with nothing asked
  // for they come out exactly as translucent as they were.
  it('leaves the backing transparent without the preference', () => {
    withThemeRoots((roots) => {
      for (const root of roots) {
        expect(getComputedStyle(root).getPropertyValue('--neba-backing').trim()).toBe(
          'transparent'
        );
      }
    });
  });

  it.runIf(server.browser === 'chromium')(
    'turns the surfaces opaque and drops the blur when the reader asks',
    async () => {
      const session = cdp();
      const screen = await render(
        <>
          <Card title="Page" data-testid="page">
            <Button>Page</Button>
          </Card>
          {/* A wash rather than a sheet, laid on the surface on its own. */}
          <Pill variant="text" title="Wash" data-testid="pill" />
          {/* The off track is a groove, a wash too. */}
          <Switch label="Track" />
          <div className="dark">
            <Card title="Dark" data-testid="dark">
              <Button>Dark</Button>
            </Card>
            <div data-theme="light">
              <Card title="Light" data-testid="light">
                <Button>Light</Button>
              </Card>
            </div>
          </div>
        </>
      );
      const cards = ['page', 'dark', 'light'].map((id) => screen.getByTestId(id).element());
      const surfaces = [
        ...cards,
        screen.getByTestId('pill').element(),
        screen.getByRole('switch').element(),
        ...screen.container.querySelectorAll('button')
      ];

      await expect.element(screen.getByRole('button', { name: 'Light' })).toBeInTheDocument();

      // Before: the acrylic, so the change below is the preference's doing.
      for (const element of surfaces) {
        expect(getComputedStyle(element).backdropFilter).not.toBe('none');
        expect(alpha(getComputedStyle(element).backgroundColor)).toBeLessThan(1);
      }

      try {
        // The dark scheme is the case the second rule in the block exists for:
        // the system-dark theme declares the blur on `:root` at three classes'
        // weight. Reduced motion is asked for as well so the fill lands at once
        // rather than travelling there over the house transition.
        for (const scheme of ['light', 'dark']) {
          await session.send('Emulation.setEmulatedMedia', {
            features: [
              { name: 'prefers-reduced-transparency', value: 'reduce' },
              { name: 'prefers-color-scheme', value: scheme },
              { name: 'prefers-reduced-motion', value: 'reduce' }
            ]
          });

          expect(matchMedia('(prefers-reduced-transparency: reduce)').matches).toBe(true);

          for (const element of surfaces) {
            const style = getComputedStyle(element);

            expect(style.backdropFilter, `${scheme}: ${element.textContent}`).toBe('none');
            expect(alpha(style.backgroundColor), `${scheme}: ${element.textContent}`).toBe(1);
          }

          // Each sheet is laid on its own root's surface, so the dark box and
          // the light box inside it stay two different sheets whatever the
          // page is in.
          const [, dark, light] = cards.map((card) => getComputedStyle(card).backgroundColor);

          expect(dark).not.toBe(light);
        }
      } finally {
        await session.send('Emulation.setEmulatedMedia', { features: [] });
      }

      expect(matchMedia('(prefers-reduced-transparency: reduce)').matches).toBe(false);
    }
  );
});
