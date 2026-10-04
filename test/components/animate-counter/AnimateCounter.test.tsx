import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { AnimateCounter } from 'neba';

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

/** What a sighted reader sees: drawn off an attribute, so it is not text. */
function shown(root: Element): string {
  return root.querySelector('[data-text]')?.getAttribute('data-text') ?? '';
}

/** The widths the box is held open at. */
function samples(root: Element): string[] {
  return [...root.querySelectorAll('[data-sample]')].map(
    (sample) => sample.getAttribute('data-sample') ?? ''
  );
}

/** A page as a server sent it, read with no script. */
function serverPage(element: React.ReactElement): HTMLElement {
  const host = document.createElement('div');

  host.innerHTML = renderToString(element);

  return host;
}

/** What a screen reader is told. */
function announced(root: Element): string {
  return root.children[0]?.textContent ?? '';
}

/*
 * On the fake clock, which fakes `requestAnimationFrame` along with the
 * timeouts. The count is a chain of animation frames, and on a real clock the
 * short runs were a race against a one-second poll and the long ones a race
 * the other way — a slow runner could reach the end of a count the test meant
 * to catch in the middle. React still commits on a task of its own, so the DOM
 * is waited for after the clock moves.
 */
describe('AnimateCounter', () => {
  // A `<div>` by default, which is not allowed inside the `<span>` a
  // Statistic's value is, nor inside a paragraph, where it broke hydration.
  it('renders a span, so it can sit inside a sentence', async () => {
    const screen = await render(
      <p>
        Served <AnimateCounter data-testid="count" value={12} trigger="manual" /> requests
      </p>
    );

    expect(screen.getByTestId('count').element().tagName).toBe('SPAN');
  });

  /*
   * The answer was in a clipped box and the count beside it was text as well,
   * so a server-rendered sentence read "Trusted by 12,0000 teams" and the same
   * sentence after the count "12,00012,000". The count is drawn, not written.
   */
  it('holds its answer as text once, in the HTML a server sends', () => {
    const host = serverPage(
      <p>
        Trusted by <AnimateCounter value={12000} locale="en-US" /> teams
      </p>
    );

    document.body.append(host);

    try {
      expect(host.textContent).toBe('Trusted by 12,000 teams');
      expect(host.innerText.replace(/\s+/g, ' ')).toBe('Trusted by 12,000 teams');
    } finally {
      host.remove();
    }
  });

  /*
   * `tabular-nums` sets every figure at one width, not every number at the
   * same number of figures, so a count to 12,000 widened the box each time it
   * gained a digit and pushed the words after it along.
   */
  it('holds its box open at both ends of the count from the first frame', async () => {
    const screen = await render(
      <AnimateCounter value={12000} trigger="manual" locale="en-US" data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    expect(shown(root)).toBe('0');
    expect(samples(root)).toEqual(['12,000', '0']);
    expect(root.querySelector('[aria-hidden="true"]')?.textContent).toBe('');
  });

  // A count down to 5 kept the room of the number it started from beside the
  // answer for good.
  it('lets the start go once the count has landed', async () => {
    const screen = await render(
      <AnimateCounter value={5} from={1000} duration={0} locale="en-US" data-testid="c" />
    );

    await expect.poll(() => samples(screen.getByTestId('c').element())).toEqual(['5']);
  });

  // It took `paused` with the props every Animate* shares and ignored it.
  it('takes no paused, which it had nothing to hold with', () => {
    // @ts-expect-error — a count is held with `trigger="manual"` and `play`
    const props: React.ComponentProps<typeof AnimateCounter> = { value: 1, paused: true };

    expect(props.value).toBe(1);
  });

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('shows the number itself, untriggered, to a reader who asked for less motion', async () => {
    reduceMotion = true;

    try {
      const screen = await render(
        <AnimateCounter value={120} from={0} trigger="manual" data-testid="c" />
      );

      expect(shown(screen.getByTestId('c').element())).toBe('120');
    } finally {
      reduceMotion = false;
    }
  });

  it('lands on its value', async () => {
    const screen = await render(<AnimateCounter value={42} duration={60} data-testid="c" />);

    await vi.runAllTimersAsync();

    await expect.poll(() => shown(screen.getByTestId('c').element())).toBe('42');
  });

  it('holds its answer as text once while it counts and after it lands', async () => {
    const screen = await render(
      <AnimateCounter value={12000} duration={4000} locale="en-US" data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    await vi.advanceTimersByTimeAsync(1500);
    await expect.poll(() => shown(root)).not.toBe('0');
    expect(root.textContent).toBe('12,000');

    await vi.runAllTimersAsync();
    await expect.poll(() => shown(root)).toBe('12,000');
    expect(root.textContent).toBe('12,000');
  });

  it('starts from where it was told, and counts from there', async () => {
    const screen = await render(
      <AnimateCounter value={100} from={90} duration={4000} data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    expect(shown(root)).toBe('90');

    await vi.advanceTimersByTimeAsync(2000);
    await expect.poll(() => shown(root)).not.toBe('90');

    const midway = Number(shown(root));

    expect(midway).toBeGreaterThan(90);
    expect(midway).toBeLessThan(100);
  });

  // A new value counted up from `from` again, so a live figure going from 100 to
  // 105 dropped to 0 and climbed back.
  it('counts a new value on from the number on screen', async () => {
    const screen = await render(<AnimateCounter value={100} duration={4000} data-testid="c" />);
    const root = screen.getByTestId('c').element();

    await vi.runAllTimersAsync();
    await expect.poll(() => shown(root)).toBe('100');

    await screen.rerender(<AnimateCounter value={105} duration={4000} data-testid="c" />);
    await vi.advanceTimersByTimeAsync(2000);

    const midway = Number(shown(root));

    expect(midway).toBeGreaterThanOrEqual(100);
    expect(midway).toBeLessThanOrEqual(105);

    await vi.runAllTimersAsync();
    await expect.poll(() => shown(root)).toBe('105');
  });

  // The default format writes up to three decimals, so a count to a whole
  // number read `29,851.407` on its way and its width shook.
  it('counts in whole numbers towards a whole number', async () => {
    const screen = await render(
      <AnimateCounter value={37251} duration={4000} locale="en-US" data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    await vi.advanceTimersByTimeAsync(1500);
    await expect.poll(() => shown(root)).not.toBe('0');

    expect(shown(root)).toMatch(/^[\d,]+$/);
  });

  it('keeps the decimal places of whichever end has more', async () => {
    const screen = await render(
      <AnimateCounter value={12.5} duration={4000} locale="en-US" data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    await vi.advanceTimersByTimeAsync(1500);
    await expect.poll(() => shown(root)).not.toBe('0');

    expect(shown(root)).toMatch(/^\d+(\.\d)?$/);
  });

  // A figure that changes width on every frame shakes the words beside it.
  it('sets its figures at one width', async () => {
    const screen = await render(<AnimateCounter value={1} duration={0} data-testid="c" />);

    expect(screen.getByTestId('c').element()).toHaveClass('tabular-nums');
  });

  /*
   * The answer is in the document from the first frame, in a clipped box: a
   * screen reader is told the number rather than a hundred intermediate ones.
   */
  it('tells a screen reader the answer and hides the count', async () => {
    const screen = await render(
      <AnimateCounter value={1234} from={0} duration={4000} data-testid="c" />
    );
    const root = screen.getByTestId('c').element();

    expect(announced(root)).toBe('1,234');
    expect(root.querySelector('[aria-hidden="true"]')).not.toBeNull();
  });

  // Intl rather than a `format` callback, so a currency is a prop.
  it('writes the number the way it was told to', async () => {
    const screen = await render(
      <AnimateCounter
        value={1234.5}
        duration={60}
        locale="en-US"
        format={{ style: 'currency', currency: 'USD' }}
        data-testid="c"
      />
    );

    await vi.runAllTimersAsync();

    await expect.poll(() => shown(screen.getByTestId('c').element())).toBe('$1,234.50');
  });

  it('jumps straight there when there is no duration', async () => {
    const screen = await render(<AnimateCounter value={7} from={0} duration={0} data-testid="c" />);

    expect(shown(screen.getByTestId('c').element())).toBe('7');
  });

  // `play` going up is a caller pressing go again, and the count stayed where
  // it had landed: its loop was keyed on having started, which it still had.
  it('counts again from the start when play goes up', async () => {
    const counter = (play: number) => (
      <AnimateCounter
        value={50}
        from={0}
        trigger="manual"
        play={play}
        duration={4000}
        data-testid="c"
      />
    );
    const screen = await render(counter(1));
    const root = screen.getByTestId('c').element();

    await vi.advanceTimersByTimeAsync(5000);
    await expect.poll(() => shown(root)).toBe('50');

    await screen.rerender(counter(2));
    // Read at once: the count sets its first frame before it asks for the next.
    expect(shown(root)).toBe('0');

    await vi.advanceTimersByTimeAsync(5000);
    await expect.poll(() => shown(root)).toBe('50');
  });

  it('waits for play when the trigger is manual', async () => {
    const screen = await render(
      <AnimateCounter value={50} from={0} trigger="manual" duration={4000} data-testid="c" />
    );

    // Longer than the whole count, so a count that had started would be over.
    await vi.advanceTimersByTimeAsync(5000);

    expect(shown(screen.getByTestId('c').element())).toBe('0');
  });
});
