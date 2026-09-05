/**
 * The `Intl` objects, memoised.
 *
 * What is worth checking here is not that a formatter formats — that is `Intl`'s
 * job — but the two properties the cache is built on, both of which fail
 * silently. The first is that the key is the *content* of the options rather
 * than their identity: the ordinary way a `format` prop gets written is a
 * literal in the JSX, so a fresh object arrives on every render and a cache
 * keyed on identity would hold nothing but garbage. The second is that no two
 * different pairs of inputs can spell the same key, which is what the NUL
 * between the halves is for.
 */
import { describe, expect, it } from 'vitest';
import { dateFormatter, numberFormatter, segmenter } from '../../src/internal/format.js';

describe('numberFormatter', () => {
  it('gives the same object back for options written out twice', () => {
    const first = numberFormatter('en-US', { maximumFractionDigits: 1 });
    const second = numberFormatter('en-US', { maximumFractionDigits: 1 });

    expect(second).toBe(first);
  });

  it('gives a different one for different options', () => {
    const one = numberFormatter('en-US', { maximumFractionDigits: 1 });
    const two = numberFormatter('en-US', { maximumFractionDigits: 2 });

    expect(two).not.toBe(one);
  });

  it('gives a different one for a different locale', () => {
    expect(numberFormatter('de-DE')).not.toBe(numberFormatter('en-US'));
  });

  // `undefined` means the runtime's own locale, which is a key of its own and
  // not the same one a named tag gets.
  it('keeps the runtime own locale apart from a named one', () => {
    expect(numberFormatter(undefined)).not.toBe(numberFormatter('en-US'));
  });

  // No options at all is not the same key as an empty options object, and
  // neither may be handed the other's formatter.
  it('keeps absent options apart from empty ones', () => {
    expect(numberFormatter('en-US')).toBe(numberFormatter('en-US', undefined));
  });

  it('formats through the object it handed back', () => {
    expect(numberFormatter('en-US', { maximumFractionDigits: 0 }).format(1234.6)).toBe('1,235');
  });
});

describe('dateFormatter', () => {
  it('gives the same object back for options written out twice', () => {
    const first = dateFormatter('en-US', { month: 'short' });
    const second = dateFormatter('en-US', { month: 'short' });

    expect(second).toBe(first);
  });

  // The two caches are separate, so a number's key and a date's key cannot
  // collide even when they are spelled identically.
  it('does not share a cache with the number formatters', () => {
    expect(dateFormatter('en-US', {})).not.toBe(numberFormatter('en-US', {}));
  });
});

describe('segmenter', () => {
  it('gives the same object back for one locale and granularity', () => {
    expect(segmenter('en', 'word')).toBe(segmenter('en', 'word'));
  });

  it('keeps the two granularities apart', () => {
    expect(segmenter('en', 'grapheme')).not.toBe(segmenter('en', 'word'));
  });
});
