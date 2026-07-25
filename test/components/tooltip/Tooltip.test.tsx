import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Tooltip } from 'neba';

describe('Tooltip', () => {
  describe('rendering', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(
        <Tooltip content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );

      expect(screen.getByRole('tooltip').query()).toBeNull();
    });

    it('renders its content when open', async () => {
      const screen = await render(
        <Tooltip defaultOpen content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );

      await expect.element(screen.getByRole('tooltip')).toHaveTextContent('Copy to clipboard');
    });

    // The trigger merges onto the child rather than wrapping it, so the tooltip
    // costs the layout nothing and the child stays whatever it was.
    it('adds no element of its own around the trigger', async () => {
      const screen = await render(
        <Tooltip content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );
      const trigger = screen.getByRole('button', { name: 'Copy' }).element();

      expect(trigger.tagName).toBe('BUTTON');
      expect(trigger.parentElement?.tagName).not.toBe('BUTTON');
    });

    it('keeps the trigger a real Neba button', async () => {
      const screen = await render(
        <Tooltip content="Copy to clipboard">
          <Button color="danger">Copy</Button>
        </Tooltip>
      );
      const trigger = screen.getByRole('button', { name: 'Copy' }).element() as HTMLElement;

      expect(trigger.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('reflects changed content on re-render', async () => {
      const screen = await render(
        <Tooltip defaultOpen content="Before">
          <Button>Copy</Button>
        </Tooltip>
      );

      await screen.rerender(
        <Tooltip defaultOpen content="After">
          <Button>Copy</Button>
        </Tooltip>
      );

      await expect.element(screen.getByRole('tooltip')).toHaveTextContent('After');
    });
  });

  describe('behaviour', () => {
    it('opens when the pointer rests on the trigger', async () => {
      const screen = await render(
        <Tooltip delay={0} content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );

      await screen.getByRole('button', { name: 'Copy' }).hover();

      await expect.element(screen.getByRole('tooltip')).toBeInTheDocument();
    });

    it('does not open when it is disabled', async () => {
      const screen = await render(
        <Tooltip disabled delay={0} content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );

      await screen.getByRole('button', { name: 'Copy' }).hover();

      expect(screen.getByRole('tooltip').query()).toBeNull();
    });

    it('reports opening to the caller', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Tooltip delay={0} content="Copy to clipboard" onOpenChange={onOpenChange}>
          <Button>Copy</Button>
        </Tooltip>
      );

      await screen.getByRole('button', { name: 'Copy' }).hover();
      await expect.element(screen.getByRole('tooltip')).toBeInTheDocument();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('honours a controlled open', async () => {
      const screen = await render(
        <Tooltip open={false} onOpenChange={() => {}} content="Copy">
          <Button>Copy</Button>
        </Tooltip>
      );

      expect(screen.getByRole('tooltip').query()).toBeNull();

      await screen.rerender(
        <Tooltip open onOpenChange={() => {}} content="Copy">
          <Button>Copy</Button>
        </Tooltip>
      );

      await expect.element(screen.getByRole('tooltip')).toBeInTheDocument();
    });
  });

  describe('the plate', () => {
    it('carries the portal hook, because it leaves the scoped subtree', async () => {
      const screen = await render(
        <Tooltip defaultOpen content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );
      const positioner = screen.getByRole('tooltip').element().parentElement;

      expect(positioner).toHaveClass('neba-portal');
    });

    it('is a filled neutral plate by default', async () => {
      const screen = await render(
        <Tooltip defaultOpen content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );
      const popup = screen.getByRole('tooltip').element() as HTMLElement;

      expect(popup).toHaveClass('bg-(--n-fill)');
      expect(popup.style.getPropertyValue('--n-fill')).toBe('var(--neba-secondary-fill)');
    });

    it('takes a colour family of its own', async () => {
      const screen = await render(
        <Tooltip defaultOpen color="danger" content="Cannot be undone">
          <Button>Delete</Button>
        </Tooltip>
      );
      const popup = screen.getByRole('tooltip').element() as HTMLElement;

      expect(popup.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('drops the wedge when asked', async () => {
      const screen = await render(
        <Tooltip defaultOpen arrow={false} content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );

      expect(screen.getByRole('tooltip').element().querySelector('svg')).toBeNull();
    });

    it('draws the wedge by default', async () => {
      const screen = await render(
        <Tooltip defaultOpen content="Copy to clipboard">
          <Button>Copy</Button>
        </Tooltip>
      );

      expect(screen.getByRole('tooltip').element().querySelector('svg')).not.toBeNull();
    });
  });
});
