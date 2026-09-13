import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { AnimateScramble } from 'neba';

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
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
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
