import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { ButtonGroup, Toggle } from 'neba';

describe('Toggle', () => {
  describe('rendering', () => {
    it('renders a button that reports whether it is pressed', async () => {
      const screen = await render(<Toggle>Bold</Toggle>);

      await expect
        .element(screen.getByRole('button', { name: 'Bold', pressed: false }))
        .toBeInTheDocument();
    });

    it('starts pressed when told to', async () => {
      const screen = await render(<Toggle defaultPressed>Bold</Toggle>);

      await expect
        .element(screen.getByRole('button', { name: 'Bold', pressed: true }))
        .toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Toggle className="my-own-class">Bold</Toggle>);

      expect(screen.getByRole('button').element()).toHaveClass('my-own-class');
    });

    it('renders the icons around the label', async () => {
      const screen = await render(
        <Toggle startIcon={<span>before</span>} endIcon={<span>after</span>}>
          Bold
        </Toggle>
      );

      await expect.element(screen.getByText('before')).toBeInTheDocument();
      await expect.element(screen.getByText('after')).toBeInTheDocument();
    });

    it('goes square when there is no label', async () => {
      const screen = await render(<Toggle aria-label="Bold" startIcon={<span>B</span>} />);

      expect(screen.getByRole('button').element()).toHaveClass('w-8');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Toggle>Before</Toggle>);

      await screen.rerender(<Toggle>After</Toggle>);

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
    });
  });

  describe('state', () => {
    it('turns on and off again when pressed', async () => {
      const screen = await render(<Toggle>Bold</Toggle>);
      const toggle = screen.getByRole('button', { name: 'Bold' });

      await toggle.click();
      await expect.element(toggle).toHaveAttribute('aria-pressed', 'true');

      await toggle.click();
      await expect.element(toggle).toHaveAttribute('aria-pressed', 'false');
    });

    it('reports every change', async () => {
      const onPressedChange = vi.fn();
      const screen = await render(<Toggle onPressedChange={onPressedChange}>Bold</Toggle>);

      await screen.getByRole('button').click();

      expect(onPressedChange).toHaveBeenCalledWith(true);
    });

    it('stays where the controlled value puts it', async () => {
      const screen = await render(<Toggle pressed={false}>Bold</Toggle>);
      const toggle = screen.getByRole('button');

      await toggle.click();

      await expect.element(toggle).toHaveAttribute('aria-pressed', 'false');
    });

    it('does not fire while disabled', async () => {
      const onPressedChange = vi.fn();
      const screen = await render(
        <Toggle disabled onPressedChange={onPressedChange}>
          Bold
        </Toggle>
      );

      await screen.getByRole('button').click({ force: true });

      expect(onPressedChange).not.toHaveBeenCalled();
    });
  });

  describe('style props', () => {
    it('maps color onto the control slots', async () => {
      const screen = await render(<Toggle color="danger">Bold</Toggle>);
      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('takes the size the group sets', async () => {
      const screen = await render(
        <ButtonGroup size="lg">
          <Toggle>Bold</Toggle>
        </ButtonGroup>
      );

      expect(screen.getByRole('button').element()).toHaveClass('h-10');
    });

    it('lets its own prop win over the group', async () => {
      const screen = await render(
        <ButtonGroup size="lg">
          <Toggle size="sm">Bold</Toggle>
        </ButtonGroup>
      );

      expect(screen.getByRole('button').element()).toHaveClass('h-6.5');
    });
  });
});
