/**
 * The reduced-motion override, checked against the rule rather than a media
 * emulation the test runner cannot do.
 *
 * The durations are declared on `:root` and again on every element that forces
 * the light theme, so a nested `.light` box does not inherit the override from
 * `:root` — it redeclares the values the override was meant to replace. The
 * override has to name each of those roots itself.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
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

/** The rules inside `@media (prefers-reduced-motion: reduce)` that zero a duration. */
function reducedMotionRules(): CSSStyleRule[] {
  const rules = [...(sheet.sheet?.cssRules ?? [])];

  return rules
    .filter(
      (rule): rule is CSSMediaRule =>
        rule instanceof CSSMediaRule && rule.conditionText.includes('prefers-reduced-motion')
    )
    .flatMap((media) => [...media.cssRules])
    .filter(
      (rule): rule is CSSStyleRule =>
        rule instanceof CSSStyleRule && rule.style.getPropertyValue('--neba-duration') !== ''
    );
}

describe('prefers-reduced-motion', () => {
  it('reaches every root the durations are declared on', () => {
    const rules = reducedMotionRules();
    const light = document.createElement('div');
    const themed = document.createElement('div');

    light.className = 'light';
    themed.setAttribute('data-theme', 'light');
    document.body.append(light, themed);

    try {
      expect(rules.length).toBeGreaterThan(0);

      for (const element of [document.documentElement, light, themed]) {
        expect(rules.some((rule) => element.matches(rule.selectorText))).toBe(true);
      }
    } finally {
      light.remove();
      themed.remove();
    }
  });

  // The case the redeclaration exists for: a light box inside a dark one, which
  // is a preview of the other theme on a page that is already in one.
  it('reaches a light root nested inside a dark one', () => {
    const rules = reducedMotionRules();
    const dark = document.createElement('div');
    const light = document.createElement('div');

    dark.className = 'dark';
    light.className = 'light';
    dark.append(light);
    document.body.append(dark);

    try {
      expect(rules.some((rule) => light.matches(rule.selectorText))).toBe(true);
    } finally {
      dark.remove();
    }
  });
});
