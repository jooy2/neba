import { createRef } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { hydrateRoot } from 'react-dom/client';
import { render } from 'vitest-browser-react';
import { ScrollZone } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

/*
 * No component test loads CSS, and a scroller with no `overflow` cannot be
 * scrolled — so nothing here asserts a scroll offset. What is observable is
 * every decision that leads to one: the track's own layout, which is written
 * inline because `lines` is a number the caller picked; how far the component
 * asks to be scrolled, read off a spy on the element's own `scrollBy`; and
 * whether it thinks there is anywhere left to go, which it works out from
 * `scrollWidth` — a measurement the browser makes whether or not the box clips.
 *
 * The children are given widths so the strip genuinely overflows the page.
 */
const cards = Array.from({ length: 6 }, (_, index) => (
  <div key={index} style={{ width: 300 }}>
    Card {index + 1}
  </div>
));

/** The scrolling box: the named group, wherever the buttons have put it. */
function scroller(screen: Awaited<ReturnType<typeof render>>) {
  return screen
    .getByTestId('zone')
    .element()
    .querySelector<HTMLElement>(':scope > [role="group"]') as HTMLElement;
}

/** And the grid inside it. */
function track(screen: Awaited<ReturnType<typeof render>>) {
  return scroller(screen).firstElementChild as HTMLElement;
}

