import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { userEvent } from 'vitest/browser';
import { WindowPane } from 'neba';

/** The names of the title bar's buttons, in the order they are drawn. */
function controlNames(screen: Awaited<ReturnType<typeof render>>) {
  return screen
    .getByRole('button')
    .elements()
    .map((button) => button.getAttribute('aria-label'));
}

/** One inline custom property off the root. */
function slot(screen: Awaited<ReturnType<typeof render>>, name: string) {
  return (screen.getByTestId('window').element() as HTMLElement).style.getPropertyValue(name);
}

describe('WindowPane', () => {
  describe('rendering', () => {
    it('renders its title and whatever is in it', async () => {
      const screen = await render(
        <WindowPane title="Finder" data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await expect.element(screen.getByText('Finder')).toBeInTheDocument();
      await expect.element(screen.getByText('Body')).toBeInTheDocument();
    });

    it('names the window after its title', async () => {
      const screen = await render(
        <WindowPane title="Finder" data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await expect.element(screen.getByRole('group', { name: 'Finder' })).toBeInTheDocument();
    });

    it('puts the controls where macOS puts them', async () => {
      const screen = await render(<WindowPane title="Finder" data-testid="window" />);

      expect(controlNames(screen)).toEqual(['Close', 'Minimize', 'Maximize']);
    });

    it('puts them where Windows puts them instead', async () => {
      const screen = await render(
        <WindowPane os="windows11" title="Explorer" data-testid="window" />
      );

      expect(controlNames(screen)).toEqual(['Minimize', 'Maximize', 'Close']);
    });

    it('draws only the buttons it was asked for', async () => {
      const screen = await render(
        <WindowPane controls={['close']} title="Finder" data-testid="window" />
      );

      expect(controlNames(screen)).toEqual(['Close']);
    });

    it('draws none at all when it is told to', async () => {
      const screen = await render(
        <WindowPane controls={false} title="Finder" data-testid="window" />
      );

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('names its buttons in the language it was given', async () => {
      const screen = await render(<WindowPane locale="ko" title="Finder" data-testid="window" />);

      await expect.element(screen.getByRole('button', { name: '최소화' })).toBeInTheDocument();
    });

    it('takes names of its own', async () => {
      const screen = await render(
        <WindowPane closeLabel="Quit" title="Finder" data-testid="window" />
      );

      await expect.element(screen.getByRole('button', { name: 'Quit' })).toBeInTheDocument();
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(<WindowPane title="Before" data-testid="window" />);

      await screen.rerender(<WindowPane title="After" data-testid="window" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own, and forwards the rest', async () => {
      const screen = await render(
        <WindowPane className="my-own-class" id="editor" title="Finder" data-testid="window" />
      );

      expect(screen.getByTestId('window').element()).toHaveClass('my-own-class', 'neba-window');
      expect(screen.getByTestId('window').element()).toHaveAttribute('id', 'editor');
    });
  });

  describe('the three buttons', () => {
    it('closes an uncontrolled window', async () => {
      const screen = await render(
        <WindowPane title="Finder" data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.poll(() => screen.getByText('Body').query()).toBeNull();
    });

    // A window that is simply dropped from the tree does not leave, it stops
    // existing — so it fades, unpressable, and is let go afterwards.
    it('lets a closed window leave before it goes', async () => {
      const screen = await render(
        <WindowPane title="Finder" data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      const root = screen.getByTestId('window').query() as HTMLElement | null;
      if (root) {
        expect(root.style.opacity).toBe('0');
        expect(root).toHaveAttribute('inert');
      }

      await expect.poll(() => screen.getByTestId('window').query()).toBeNull();
    });

    it('leaves a controlled window open and reports the press', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <WindowPane open title="Finder" onOpenChange={onOpenChange} data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
      await expect.element(screen.getByText('Body')).toBeInTheDocument();
    });

    // A page has no dock to send a window to, so minimizing rolls it up to its
    // title bar and leaves it where it was. The body stays in the tree — that is
    // what the roll-up travels over — and is made inert rather than unmounted,
    // so nothing inside it is focusable while it cannot be seen.
    it('rolls the window up to its title bar', async () => {
      const screen = await render(
        <WindowPane title="Finder" height={200} data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      const root = screen.getByTestId('window').element() as HTMLElement;
      const bar = screen.getByText('Finder').element().closest('div') as HTMLElement;

      await screen.getByRole('button', { name: 'Minimize' }).click();

      await expect.poll(() => screen.getByText('Body').element().closest('[inert]')).not.toBeNull();
      await expect.poll(() => root.style.height).not.toBe('200px');
      expect(Number.parseFloat(root.style.height)).toBeGreaterThanOrEqual(bar.offsetHeight);
      await expect.element(screen.getByText('Finder')).toBeInTheDocument();
    });

    it('unrolls it again, and gives the body back', async () => {
      const screen = await render(
        <WindowPane title="Finder" height={200} data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await screen.getByRole('button', { name: 'Minimize' }).click();
      await expect.poll(() => screen.getByText('Body').element().closest('[inert]')).not.toBeNull();

      await screen.getByRole('button', { name: 'Minimize' }).click();

      await expect.poll(() => screen.getByText('Body').element().closest('[inert]')).toBeNull();
      await expect
        .poll(() => (screen.getByTestId('window').element() as HTMLElement).style.height)
        .toBe('200px');
    });

    it('fills what is holding it when it is maximized, and says so on the button', async () => {
      const screen = await render(
        <WindowPane title="Finder" width={320} data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      await screen.getByRole('button', { name: 'Maximize' }).click();

      await expect.element(screen.getByRole('button', { name: 'Restore' })).toBeInTheDocument();
      expect((screen.getByTestId('window').element() as HTMLElement).style.width).toBe('100%');
    });

    it('maximizes on a double click of the title bar', async () => {
      const onMaximizedChange = vi.fn();
      const screen = await render(
        <WindowPane title="Finder" onMaximizedChange={onMaximizedChange} data-testid="window" />
      );

      await screen.getByText('Finder').dblClick();

      expect(onMaximizedChange).toHaveBeenCalledWith(true);
    });

    it('reports a maximize a caller is driving without acting on it', async () => {
      const onMaximizedChange = vi.fn();
      const screen = await render(
        <WindowPane
          title="Finder"
          maximized={false}
          onMaximizedChange={onMaximizedChange}
          width={320}
          data-testid="window"
        />
      );

      await screen.getByRole('button', { name: 'Maximize' }).click();

      expect(onMaximizedChange).toHaveBeenCalledWith(true);
      expect((screen.getByTestId('window').element() as HTMLElement).style.width).toBe('320px');
    });
  });

  describe('the chrome', () => {
    it('dyes the title bar with the colour family when it is asked to', async () => {
      const screen = await render(
        <WindowPane accent color="info" title="Finder" data-testid="window" />
      );

      expect(slot(screen, '--n-window-bar')).toBe('var(--neba-info-solid)');
      expect(slot(screen, '--n-window-bar-fg')).toBe('var(--neba-info-on-solid)');
    });

    it('quietens an inactive window rather than fading it', async () => {
      const screen = await render(
        <WindowPane accent active={false} title="Finder" data-testid="window" />
      );

      expect(slot(screen, '--n-window-bar')).not.toContain('solid');
      expect(slot(screen, '--n-window-bar-fg')).toBe('var(--neba-muted-fg)');
      expect((screen.getByTestId('window').element() as HTMLElement).style.opacity).toBe('');
    });

    it('lets the page through the chrome, and turns the acrylic on with it', async () => {
      const screen = await render(
        <WindowPane transparency={0.4} title="Finder" data-testid="window" />
      );

      expect(slot(screen, '--n-window-body')).toBe(
        'color-mix(in oklab, var(--neba-surface) 60%, transparent)'
      );
      expect(screen.getByTestId('window').element()).toHaveClass(
        '[backdrop-filter:var(--neba-blur)]'
      );
    });

    it('leaves an opaque window with nothing to blur', async () => {
      const screen = await render(<WindowPane title="Finder" data-testid="window" />);

      expect(slot(screen, '--n-window-body')).toBe('var(--neba-surface)');
      expect(screen.getByTestId('window').element()).not.toHaveClass(
        '[backdrop-filter:var(--neba-blur)]'
      );
    });

    it('drops the shadow when it is told to', async () => {
      const screen = await render(<WindowPane elevation={0} title="Finder" data-testid="window" />);

      expect(slot(screen, '--n-window-shadow')).toBe('var(--neba-shadow-0)');
    });

    // Being in front is a step of elevation rather than a ring: none of the four
    // systems draws an outline around the window you are using.
    it('sits a step further off the page while it is in front', async () => {
      const screen = await render(<WindowPane elevation={2} title="Finder" data-testid="window" />);

      expect(slot(screen, '--n-window-shadow')).toBe('var(--neba-shadow-2)');

      await screen.rerender(
        <WindowPane elevation={2} active={false} title="Finder" data-testid="window" />
      );

      expect(slot(screen, '--n-window-shadow')).toBe('var(--neba-shadow-1)');
    });
  });

  describe('which window is in front', () => {
    it('starts in front, so a page with one window on it is not greyed out', async () => {
      const screen = await render(<WindowPane title="Finder" data-testid="window" />);

      expect(slot(screen, '--n-window-bar-fg')).toBe('var(--neba-fg)');
    });

    it('steps back when another window is pressed', async () => {
      const screen = await render(
        <>
          <WindowPane title="One" data-testid="window" />
          <WindowPane title="Two" data-testid="other" />
        </>
      );

      screen
        .getByTestId('other')
        .element()
        .dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));

      await expect.poll(() => slot(screen, '--n-window-bar-fg')).toBe('var(--neba-muted-fg)');
    });

    it('comes back to the front when it is pressed itself', async () => {
      const screen = await render(
        <>
          <WindowPane title="One" data-testid="window" />
          <WindowPane title="Two" data-testid="other" />
        </>
      );

      const one = screen.getByTestId('window').element();
      const other = screen.getByTestId('other').element();

      other.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));
      await expect.poll(() => slot(screen, '--n-window-bar-fg')).toBe('var(--neba-muted-fg)');

      one.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));
      await expect.poll(() => slot(screen, '--n-window-bar-fg')).toBe('var(--neba-fg)');
    });

    // A paragraph is not a desktop: pressing the page around a window is not the
    // same as pressing away from it.
    it('stays in front when the page around it is pressed', async () => {
      const screen = await render(
        <>
          <WindowPane title="One" data-testid="window" />
          <p data-testid="prose">Somewhere else entirely</p>
        </>
      );

      screen
        .getByTestId('prose')
        .element()
        .dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));

      await expect.poll(() => slot(screen, '--n-window-bar-fg')).toBe('var(--neba-fg)');
    });

    it('leaves it alone when the caller is driving it', async () => {
      const screen = await render(
        <>
          <WindowPane title="One" active data-testid="window" />
          <WindowPane title="Two" data-testid="other" />
        </>
      );

      screen
        .getByTestId('other')
        .element()
        .dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));

      await expect.poll(() => slot(screen, '--n-window-bar-fg')).toBe('var(--neba-fg)');
    });
  });

  describe('where it sits', () => {
    it('stays in the flow by default, and is moved by its offset', async () => {
      const screen = await render(
        <WindowPane title="Finder" offset={{ x: 24, y: 12 }} data-testid="window" />
      );

      const root = screen.getByTestId('window').element() as HTMLElement;

      expect(root.style.position).toBe('relative');
      expect(root.style.left).toBe('24px');
      expect(root.style.top).toBe('12px');
    });

    it('pins itself to whatever is holding it', async () => {
      const screen = await render(
        <WindowPane title="Finder" position="absolute" data-testid="window" />
      );

      expect((screen.getByTestId('window').element() as HTMLElement).style.position).toBe(
        'absolute'
      );
    });

    it('reports where a drag put it', async () => {
      const onOffsetChange = vi.fn();
      const screen = await render(
        <WindowPane title="Finder" draggable onOffsetChange={onOffsetChange} data-testid="window" />
      );

      const bar = screen.getByText('Finder').element().closest('div') as HTMLElement;
      // A synthetic press cannot capture a pointer the browser has no record of,
      // and capturing one is not what is being tested.
      bar.setPointerCapture = () => {};

      bar.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          button: 0,
          pointerId: 1,
          clientX: 100,
          clientY: 100
        })
      );
      bar.dispatchEvent(
        new PointerEvent('pointermove', {
          bubbles: true,
          pointerId: 1,
          clientX: 140,
          clientY: 130
        })
      );
      bar.dispatchEvent(new PointerEvent('pointerup', { bubbles: true, pointerId: 1 }));

      expect(onOffsetChange).toHaveBeenLastCalledWith({ x: 40, y: 30 });
    });

    it('does not move a window that was not made draggable', async () => {
      const onOffsetChange = vi.fn();
      const screen = await render(
        <WindowPane title="Finder" onOffsetChange={onOffsetChange} data-testid="window" />
      );

      const bar = screen.getByText('Finder').element().closest('div') as HTMLElement;
      bar.setPointerCapture = () => {};

      bar.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          button: 0,
          pointerId: 1,
          clientX: 100,
          clientY: 100
        })
      );
      bar.dispatchEvent(
        new PointerEvent('pointermove', { bubbles: true, pointerId: 1, clientX: 160 })
      );

      expect(onOffsetChange).not.toHaveBeenCalled();
    });
  });

  describe('resizing', () => {
    it('offers no handles until it is made resizable', async () => {
      const screen = await render(<WindowPane title="Finder" data-testid="window" />);

      expect(screen.getByRole('button', { name: 'Resize window' }).query()).toBeNull();
    });

    it('leaves one corner reachable without a pointer', async () => {
      const screen = await render(
        <WindowPane title="Finder" resizable width={320} height={200} data-testid="window">
          <p>Body</p>
        </WindowPane>
      );

      const corner = screen.getByRole('button', { name: 'Resize window' });

      await expect.element(corner).toBeInTheDocument();

      const root = screen.getByTestId('window').element() as HTMLElement;
      // Measured rather than assumed: what a `width` of 320 comes to on the page
      // depends on a box model no component test loads a stylesheet to decide.
      const before = root.getBoundingClientRect().width;

      corner.element().focus();
      await expect.poll(() => document.activeElement).toBe(corner.element());

      await userEvent.keyboard('{ArrowRight}');

      await expect.poll(() => root.style.width).toBe(`${before + 16}px`);
    });

    it('reports the size a drag settled on', async () => {
      const onResize = vi.fn();
      const screen = await render(
        <WindowPane
          title="Finder"
          resizable
          width={320}
          height={200}
          onResize={onResize}
          data-testid="window"
        />
      );

      const root = screen.getByTestId('window').element() as HTMLElement;
      const before = root.getBoundingClientRect();

      const corner = screen.getByRole('button', { name: 'Resize window' }).element() as HTMLElement;
      corner.setPointerCapture = () => {};

      corner.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          button: 0,
          pointerId: 1,
          clientX: 320,
          clientY: 200
        })
      );
      corner.dispatchEvent(
        new PointerEvent('pointermove', {
          bubbles: true,
          pointerId: 1,
          clientX: 380,
          clientY: 240
        })
      );
      corner.dispatchEvent(new PointerEvent('pointerup', { bubbles: true, pointerId: 1 }));

      expect(onResize).toHaveBeenLastCalledWith({
        width: before.width + 60,
        height: before.height + 40
      });
    });

    it('never lets a window be dragged smaller than its own minimum', async () => {
      const onResize = vi.fn();
      const screen = await render(
        <WindowPane
          title="Finder"
          resizable
          width={320}
          height={200}
          minWidth={240}
          onResize={onResize}
          data-testid="window"
        />
      );

      const corner = screen.getByRole('button', { name: 'Resize window' }).element() as HTMLElement;
      corner.setPointerCapture = () => {};

      corner.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          button: 0,
          pointerId: 1,
          clientX: 320,
          clientY: 200
        })
      );
      corner.dispatchEvent(
        new PointerEvent('pointermove', {
          bubbles: true,
          pointerId: 1,
          clientX: 0,
          clientY: 0
        })
      );

      expect(onResize).toHaveBeenLastCalledWith(expect.objectContaining({ width: 240 }));
    });
  });
});
