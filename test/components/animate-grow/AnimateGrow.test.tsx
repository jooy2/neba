import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateGrow } from 'neba';

describe('AnimateGrow', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateGrow>Unfolding</AnimateGrow>);

      await expect.element(screen.getByText('Unfolding')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateGrow data-testid="grow">Unfolding</AnimateGrow>);

      expect(screen.getByTestId('grow').element()).toHaveAttribute('data-neba-animation', 'grow');
    });

    it('renders something other than a div when told', async () => {
      const screen = await render(
        <AnimateGrow render={<li />} data-testid="grow">
          Unfolding
        </AnimateGrow>
      );

      expect(screen.getByTestId('grow').element().tagName).toBe('LI');
    });
  });

  describe('settings', () => {
    it('starts a little under full size by default', async () => {
      const screen = await render(<AnimateGrow data-testid="grow">Unfolding</AnimateGrow>);
      const element = screen.getByTestId('grow').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-scale')).toBe('0.8');
    });

    it('starts from the scale it was given', async () => {
      const screen = await render(
        <AnimateGrow from={1.4} data-testid="grow">
          Settling
        </AnimateGrow>
      );
      const element = screen.getByTestId('grow').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-scale')).toBe('1.4');
    });

    it('unfolds about the point it was told to', async () => {
      const screen = await render(
        <AnimateGrow origin="top left" data-testid="grow">
          Unfolding
        </AnimateGrow>
      );
      const element = screen.getByTestId('grow').element() as HTMLElement;

      expect(element.style.transformOrigin).toBe('left top');
    });

    it('drops the opacity ramp when fade is off', async () => {
      const screen = await render(
        <AnimateGrow fade={false} data-testid="grow">
          Unfolding
        </AnimateGrow>
      );
      const element = screen.getByTestId('grow').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-opacity')).toBe('1');
    });

    it('folds away for mode="out"', async () => {
      const screen = await render(
        <AnimateGrow mode="out" data-testid="grow">
          Folding
        </AnimateGrow>
      );
      const element = screen.getByTestId('grow').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });
  });
});
