import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ProgressCircular } from 'neba';

describe('ProgressCircular', () => {
  describe('rendering', () => {
    it('renders a progress bar', async () => {
      const screen = await render(<ProgressCircular value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('is named by its label', async () => {
      const screen = await render(<ProgressCircular value={40} label="Saving" />);

      await expect.element(screen.getByRole('progressbar', { name: 'Saving' })).toBeInTheDocument();
    });

    it('hides the drawing from a screen reader, which reads the role instead', async () => {
      const screen = await render(<ProgressCircular value={40} />);
      const svg = screen.getByRole('progressbar').element().querySelector('svg');

      expect(svg).toHaveAttribute('aria-hidden', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<ProgressCircular value={10} showValue />);

      await expect.element(screen.getByText('10%')).toBeInTheDocument();

      await screen.rerender(<ProgressCircular value={90} showValue />);

      await expect.element(screen.getByText('90%')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<ProgressCircular value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });
  });

  describe('the arc', () => {
    // The ring is one circle with a dash pattern on it, so the only thing that
    // distinguishes 0% from 100% is the offset. Getting the direction backwards
    // is the classic bug here, and it looks plausible either way.
    it('closes the gap as the value climbs', async () => {
      const screen = await render(<ProgressCircular value={0} />);
      const arc = () =>
        screen.getByRole('progressbar').element().querySelectorAll('circle')[1] as SVGCircleElement;

      const empty = Number(arc().getAttribute('stroke-dashoffset'));

      await screen.rerender(<ProgressCircular value={100} />);
      const full = Number(arc().getAttribute('stroke-dashoffset'));

      expect(empty).toBeGreaterThan(0);
      expect(full).toBe(0);
    });

    it('starts at the top of the ring rather than at three o’clock', async () => {
      const screen = await render(<ProgressCircular value={50} />);
      const arc = screen.getByRole('progressbar').element().querySelectorAll('circle')[1];

      expect(arc.getAttribute('transform')).toContain('rotate(-90');
    });

    it('grows with size', async () => {
      const screen = await render(<ProgressCircular value={40} size="xs" />);
      const small = screen.getByRole('progressbar').element().querySelector('svg');

      expect(small).toHaveAttribute('width', '14');

      await screen.rerender(<ProgressCircular value={40} size="xl" />);

      expect(screen.getByRole('progressbar').element().querySelector('svg')).toHaveAttribute(
        'width',
        '32'
      );
    });
  });

  describe('indeterminate', () => {
    it('is indeterminate by default', async () => {
      const screen = await render(<ProgressCircular />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('turns instead of filling', async () => {
      const screen = await render(<ProgressCircular />);

      expect(
        screen.getByRole('progressbar').element().querySelector('.neba-ring-spin')
      ).not.toBeNull();
    });

    it('stops turning once it is given a value', async () => {
      const screen = await render(<ProgressCircular />);

      await screen.rerender(<ProgressCircular value={40} />);

      expect(screen.getByRole('progressbar').element().querySelector('.neba-ring-spin')).toBeNull();
    });
  });

  describe('style props', () => {
    it('maps colour onto the token slots', async () => {
      const screen = await render(<ProgressCircular value={40} color="danger" />);
      const element = screen.getByRole('progressbar').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
    });
  });
});
