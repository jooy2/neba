/**
 * An effect inside another, checked against the stylesheet. The `--n-anim-*`
 * slots are custom properties and inherit, and what keeps one effect from
 * taking another's settings is CSS that no component test loads.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateFade, AnimateReveal, Box } from 'neba';
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

describe('a transition inside an Animate*', () => {
  // It inherited the wrapper's paused state, so an entrance inside a wrapper
  // waiting for its trigger did not run until the wrapper did.
  it('runs on mount whatever the wrapper around it is waiting for', async () => {
    const screen = await render(
      <AnimateFade trigger="manual">
        <Box transition="fade" data-testid="inner">
          Saved
        </Box>
      </AnimateFade>
    );

    expect(getComputedStyle(screen.getByTestId('inner').element()).animationPlayState).toBe(
      'running'
    );
  });

  // It inherited the reveal's opacity, so its fade ran from full to full.
  it('starts from its own first frame rather than from the wrapper', async () => {
    const screen = await render(
      <AnimateReveal>
        <Box transition="fade" data-testid="inner">
          Saved
        </Box>
      </AnimateReveal>
    );

    expect(
      getComputedStyle(screen.getByTestId('inner').element()).getPropertyValue('--n-anim-opacity')
    ).toBe('');
  });
});
