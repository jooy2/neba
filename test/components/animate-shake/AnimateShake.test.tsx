import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateShake } from 'neba';

describe('AnimateShake', () => {
  it('renders what it was given and says which effect it is', async () => {
    const screen = await render(<AnimateShake data-testid="s">Wrong</AnimateShake>);

    await expect.element(screen.getByText('Wrong')).toBeInTheDocument();
    expect(screen.getByTestId('s').element()).toHaveAttribute('data-neba-animation', 'shake');
  });

  /*
   * A shake is an answer to something the reader just did, so it waits to be
   * played rather than running on mount. Decoration that moves is what a reader
   * learns to ignore.
   */
  it('waits to be played rather than running on mount', async () => {
    const screen = await render(<AnimateShake data-testid="s">Wrong</AnimateShake>);

    expect(screen.getByTestId('s').element()).toHaveAttribute('data-state', 'paused');
  });

  it('runs when it is played', async () => {
    const screen = await render(
      <AnimateShake play data-testid="s">
        Wrong
      </AnimateShake>
    );

    expect(screen.getByTestId('s').element()).toHaveAttribute('data-state', 'running');
  });

  it('travels as far as it was told', async () => {
    const screen = await render(
      <AnimateShake distance="1rem" data-testid="s">
        Wrong
      </AnimateShake>
    );

    expect(
      (screen.getByTestId('s').element() as HTMLElement).style.getPropertyValue('--n-anim-x')
    ).toBe('1rem');
  });
});