describe('ScrollZone', () => {
  describe('rendering', () => {
    it('renders every child', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);

      await expect.element(screen.getByText('Card 1')).toBeInTheDocument();
      await expect.element(screen.getByText('Card 6')).toBeInTheDocument();
    });

    it('lays the children out in one line running across', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);

      expect(track(screen).style.gridAutoFlow).toBe('column');
      expect(track(screen).style.gridTemplateRows).toBe('repeat(1, auto)');
    });

    it('takes a second line', async () => {
      const screen = await render(
        <ScrollZone lines={2} data-testid="zone">
          {cards}
        </ScrollZone>
      );

      expect(track(screen).style.gridTemplateRows).toBe('repeat(2, auto)');
    });

    it('turns the layout on its side when it runs down the page', async () => {
      const screen = await render(
        <ScrollZone orientation="vertical" lines={3} data-testid="zone">
          {cards}
        </ScrollZone>
      );

      expect(track(screen).style.gridAutoFlow).toBe('row');
      expect(track(screen).style.gridTemplateColumns).toBe('repeat(3, minmax(0px, 1fr))');
    });

    it('writes spacing as a length on Tailwind’s own scale', async () => {
      const screen = await render(
        <ScrollZone spacing={6} data-testid="zone">
          {cards}
        </ScrollZone>
      );

      expect(track(screen).style.gap).toBe('1.5rem');
    });

    it('names the scrollable region', async () => {
      const screen = await render(
        <ScrollZone label="Categories" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      await expect.element(screen.getByRole('group', { name: 'Categories' })).toBeInTheDocument();
    });

    it('leaves the strip reachable from the keyboard', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);

      await expect.poll(() => scroller(screen).getAttribute('tabindex')).toBe('0');
    });

    // A row of chips that fits was a tab stop that did nothing.
    it('keeps a strip that fits out of the tab order', async () => {
      const screen = await render(
        <ScrollZone data-testid="zone">
          <div style={{ width: 20 }}>One</div>
        </ScrollZone>
      );

      await expect.element(screen.getByRole('group')).toHaveAttribute('tabindex', '-1');
    });

    // The strip has to be a tab stop or a reader with no pointer cannot move
    // it, and a tab stop with no name announces nothing at all when the focus
    // lands on it.
    it('still says what it is when it was given no label', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);

      await expect
        .element(screen.getByRole('group', { name: 'Scrollable content' }))
        .toBeInTheDocument();
    });

    it('reflects a changed set of children on re-render', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);

      await screen.rerender(
        <ScrollZone data-testid="zone">
          <div>Only</div>
        </ScrollZone>
      );

      await expect.element(screen.getByText('Only')).toBeInTheDocument();
      expect(screen.getByText('Card 1').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own, and forwards the rest', async () => {
      const screen = await render(
        <ScrollZone className="my-own-class" id="shelf" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      expect(screen.getByTestId('zone').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('zone').element()).toHaveAttribute('id', 'shelf');
    });

    it('hands the scrolling box to scrollerRef and keeps ref on the root', async () => {
      const ref = createRef<HTMLDivElement>();
      const scrollerRef = createRef<HTMLDivElement>();
      const screen = await render(
        <ScrollZone ref={ref} scrollerRef={scrollerRef} data-testid="zone">
          {cards}
        </ScrollZone>
      );

      expect(ref.current).toBe(screen.getByTestId('zone').element());
      expect(scrollerRef.current).toBe(scroller(screen));
    });

    // A scroll does not bubble, so an `onScroll` passed through to the root never
    // heard the box inside it scroll.
    it('calls onScroll when the strip scrolls', async () => {
      const onScroll = vi.fn();
      const screen = await render(
        <ScrollZone onScroll={onScroll} data-testid="zone">
          {cards}
        </ScrollZone>
      );

      scroller(screen).dispatchEvent(new Event('scroll'));

      await expect.poll(() => onScroll.mock.calls.length).toBe(1);
    });
  });

  describe('the buttons', () => {
    // Overlaid, the absence costs nothing, so `auto` takes the button away
    // outright rather than disabling it.
    it('offers only the overlaid one that has somewhere to go', async () => {
      const screen = await render(
        <ScrollZone buttonPlacement="overlay" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Scroll forward' }))
        .toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Scroll back' }).query()).toBeNull();
    });

    it('draws both from the first paint when it is told to', async () => {
      const screen = await render(
        <ScrollZone buttons="always" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Scroll back' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('button', { name: 'Scroll forward' }))
        .not.toHaveAttribute('aria-disabled', 'true');
    });

    // Pressing it is what runs it out, and a button that is taken away or made
    // `disabled` under the focus drops the focus onto the document.
    it('keeps the focus on an overlaid button that runs out, until the focus leaves', async () => {
      const screen = await render(
        <ScrollZone buttonPlacement="overlay" data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const forward = screen.getByRole('button', { name: 'Scroll forward' });

      (forward.element() as HTMLElement).focus();
      // The one place a scroll is needed: without a stylesheet the strip does not
      // clip, so it is given the overflow its class would have given it.
      const strip = scroller(screen);
      strip.style.overflowX = 'auto';
      strip.scrollLeft = strip.scrollWidth;

      await expect.element(forward).toHaveAttribute('aria-disabled', 'true');
      await expect.element(forward).toHaveFocus();

      strip.focus();

      await expect
        .element(screen.getByRole('button', { name: 'Scroll forward' }))
        .not.toBeInTheDocument();
    });

    it('draws none at all when it is told to', async () => {
      const screen = await render(
        <ScrollZone buttons="none" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      await expect.element(screen.getByText('Card 1')).toBeInTheDocument();
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('draws neither while everything fits', async () => {
      const screen = await render(
        <ScrollZone data-testid="zone">
          <div>Alone</div>
        </ScrollZone>
      );

      await expect.element(screen.getByText('Alone')).toBeInTheDocument();
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('names itself in the language it was given', async () => {
      const screen = await render(
        <ScrollZone locale="ko" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      await expect
        .element(screen.getByRole('button', { name: '앞으로 스크롤' }))
        .toBeInTheDocument();
    });

    it('takes names of its own', async () => {
      const screen = await render(
        <ScrollZone buttons="always" previousLabel="Earlier" nextLabel="Later" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      await expect.element(screen.getByRole('button', { name: 'Later' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Earlier' })).toBeInTheDocument();
    });
  });

  describe('where the buttons sit', () => {
    // Overlaid, the strip keeps every pixel of its box and an item passes under
    // a button. Inline, the scroller stops where the button starts, so an item
    // is cut off at its edge rather than half-hidden behind it.
    it('puts them beside the strip by default', async () => {
      const screen = await render(
        <ScrollZone buttons="always" data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const root = screen.getByTestId('zone').element();

      await expect
        .element(screen.getByRole('button', { name: 'Scroll forward' }))
        .toBeInTheDocument();
      // A lane either side of the scroller, and the scroller between them.
      expect(root.children).toHaveLength(3);
      expect(root.children[1]).toBe(scroller(screen));
      expect(
        root.children[2].contains(screen.getByRole('button', { name: 'Scroll forward' }).element())
      ).toBe(true);
    });

    it('overlays them when it is asked to', async () => {
      const screen = await render(
        <ScrollZone buttonPlacement="overlay" data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const root = screen.getByTestId('zone').element();

      await expect
        .element(screen.getByRole('button', { name: 'Scroll forward' }))
        .toBeInTheDocument();
      // The scroller and the overlay the buttons are in, and nothing else.
      expect(root.children).toHaveLength(2);
      expect(root.children[1]).toHaveClass('absolute');
    });

    // A lane that came and went would resize the strip under the pointer that
    // had just reached the end of it, so it is held open either way — and a lane
    // that is paid for is one the button stays in, disabled, rather than one that
    // reads as stray padding at the edge every reader meets first.
    it('disables an inline button with nowhere to go rather than emptying its lane', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);
      const root = screen.getByTestId('zone').element();

      await expect
        .element(screen.getByRole('button', { name: 'Scroll back' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('button', { name: 'Scroll forward' }))
        .not.toHaveAttribute('aria-disabled', 'true');
      // A lane either side, and nothing invisible or `inert` in either of them.
      expect(root.children).toHaveLength(3);
      expect(root.children[0]).not.toHaveClass('invisible');
      expect(root.children[0]).not.toHaveAttribute('inert');
    });

    it('runs the strip down the page with the buttons above and below it', async () => {
      const screen = await render(
        <ScrollZone orientation="vertical" buttons="always" data-testid="zone">
          {cards}
        </ScrollZone>
      );

      expect(screen.getByTestId('zone').element()).toHaveClass('flex-col');
      expect(screen.getByTestId('zone').element().children).toHaveLength(3);
    });
  });

  /*
   * The lanes used to arrive from an effect, after the first paint, so every
   * item of a strip that overflowed moved inward by a lane's width and a row of
   * short chips grew to a button's height.
   */
  describe('before it has measured itself', () => {
    /** The server's HTML for a zone, on the page. */
    function serverRendered(tree: React.ReactElement) {
      const host = document.createElement('div');

      host.innerHTML = renderToString(tree);
      document.body.append(host);

      return host;
    }

    const named = (host: HTMLElement, name: string) =>
      host.querySelector<HTMLElement>(`button[aria-label="${name}"]`);

    it('holds both inline lanes open in the server’s HTML, with nothing visible in them', () => {
      const host = serverRendered(<ScrollZone>{cards}</ScrollZone>);

      try {
        const root = host.firstElementChild as HTMLElement;

        expect(root.children).toHaveLength(3);

        for (const name of ['Scroll back', 'Scroll forward']) {
          expect(getComputedStyle(named(host, name) as HTMLElement).visibility).toBe('hidden');
        }
      } finally {
        host.remove();
      }
    });

    it('shows the buttons in the lanes it already held once the strip overflows', async () => {
      const tree = <ScrollZone>{cards}</ScrollZone>;
      const host = serverRendered(tree);
      const lane = host.firstElementChild?.firstElementChild;
      const onRecoverableError = vi.fn();
      const root = hydrateRoot(host, tree, { onRecoverableError });

      try {
        await expect
          .poll(() => getComputedStyle(named(host, 'Scroll forward') as HTMLElement).visibility)
          .toBe('visible');
        // The lane the server drew, kept rather than drawn again.
        expect(host.firstElementChild?.firstElementChild).toBe(lane);
        expect(named(host, 'Scroll back')).toHaveAttribute('aria-disabled', 'true');
        expect(named(host, 'Scroll forward')).not.toHaveAttribute('aria-disabled', 'true');
        expect(onRecoverableError).not.toHaveBeenCalled();
      } finally {
        root.unmount();
        host.remove();
      }
    });

    it('gives the lanes back when the strip fits', async () => {
      const tree = (
        <ScrollZone>
          <div>Alone</div>
        </ScrollZone>
      );
      const host = serverRendered(tree);
      const root = hydrateRoot(host, tree);

      try {
        await expect.poll(() => host.firstElementChild?.children.length).toBe(1);
        expect(host.querySelector('button')).toBeNull();
      } finally {
        root.unmount();
        host.remove();
      }
    });

    /*
     * The first measurement is taken with the lanes in place, and a strip that
     * fits the zone but not the room left between two lanes was kept as a
     * scroller. No stylesheet is loaded here, so what it would have done to the
     * root, the lanes and the scroller is written into the page instead.
     */
    describe('measured against the room the lanes would give back', () => {
      function withLayout() {
        const sheet = document.createElement('style');

        sheet.textContent = [
          '[data-testid="zone"] { display: flex; width: 400px; column-gap: 8px; }',
          '[data-testid="zone"] > span { flex: 0 0 40px; }',
          '[data-testid="zone"] > [role="group"] { flex: 1 1 auto; min-width: 0; overflow-x: auto; }'
        ].join('\n');
        document.head.append(sheet);

        return sheet;
      }

      it('draws no buttons for a strip that fits only without them', async () => {
        const sheet = withLayout();

        try {
          // 380 is wider than the 304 left between two lanes, and narrower than 400.
          const screen = await render(
            <ScrollZone data-testid="zone">
              <div style={{ width: 380 }}>Wide</div>
            </ScrollZone>
          );

          await expect.element(screen.getByText('Wide')).toBeInTheDocument();
          expect(screen.getByRole('button').query()).toBeNull();
          expect(screen.getByTestId('zone').element().children).toHaveLength(1);
        } finally {
          sheet.remove();
        }
      });

      it('keeps them for a strip wider than the zone', async () => {
        const sheet = withLayout();

        try {
          const screen = await render(
            <ScrollZone data-testid="zone">
              <div style={{ width: 600 }}>Wider</div>
            </ScrollZone>
          );

          await expect
            .element(screen.getByRole('button', { name: 'Scroll forward' }))
            .not.toHaveAttribute('aria-disabled', 'true');
          expect(screen.getByTestId('zone').element().children).toHaveLength(3);
        } finally {
          sheet.remove();
        }
      });
    });
  });

  describe('pressing one', () => {
    it('moves to the next child along', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      await screen.getByRole('button', { name: 'Scroll forward' }).click();

      // The second card starts 300px plus the default gutter along, and that is
      // the offset the component measured rather than one it assumed.
      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 308 }));
    });

    it('moves by more than one when it is asked to', async () => {
      const screen = await render(
        <ScrollZone step={2} data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const scrollBy = vi.spyOn(scroller(screen), 'scrollBy');

      await screen.getByRole('button', { name: 'Scroll forward' }).click();

      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 616 }));
    });

    it('moves by everything on screen in page mode', async () => {
      const screen = await render(
        <ScrollZone mode="page" data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      await screen.getByRole('button', { name: 'Scroll forward' }).click();

      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: box.clientWidth }));
    });

    it('still moves on a tap in hold mode, rather than doing nothing', async () => {
      const screen = await render(
        <ScrollZone mode="hold" data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const scrollBy = vi.spyOn(scroller(screen), 'scrollBy');

      await screen.getByRole('button', { name: 'Scroll forward' }).click();

      await expect.poll(() => scrollBy.mock.calls.length).toBeGreaterThan(0);
    });
  });

  /*
   * A wheel is dispatched rather than rolled: `page.mouse.wheel` scrolls the
   * frame, and what is being asserted is what the component did with the event
   * — whether it took it, and how far it asked the strip to go.
   */
  describe('the wheel', () => {
    function roll(box: HTMLElement, init: WheelEventInit) {
      const event = new WheelEvent('wheel', { bubbles: true, cancelable: true, ...init });
      box.dispatchEvent(event);

      return event;
    }

    it('leaves it to the page unless it is asked for it', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      expect(roll(box, { deltaY: 120 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });

    it('turns a wheel rolled down the page into travel along the strip', async () => {
      const screen = await render(
        <ScrollZone wheel data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      expect(roll(box, { deltaY: 120 }).defaultPrevented).toBe(true);
      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 120 }));
    });

    it('counts a notch measured in lines as lines', async () => {
      const screen = await render(
        <ScrollZone wheel data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      roll(box, { deltaY: 3, deltaMode: 1 });

      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 48 }));
    });

    // The strip is at its start, so there is nothing behind it — and the page
    // still does not get the wheel, because the pointer is inside the strip.
    it('holds the wheel at the end of the strip', async () => {
      const screen = await render(
        <ScrollZone wheel data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);

      expect(roll(box, { deltaY: -120 }).defaultPrevented).toBe(true);
    });

    // Which is what makes the hold safe: a strip with room to spare is not a
    // scroll container as far as the reader is concerned, and holding the page
    // there would be holding it for nothing.
    it('holds nothing on a strip that fits', async () => {
      const screen = await render(
        <ScrollZone wheel data-testid="zone">
          <div style={{ width: 20 }}>One</div>
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      expect(roll(box, { deltaY: 120 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });

    // A strip inside a strip, or a NumberField being scrubbed on one. The event
    // bubbles out to the outer handler either way.
    it('leaves a notch something nearer the pointer has already answered', async () => {
      const screen = await render(
        <ScrollZone wheel data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');
      const event = new WheelEvent('wheel', { bubbles: true, cancelable: true, deltaY: 120 });

      event.preventDefault();
      box.dispatchEvent(event);

      expect(scrollBy).not.toHaveBeenCalled();
    });

    it('leaves a sideways wheel to the browser, which already scrolls the strip', async () => {
      const screen = await render(
        <ScrollZone wheel data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      expect(roll(box, { deltaX: 120, deltaY: 4 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });

    it('ignores the prop on a strip that already runs the way the wheel points', async () => {
      const screen = await render(
        <ScrollZone orientation="vertical" wheel data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      expect(roll(box, { deltaY: 120 }).defaultPrevented).toBe(false);
      expect(scrollBy).not.toHaveBeenCalled();
    });
  });

  describe('dragging', () => {
    // A mandatory snap answers every offset a drag writes by jumping to the
    // nearest card, so the strip stepped under the pointer instead of following
    // it.
    it('holds a snap off while the strip is dragged, and hands it back after', async () => {
      const screen = await render(
        <ScrollZone snap data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      // A synthetic press cannot capture a pointer the browser has no record of,
      // and capturing one is not what is being tested.
      box.setPointerCapture = () => {};

      box.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          button: 0,
          pointerId: 1,
          pointerType: 'mouse',
          clientX: 400,
          clientY: 20
        })
      );
      box.dispatchEvent(
        new PointerEvent('pointermove', {
          bubbles: true,
          buttons: 1,
          pointerId: 1,
          pointerType: 'mouse',
          clientX: 300,
          clientY: 20
        })
      );

      expect(box.style.scrollSnapType).toBe('none');

      box.dispatchEvent(new PointerEvent('pointerup', { bubbles: true, pointerId: 1 }));

      expect(box.style.scrollSnapType).toBe('');
    });

    // The pointer's travel was written to the strip as it came, so inside a
    // scaled ancestor the cards ran ahead of the hand.
    it('keeps the content under the pointer inside a scaled ancestor', async () => {
      const screen = await render(
        <div style={{ scale: '0.5', transformOrigin: 'top left' }}>
          <ScrollZone data-testid="zone">{cards}</ScrollZone>
        </div>
      );
      const box = scroller(screen);
      box.setPointerCapture = () => {};
      // What the stylesheet gives the strip, which no component test loads.
      box.style.overflowX = 'auto';

      await expect.poll(() => box.scrollWidth > box.clientWidth + 100).toBe(true);

      const press = (type: string, clientX: number) =>
        box.dispatchEvent(
          new PointerEvent(type, {
            bubbles: true,
            button: 0,
            buttons: type === 'pointerup' ? 0 : 1,
            pointerId: 1,
            pointerType: 'mouse',
            clientX,
            clientY: 10
          })
        );

      press('pointerdown', 200);
      press('pointermove', 150);

      // Fifty pixels on the screen at half size is a hundred of the strip's own.
      expect(box.scrollLeft).toBe(100);

      press('pointerup', 150);
    });

    // The press is let go outside the strip before it has moved far enough to
    // be a drag, so its pointerup never reaches the strip.
    it('lets a press go that was released outside the strip', async () => {
      const screen = await render(
        <ScrollZone snap data-testid="zone">
          {cards}
        </ScrollZone>
      );
      const box = scroller(screen);
      box.setPointerCapture = () => {};

      box.dispatchEvent(
        new PointerEvent('pointerdown', {
          bubbles: true,
          button: 0,
          pointerId: 1,
          pointerType: 'mouse',
          clientX: 400,
          clientY: 20
        })
      );
      document.body.dispatchEvent(new PointerEvent('pointerup', { bubbles: true, pointerId: 1 }));

      // A later hover over the strip, with no button held.
      box.dispatchEvent(
        new PointerEvent('pointermove', {
          bubbles: true,
          buttons: 0,
          pointerId: 1,
          pointerType: 'mouse',
          clientX: 300,
          clientY: 20
        })
      );
      box.dispatchEvent(
        new PointerEvent('pointermove', {
          bubbles: true,
          buttons: 0,
          pointerId: 1,
          pointerType: 'mouse',
          clientX: 200,
          clientY: 20
        })
      );

      expect(box.dataset.dragging).toBeUndefined();
      expect(box.style.scrollSnapType).toBe('');
      expect(document.body.style.getPropertyValue('-webkit-user-select')).toBe('');
    });
  });
});
