import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Button, Dialog, DialogClose } from 'neba';

describe('Dialog', () => {
  describe('rendering', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(<Dialog title="Delete workspace">This cannot be undone.</Dialog>);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('renders a dialog named by its title', async () => {
      const screen = await render(
        <Dialog defaultOpen title="Delete workspace">
          This cannot be undone.
        </Dialog>
      );

      await expect
        .element(screen.getByRole('dialog', { name: 'Delete workspace' }))
        .toBeInTheDocument();
    });

    it('renders the title as a real heading', async () => {
      const screen = await render(<Dialog defaultOpen title="Delete workspace" />);

      await expect
        .element(screen.getByRole('heading', { name: 'Delete workspace' }))
        .toBeInTheDocument();
    });

    it('describes the dialog with its description', async () => {
      const screen = await render(
        <Dialog defaultOpen title="Delete workspace" description="Everything in it goes too." />
      );

      await expect
        .element(screen.getByRole('dialog'))
        .toHaveAccessibleDescription('Everything in it goes too.');
    });

    it('renders the body and the actions', async () => {
      const screen = await render(
        <Dialog defaultOpen title="Delete workspace" actions={<Button>Delete</Button>}>
          This cannot be undone.
        </Dialog>
      );

      await expect.element(screen.getByText('This cannot be undone.')).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Delete' })).toBeInTheDocument();
    });
  });

  describe('opening and closing', () => {
    it('opens from its trigger', async () => {
      const screen = await render(
        <Dialog trigger={<Button>Open</Button>} title="Delete workspace" />
      );

      await screen.getByRole('button', { name: 'Open' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    // These two use `modal="trap-focus"` rather than the default. A fully modal
    // Base UI dialog renders an inert overlay with inline `position: fixed;
    // inset: 0`, and nothing loads Tailwind into the test run — so the `z-50`
    // that puts the sheet above it in a real app is an inert string here and
    // every click lands on the overlay. The wiring under test is the same.
    it('closes from the × button', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Dialog
          defaultOpen
          modal="trap-focus"
          title="Delete workspace"
          onOpenChange={onOpenChange}
        />
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
    });

    it('closes from a DialogClose in the actions', async () => {
      const screen = await render(
        <Dialog
          defaultOpen
          modal="trap-focus"
          title="Delete workspace"
          actions={<DialogClose render={<Button>Cancel</Button>} />}
        />
      );

      await screen.getByRole('button', { name: 'Cancel' }).click();

      await expect.element(screen.getByRole('dialog')).not.toBeInTheDocument();
    });

    it('hides the × when asked', async () => {
      const screen = await render(<Dialog defaultOpen showClose={false} title="Delete" />);

      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();
    });

    it('takes a custom accessible name for the × button', async () => {
      const screen = await render(<Dialog defaultOpen closeLabel="Dismiss" title="Delete" />);

      await expect.element(screen.getByRole('button', { name: 'Dismiss' })).toBeInTheDocument();
    });

    it('honours a controlled open', async () => {
      const screen = await render(
        <Dialog open={false} onOpenChange={() => {}} title="Delete workspace" />
      );

      expect(screen.getByRole('dialog').query()).toBeNull();

      await screen.rerender(<Dialog open onOpenChange={() => {}} title="Delete workspace" />);

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('stays open on Escape when it is not dismissible', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Dialog defaultOpen dismissible={false} title="Delete" onOpenChange={onOpenChange} />
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      expect(onOpenChange).not.toHaveBeenCalled();
    });
  });

  describe('style props', () => {
    it('caps the sheet at the width its size implies', async () => {
      const screen = await render(<Dialog defaultOpen size="sm" title="Delete" />);

      await expect.element(screen.getByRole('dialog')).toHaveClass('max-w-96');
    });

    it('takes an explicit width instead', async () => {
      const screen = await render(<Dialog defaultOpen width={640} title="Delete" />);
      const element = screen.getByRole('dialog').element() as HTMLElement;

      expect(element.style.maxWidth).toBe('640px');
      expect(element).not.toHaveClass('max-w-lg');
    });

    it('fills the viewport when full screen', async () => {
      const screen = await render(<Dialog defaultOpen fullScreen title="Delete" />);

      await expect.element(screen.getByRole('dialog')).toHaveClass('rounded-none');
    });

    /**
     * The body is a scroll container and a scroll container clips at its padding
     * box, so a field flush against the top or bottom of it had its focus ring —
     * drawn 4px outside the control — sliced off. The padding is room for the
     * ring and the negative margin hands the space straight back.
     */
    it('leaves room for a focus ring at the edges of the scrolling body', async () => {
      const screen = await render(
        <Dialog defaultOpen title="Delete">
          <input aria-label="Name" />
        </Dialog>
      );
      const body = screen.getByLabelText('Name').element().parentElement as HTMLElement;

      expect(body).toHaveClass('overflow-y-auto');
      expect(body).toHaveClass('py-1');
      expect(body).toHaveClass('-my-1');
    });

    it('does not pull the body up when dividers already give it room', async () => {
      const screen = await render(
        <Dialog defaultOpen dividers title="Delete">
          <input aria-label="Name" />
        </Dialog>
      );
      const body = screen.getByLabelText('Name').element().parentElement as HTMLElement;

      expect(body).not.toHaveClass('-my-1');
      expect(body).toHaveClass('border-t');
    });

    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(<Dialog defaultOpen color="danger" title="Delete" />);
      const element = screen.getByRole('dialog').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-danger-line)');
    });

    it('never applies a transform', async () => {
      const screen = await render(
        <Dialog
          defaultOpen
          dividers
          title="Delete"
          description="Gone for good."
          actions={<Button>Delete</Button>}
        >
          This cannot be undone.
        </Dialog>
      );
      const html = screen.getByRole('dialog').element().outerHTML;

      expect(html).not.toContain('scale');
      expect(html).not.toContain('translate');
    });
  });
});
