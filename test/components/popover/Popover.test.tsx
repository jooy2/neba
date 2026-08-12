import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Popover, PopoverClose } from 'neba';

describe('Popover', () => {
  describe('rendering', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(
        <Popover trigger={<Button>Share</Button>} title="Share this page" />
      );

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('renders a dialog named by its title', async () => {
      const screen = await render(<Popover defaultOpen title="Share this page" />);

      await expect
        .element(screen.getByRole('dialog', { name: 'Share this page' }))
        .toBeInTheDocument();
    });

    it('describes the popup with its description', async () => {
      const screen = await render(
        <Popover defaultOpen title="Share this page" description="Anyone with the link can read." />
      );

      await expect
        .element(screen.getByRole('dialog'))
        .toHaveAccessibleDescription('Anyone with the link can read.');
    });

    it('renders the body', async () => {
      const screen = await render(
        <Popover defaultOpen title="Share this page">
          <Button>Copy link</Button>
        </Popover>
      );

      await expect.element(screen.getByRole('button', { name: 'Copy link' })).toBeInTheDocument();
    });

    it('reflects changed content on re-render', async () => {
      const screen = await render(<Popover defaultOpen title="Before" />);

      await screen.rerender(<Popover defaultOpen title="After" />);

      await expect.element(screen.getByRole('dialog', { name: 'After' })).toBeInTheDocument();
    });
  });

  describe('opening and closing', () => {
    it('opens from its trigger', async () => {
      const screen = await render(
        <Popover trigger={<Button>Share</Button>} title="Share this page" />
      );

      await screen.getByRole('button', { name: 'Share' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('keeps the trigger a real Neba button', async () => {
      const screen = await render(
        <Popover trigger={<Button color="danger">Share</Button>} title="Share this page" />
      );
      const trigger = screen.getByRole('button', { name: 'Share' }).element() as HTMLElement;

      expect(trigger.style.getPropertyValue('--n-fill')).toBe('var(--neba-danger-fill)');
    });

    it('reports opening to the caller', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Popover trigger={<Button>Share</Button>} title="Share" onOpenChange={onOpenChange} />
      );

      await screen.getByRole('button', { name: 'Share' }).click();
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('honours a controlled open', async () => {
      const screen = await render(
        <Popover open={false} onOpenChange={() => {}} title="Share this page" />
      );

      expect(screen.getByRole('dialog').query()).toBeNull();

      await screen.rerender(<Popover open onOpenChange={() => {}} title="Share this page" />);

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('closes from a PopoverClose', async () => {
      const screen = await render(
        <Popover defaultOpen title="Share this page">
          <PopoverClose render={<Button>Done</Button>} />
        </Popover>
      );

      await screen.getByRole('button', { name: 'Done' }).click();

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    it('closes on Escape', async () => {
      const screen = await render(<Popover defaultOpen title="Share this page" />);
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    // `dismissible={false}` cancels the two ways out that are not deliberate.
    // A `PopoverClose` still gets through, which is what keeps it from being a
    // trap rather than a decision.
    it('stays open on Escape when it is not dismissible', async () => {
      const screen = await render(
        <Popover defaultOpen dismissible={false} title="Share this page">
          <PopoverClose render={<Button>Done</Button>} />
        </Popover>
      );

      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Done' }).click();

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });
  });

  describe('the sheet', () => {
    it('carries the portal hook, because it leaves the scoped subtree', async () => {
      const screen = await render(<Popover defaultOpen title="Share this page" />);
      const positioner = screen.getByRole('dialog').element().parentElement;

      expect(positioner).toHaveClass('neba-portal');
    });

    it('is an undyed panel that floats', async () => {
      const screen = await render(<Popover defaultOpen title="Share this page" />);
      const popup = screen.getByRole('dialog').element() as HTMLElement;

      expect(popup).toHaveClass('bg-(--n-panel-press)');
      expect(popup.style.getPropertyValue('--n-panel-press')).toBe('var(--neba-panel-press)');
      expect(popup.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-3)');
    });

    it('sends the colour family to the edge and the ring', async () => {
      const screen = await render(<Popover defaultOpen color="success" title="Deployed" />);
      const popup = screen.getByRole('dialog').element() as HTMLElement;

      expect(popup.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
      expect(popup.style.getPropertyValue('--n-ring')).toBe('var(--neba-success-ring)');
    });

    it('caps its width on the size ladder', async () => {
      const screen = await render(<Popover defaultOpen size="sm" title="Share this page" />);

      expect(screen.getByRole('dialog').element()).toHaveClass('max-w-64');
    });

    it('takes an explicit width instead', async () => {
      const screen = await render(<Popover defaultOpen width={420} title="Share this page" />);
      const popup = screen.getByRole('dialog').element() as HTMLElement;

      expect(popup).not.toHaveClass('max-w-80');
      expect(popup.style.maxWidth).toBe('420px');
    });

    it('draws no wedge by default', async () => {
      const screen = await render(<Popover defaultOpen title="Share this page" />);

      expect(screen.getByRole('dialog').element().querySelector('svg')).toBeNull();
    });

    it('draws the wedge when asked', async () => {
      const screen = await render(<Popover defaultOpen arrow title="Share this page" />);

      expect(screen.getByRole('dialog').element().querySelector('svg')).not.toBeNull();
    });
  });

  describe('the close button', () => {
    it('is not drawn by default', async () => {
      const screen = await render(<Popover defaultOpen title="Share this page" />);

      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();
    });

    it('closes the popup when it is', async () => {
      const screen = await render(<Popover defaultOpen showClose title="Share this page" />);

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    it('takes a name of its own', async () => {
      const screen = await render(
        <Popover defaultOpen showClose closeLabel="Dismiss" title="Share this page" />
      );

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });
  });

  describe('locale', () => {
    it('names the × in the language it was given', async () => {
      const screen = await render(<Popover defaultOpen showClose locale="ko" title="공유" />);

      await expect.element(screen.getByRole('button', { name: '닫기' })).toBeInTheDocument();
    });

    it('takes a word of its own over the locale', async () => {
      const screen = await render(
        <Popover defaultOpen showClose locale="ko" closeLabel="Dismiss" title="공유" />
      );

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });
  });
});
