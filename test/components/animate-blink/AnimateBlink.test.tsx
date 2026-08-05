import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateBlink } from 'neba';

describe('AnimateBlink', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateBlink>Live</AnimateBlink>);

      await expect.element(screen.getByText('Live')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateBlink data-testid="blink">Live</AnimateBlink>);

      expect(screen.getByTestId('blink').element()).toHaveAttribute('data-neba-animation', 'blink');
    });
  });

  describe('settings', () => {
    // A single blink is a flicker, which nobody asks for.
    it('repeats forever unless told otherwise', async () => {
      const screen = await render(<AnimateBlink data-testid="blink">Live</AnimateBlink>);
      const element = screen.getByTestId('blink').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('infinite');
    });

    it('counts the cycles when given a number', async () => {
      const screen = await render(
        <AnimateBlink repeat={3} data-testid="blink">
          Live
        </AnimateBlink>
      );
      const element = screen.getByTestId('blink').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('3');
    });

    it('dips to the floor it was given rather than to nothing', async () => {
      const screen = await render(
        <AnimateBlink min={0.45} data-testid="blink">
          Live
        </AnimateBlink>
      );
      const element = screen.getByTestId('blink').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-opacity')).toBe('0.45');
    });

    it('can be held still', async () => {
      const screen = await render(
        <AnimateBlink paused data-testid="blink">
          Live
        </AnimateBlink>
      );
      const element = screen.getByTestId('blink').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-state')).toBe('paused');
    });
  });
});
