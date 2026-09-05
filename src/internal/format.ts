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
 * The cache is keyed on the locale and the options together, and it is unbounded
 * on purpose. The keys are not user data: they come from a component's own
 * option objects, of which any one page has a handful, so there is nothing here
 * that grows with the size of a table or the length of a series.
 *
 * The options object is deliberately *not* part of the key by identity. A caller
 * writing `format={{ style: 'currency', currency: 'USD' }}` inline hands over a
 * new object on every render — which is the ordinary way that prop gets written
 * — and keying on identity would miss every time and cache nothing but garbage.
 */

/**
 * `undefined` locale means the runtime's own, and is a key of its own. The
 * two halves are parted by a NUL, which no locale tag and no option name can
 * contain, so no two different pairs of inputs can spell the same key.
 */
function cacheKey(locale: string | undefined, options: object | undefined): string {
  return `${locale ?? ''}\u0000${options ? JSON.stringify(options) : ''}`;
}

const dateFormatters = new Map<string, Intl.DateTimeFormat>();

/** A memoised `Intl.DateTimeFormat`. */
export function dateFormatter(
  locale: string | undefined,
  options: Intl.DateTimeFormatOptions
): Intl.DateTimeFormat {
  const key = cacheKey(locale, options);
  let formatter = dateFormatters.get(key);

  if (!formatter) {
    formatter = new Intl.DateTimeFormat(locale, options);
    dateFormatters.set(key, formatter);
  }

  return formatter;
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

  const key = cacheKey(locale, { granularity });
  let found = segmenters.get(key);

  if (!found) {
    found = new Intl.Segmenter(locale, { granularity });
    segmenters.set(key, found);
  }

  return found;
}

const numberFormatters = new Map<string, Intl.NumberFormat>();

/** A memoised `Intl.NumberFormat`. */
export function numberFormatter(
  locale: string | undefined,
  options?: Intl.NumberFormatOptions
): Intl.NumberFormat {
  const key = cacheKey(locale, options);
  let formatter = numberFormatters.get(key);

  if (!formatter) {
    formatter = new Intl.NumberFormat(locale, options);
    numberFormatters.set(key, formatter);
  }

  return formatter;
}
