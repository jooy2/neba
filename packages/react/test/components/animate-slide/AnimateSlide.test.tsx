import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateSlide } from 'neba';

describe('AnimateSlide', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateSlide>Sliding</AnimateSlide>);

      await expect.element(screen.getByText('Sliding')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateSlide data-testid="slide">Sliding</AnimateSlide>);

      expect(screen.getByTestId('slide').element()).toHaveAttribute('data-neba-animation', 'slide');
    });
  });

  describe('direction', () => {
    it('comes up from below by default', async () => {
      const screen = await render(<AnimateSlide data-testid="slide">Sliding</AnimateSlide>);
      const element = screen.getByTestId('slide').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-x')).toBe('0px');
      expect(element.style.getPropertyValue('--n-anim-y')).toBe('100%');
    });

    it('comes down from above for from="top"', async () => {
      const screen = await render(
        <AnimateSlide from="top" data-testid="slide">
          Sliding
        </AnimateSlide>
      );
      const element = screen.getByTestId('slide').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-y')).toBe('calc(-1 * 100%)');
    });

    it('comes in from the left for from="left"', async () => {
      const screen = await render(
        <AnimateSlide from="left" distance={40} data-testid="slide">
          Sliding
        </AnimateSlide>
      );
      const element = screen.getByTestId('slide').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-x')).toBe('-40px');
      expect(element.style.getPropertyValue('--n-anim-y')).toBe('0px');
    });

    it('takes a number as pixels', async () => {
      const screen = await render(
        <AnimateSlide distance={24} data-testid="slide">
          Sliding
        </AnimateSlide>
      );
      const element = screen.getByTestId('slide').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-y')).toBe('24px');
    });

    it('takes a string as a CSS length', async () => {
      const screen = await render(
        <AnimateSlide distance="3rem" data-testid="slide">
          Sliding
        </AnimateSlide>
      );
      const element = screen.getByTestId('slide').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-y')).toBe('3rem');
    });

    it('leaves by the same edge for mode="out"', async () => {
      const screen = await render(
        <AnimateSlide mode="out" data-testid="slide">
          Leaving
        </AnimateSlide>
      );
      const element = screen.getByTestId('slide').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });
  });
});
