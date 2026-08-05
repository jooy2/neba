import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateRotate } from 'neba';

describe('AnimateRotate', () => {
  describe('rendering', () => {
    it('renders what it was given', async () => {
      const screen = await render(<AnimateRotate>Turning</AnimateRotate>);

      await expect.element(screen.getByText('Turning')).toBeInTheDocument();
    });

    it('says which effect it is running', async () => {
      const screen = await render(<AnimateRotate data-testid="rotate">Turning</AnimateRotate>);

      expect(screen.getByTestId('rotate').element()).toHaveAttribute(
        'data-neba-animation',
        'rotate'
      );
    });
  });

  describe('angles', () => {
    it('swings half a turn into place by default', async () => {
      const screen = await render(<AnimateRotate data-testid="rotate">Turning</AnimateRotate>);
      const element = screen.getByTestId('rotate').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-angle')).toBe('-180deg');
      expect(element.style.getPropertyValue('--n-anim-angle-to')).toBe('0deg');
    });

    // Two angles rather than one is what lets a single component be both an
    // arrival and an endless spin.
    it('takes both ends of the turn', async () => {
      const screen = await render(
        <AnimateRotate from={0} to={360} repeat="infinite" easing="linear" data-testid="rotate">
          Spinning
        </AnimateRotate>
      );
      const element = screen.getByTestId('rotate').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-angle')).toBe('0deg');
      expect(element.style.getPropertyValue('--n-anim-angle-to')).toBe('360deg');
      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('infinite');
      expect(element.style.getPropertyValue('--n-anim-ease')).toBe('linear');
    });

    it('turns about the point it was told to', async () => {
      const screen = await render(
        <AnimateRotate origin="bottom right" data-testid="rotate">
          Turning
        </AnimateRotate>
      );
      const element = screen.getByTestId('rotate').element() as HTMLElement;

      expect(element.style.transformOrigin).toBe('right bottom');
    });

    it('drops the opacity ramp when fade is off', async () => {
      const screen = await render(
        <AnimateRotate fade={false} data-testid="rotate">
          Spinning
        </AnimateRotate>
      );
      const element = screen.getByTestId('rotate').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-anim-opacity')).toBe('1');
    });
  });
});
