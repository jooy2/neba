import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { Overlay } from 'neba';

/**
 * The scrim. It carries no role of its own and no test hook — it is the one
 * `.neba-portal` element that is hidden from the accessibility tree, which is
 * what separates it from the viewport the content sits in.
 */
function backdrop(): HTMLElement {
  const element = document.querySelector('.neba-portal[aria-hidden="true"]');

  expect(element).not.toBeNull();
  return element as HTMLElement;
}

describe('Overlay', () => {
  describe('rendering', () => {
    it('renders nothing while closed', async () => {
      const screen = await render(<Overlay>Working…</Overlay>);

      expect(screen.getByText('Working…').query()).toBeNull();
    });

    it('renders its content while open', async () => {
      const screen = await render(<Overlay open>Working…</Overlay>);

      await expect.element(screen.getByText('Working…')).toBeInTheDocument();
    });

    it('is a dialog named by its label', async () => {
      const screen = await render(
        <Overlay open label="Publishing">
          Working…
        </Overlay>
      );

      await expect.element(screen.getByRole('dialog', { name: 'Publishing' })).toBeInTheDocument();
    });

    it('names itself even with nothing readable inside', async () => {
      const screen = await render(<Overlay open />);

      await expect.element(screen.getByRole('dialog', { name: 'Overlay' })).toBeInTheDocument();
    });

    it('opens from defaultOpen', async () => {
      const screen = await render(<Overlay defaultOpen>Working…</Overlay>);

      await expect.element(screen.getByText('Working…')).toBeInTheDocument();
    });

    it('reflects a changed open on re-render', async () => {
      const screen = await render(<Overlay open={false}>Working…</Overlay>);

      expect(screen.getByText('Working…').query()).toBeNull();

      await screen.rerender(<Overlay open>Working…</Overlay>);

      await expect.element(screen.getByText('Working…')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names on the content', async () => {
      const screen = await render(
        <Overlay open className="my-own-class">
          Working…
        </Overlay>
      );

      expect(screen.getByText('Working…').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('dismissal', () => {
    it('refuses Escape by default', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Overlay open onOpenChange={onOpenChange}>
          Working…
        </Overlay>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      expect(onOpenChange).not.toHaveBeenCalled();
      await expect.element(screen.getByText('Working…')).toBeInTheDocument();
    });

    it('closes on Escape when dismissible', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <Overlay open dismissible onOpenChange={onOpenChange}>
          Working…
        </Overlay>
      );

      // Wait for the overlay to hold the focus rather than for its markup: it
      // takes focus in an effect after it mounts, and a key pressed in between
      // lands wherever the focus still was.
      await vi.waitFor(() =>
        expect(screen.getByRole('dialog').element().contains(document.activeElement)).toBe(true)
      );
      await userEvent.keyboard('{Escape}');

      await vi.waitFor(() => expect(onOpenChange).toHaveBeenCalledWith(false));
    });
  });

  describe('style props', () => {
    it('dims with the scrim by default', async () => {
      await render(<Overlay open>Working…</Overlay>);

      expect(backdrop()).toHaveClass('bg-(--neba-scrim)');
    });

    it('draws nothing at all when clear', async () => {
      await render(
        <Overlay open tone="clear">
          Working…
        </Overlay>
      );

      expect(backdrop()).not.toHaveClass('bg-(--neba-scrim)');
      expect(getComputedStyle(backdrop()).backdropFilter).toBe('none');
    });

    it('moves the content down the viewport with align', async () => {
      const screen = await render(
        <Overlay open align="end">
          Working…
        </Overlay>
      );
      const viewport = screen.getByRole('dialog').element().parentElement as HTMLElement;

      expect(viewport).toHaveClass('items-end');
    });

    it('carries the colour family into the slots', async () => {
      const screen = await render(
        <Overlay open color="danger">
          Working…
        </Overlay>
      );
      const popup = screen.getByRole('dialog').element() as HTMLElement;

      expect(popup.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });
  });

  describe('locale', () => {
    it('names the sheet in the language it was given', async () => {
      const screen = await render(
        <Overlay open locale="ko">
          불러오는 중
        </Overlay>
      );

      await expect.element(screen.getByRole('dialog', { name: '오버레이' })).toBeInTheDocument();
    });

    it('takes a name of its own over the locale', async () => {
      const screen = await render(
        <Overlay open locale="ko" label="Loading">
          불러오는 중
        </Overlay>
      );

      await expect.element(screen.getByRole('dialog', { name: 'Loading' })).toBeInTheDocument();
    });
  });
});
