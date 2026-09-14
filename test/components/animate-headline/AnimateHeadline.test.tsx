import { act } from 'react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { AnimateHeadline } from 'neba';

/*
 * The reduced-motion answer, under the test's control. The library keeps one
 * `MediaQueryList` per query and reads its `matches` live, so a stand-in handed
 * out before the first render is the one every render in this file asks.
 */
let reduceMotion = false;
const matchMedia = window.matchMedia.bind(window);

window.matchMedia = (query: string) => {
  const list = matchMedia(query);

  if (!query.includes('prefers-reduced-motion')) {
    return list;
  }

  return new Proxy(list, {
    get(target, key) {
      if (key === 'matches') {
        return reduceMotion;
      }
      const value = Reflect.get(target, key, target);
      return typeof value === 'function' ? value.bind(target) : value;
    }
  });
};

const LINES = [
  <span key="a">Faster</span>,
  <span key="b">Simpler</span>,
  <span key="c">Quieter</span>
];

describe('AnimateHeadline', () => {
  describe('rendering', () => {
    it('says which effect it is running', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">{LINES}</AnimateHeadline>
      );

      expect(screen.getByTestId('headline').element()).toHaveAttribute(
        'data-neba-animation',
        'headline'
      );
    });

    // Every line keeps its space, so the box is as tall as the longest of them
    // from the first frame and never resizes as the reel turns.
    it('keeps every line in the document', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">{LINES}</AnimateHeadline>
      );
      const items = screen
        .getByTestId('headline')
        .element()
        .querySelectorAll('.neba-headline-item');

      expect(items).toHaveLength(3);
    });

    it('marks only one line as showing', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">{LINES}</AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      expect(root.querySelectorAll('[data-state="active"]')).toHaveLength(1);
      expect(root.children[0]).toHaveAttribute('data-state', 'active');
    });

    it('keeps a line’s own class names', async () => {
      const screen = await render(
        <AnimateHeadline data-testid="headline">
          <span className="my-own-class">Faster</span>
        </AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      expect(root.children[0]).toHaveClass('my-own-class');
      expect(root.children[0]).toHaveClass('neba-headline-item');
    });
  });

  /*
   * On the fake clock. The reel turns on a timeout that is set again after every
   * commit, and on a real clock these tests raced it: a line that is showing for
   * forty milliseconds can fall between two reads of a poll that looks every
   * fifty, so "comes back to the first line" could miss the third line on any
   * run. With one step at a time there is exactly one line to find after each.
   *
   * That next timeout is set by an effect once the turn has committed, so moving
   * the clock the moment the new line is on screen can move it before the
   * timeout exists: WebKit showed the line and ran the effect far enough apart
   * that the reel stopped on the third line. So the clock moves inside `act`,
   * which finishes the render and its effects before it returns, and each turn
   * is read straight off the DOM afterwards.
   */
  describe('turning', () => {
    const step = 60_000;

    /** Moves the fake clock and lets React finish everything that moved it. */
    const elapse = async (ms: number) => {
      // What tells React this is a test that drives `act` itself. The render
      // helper sets it only around its own calls and clears it after them.
      const scope = globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean };

      scope.IS_REACT_ACT_ENVIRONMENT = true;

      try {
        await act(() => vi.advanceTimersByTimeAsync(ms));
      } finally {
        scope.IS_REACT_ACT_ENVIRONMENT = false;
      }
    };

    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    /** Which line is showing, by position. */
    const showing = (root: Element) =>
      [...root.children].findIndex((line) => line.getAttribute('data-state') === 'active');

    it('starts on the line it was given', async () => {
      const screen = await render(
        <AnimateHeadline defaultIndex={1} data-testid="headline">
          {LINES}
        </AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      expect(root.children[1]).toHaveAttribute('data-state', 'active');
    });

    it('moves on after the interval, and not before', async () => {
      const onIndexChange = vi.fn();
      const screen = await render(
        <AnimateHeadline
          interval={step}
          duration={20}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      await elapse(step - 1);
      expect(showing(root)).toBe(0);
      expect(onIndexChange).not.toHaveBeenCalled();

      await elapse(1);
      expect(showing(root)).toBe(1);

      expect(onIndexChange).toHaveBeenCalledWith(1);
    });

    it('comes back to the first line', async () => {
      const screen = await render(
        <AnimateHeadline interval={step} duration={10} data-testid="headline">
          {LINES}
        </AnimateHeadline>
      );
      const root = screen.getByTestId('headline').element();

      for (const line of [1, 2, 0]) {
        await elapse(step);
        expect(showing(root)).toBe(line);
      }
    });

    /*
     * One call covering several intervals is enough for the two tests below. A
     * turn that should not happen would be the first timeout to fire, and that
     * one is already set when the clock moves.
     */
    it('stops on the last line when loop is off', async () => {
      const onIndexChange = vi.fn();
      const screen = await render(
        <AnimateHeadline
          loop={false}
          defaultIndex={2}
          interval={step}
          duration={10}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      await elapse(step * 3);

      expect(onIndexChange).not.toHaveBeenCalled();
      expect(screen.getByTestId('headline').element().children[2]).toHaveAttribute(
        'data-state',
        'active'
      );
    });

    it('stays on its line when the reader asked for less motion', async () => {
      reduceMotion = true;

      try {
        const onIndexChange = vi.fn();
        const screen = await render(
          <AnimateHeadline interval={step} onIndexChange={onIndexChange} data-testid="headline">
            {LINES}
          </AnimateHeadline>
        );

        await elapse(step * 3);

        expect(showing(screen.getByTestId('headline').element())).toBe(0);
        expect(onIndexChange).not.toHaveBeenCalled();
      } finally {
        reduceMotion = false;
      }
    });

    // A controlled Headline is somebody else's timer; a second one running
    // underneath it would fight for the same state.
    it('does not turn itself when it is handed an index', async () => {
      const onIndexChange = vi.fn();
      const screen = await render(
        <AnimateHeadline
          index={0}
          interval={step}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      await elapse(step * 3);

      expect(onIndexChange).not.toHaveBeenCalled();

      await screen.rerender(
        <AnimateHeadline
          index={2}
          interval={step}
          onIndexChange={onIndexChange}
          data-testid="headline"
        >
          {LINES}
        </AnimateHeadline>
      );

      expect(screen.getByTestId('headline').element().children[2]).toHaveAttribute(
        'data-state',
        'active'
      );
    });
  });

  // Its root was a `<div>`, which inside a `<p>` is invalid markup that React
  // reports as a hydration error, and there was no `render` to make it a heading.
  describe('its element', () => {
    it('draws no block element, so it can sit inside a paragraph', () => {
      const html = renderToString(
        <p>
          <AnimateHeadline>
            <span>Fast</span>
            <span>Calm</span>
          </AnimateHeadline>
        </p>
      );

      expect(html).not.toContain('<div');
    });

    it('renders the element it is handed', async () => {
      const screen = await render(
        <AnimateHeadline render={<h2 />} data-testid="root">
          <span>Fast</span>
          <span>Calm</span>
        </AnimateHeadline>
      );

      expect(screen.getByTestId('root').element().tagName).toBe('H2');
    });
  });
});
