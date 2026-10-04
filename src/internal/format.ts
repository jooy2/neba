/**
 * The `Intl` objects, memoised.
 *
 * Here for the reason everything else in this folder is: unrelated parts of the
 * library construct them, and constructing one is the expensive half of
 * using one. Measured on V8, `new Intl.NumberFormat(...).format(n)` costs about
 * 16µs and `format(n)` on a formatter that already exists costs about 0.3µs —
 * fifty-five times the work to produce the same string.
 *
 * That ratio only matters where the call is in a loop or in a render, and in
 * this library it is both. A calendar builds seven weekday names and twelve
 * month names for a 42-cell month view. A chart writes one label per axis tick,
 * one per category and one per tooltip row, and it writes all of them again on
 * every re-render — which, on a chart being hovered, is every frame.
 *
 * The cache is keyed on the locale and the options together, and it goes
 * through `memoise` so it cannot grow without bound. Nothing here grows with
 * the size of a table or the length of a series — a page has a handful of
 * option objects — but both halves of the key reach these functions from public
 * props, so neither half is the library's to promise anything about.
 *
 * The options object is deliberately *not* part of the key by identity. A caller
 * writing `format={{ style: 'currency', currency: 'USD' }}` inline hands over a
 * new object on every render — which is the ordinary way that prop gets written
 * — and keying on identity would miss every time and cache nothing but garbage.
 *
 * Writing that key is the other cost, and in a table it is most of it:
 * `JSON.stringify` and a fresh string to hash on every lookup, which across
 * thirty thousand cells was several milliseconds of a dashboard's mount for a
 * formatter that was already built. So a lookup first asks the last few it
 * answered, comparing the options key by key, and only a lookup none of them
 * matches writes a key.
 */

import { memoise } from './cache.js';

/**
 * `undefined` locale means the runtime's own, and is a key of its own. The
 * two halves are parted by a NUL, which no locale tag and no option name can
 * contain, so no two different pairs of inputs can spell the same key.
 */
function cacheKey(locale: string | undefined, options: object | undefined): string {
  return `${locale ?? ''}\u0000${options ? JSON.stringify(options) : ''}`;
}

/**
 * One lookup answered, kept to answer the same question again without a key.
 *
 * The options are held as their keys and values, read off when the entry was
 * written, rather than as the caller's object: a caller who changes their own
 * options after a lookup has asked a different question, and an entry holding
 * their object would change its answer with it.
 */
interface Recent<T> {
  locale: string | undefined;
  keys: string[] | null;
  values: unknown[];
  value: T;
}

interface Cache<T> {
  store: Map<string, T>;
  recent: Recent<T>[];
  next: number;
}

/** Enough for the handful of formats a page interleaves, and few enough to scan. */
const RECENT = 8;

/**
 * Whether `options`, whose keys are `keys`, are the ones `entry` was asked with.
 *
 * The same keys in the same order with the same value under each, which is
 * exactly when the two would write the same JSON. Every `Intl` option is a
 * string, a number or a boolean, so one level is all there is to compare. It
 * walks arrays rather than the objects themselves on purpose: the options of
 * every formatter on a page pass through here, and a loop over objects of a
 * dozen different shapes is the slow kind.
 */
function sameOptions(
  entry: Recent<unknown>,
  keys: string[] | null,
  options: Record<string, unknown> | undefined
): boolean {
  const held = entry.keys;

  if (!keys || !held) return keys === held;
  if (keys.length !== held.length) return false;

  for (let index = 0; index < keys.length; index += 1) {
    if (keys[index] !== held[index] || options![keys[index]] !== entry.values[index]) {
      return false;
    }
  }

  return true;
}

/** Reads a formatter out of `memo`, building it on a miss. */
function lookup<T>(
  memo: Cache<T>,
  locale: string | undefined,
  options: object | undefined,
  build: () => T
): T {
  const given = options as Record<string, unknown> | undefined;
  const keys = given ? Object.keys(given) : null;

  for (const entry of memo.recent) {
    if (entry.locale === locale && sameOptions(entry, keys, given)) return entry.value;
  }

  const value = memoise(memo.store, cacheKey(locale, options), build);

  // Written round a ring rather than pushed and shifted: the oldest entry is
  // the one to go, and finding it costs nothing.
  memo.recent[memo.next] = {
    locale,
    keys,
    values: keys ? keys.map((key) => given![key]) : [],
    value
  };
  memo.next = (memo.next + 1) % RECENT;

  return value;
}

const dateFormatters: Cache<Intl.DateTimeFormat> = { store: new Map(), recent: [], next: 0 };

/** A memoised `Intl.DateTimeFormat`. */
export function dateFormatter(
  locale: string | undefined,
  options: Intl.DateTimeFormatOptions
): Intl.DateTimeFormat {
  return lookup(dateFormatters, locale, options, () => new Intl.DateTimeFormat(locale, options));
}

const segmenters = new Map<string, Intl.Segmenter>();

/**
 * A memoised `Intl.Segmenter`, or `null` on a runtime that has none.
 *
 * The same rule as the two above, and the one constructor that was still being
 * built per call. `AnimateTyping` asks for a string's graphemes, `AnimateSplit`
 * for its words and `AnimateScramble` for its graphemes again — three effects
 * that a page may well hold several of, each rebuilding a segmenter for a
 * string that has not changed.
 *
 * `null` rather than a throw where `Intl.Segmenter` is missing: a caller can
 * fall back to a spread, and a text effect is not worth taking a page down for.
 */
export function segmenter(
  locale: string | undefined,
  granularity: Intl.SegmenterOptions['granularity']
): Intl.Segmenter | null {
  if (typeof Intl === 'undefined' || !('Segmenter' in Intl)) {
    return null;
  }

  // One option, and a word with no NUL in it, so it is the key as it stands.
  return memoise(
    segmenters,
    `${locale ?? ''}\u0000${granularity ?? ''}`,
    () => new Intl.Segmenter(locale, { granularity })
  );
}

const numberFormatters: Cache<Intl.NumberFormat> = { store: new Map(), recent: [], next: 0 };

/** A memoised `Intl.NumberFormat`. */
export function numberFormatter(
  locale: string | undefined,
  options?: Intl.NumberFormatOptions
): Intl.NumberFormat {
  return lookup(numberFormatters, locale, options, () => new Intl.NumberFormat(locale, options));
}
