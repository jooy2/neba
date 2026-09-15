import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateScramble } from 'neba';

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

function shown(root: Element): string {
  return root.querySelector('[aria-hidden="true"]')?.textContent ?? '';
}

/*
 * On the fake clock. The letters settle on a chain of timeouts while an
 * interval redraws the noise, and on a real clock both kinds of test raced it:
 * a short run against a one-second poll, and a long one the other way — a
 * reading of the first frame that a slow runner had already moved past, so a
 * letter had settled and `####` read `A###`. React still commits on a task of
 * its own, so the DOM is waited for after the clock moves.
 */
describe('AnimateScramble', () => {
  // The docs said the box never changed size, and in a proportional font the
  // noise was wider or narrower than the text it settled into.
  it('lays its box out from the final text', async () => {
    const screen = await render(
      <AnimateScramble text="Hello there" trigger="manual" data-testid="scramble" />
    );
    const sample = screen.getByTestId('scramble').element().querySelector('[data-sample]');

    expect(sample).toHaveAttribute('data-sample', 'Hello there');
    expect(sample?.textContent).toBe('');
  });

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // `hover` and `manual` may never be triggered, and noise waiting for them is
  // motion the reader asked not to see.
  it('shows the text itself, untriggered, to a reader who asked for less motion', async () => {
    reduceMotion = true;

    try {
      const screen = await render(<AnimateScramble text="NEBA" trigger="manual" data-testid="s" />);

      expect(shown(screen.getByTestId('s').element())).toBe('NEBA');
    } finally {
      reduceMotion = false;
    }
  });

  it('settles on the text it was given', async () => {
    const screen = await render(<AnimateScramble text="NEBA" duration={80} data-testid="s" />);

    await vi.runAllTimersAsync();

    await expect.poll(() => shown(screen.getByTestId('s').element())).toBe('NEBA');
  });

  /*
   * A minute a letter, and noise that never redraws, because `expect.poll`
   * moves a fake clock on by its own interval each time it retries: with a step
   * that long no retry reaches the next letter, and with the pool a single
   * character what has not settled can only read `#`.
   */
  it('settles one letter at a time from the left', async () => {
    const step = 60_000;
    const screen = await render(
      <AnimateScramble
        text="ABCD"
        characters="#"
        duration={step * 4}
        tick={step * 100}
        data-testid="s"
      />
    );
    const root = screen.getByTestId('s').element();

    for (const frame of ['A###', 'AB##', 'ABC#', 'ABCD']) {
      await vi.advanceTimersByTimeAsync(step);
      await expect.poll(() => shown(root)).toBe(frame);
    }
  });

  // Pausing tore the settling down, and resuming started it again from the
  // first letter, so a paused heading went back to noise.
  it('picks up where it was paused rather than starting over', async () => {
    const step = 60_000;
    const props = { text: 'ABCD', characters: '#', duration: step * 4, tick: step * 100 };
    const screen = await render(<AnimateScramble {...props} data-testid="s" />);
    const root = screen.getByTestId('s').element();

    await vi.advanceTimersByTimeAsync(step * 2);
    await expect.poll(() => shown(root)).toBe('AB##');

    await screen.rerender(<AnimateScramble {...props} paused data-testid="s" />);
    await screen.rerender(<AnimateScramble {...props} data-testid="s" />);

    await expect.poll(() => shown(root)).toBe('AB##');

    await vi.advanceTimersByTimeAsync(step);
    await expect.poll(() => shown(root)).toBe('ABC#');
  });

  // The box never changes size, which is the whole reason to reach for this
  // rather than for a typewriter.
  it('is the finished length from the first frame', async () => {
    const screen = await render(<AnimateScramble text="NEBA UI" duration={4000} data-testid="s" />);

    expect(shown(screen.getByTestId('s').element())).toHaveLength(7);
  });

  /* A space that flickered into a letter would read as the words having moved. */
  it('never scrambles whitespace', async () => {
    const screen = await render(<AnimateScramble text="AB CD" duration={4000} data-testid="s" />);

    expect(shown(screen.getByTestId('s').element())[2]).toBe(' ');
  });

  it('draws the noise from the pool it was given', async () => {
    const screen = await render(
      <AnimateScramble text="ABCD" characters="#" duration={4000} data-testid="s" />
    );

    expect(shown(screen.getByTestId('s').element())).toBe('####');
  });

  /*
   * The noise is picked during the render, so with a random source every
   * re-render from anywhere above — a parent's state, a route change, a resize
   * — reshuffled every unsettled letter at whatever moment that render landed.
   * The effect is a clock and was answering to the whole page.
   */
  it('does not reshuffle on a render that is not a tick', async () => {
    const screen = await render(
      <AnimateScramble text="ABCDEFGH" tick={100000} duration={100000} data-testid="s" />
    );
    const before = shown(screen.getByTestId('s').element());

    await screen.rerender(
      <AnimateScramble
        text="ABCDEFGH"
        tick={100000}
        duration={100000}
        data-testid="s"
        className="a-change-that-is-not-a-tick"
      />
    );

    expect(shown(screen.getByTestId('s').element())).toBe(before);
  });

  it('tells a screen reader the finished text', async () => {
    const screen = await render(<AnimateScramble text="NEBA" duration={4000} data-testid="s" />);

    expect(screen.getByTestId('s').element().children[0].textContent).toBe('NEBA');
  });

  it('takes the text from its children too', async () => {
    const screen = await render(
      <AnimateScramble duration={60} data-testid="s">
        Hello
      </AnimateScramble>
    );

    await vi.runAllTimersAsync();

    await expect.poll(() => shown(screen.getByTestId('s').element())).toBe('Hello');
  });
});
