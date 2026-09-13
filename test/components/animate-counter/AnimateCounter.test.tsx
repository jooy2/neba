import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
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

/** What a sighted reader sees. */
function shown(root: Element): string {
  return root.querySelector('[aria-hidden="true"]')?.textContent ?? '';
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

  it('waits for play when the trigger is manual', async () => {
    const screen = await render(
      <AnimateCounter value={50} from={0} trigger="manual" duration={4000} data-testid="c" />
    );

    // Longer than the whole count, so a count that had started would be over.
    await vi.advanceTimersByTimeAsync(5000);

    expect(shown(screen.getByTestId('c').element())).toBe('0');
  });
});
