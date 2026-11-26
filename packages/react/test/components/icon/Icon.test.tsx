import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Icon } from 'neba';

/** A stand-in for whatever an icon set hands back: an svg with its own size. */
function Glyph() {
  return (
    <svg viewBox="0 0 16 16" width="16" height="16" data-testid="glyph">
      <circle cx="8" cy="8" r="6" />
    </svg>
  );
}

describe('Icon', () => {
  describe('rendering', () => {
    it('renders the glyph passed as a prop rather than as children', async () => {
      const screen = await render(<Icon icon={<Glyph />} label="Status" />);

      expect(
        screen.getByRole('img', { name: 'Status' }).element().querySelector('svg')
      ).not.toBeNull();
    });

    it('reflects a changed glyph on re-render', async () => {
      const screen = await render(<Icon icon={<span>before</span>} label="Status" />);
      const element = screen.getByRole('img', { name: 'Status' }).element();

      expect(element.textContent).toBe('before');

      await screen.rerender(<Icon icon={<span>after</span>} label="Status" />);

      expect(element.textContent).toBe('after');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Icon icon={<Glyph />} label="Status" className="my-own-class" />
      );

      expect(screen.getByRole('img', { name: 'Status' }).element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the underlying span', async () => {
      const screen = await render(<Icon icon={<Glyph />} label="Status" data-kind="status" />);

      expect(screen.getByRole('img', { name: 'Status' }).element()).toHaveAttribute(
        'data-kind',
        'status'
      );
    });
  });

  describe('accessibility', () => {
    it('is announced as an image when it carries a label', async () => {
      const screen = await render(<Icon icon={<Glyph />} label="Deployed" />);
      const element = screen.getByRole('img', { name: 'Deployed' }).element();

      expect(element).toHaveAttribute('aria-label', 'Deployed');
      expect(element).not.toHaveAttribute('aria-hidden');
    });

    it('is hidden from the accessibility tree without one', async () => {
      const screen = await render(
        <div data-testid="host">
          <Icon icon={<Glyph />} />
        </div>
      );
      const host = screen.getByTestId('host').element();

      expect(screen.getByRole('img').query()).toBeNull();
      expect(host.firstElementChild).toHaveAttribute('aria-hidden', 'true');
    });
  });

  describe('style props', () => {
    it('sizes the box on its own ladder rather than the control heights', async () => {
      const screen = await render(<Icon icon={<Glyph />} label="Status" size="md" />);
      const element = screen.getByRole('img', { name: 'Status' }).element();

      expect(element).toHaveClass('size-5');

      await screen.rerender(<Icon icon={<Glyph />} label="Status" size="xl" />);

      expect(element).toHaveClass('size-7');
      expect(element).not.toHaveClass('size-5');
    });

    it('inherits its colour by default and takes a family when asked', async () => {
      const screen = await render(<Icon icon={<Glyph />} label="Status" />);
      const element = screen.getByRole('img', { name: 'Status' }).element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('');
      expect(element).not.toHaveClass('text-(--n-accent)');

      await screen.rerender(<Icon icon={<Glyph />} label="Status" color="danger" />);

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
      expect(element).toHaveClass('text-(--n-accent)');
    });
  });

  describe('transition', () => {
    it('takes an entrance animation', async () => {
      const screen = await render(
        <Icon icon={<svg />} label="Refresh" transition={{ type: 'rotate', repeat: 'infinite' }} />
      );
      const element = screen.getByRole('img', { name: 'Refresh' }).element() as HTMLElement;

      expect(element).toHaveClass('neba-anim-rotate');
      expect(element.style.getPropertyValue('--n-anim-repeat')).toBe('infinite');
    });

    it('keeps the colour slot when it also has an animation', async () => {
      const screen = await render(
        <Icon icon={<svg />} label="Refresh" color="danger" transition="fade" />
      );
      const element = screen.getByRole('img', { name: 'Refresh' }).element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-danger-accent)');
      expect(element.style.getPropertyValue('--n-anim-duration')).toBe('320ms');
    });
  });
});
