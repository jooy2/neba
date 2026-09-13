/**
 * The iOS rule that keeps a tapped field from zooming the page.
 *
 * No browser the suite runs in is iOS Safari, so the condition is checked
 * through the CSSOM: that the rule exists behind the WebKit-on-iOS guard and
 * matches the element every text field puts its hook on.
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

describe('text inputs on iOS', () => {
  it('raise a field to 16px only where -webkit-touch-callout is supported', () => {
    const guarded = [...(sheet.sheet?.cssRules ?? [])]
      .filter(
        (rule): rule is CSSSupportsRule =>
          rule instanceof CSSSupportsRule && rule.conditionText.includes('-webkit-touch-callout')
      )
      .flatMap((rule) => [...rule.cssRules])
      .filter((rule): rule is CSSStyleRule => rule instanceof CSSStyleRule);

    const input = document.createElement('input');
    input.className = 'neba-input';
    document.body.append(input);

    try {
      const rule = guarded.find((each) => input.matches(each.selectorText));

      expect(rule?.style.getPropertyValue('font-size')).toBe('max(1em, 16px)');
    } finally {
      input.remove();
    }
  });
});
