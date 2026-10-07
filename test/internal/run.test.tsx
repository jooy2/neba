/**
 * The clock behind a run's elapsed time.
 *
 * What it promises is about renders rather than about pixels: the component
 * that holds a run renders when the run starts and when it ends, the number is
 * the only thing that renders in between, and however many runs are going
 * there is one timer behind them.
 */
import * as React from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { RunTime, useRunClock } from '../../src/internal/run.js';

afterEach(() => {
  vi.useRealTimers();
  vi.restoreAllMocks();
});

/** How many commits rendered a `Row` itself, as opposed to the number in it. */
let rowCommits = 0;

/**
 * A row that holds a run's clock. The Profiler holds only the row's own part,
 * so a commit that redrew nothing but the number is not counted.
 */
function Row({ running, duration }: { running: boolean; duration?: number }) {
  const clock = useRunClock(running, duration);

  return (
    <>
      <React.Profiler id="row" onRender={() => (rowCommits += 1)}>
        <span>Row</span>
      </React.Profiler>
      <RunTime {...clock} className="time" />
    </>
  );
}

const shown = (container: HTMLElement) =>
  [...container.querySelectorAll('.time')].map((time) => time.textContent);

describe('the run clock', () => {
  it('counts whole seconds without rendering the row that holds it', async () => {
    vi.useFakeTimers();

    const screen = await render(<Row running />);
    const settled = rowCommits;

    expect(shown(screen.container)).toEqual([]);

    await vi.advanceTimersByTimeAsync(3000);
    await vi.waitFor(() => expect(shown(screen.container)).toEqual(['3s']));

    expect(rowCommits).toBe(settled);
  });

  it('keeps the exact total once the run ends', async () => {
    vi.useFakeTimers();

    const screen = await render(<Row running />);

    await vi.advanceTimersByTimeAsync(4900);
    await screen.rerender(<Row running={false} />);

    expect(shown(screen.container)).toEqual(['4.9s']);
  });

  it('takes a duration the caller knows over the count', async () => {
    const screen = await render(<Row running duration={340} />);

    expect(shown(screen.container)).toEqual(['340ms']);
  });

  it('runs every count on one timer', async () => {
    const setInterval = vi.spyOn(window, 'setInterval');
    const screen = await render(
      <>
        <Row running />
        <Row running />
        <Row running />
      </>
    );

    await vi.waitFor(() =>
      expect(setInterval.mock.calls.filter(([, delay]) => delay === 1000)).toHaveLength(1)
    );

    screen.unmount();
  });
});
