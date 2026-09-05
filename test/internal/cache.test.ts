/**
 * The bound under the memos.
 *
 * Five caches in `internal/` are keyed on something a caller chose, and what
 * makes a bound worth having is exactly what makes it hard to notice: a page
 * that behaves identically either way, and a map that only grows. So what is
 * checked here is the ceiling and what happens at it, rather than that a memo
 * remembers — which the four callers already demonstrate.
 */
import { describe, expect, it, vi } from 'vitest';
import { memoise } from '../../src/internal/cache.js';

describe('memoise', () => {
  it('builds once and hands the same value back', () => {
    const store = new Map<string, object>();
    const build = vi.fn(() => ({}));

    const first = memoise(store, 'a', build);
    const second = memoise(store, 'a', build);

    expect(second).toBe(first);
    expect(build).toHaveBeenCalledTimes(1);
  });

  it('builds one value per key', () => {
    const store = new Map<string, object>();

    expect(memoise(store, 'a', () => ({}))).not.toBe(memoise(store, 'b', () => ({})));
  });

  // `localeWeekStart` caches Sunday as `0` and `listFor` caches `null` for a
  // runtime with no `matchMedia`. A hit test written on truthiness would rebuild
  // both on every call, which is the memo doing nothing at all.
  it('holds a falsy value as a value', () => {
    const store = new Map<string, number | null>();
    const zero = vi.fn(() => 0);
    const nothing = vi.fn(() => null);

    memoise(store, 'zero', zero);
    memoise(store, 'zero', zero);
    memoise(store, 'null', nothing);
    memoise(store, 'null', nothing);

    expect(zero).toHaveBeenCalledTimes(1);
    expect(nothing).toHaveBeenCalledTimes(1);
  });

  /*
   * The ceiling itself, asserted loosely on purpose: what matters is that there
   * is one and that it is nowhere near five hundred, not where exactly it was
   * set. The library's own use of any of these five is a dozen entries.
   */
  it('empties rather than growing without bound', () => {
    const store = new Map<number, number>();

    for (let index = 0; index < 500; index += 1) {
      memoise(store, index, () => index);
    }

    expect(store.size).toBeLessThan(100);
  });

  // Emptying is only ever a cost, never an error: the next call builds what it
  // would have built anyway.
  it('builds again for a key it dropped', () => {
    const store = new Map<number, string>();

    memoise(store, -1, () => 'first');

    for (let index = 0; index < 500; index += 1) {
      memoise(store, index, () => 'filler');
    }

    expect(memoise(store, -1, () => 'second')).toBe('second');
  });
});
