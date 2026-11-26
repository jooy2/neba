import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { Pane, Panes } from 'neba';

/*
 * A split is laid out by `display: flex` on the container and a `flex-basis` on
 * each pane, and no component test loads CSS — so a measured width here would be
 * the width of the page whatever the component decided. What *is* observable is
 * the decision itself: every handle publishes the share of the pane in front of
 * it as `aria-valuenow`, which is the same number the callbacks report and the
 * same number the basis is written from.
 *
 * The container is 408px wide with an 8px handle in it, so two panes have 400px
 * to share and one percent is four pixels.
 */

/** The share, in percent, of the pane before each handle. */
function shares(screen: Awaited<ReturnType<typeof render>>) {
  return screen
    .getByRole('separator')
    .elements()
    .map((handle) => Number(handle.getAttribute('aria-valuenow')));
}

/** A split with a width to measure against. */
function Sample(props: React.ComponentProps<typeof Panes>) {
  return (
    <div style={{ width: 408, height: 208 }}>
      <Panes {...props} />
    </div>
  );
}

describe('Panes', () => {
  describe('rendering', () => {
    it('puts a handle between every pair of panes', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
          <Pane>Three</Pane>
        </Sample>
      );

      await expect.poll(() => screen.getByRole('separator').elements()).toHaveLength(2);
      // A finger dragging a handle would otherwise scroll the page and lose the pointer.
      for (const handle of screen.getByRole('separator').elements()) {
        expect(handle).toHaveClass('touch-none');
      }
    });

    it('renders no handle for a single pane', async () => {
      const screen = await render(
        <Sample>
          <Pane>Only</Pane>
        </Sample>
      );

      await expect.element(screen.getByText('Only')).toBeInTheDocument();
      expect(screen.getByRole('separator').query()).toBeNull();
    });

    it('splits the space evenly when no pane asks for a share', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      await expect.poll(() => shares(screen)).toEqual([50]);
    });

    it('gives a pane the share it asks for as a percentage', async () => {
      const screen = await render(
        <Sample>
          <Pane defaultSize={25}>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      await expect.poll(() => shares(screen)).toEqual([25]);
    });

    it('gives a pane the share it asks for as a length', async () => {
      const screen = await render(
        <Sample>
          <Pane defaultSize="120px">One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      // 120 of the 400 there are to share.
      await expect.poll(() => shares(screen)).toEqual([30]);
    });

    // A length is resolved in layout pixels, so it is divided by the room the
    // split has in layout pixels too, not by the room it is drawn in.
    it('gives a pane its length inside a scaled ancestor', async () => {
      const screen = await render(
        <div style={{ scale: '0.5', transformOrigin: 'top left' }}>
          <Sample>
            <Pane defaultSize="120px">One</Pane>
            <Pane>Two</Pane>
          </Sample>
        </div>
      );

      await expect.poll(() => shares(screen)).toEqual([30]);
    });

    it('writes the share out as a basis that pays for the handles', async () => {
      const screen = await render(
        <Sample>
          <Pane data-pane>One</Pane>
          <Pane data-pane>Two</Pane>
        </Sample>
      );

      // The browser folds the arithmetic before it reports it back, which is
      // the point: half of what is left once the handle has been paid for.
      await expect
        .poll(() =>
          screen.container.querySelector<HTMLElement>('[data-pane]')?.style.flex.replace(/\s+/g, '')
        )
        .toContain('calc(50%-4px)');
    });

    // A handle runs across the axis the panes run along, which is the one thing
    // about it a caller is most likely to expect the other way round.
    it('stands a handle upright between panes that run across', async () => {
      const screen = await render(
        <Sample orientation="horizontal">
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      await expect
        .element(screen.getByRole('separator'))
        .toHaveAttribute('aria-orientation', 'vertical');
    });

    it('lays a handle flat between panes that stack', async () => {
      const screen = await render(
        <Sample orientation="vertical">
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      await expect
        .element(screen.getByRole('separator'))
        .toHaveAttribute('aria-orientation', 'horizontal');
    });

    it('measures the other axis when the panes are stacked', async () => {
      // The height is stated here rather than left to `h-full`, which is a class
      // and so does nothing without a stylesheet. The width above needs no such
      // help: a `<div>` is already as wide as what holds it.
      const screen = await render(
        <Sample orientation="vertical" style={{ height: 208 }}>
          <Pane defaultSize="50px">One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      // 208 tall, less the 8px handle, is 200 to share.
      await expect.poll(() => shares(screen)).toEqual([25]);
    });

    it('re-splits when a pane is added on re-render', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      await screen.rerender(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
          <Pane>Three</Pane>
        </Sample>
      );

      await expect.poll(() => shares(screen)).toEqual([33, 33]);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Sample className="my-own-class">
          <Pane className="my-pane-class">One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
      expect(screen.container.querySelector('.my-pane-class')).not.toBeNull();
    });
  });

  describe('resizing', () => {
    it('takes the tab key to the handle', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      await expect.element(screen.getByRole('separator')).toHaveAttribute('tabindex', '0');
    });

    // A handle was read as "separator, 50", with nothing to say what it moved.
    it('names each handle and points it at the two panes it resizes', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane id="editor">Two</Pane>
        </Sample>
      );
      const handle = screen.getByRole('separator', { name: 'Resize panes' });

      await expect.element(handle).toBeInTheDocument();

      const [before, after] = (handle.element().getAttribute('aria-controls') ?? '').split(' ');

      expect(document.getElementById(before)).toHaveTextContent('One');
      expect(after).toBe('editor');
    });

    it('takes a name of its own, per handle', async () => {
      const screen = await render(
        <Sample handleLabel={(index) => `Resize column ${index + 1}`}>
          <Pane>One</Pane>
          <Pane>Two</Pane>
          <Pane>Three</Pane>
        </Sample>
      );

      await expect
        .element(screen.getByRole('separator', { name: 'Resize column 2' }))
        .toBeInTheDocument();
    });

    it('moves the boundary with the arrow keys', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowRight}');

      // One press is 16px, which is four percent of the 400 on offer.
      await expect.poll(() => shares(screen)).toEqual([54]);

      await userEvent.keyboard('{ArrowLeft}{ArrowLeft}');

      await expect.poll(() => shares(screen)).toEqual([46]);
    });

    // A drag already followed the direction; the arrows moved the boundary
    // away from the key that was pressed.
    it('moves the boundary towards the arrow pressed under RTL', async () => {
      const screen = await render(
        <div dir="rtl">
          <Sample>
            <Pane>One</Pane>
            <Pane>Two</Pane>
          </Sample>
        </div>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowLeft}');

      // The first pane is on the right, so moving the boundary left grows it.
      await expect.poll(() => shares(screen)).toEqual([54]);

      await userEvent.keyboard('{ArrowRight}{ArrowRight}');

      await expect.poll(() => shares(screen)).toEqual([46]);
    });

    it('holds a pane at its own minimum', async () => {
      const screen = await render(
        <Sample>
          <Pane minSize="192px">One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowLeft}{ArrowLeft}');

      await expect.poll(() => shares(screen)).toEqual([48]);
    });

    // A pane's floor is its neighbour's ceiling: dragging one open has to stop
    // where the other would go under its own minimum.
    it("holds a pane at its neighbour's minimum", async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane minSize="192px">Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowRight}{ArrowRight}');

      await expect.poll(() => shares(screen)).toEqual([52]);
    });

    it('holds a pane at its maximum', async () => {
      const screen = await render(
        <Sample>
          <Pane maxSize="208px">One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowRight}{ArrowRight}');

      await expect.poll(() => shares(screen)).toEqual([52]);
    });

    it('reports every pane, in percent', async () => {
      const onResizeEnd = vi.fn();
      const screen = await render(
        <Sample onResizeEnd={onResizeEnd}>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowRight}');

      await expect.poll(() => onResizeEnd.mock.calls.at(-1)?.[0].map(Math.round)).toEqual([54, 46]);
    });

    it('does not move when the split is not resizable', async () => {
      const screen = await render(
        <Sample resizable={false}>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      screen.getByRole('separator').element().focus();
      await userEvent.keyboard('{ArrowRight}');

      await expect.poll(() => shares(screen)).toEqual([50]);
    });

    it('keeps a fixed split out of the tab order', async () => {
      const screen = await render(
        <Sample resizable={false}>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );

      await expect.element(screen.getByRole('separator')).toHaveAttribute('tabindex', '-1');
    });

    /*
     * A drag takes the whole document's text selection away for as long as it
     * runs, and the `pointerup` that gives it back never arrives if the split
     * leaves the page first. What is left is a page nobody can select text on.
     */
    it('gives the page its text selection back if it unmounts mid-drag', async () => {
      const screen = await render(
        <Sample>
          <Pane>One</Pane>
          <Pane>Two</Pane>
        </Sample>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      const handle = screen.getByRole('separator').element() as HTMLElement;
      // A synthetic press cannot capture a pointer the browser has no record of,
      // and capturing one is not what is being tested.
      handle.setPointerCapture = () => {};

      // Read through the computed style rather than off the inline declaration:
      // WebKit has no `userSelect` on a style object, so an assertion written
      // against that name passes on a plain JS property the component set and
      // says nothing about whether the page can still be selected. The prefixed
      // name is the one all three engines answer to, and its default differs
      // between them, so the state before the drag is what the state after it is
      // compared against.
      const selectable = () => getComputedStyle(document.body).webkitUserSelect;
      const before = selectable();

      // Otherwise both assertions below would hold without the component.
      expect(before).not.toBe('none');

      handle.dispatchEvent(
        new PointerEvent('pointerdown', { bubbles: true, button: 0, pointerId: 1, clientX: 204 })
      );

      expect(selectable()).toBe('none');

      screen.unmount();

      expect(selectable()).toBe(before);
    });
  });

  describe('dragging', () => {
    // At half size, a hand that moves 20 pixels across the screen has moved the
    // boundary 40 of the split's own, which is ten percent of 400.
    it('follows the pointer inside a scaled ancestor', async () => {
      const screen = await render(
        <div style={{ scale: '0.5', transformOrigin: 'top left' }}>
          <Sample>
            <Pane>One</Pane>
            <Pane>Two</Pane>
          </Sample>
        </div>
      );
      await expect.poll(() => shares(screen)).toEqual([50]);

      const handle = screen.getByRole('separator').element() as HTMLElement;
      handle.setPointerCapture = () => {};

      handle.dispatchEvent(
        new PointerEvent('pointerdown', { bubbles: true, button: 0, pointerId: 1, clientX: 102 })
      );
      handle.dispatchEvent(
        new PointerEvent('pointermove', { bubbles: true, buttons: 1, pointerId: 1, clientX: 122 })
      );
      handle.dispatchEvent(new PointerEvent('pointerup', { bubbles: true, pointerId: 1 }));

      await expect.poll(() => shares(screen)).toEqual([60]);
    });
  });

  /*
   * A split that measured itself in an effect was drawn as an even split until
   * then, on the server's HTML and in a client-only app's first frame alike,
   * and every pane with a `defaultSize` jumped to it after the first paint.
   */
  describe('before it has measured itself', () => {
    /** The server's HTML for a split, in a host of the same size as `Sample`. */
    function serverRendered(tree: React.ReactElement) {
      const host = document.createElement('div');

      host.style.width = '408px';
      host.style.height = '208px';
      host.innerHTML = renderToString(tree);
      document.body.append(host);

      return host;
    }

    const panesIn = (host: HTMLElement) => [...host.querySelectorAll<HTMLElement>('[data-pane]')];

    it('writes a length into the server’s HTML as the pane’s own size', () => {
      const host = serverRendered(
        <Panes>
          <Pane defaultSize="120px" data-pane>
            One
          </Pane>
          <Pane data-pane>Two</Pane>
        </Panes>
      );

      try {
        const [sized, rest] = panesIn(host);

        expect(sized.style.flexBasis).toBe('120px');
        // What is left over, shared by the panes with no size of their own.
        expect(rest.style.flexGrow).toBe('1');
        expect(rest.style.flexBasis).toBe('0%');
      } finally {
        host.remove();
      }
    });

    // Telling a length from a share used to convert it, and converting a `rem`
    // read the root's font size off the page on every render.
    it('reads nothing off the page to tell a length from a share', () => {
      const read = vi.spyOn(window, 'getComputedStyle');

      try {
        const html = renderToString(
          <Panes>
            <Pane defaultSize="15rem">One</Pane>
            <Pane>Two</Pane>
          </Panes>
        );

        expect(html).toContain('15rem');
        expect(read).not.toHaveBeenCalled();
      } finally {
        read.mockRestore();
      }
    });

    // A share needs no measuring, so the server already writes the fraction the
    // measurement would, and the handle already says what it is.
    it('writes a split given in shares exactly as it will be measured', () => {
      const host = serverRendered(
        <Panes>
          <Pane defaultSize={25} data-pane>
            One
          </Pane>
          <Pane data-pane>Two</Pane>
        </Panes>
      );

      try {
        const [sized, rest] = panesIn(host);

        expect(sized.style.flex.replace(/\s+/g, '')).toContain('calc(25%-2px)');
        expect(rest.style.flex.replace(/\s+/g, '')).toContain('calc(75%-6px)');
        expect(host.querySelector('[role="separator"]')).toHaveAttribute('aria-valuenow', '25');
      } finally {
        host.remove();
      }
    });

    /*
     * No stylesheet is loaded, so the two things it would have done are written
     * here instead: the root is a flex row, and a handle is the 8px track its
     * class would have made it. With those, the widths are the layout itself.
     */
    it('measures itself into the split the server drew', async () => {
      const tree = (
        <Panes style={{ display: 'flex', height: '100%' }}>
          <Pane defaultSize="120px" data-pane>
            One
          </Pane>
          <Pane data-pane>Two</Pane>
          <Pane defaultSize={20} data-pane>
            Three
          </Pane>
        </Panes>
      );
      const track = document.createElement('style');

      track.textContent = '[role="separator"] { flex: 0 0 8px; }';
      document.head.append(track);

      const host = serverRendered(tree);
      const widths = () => panesIn(host).map((pane) => Math.round(pane.offsetWidth));
      const painted = widths();
      const onRecoverableError = vi.fn();
      const root = hydrateRoot(host, tree, { onRecoverableError });

      try {
        // 392 to share once the two handles are paid for: 120, a fifth, and the rest.
        expect(painted).toEqual([120, 194, 78]);

        await expect
          .poll(() => host.querySelector('[role="separator"]')?.getAttribute('aria-valuenow'))
          .toBe('31');
        expect(widths()).toEqual(painted);
        expect(onRecoverableError).not.toHaveBeenCalled();
      } finally {
        root.unmount();
        host.remove();
        track.remove();
      }
    });
  });

  describe('nesting', () => {
    it('lays out a split inside a pane', async () => {
      const screen = await render(
        <Sample>
          <Pane>Sidebar</Pane>
          <Pane>
            <Panes orientation="vertical">
              <Pane>Editor</Pane>
              <Pane>Terminal</Pane>
            </Panes>
          </Pane>
        </Sample>
      );

      await expect.poll(() => screen.getByRole('separator').elements()).toHaveLength(2);
      await expect.element(screen.getByText('Terminal')).toBeInTheDocument();
    });
  });
});
