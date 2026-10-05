/**
 * Which portalled surface is drawn over which, measured with the stylesheet on.
 *
 * Every portalled surface reads `--neba-z-portal`, so between two of them the
 * one later in the document is on top. That is right for a menu opened inside a
 * dialog, whose portal comes after the dialog's, and wrong for the toast stack,
 * whose portal mounts with its provider and so comes before any dialog opened
 * under it. The toast viewport sits one step above the rest for that reason, and
 * the step is a class, so only a test with the stylesheet on can see it.
 *
 * "On top" is asked of the page: the element at the centre of a control has to
 * be that control or something inside it, which is where a click there lands.
 */
import * as React from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Button, Dialog, Drawer, Menu, MenuItem, ToastProvider, useToast } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(() => {
  document.documentElement.style.removeProperty('--neba-z-portal');
});

/** Raises a toast when it mounts, so inside a dialog it is raised while the dialog is open. */
function Raise({ onAction }: { onAction?: () => void }) {
  const { add } = useToast();

  React.useEffect(() => {
    add({ title: 'Saved', actionLabel: 'Undo', onAction, timeout: 0 });
  }, [add, onAction]);

  return null;
}

/** Whether a click at the centre of `element` would land on it. */
function drawnOnTop(element: Element): boolean {
  const rect = element.getBoundingClientRect();
  const hit = document.elementFromPoint(rect.left + rect.width / 2, rect.top + rect.height / 2);

  return hit !== null && element.contains(hit);
}

/** The z-index of the portalled layer `element` is drawn in. */
function layerOf(element: Element): number {
  return Number(getComputedStyle(element.closest('.neba-portal') as Element).zIndex);
}

describe('the toast stack', () => {
  it('is drawn over a modal dialog it was raised under, and its buttons take the click', async () => {
    const onAction = vi.fn();
    const screen = await render(
      <ToastProvider closeLabel="Dismiss">
        <Dialog open showClose={false} title="Edit profile">
          <Raise onAction={onAction} />
        </Dialog>
      </ToastProvider>
    );
    const action = screen.getByRole('button', { name: 'Undo' });
    // Base UI keeps the close button out of the accessibility tree until the
    // stack is expanded or the button has focus.
    const close = screen.getByRole('button', { name: 'Dismiss', includeHidden: true });

    await expect.element(screen.getByRole('dialog', { name: 'Edit profile' })).toBeInTheDocument();
    await expect.element(action).toBeInTheDocument();
    await expect.poll(() => drawnOnTop(action.element())).toBe(true);
    expect(drawnOnTop(close.element())).toBe(true);

    await userEvent.click(action);
    expect(onAction).toHaveBeenCalledOnce();

    await userEvent.click(close);
    await expect.element(screen.getByText('Saved')).not.toBeInTheDocument();
  });

  it('stays over a drawer when the host moves --neba-z-portal', async () => {
    document.documentElement.style.setProperty('--neba-z-portal', '1400');

    const screen = await render(
      <ToastProvider closeLabel="Dismiss">
        <Drawer open title="Filters">
          <Raise />
        </Drawer>
      </ToastProvider>
    );
    const close = screen.getByRole('button', { name: 'Dismiss', includeHidden: true });
    const drawer = screen.getByRole('dialog', { name: 'Filters' });

    await expect.element(drawer).toBeInTheDocument();
    await expect.element(close).toBeInTheDocument();
    await expect.poll(() => drawnOnTop(close.element())).toBe(true);

    expect(layerOf(drawer.element())).toBe(1400);
    expect(layerOf(close.element())).toBeGreaterThan(1400);
  });
});

describe('a popup opened inside a dialog', () => {
  it('is drawn over the dialog, in the same layer as the dialog', async () => {
    const screen = await render(
      <ToastProvider>
        <Dialog open showClose={false} title="Edit profile">
          <Menu defaultOpen trigger={<Button>Actions</Button>}>
            <MenuItem>Rename</MenuItem>
          </Menu>
        </Dialog>
      </ToastProvider>
    );
    const item = screen.getByRole('menuitem', { name: 'Rename' });

    await expect.element(item).toBeInTheDocument();
    await expect.poll(() => drawnOnTop(item.element())).toBe(true);

    expect(layerOf(item.element())).toBe(
      layerOf(screen.getByRole('dialog', { name: 'Edit profile' }).element())
    );
  });
});
