/**
 * The stylesheet's answer to a page with scripting off, checked against the
 * rules rather than a media emulation the test runner cannot do.
 *
 * A server-rendered `Animate*` waiting for its trigger is in the HTML on its
 * first frame, and only the script would ever let it go.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateAppear, AnimateFade } from 'neba';
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

/** The style rules inside `@media (scripting: none)`. */
function noScriptRules(): CSSStyleRule[] {
  return [...(sheet.sheet?.cssRules ?? [])]
    .filter(
      (rule): rule is CSSMediaRule =>
        rule instanceof CSSMediaRule && rule.conditionText.includes('scripting')
    )
    .flatMap((media) => [...media.cssRules])
    .filter((rule): rule is CSSStyleRule => rule instanceof CSSStyleRule);
}

describe('scripting off', () => {
  it('draws an effect waiting for its trigger as it ends', async () => {
    const screen = await render(
      <>
        <AnimateFade trigger="manual" data-testid="fade">
          Arriving
        </AnimateFade>
        <AnimateAppear trigger="manual" data-testid="appear">
          <p>First</p>
          <p>Second</p>
        </AnimateAppear>
      </>
    );
    const rules = noScriptRules();
    const stopped = (element: Element) =>
      rules.some(
        (rule) => element.matches(rule.selectorText) && rule.style.animationName === 'none'
      );

    expect(rules.length).toBeGreaterThan(0);
    expect(stopped(screen.getByTestId('fade').element())).toBe(true);
    // A staggered effect is on the children rather than on the root.
    expect(stopped(screen.getByText('First').element())).toBe(true);
  });

  it('leaves an effect that runs on mount alone', async () => {
    const screen = await render(<AnimateFade data-testid="fade">Arriving</AnimateFade>);
    const fade = screen.getByTestId('fade').element();

    expect(noScriptRules().some((rule) => fade.matches(rule.selectorText))).toBe(false);
  });
});
