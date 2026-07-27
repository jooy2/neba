import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { IconButton } from 'neba';

function Glyph() {
  return <svg viewBox="0 0 16 16" />;
}

describe('IconButton', () => {
  describe('rendering', () => {
    it('takes its accessible name from label', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add item" />);

      await expect.element(screen.getByRole('button', { name: 'Add item' })).toBeInTheDocument();
    });

    it('renders a native button holding the glyph', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add item" />);
      const element = screen.getByRole('button').element();

      expect(element.tagName).toBe('BUTTON');
      expect(element.querySelector('svg')).not.toBeNull();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add item" />);

      await screen.rerender(<IconButton icon={<Glyph />} label="Remove item" />);

      await expect.element(screen.getByRole('button', { name: 'Remove item' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Add item' }).query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <IconButton icon={<Glyph />} label="Add item" className="my-own-class" />
      );

      expect(screen.getByRole('button').element()).toHaveClass('my-own-class');
    });
  });

  describe('shape', () => {
    it('is round, and stays round whatever radius the size ladder would give it', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add item" size="xl" />);
      const element = screen.getByRole('button').element() as HTMLElement;

      // Inline rather than a utility on purpose: it has to beat the `rounded-*`
      // class Button writes, and class order is not something to depend on.
      expect(element.style.borderRadius).toBe('9999px');
    });

    it('lets a caller override the radius through style', async () => {
      const screen = await render(
        <IconButton icon={<Glyph />} label="Add item" style={{ borderRadius: '4px' }} />
      );

      expect((screen.getByRole('button').element() as HTMLElement).style.borderRadius).toBe('4px');
    });

    it('takes the square footprint of an icon-only control', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add item" size="md" />);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('h-8');
      expect(element).toHaveClass('w-8');
      expect(element).toHaveClass('px-0');
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots Button reads from', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Delete" color="danger" />);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('changes size without changing density, and vice versa', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add" size="lg" />);
      const element = screen.getByRole('button').element();

      expect(element).toHaveClass('h-10');

      await screen.rerender(
        <IconButton icon={<Glyph />} label="Add" size="lg" density="compact" />
      );

      expect(element).toHaveClass('h-10');
    });
  });

  describe('states', () => {
    it('fires onClick when idle', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <IconButton icon={<Glyph />} label="Add item" onClick={onClick} />
      );

      await screen.getByRole('button').click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('does not fire onClick when disabled', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <IconButton icon={<Glyph />} label="Add item" disabled onClick={onClick} />
      );

      expect(screen.getByRole('button').element()).toBeDisabled();

      await screen.getByRole('button').click({ force: true });

      expect(onClick).not.toHaveBeenCalled();
    });

    it('swaps the glyph for a spinner while loading', async () => {
      const screen = await render(<IconButton icon={<Glyph />} label="Add item" loading />);
      const element = screen.getByRole('button').element();

      expect(element).toHaveAttribute('aria-busy', 'true');
      expect(element.querySelector('.animate-spin')).not.toBeNull();
    });
  });
});
