/**
 * The stylesheet's answer to a page with scripting off, and to a reader who has
 * asked for less motion before any script has run, checked against the rules
 * rather than a media emulation the test runner cannot do.
 *
 * A server-rendered `Animate*` waiting for its trigger is in the HTML on its
 * first frame, and only the script would ever let it go. A text effect is in
 * the HTML on its opening frame too: an empty line, noise, or a count's `from`.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateAppear, AnimateCounter, AnimateFade, AnimateScramble, AnimateTyping } from 'neba';
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

/** The style rules inside a media rule whose condition names every one of `features`. */
function rulesUnder(...features: string[]): CSSStyleRule[] {
  return [...(sheet.sheet?.cssRules ?? [])]
    .filter(
      (rule): rule is CSSMediaRule =>
        rule instanceof CSSMediaRule &&
        features.every((feature) => rule.conditionText.includes(feature))
    )
    .flatMap((media) => [...media.cssRules])
    .filter((rule): rule is CSSStyleRule => rule instanceof CSSStyleRule);
}

const noScriptRules = () => rulesUnder('scripting');

/** The value a rule among `rules` gives `property` on `element`, or its pseudo-element. */
function declared(
  rules: CSSStyleRule[],
  element: Element,
  property: string,
  pseudo = ''
): string | undefined {
  return rules
    .filter((rule) => {
      const selectors = rule.selectorText.split(',').map((selector) => selector.trim());

      return selectors.some((selector) =>
        pseudo
          ? selector.endsWith(pseudo) && element.matches(selector.slice(0, -pseudo.length))
          : !selector.includes('::') && element.matches(selector)
      );
    })
    .map((rule) => rule.style.getPropertyValue(property))
    .find((value) => value !== '');
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

// Drawn by the stylesheet, so the final text is there before any script could
// say the reader asked for less motion, and with no script at all. The script
// draws the same thing once it runs, so nothing moves when it does.
describe('the text effects without their motion', () => {
  it('draws the final text in place of what moves, in both cases', async () => {
    const screen = await render(
      <>
        <AnimateTyping text="Typed into place" trigger="manual" data-testid="typing" />
        <AnimateScramble text="RESOLVING" trigger="manual" data-testid="scramble" />
        <AnimateCounter from={1000} value={5} trigger="manual" data-testid="counter" />
      </>
    );
    const rules = rulesUnder('prefers-reduced-motion', 'scripting');
    const typing = screen.getByTestId('typing').element();
    const scramble = screen.getByTestId('scramble').element();
    const counter = screen.getByTestId('counter').element();
    const typed = typing.querySelector('[data-text]')!;
    const final = typing.querySelector('[data-sample]')!;
    const noisy = scramble.querySelector('[data-sample][data-text]')!;
    const count = counter.querySelector('[data-text]')!;
    const [answer, start] = counter.querySelectorAll('[data-sample]');

    expect(rules.length).toBeGreaterThan(0);

    expect(declared(rules, typed, 'display')).toBe('none');
    expect(declared(rules, final, 'visibility')).toBe('visible');

    expect(declared(rules, noisy, 'visibility')).toBe('visible');
    expect(declared(rules, noisy, 'content', '::after')).toBe('none');

    expect(answer).toHaveAttribute('data-sample', '5');
    expect(declared(rules, count, 'display')).toBe('none');
    expect(declared(rules, answer, 'visibility')).toBe('visible');
    expect(declared(rules, start, 'display')).toBe('none');
  });
});
