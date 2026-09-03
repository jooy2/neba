import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Drawer, DrawerClose } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

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

    /**
     * The one surface in the library that does not simply fade. Every other one
     * appears where it will stay, so moving it drags text the reader is already
     * on; a drawer has a home, and until it opens it is not on the screen at
     * all. It used to fade, which threw away the only thing distinguishing it
     * from a Dialog.
     */
    it('comes in from the edge it is attached to, whichever that is', async () => {
      const screen = await render(<Drawer defaultOpen title="Navigation" />);
      const panel = screen.getByRole('dialog').element();

      expect(panel.className).toContain('transition:translate');
      expect(panel).toHaveClass('data-[starting-style]:[translate:-100%_0]');
      expect(panel).toHaveClass('data-[ending-style]:[translate:-100%_0]');
      // The panel travels; the scrim behind it is what fades.
      expect(panel.className).not.toContain('data-[starting-style]:opacity-0');
    });

    it('comes up from the bottom when that is where it lives', async () => {
      const screen = await render(<Drawer defaultOpen side="bottom" title="Filters" />);

      expect(screen.getByRole('dialog').element()).toHaveClass(
        'data-[starting-style]:[translate:0_100%]'
      );
    });

    /** An inline drawer is in the flow, and moving the page is not its to do. */
    it('does not travel when it is inline', async () => {
      const screen = await render(<Drawer mode="inline" defaultOpen title="Filters" />);
      // An inline drawer is not a dialog and takes no forwarded props, so the
      // panel is reached through the heading it drew.
      const panel = screen.getByRole('heading', { name: 'Filters' }).element().closest('div')
        ?.parentElement as HTMLElement;

      expect(panel.className).not.toContain('transition:translate');
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

  describe('locale', () => {
    it('names the × in the language it was given', async () => {
      const screen = await render(<Drawer defaultOpen showClose locale="ko" title="설정" />);

      await expect.element(screen.getByRole('button', { name: '닫기' })).toBeInTheDocument();
    });

    it('takes a word of its own over the locale', async () => {
      const screen = await render(
        <Drawer defaultOpen showClose locale="ko" closeLabel="Dismiss" title="설정" />
      );

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });
  });

  describe('forwarded props', () => {
    it('passes an unknown prop to the panel', async () => {
      await render(<Drawer defaultOpen title="Settings" data-analytics="settings-panel" />);

      await expect
        .element(document.querySelector<HTMLElement>('[data-analytics="settings-panel"]')!)
        .toBeInTheDocument();
    });

    /**
     * Both modes, because they are one component and a caller does not choose
     * which one they get — a Sidebar swaps them at a breakpoint. The inline
     * panel was rendering none of them, so an `id`, a `data-*` or an `aria-*`
     * survived on a wide screen and vanished on a narrow one.
     */
    it('passes an unknown prop to the inline panel too', async () => {
      const screen = await render(
        <Drawer mode="inline" title="Settings" data-analytics="settings-panel" />
      );

      await expect.element(screen.getByRole('heading', { name: 'Settings' })).toBeInTheDocument();
      expect(document.querySelector('[data-analytics="settings-panel"]')).not.toBeNull();
    });

    it('lets a caller name the inline panel for a label elsewhere on the page', async () => {
      const screen = await render(
        <Drawer mode="inline" title="Filters" id="filters" aria-describedby="hint" />
      );

      const panel = document.getElementById('filters');

      await expect.element(screen.getByRole('heading', { name: 'Filters' })).toBeInTheDocument();
      expect(panel).not.toBeNull();
      expect(panel?.getAttribute('aria-describedby')).toBe('hint');
    });
  });
});
