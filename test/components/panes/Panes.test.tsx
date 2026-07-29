import { describe, expect, it, vi } from 'vitest';
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
