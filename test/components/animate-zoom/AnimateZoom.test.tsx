import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateZoom } from 'neba';

describe('AnimateZoom', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateZoom>Landed</AnimateZoom>);

      await expect.element(screen.getByText('Landed')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateZoom data-testid="zoom">Landed</AnimateZoom>);

      expect(screen.getByTestId('zoom').element()).toHaveAttribute('data-neba-animation', 'zoom');
    });
  });

  describe('settings', () => {
    // The difference from Grow is the distance and the fixed origin, so these
    // two are the whole of what makes it a separate component.
    it('starts much smaller than Grow does', async () => {
      const screen = await render(<AnimateZoom data-testid="zoom">Landed</AnimateZoom>);
      const element = screen.getByTestId('zoom').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-scale')).toBe('0.4');
    });

    it('always comes from the middle', async () => {
      const screen = await render(<AnimateZoom data-testid="zoom">Landed</AnimateZoom>);
      const element = screen.getByTestId('zoom').element() as HTMLElement;

      expect(element.style.transformOrigin).toBe('center center');
    });

    it('starts from the scale it was given', async () => {
      const screen = await render(
        <AnimateZoom from={2} data-testid="zoom">
          Landed
        </AnimateZoom>
      );
      const element = screen.getByTestId('zoom').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-scale')).toBe('2');
    });

    it('falls away for mode="out"', async () => {
      const screen = await render(
        <AnimateZoom mode="out" data-testid="zoom">
          Gone
        </AnimateZoom>
      );
      const element = screen.getByTestId('zoom').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });
  });
});
