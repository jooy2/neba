/**
 * An `AnimateMarquee` under the stylesheet, which is where its motion is.
 *
 * Its duration is measured after the first render, and changes whenever the
 * strip does, and a running animation whose duration changes reads its place
 * off the new one. No component test loads the stylesheet, so none of them has
 * an animation to look at.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateMarquee } from 'neba';
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

/** How far through its current pass the first track's animation is, from 0 to 1. */
function progress(root: Element): number {
  const [animation] = root.querySelector('.neba-marquee-track')!.getAnimations();
  const timing = animation.effect!.getComputedTiming();

  return Number(timing.progress);
}

describe('AnimateMarquee under the stylesheet', () => {
  // The strip jumped once after hydration, when the measured duration replaced
  // the one a server guesses, and again on every resize.
  it('stays where it was when its duration changes', async () => {
    const strip = (duration: number) => (
      <AnimateMarquee duration={duration} pauseOnHover={false} data-testid="strip">
        <span>Alpha</span>
        <span>Beta</span>
      </AnimateMarquee>
    );
    const screen = await render(strip(8000));
    const root = screen.getByTestId('strip').element();

    await new Promise((resolve) => setTimeout(resolve, 1000));

    const before = progress(root);

    await screen.rerender(strip(2000));

    expect(before).toBeGreaterThan(0.05);
    expect(Math.abs(progress(root) - before)).toBeLessThan(0.03);
  });
});
