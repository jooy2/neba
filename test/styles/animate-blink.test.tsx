/**
 * A held blink, checked against the stylesheet. No component test loads CSS, and
 * what rests a paused blink at full opacity is a rule in it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateBlink } from 'neba';
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

describe('AnimateBlink under the stylesheet', () => {
  // Paused, the animation held its place in the cycle, so `paused={!recording}`
  // left a recording light half drawn or, at a floor of zero, invisible.
  it('rests a held blink at full opacity', async () => {
    const screen = await render(
      <AnimateBlink paused min={0} data-testid="blink">
        Recording
      </AnimateBlink>
    );
    const element = screen.getByTestId('blink').element();

    expect(getComputedStyle(element).animationName).toBe('none');
    expect(getComputedStyle(element).opacity).toBe('1');
  });

  it('blinks while it is not held', async () => {
    const screen = await render(<AnimateBlink data-testid="blink">Recording</AnimateBlink>);

    expect(getComputedStyle(screen.getByTestId('blink').element()).animationName).toBe(
      'neba-anim-blink'
    );
  });
});
