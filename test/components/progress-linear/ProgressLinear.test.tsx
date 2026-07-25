import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ProgressLinear } from 'neba';

describe('ProgressLinear', () => {
  describe('rendering', () => {
    it('renders a progress bar', async () => {
      const screen = await render(<ProgressLinear value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('reports the value and the range', async () => {
      const screen = await render(<ProgressLinear value={3} min={0} max={4} />);
      const element = screen.getByRole('progressbar');

      await expect.element(element).toHaveAttribute('aria-valuenow', '3');
      await expect.element(element).toHaveAttribute('aria-valuemin', '0');
      await expect.element(element).toHaveAttribute('aria-valuemax', '4');
    });

    it('is named by its label', async () => {
      const screen = await render(<ProgressLinear value={40} label="Uploading" />);

      await expect
        .element(screen.getByRole('progressbar', { name: 'Uploading' }))
        .toBeInTheDocument();
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<ProgressLinear value={10} showValue />);

      await expect.element(screen.getByText('10%')).toBeInTheDocument();

      await screen.rerender(<ProgressLinear value={90} showValue />);

      await expect.element(screen.getByText('90%')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<ProgressLinear value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });
  });

  describe('the value', () => {
    it('shows a percentage of the range, not of 100', async () => {
      const screen = await render(<ProgressLinear value={3} min={0} max={4} showValue />);

      await expect.element(screen.getByText('75%')).toBeInTheDocument();
    });

    it('says the same thing to a screen reader as it does on screen', async () => {
      const screen = await render(<ProgressLinear value={3} min={0} max={4} showValue />);

      await expect
        .element(screen.getByRole('progressbar'))
        .toHaveAttribute('aria-valuetext', '75%');
    });

    it('uses the caller-supplied format when there is one', async () => {
      const screen = await render(
        <ProgressLinear value={1200} max={4000} showValue format={{ useGrouping: false }} />
      );

      await expect.element(screen.getByText('1200')).toBeInTheDocument();
      expect(screen.getByText('30%').query()).toBeNull();
    });

    it('hides the value until it is asked for', async () => {
      const screen = await render(<ProgressLinear value={40} />);

      expect(screen.getByText('40%').query()).toBeNull();
    });
  });

  describe('indeterminate', () => {
    it('is indeterminate by default', async () => {
      const screen = await render(<ProgressLinear />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('sweeps instead of filling', async () => {
      const screen = await render(<ProgressLinear />);

      expect(screen.getByRole('progressbar').element().querySelector('.neba-sweep')).not.toBeNull();
    });

    it('stops sweeping once it is given a value', async () => {
      const screen = await render(<ProgressLinear />);

      await screen.rerender(<ProgressLinear value={40} />);

      expect(screen.getByRole('progressbar').element().querySelector('.neba-sweep')).toBeNull();
    });

    it('clamps a value that ran past its own maximum', async () => {
      const screen = await render(<ProgressLinear value={140} showValue />);

      await expect.element(screen.getByText('100%')).toBeInTheDocument();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(<ProgressLinear value={40} color="success" />);
      const element = screen.getByRole('progressbar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
    });

    it('thickens with size', async () => {
      const screen = await render(<ProgressLinear value={40} size="xl" />);

      expect(screen.getByRole('progressbar').element().querySelector('.h-2')).not.toBeNull();
    });

    it('never applies a transform', async () => {
      const screen = await render(<ProgressLinear label="Uploading" showValue />);

      expect(screen.getByRole('progressbar').element().outerHTML).not.toContain('translate');
    });
  });
});
