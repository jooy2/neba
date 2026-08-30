import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Meter } from 'neba';

describe('Meter', () => {
  describe('rendering', () => {
    it('renders a meter carrying its value and range', async () => {
      const screen = await render(<Meter value={40} label="Storage" />);
      const meter = screen.getByRole('meter', { name: 'Storage' });

      await expect.element(meter).toBeInTheDocument();
      await expect.element(meter).toHaveAttribute('aria-valuenow', '40');
      await expect.element(meter).toHaveAttribute('aria-valuemin', '0');
      await expect.element(meter).toHaveAttribute('aria-valuemax', '100');
    });

    it('takes a range of its own', async () => {
      const screen = await render(<Meter value={3} min={0} max={4} label="Seats" />);
      const meter = screen.getByRole('meter');

      await expect.element(meter).toHaveAttribute('aria-valuemax', '4');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Meter value={10} className="my-own-class" />);

      expect(screen.getByRole('meter').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<Meter value={10} label="Storage" />);

      await screen.rerender(<Meter value={90} label="Storage" />);

      await expect.element(screen.getByRole('meter')).toHaveAttribute('aria-valuenow', '90');
    });
  });

  describe('value text', () => {
    it('does not draw the value unless asked', async () => {
      const screen = await render(<Meter value={40} label="Storage" />);

      expect(screen.getByText('40%').query()).toBeNull();
    });

    it('writes the value as a share of the range', async () => {
      const screen = await render(<Meter value={2} min={0} max={8} showValue />);

      await expect.element(screen.getByText('25%')).toBeInTheDocument();
    });

    it('writes the value through format when it is given one', async () => {
      const screen = await render(
        <Meter
          value={12}
          max={20}
          showValue
          format={{ style: 'unit', unit: 'gigabyte', unitDisplay: 'narrow' }}
        />
      );

      await expect.element(screen.getByText(/12/)).toBeInTheDocument();
      expect(screen.getByText('60%').query()).toBeNull();
    });
  });

  describe('thresholds', () => {
    const thresholds = [
      { from: 70, color: 'warning' },
      { from: 90, color: 'danger' }
    ] as const;

    it('keeps its own colour below every threshold', async () => {
      const screen = await render(<Meter value={40} thresholds={thresholds} />);
      const element = screen.getByRole('meter').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
    });

    it('takes the family of the last threshold it has reached', async () => {
      const screen = await render(<Meter value={75} thresholds={thresholds} />);
      const element = screen.getByRole('meter').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-warning-fill)');
    });

    it('moves on to the next family as the value climbs', async () => {
      const screen = await render(<Meter value={75} thresholds={thresholds} />);

      await screen.rerender(<Meter value={95} thresholds={thresholds} />);

      const element = screen.getByRole('meter').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('maps color onto the slots when there are no thresholds', async () => {
      const screen = await render(<Meter value={40} color="success" />);
      const element = screen.getByRole('meter').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
    });
  });
});
