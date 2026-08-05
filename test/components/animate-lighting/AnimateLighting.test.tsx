import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateLighting } from 'neba';

describe('AnimateLighting', () => {
  describe('rendering', () => {
    it('renders what it lights', async () => {
      const screen = await render(<AnimateLighting>Processing</AnimateLighting>);

      await expect.element(screen.getByText('Processing')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(
        <AnimateLighting data-testid="lighting">Processing</AnimateLighting>
      );

      expect(screen.getByTestId('lighting').element()).toHaveAttribute(
        'data-neba-animation',
        'lighting'
      );
    });

    it('carries the class the stylesheet hangs the light off', async () => {
      const screen = await render(
        <AnimateLighting data-testid="lighting">Processing</AnimateLighting>
      );

      expect(screen.getByTestId('lighting').element()).toHaveClass('neba-anim-lighting');
    });

    it('renders something other than a div when told', async () => {
      const screen = await render(
        <AnimateLighting render={<section />} data-testid="lighting">
          Processing
        </AnimateLighting>
      );

      expect(screen.getByTestId('lighting').element().tagName).toBe('SECTION');
    });
  });

  describe('the light', () => {
    it('is drawn in the colour family it was given', async () => {
      const screen = await render(
        <AnimateLighting color="success" data-testid="lighting">
          Processing
        </AnimateLighting>
      );
      const element = screen.getByTestId('lighting').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-glow')).toBe('var(--neba-success-accent)');
    });

    it('takes a raw colour over the family', async () => {
      const screen = await render(
        <AnimateLighting color="success" glow="#ff00ff" data-testid="lighting">
          Processing
        </AnimateLighting>
      );
      const element = screen.getByTestId('lighting').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-glow')).toBe('#ff00ff');
    });

    it('takes its shape from the arc, the spread and the blur', async () => {
      const screen = await render(
        <AnimateLighting arc={120} spread={8} blur={0} data-testid="lighting">
          Processing
        </AnimateLighting>
      );
      const element = screen.getByTestId('lighting').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-glow-arc')).toBe('120deg');
      expect(element.style.getPropertyValue('--n-anim-glow-width')).toBe('8px');
      expect(element.style.getPropertyValue('--n-anim-glow-blur')).toBe('0px');
    });

    it('travels forever unless told otherwise', async () => {
      const screen = await render(
        <AnimateLighting data-testid="lighting">Processing</AnimateLighting>
      );
      const element = screen.getByTestId('lighting').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('infinite');
    });

    it('runs the other way round when reversed', async () => {
      const screen = await render(
        <AnimateLighting reverse data-testid="lighting">
          Processing
        </AnimateLighting>
      );
      const element = screen.getByTestId('lighting').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });
  });
});
