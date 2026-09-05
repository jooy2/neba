/**
 * A memo that cannot grow without bound.
 *
 * Five caches in this folder are keyed on something a caller chose — a
 * `locale`, a media query string, the options behind a `format` prop — and
 * every one of those keys arrives through a public prop or a public hook. The
 * library's own use of them is a handful of entries each: a dozen queries, two
 * segmenter granularities, however many languages a product ships. A caller
 * computing a key is the case with no ceiling, and what sits on the far side is
 * an `Intl` object or a live `MediaQueryList` rather than a few bytes.
 *
 * So there is a ceiling, and reaching it empties the store rather than evicting
 * the coldest entry. An LRU wants a second structure and an ordering to
 * maintain on every read, which is real work on the one path this exists to
 * make cheap; emptying is a single branch, and the worst it can do is make the
 * next call build what it would have built anyway. The limit is far above
 * anything the library itself reaches, so an ordinary page never meets it.
 *
 * One rule comes with the shape: a store must not hold `undefined` as a value,
 * or every read of that key misses and builds again. All five hold an object, a
 * number or `null`.
 */

/** Well past any legitimate use, and still a bound. */
const LIMIT = 64;

/** Reads `key` out of `store`, filling it in with `build` on a miss. */
export function memoise<K, V>(store: Map<K, V>, key: K, build: () => V): V {
  const hit = store.get(key);

  if (hit !== undefined) {
    return hit;
  }

  if (store.size >= LIMIT) {
    store.clear();
  }

  const value = build();

  store.set(key, value);

  return value;
}
