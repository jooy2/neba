import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateFade } from 'neba';

describe('AnimateFade', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateFade>Arriving</AnimateFade>);

      await expect.element(screen.getByText('Arriving')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateFade data-testid="fade">Arriving</AnimateFade>);

      expect(screen.getByTestId('fade').element()).toHaveAttribute('data-neba-animation', 'fade');
    });

    it('renders something other than a div when told', async () => {
      const screen = await render(
        <AnimateFade render={<section />} data-testid="fade">
          Arriving
        </AnimateFade>
      );

      expect(screen.getByTestId('fade').element().tagName).toBe('SECTION');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <AnimateFade className="my-own-class" data-testid="fade">
          Arriving
        </AnimateFade>
      );

      expect(screen.getByTestId('fade').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('fade').element()).toHaveClass('neba-anim');
    });
  });

  describe('settings', () => {
    it('writes the timings into the slots the stylesheet reads', async () => {
      const screen = await render(
        <AnimateFade duration={800} delay={120} repeat={3} data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-duration')).toBe('800ms');
      expect(element.style.getPropertyValue('--n-anim-delay')).toBe('120ms');
      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('3');
    });

    it('writes an endless repeat as the word CSS uses', async () => {
      const screen = await render(
        <AnimateFade repeat="infinite" data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('infinite');
    });

    it('starts from the opacity it was given', async () => {
      const screen = await render(
        <AnimateFade from={0.3} data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-opacity')).toBe('0.3');
    });

    it('runs the same animation backwards for mode="out"', async () => {
      const screen = await render(
        <AnimateFade mode="out" data-testid="fade">
          Leaving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('reverse');
    });

    it('combines alternate with the direction rather than replacing it', async () => {
      const screen = await render(
        <AnimateFade mode="out" alternate data-testid="fade">
          Leaving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-direction')).toBe('alternate-reverse');
    });
  });

  describe('triggers', () => {
    it('runs on mount by default', async () => {
      const screen = await render(<AnimateFade data-testid="fade">Arriving</AnimateFade>);

      expect(screen.getByTestId('fade').element()).toHaveAttribute('data-state', 'running');
    });

    it('waits to be told when the trigger is manual', async () => {
      const screen = await render(
        <AnimateFade trigger="manual" data-testid="fade">
          Arriving
        </AnimateFade>
      );

      await expect.element(screen.getByTestId('fade')).toHaveAttribute('data-state', 'paused');

      await screen.rerender(
        <AnimateFade trigger="manual" play data-testid="fade">
          Arriving
        </AnimateFade>
      );

      await expect.element(screen.getByTestId('fade')).toHaveAttribute('data-state', 'running');
    });

    it('holds where it is when paused', async () => {
      const screen = await render(
        <AnimateFade paused data-testid="fade">
          Arriving
        </AnimateFade>
      );
      const element = screen.getByTestId('fade').element() as HTMLElement;

      expect(element).toHaveAttribute('data-state', 'paused');
      expect(element.style.getPropertyValue('--n-anim-state')).toBe('paused');
    });
  });
});
