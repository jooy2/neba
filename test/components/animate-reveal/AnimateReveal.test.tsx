import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateReveal } from 'neba';

describe('AnimateReveal', () => {
  it('renders what it was given and says which effect it is', async () => {
    const screen = await render(<AnimateReveal data-testid="r">Uncovered</AnimateReveal>);

    await expect.element(screen.getByText('Uncovered')).toBeInTheDocument();
    expect(screen.getByTestId('r').element()).toHaveAttribute('data-neba-animation', 'reveal');
    expect(screen.getByTestId('r').element()).toHaveClass('neba-anim-reveal');
  });

  // The clip is what the effect *is*: the box never moves and never changes
  // size, so an inset is the only thing to animate.
  it.each([
    ['left', 'inset(0 100% 0 0)'],
    ['right', 'inset(0 0 0 100%)'],
    ['top', 'inset(0 0 100% 0)'],
    ['bottom', 'inset(100% 0 0 0)']
  ] as const)('wipes from the %s', async (side, clip) => {
    const screen = await render(
      <AnimateReveal side={side} data-testid="r">
        Uncovered
      </AnimateReveal>
    );

    expect(
      (screen.getByTestId('r').element() as HTMLElement).style.getPropertyValue('--n-anim-clip')
    ).toBe(clip);
  });

  // A reveal is not a fade, so the opacity slot rests at 1 rather than 0.
  it('does not fade unless it is asked to', async () => {
    const plain = await render(<AnimateReveal data-testid="r">A</AnimateReveal>);

    expect(
      (plain.getByTestId('r').element() as HTMLElement).style.getPropertyValue('--n-anim-opacity')
    ).toBe('1');

    const fading = await render(
      <AnimateReveal from={0} data-testid="f">
        A
      </AnimateReveal>
    );

    expect(
      (fading.getByTestId('f').element() as HTMLElement).style.getPropertyValue('--n-anim-opacity')
    ).toBe('0');
  });

  it('runs backwards to cover it up again', async () => {
    const screen = await render(
      <AnimateReveal mode="out" data-testid="r">
        A
      </AnimateReveal>
    );

    expect(
      (screen.getByTestId('r').element() as HTMLElement).style.getPropertyValue(
        '--n-anim-direction'
      )
    ).toBe('reverse');
  });
});
