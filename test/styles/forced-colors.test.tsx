/**
 * The forced-colours block, checked against the rules and the parts they reach.
 *
 * No runner here puts a browser in a forced palette, so this asserts what can
 * be seen from outside it: that the rules exist behind the media query, and
 * that the parts they name carry the hooks the rules select on — a hook a
 * component stopped writing would leave a rule that never matches anything.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, ProgressLinear, Slider, Switch } from 'neba';
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

function forcedRules(): CSSStyleRule[] {
  return [...(sheet.sheet?.cssRules ?? [])]
    .filter(
      (rule): rule is CSSMediaRule =>
        rule instanceof CSSMediaRule && rule.conditionText.includes('forced-colors')
    )
    .flatMap((media) => [...media.cssRules])
    .filter((rule): rule is CSSStyleRule => rule instanceof CSSStyleRule);
}

describe('forced colours', () => {
  it('gives every part that says something by colour or shadow a rule of its own', async () => {
    const rules = forcedRules();
    const screen = await render(
      <>
        <Button>Save</Button>
        <Switch aria-label="Wi-Fi" defaultChecked />
        <ProgressLinear aria-label="Upload" value={40} />
        <Slider aria-label="Volume" defaultValue={40} />
      </>
    );
    const root = screen.container;

    const parts = [
      root.querySelector('button'),
      root.querySelector('[role="switch"]'),
      root.querySelector('[role="switch"] > *'),
      root.querySelector('.neba-progress-indicator'),
      root.querySelector('.neba-progress-track'),
      root.querySelector('.neba-slider-indicator'),
      root.querySelector('.neba-slider-rail'),
      root.querySelector('.neba-slider-thumb')
    ];

    for (const part of parts) {
      expect(part, 'a part the block names').not.toBeNull();
      expect(
        rules.some((rule) => part!.matches(rule.selectorText)),
        part!.outerHTML.slice(0, 80)
      ).toBe(true);
    }
  });
});
