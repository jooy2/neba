import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { ScrollZone } from 'neba';

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

/** The scrolling box: the only child of the root. */
function scroller(screen: Awaited<ReturnType<typeof render>>) {
  return screen.getByTestId('zone').element().firstElementChild as HTMLElement;
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

      expect(scroller(screen)).toHaveAttribute('tabindex', '0');
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
  });

  describe('the buttons', () => {
    it('offers the one that has somewhere to go', async () => {
      const screen = await render(<ScrollZone data-testid="zone">{cards}</ScrollZone>);

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

      await expect.element(screen.getByRole('button', { name: 'Scroll back' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Scroll forward' })).toBeEnabled();
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
});
