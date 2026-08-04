import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Drawer, DrawerClose } from 'neba';

describe('Drawer', () => {
  describe('overlay mode', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(<Drawer trigger={<Button>Menu</Button>} title="Navigation" />);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('renders a dialog named by its title', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);

      await expect.element(screen.getByRole('dialog', { name: 'Navigation' })).toBeInTheDocument();
    });

    it('renders the title as a real heading', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);

      await expect.element(screen.getByRole('heading', { name: 'Navigation' })).toBeInTheDocument();
    });

    it('describes the drawer with its description', async () => {
      const screen = await render(
        <Drawer defaultOpen title="Navigation" description="Every project you can reach." />
      );

      await expect
        .element(screen.getByRole('dialog'))
        .toHaveAccessibleDescription('Every project you can reach.');
    });

    it('renders the body and the actions', async () => {
      const screen = await render(
        <Drawer defaultOpen title="Filters" actions={<Button>Apply</Button>}>
          Narrow the table down.
        </Drawer>
      );

      await expect.element(screen.getByText('Narrow the table down.')).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Apply' })).toBeInTheDocument();
    });

    it('opens from its trigger', async () => {
      const screen = await render(<Drawer trigger={<Button>Menu</Button>} title="Navigation" />);

      await screen.getByRole('button', { name: 'Menu' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('reports opening to the caller', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Drawer trigger={<Button>Menu</Button>} title="Navigation" onOpenChange={onOpenChange} />
      );

      await screen.getByRole('button', { name: 'Menu' }).click();
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it('honours a controlled open', async () => {
      const screen = await render(
        <Drawer open={false} onOpenChange={() => {}} title="Navigation" />
      );

      expect(screen.getByRole('dialog').query()).toBeNull();

      await screen.rerender(<Drawer open onOpenChange={() => {}} title="Navigation" />);

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    // `modal="trap-focus"` rather than the default, for the reason Dialog's own
    // click tests use it: a fully modal Base UI dialog renders an inert overlay
    // with inline `position: fixed; inset: 0`, and nothing loads Tailwind into
    // the test run — so the `z-50` that puts the panel above it in a real app is
    // an inert string here and every click lands on the overlay.
    it('closes from a DrawerClose', async () => {
      const screen = await render(
        <Drawer
          defaultOpen
          modal="trap-focus"
          title="Filters"
          actions={<DrawerClose render={<Button>Cancel</Button>} />}
        />
      );

      await screen.getByRole('button', { name: 'Cancel' }).click();

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    it('closes from the × and takes a name for it', async () => {
      const screen = await render(
        <Drawer defaultOpen modal="trap-focus" closeLabel="Dismiss" title="Filters" />
      );

      await screen.getByRole('button', { name: 'Dismiss' }).click();

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    it('stays open on Escape when it is not dismissible', async () => {
      const screen = await render(
        <Drawer defaultOpen dismissible={false} modal="trap-focus" title="Filters" />
      );

      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('carries the portal hook, because it leaves the scoped subtree', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);
      const viewport = screen.getByRole('dialog').element().parentElement;

      expect(viewport).toHaveClass('neba-portal');
    });

    it('floats, so it carries a shadow', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);
      const panel = screen.getByRole('dialog').element() as HTMLElement;

      expect(panel.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-3)');
    });
  });

  describe('inline mode', () => {
    it('is in the layout without being opened', async () => {
      const screen = await render(<Drawer mode="inline" title="Projects" />);

      await expect.element(screen.getByRole('heading', { name: 'Projects' })).toBeInTheDocument();
    });

    // Not a dialog: there is no scrim, no focus trap and nothing to dismiss, so
    // announcing one would be announcing something that is not there.
    it('is not a dialog', async () => {
      const screen = await render(<Drawer mode="inline" title="Projects" />);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('leaves the layout when it is closed', async () => {
      const screen = await render(
        <Drawer mode="inline" open={false} onOpenChange={() => {}} title="Projects" />
      );

      expect(screen.getByRole('heading', { name: 'Projects' }).query()).toBeNull();
    });

    it('draws no × by default', async () => {
      const screen = await render(<Drawer mode="inline" title="Projects" />);

      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();
    });

    it('reports a close from its × when it is asked for one', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Drawer mode="inline" showClose title="Projects" onOpenChange={onOpenChange} />
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
    });

    it('does not render a trigger, because there is nothing to open', async () => {
      const screen = await render(
        <Drawer mode="inline" trigger={<Button>Menu</Button>} title="Projects" />
      );

      expect(screen.getByRole('button', { name: 'Menu' }).query()).toBeNull();
    });

    // An inline panel is part of the layout rather than floating over it, so it
    // carries no drop shadow. `className` is the hook: unlike the overlay panel
    // there is no dialog role to find it by.
    it('sits flat on the page', async () => {
      await render(<Drawer mode="inline" title="Projects" className="neba-inline-panel" />);
      const panel = document.querySelector('.neba-inline-panel') as HTMLElement;

      expect(panel.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-0)');
    });
  });

  describe('side', () => {
    it('hangs off the left and cuts its right corners by default', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);
      const panel = screen.getByRole('dialog').element();

      expect(panel).toHaveClass('rounded-r-(--neba-radius-md)');
      expect(panel).toHaveClass('border-r');
      expect(panel.parentElement).toHaveClass('justify-start');
    });

    it('cuts the corners on the free edge whichever side it is', async () => {
      const screen = await render(<Drawer defaultOpen side="bottom" title="Filters" />);
      const panel = screen.getByRole('dialog').element();

      expect(panel).toHaveClass('rounded-t-(--neba-radius-md)');
      expect(panel).toHaveClass('border-t');
      expect(panel.parentElement).toHaveClass('flex-col');
      expect(panel.parentElement).toHaveClass('justify-end');
    });

    it('squares every corner when rounded is off', async () => {
      const screen = await render(<Drawer defaultOpen rounded={false} title="Navigation" />);

      expect(screen.getByRole('dialog').element().className).not.toContain('rounded-');
    });

    it('moves the radius with size', async () => {
      const screen = await render(<Drawer defaultOpen size="xl" side="right" title="Navigation" />);

      expect(screen.getByRole('dialog').element()).toHaveClass('rounded-l-(--neba-radius-xl)');
    });
  });

  describe('extent', () => {
    it('takes a width off the size ladder on a side panel', async () => {
      const screen = await render(<Drawer defaultOpen size="sm" title="Navigation" />);

      expect(screen.getByRole('dialog').element()).toHaveClass('w-64');
    });

    it('is the content on a top or bottom panel, capped at the window', async () => {
      const screen = await render(<Drawer defaultOpen side="bottom" title="Filters" />);
      const panel = screen.getByRole('dialog').element();

      expect(panel).toHaveClass('max-h-[85%]');
      expect(panel).toHaveClass('w-full');
    });

    it('is a width for a side panel', async () => {
      const screen = await render(<Drawer defaultOpen extent={360} title="Navigation" />);
      const panel = screen.getByRole('dialog').element() as HTMLElement;

      expect(panel).not.toHaveClass('w-80');
      expect(panel.style.width).toBe('360px');
      expect(panel.style.height).toBe('');
    });

    it('is a height for a top or bottom panel', async () => {
      const screen = await render(
        <Drawer defaultOpen side="bottom" extent="50vh" title="Filters" />
      );
      const panel = screen.getByRole('dialog').element() as HTMLElement;

      expect(panel.style.height).toBe('50vh');
      expect(panel.style.width).toBe('');
    });
  });

  describe('the sheet', () => {
    it('is an undyed panel, so what it holds keeps its own colours', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);
      const panel = screen.getByRole('dialog').element() as HTMLElement;

      expect(panel).toHaveClass('bg-(--n-panel-press)');
      expect(panel.style.getPropertyValue('--n-panel-press')).toBe('var(--neba-panel-press)');
    });

    it('sends the colour family to the edge and the ring', async () => {
      const screen = await render(<Drawer defaultOpen color="warning" title="Navigation" />);
      const panel = screen.getByRole('dialog').element() as HTMLElement;

      expect(panel.style.getPropertyValue('--n-line')).toBe('var(--neba-warning-line)');
      expect(panel.style.getPropertyValue('--n-ring')).toBe('var(--neba-warning-ring)');
    });

    it('rules its sections when it is asked to', async () => {
      const screen = await render(
        <Drawer defaultOpen dividers title="Filters" actions={<Button>Apply</Button>}>
          Narrow the table down.
        </Drawer>
      );
      const footer = screen.getByRole('button', { name: 'Apply' }).element().parentElement;

      expect(footer).toHaveClass('border-t');
    });
  });
});
