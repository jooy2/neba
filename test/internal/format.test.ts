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
 *
 * In front of that key sit the last few lookups, matched by comparing the
 * options rather than by writing their key. What can go wrong there is an
 * answer that outlives its question: an entry that still matches after the
 * caller changed their own object, or one that matches a different locale.
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

  it('keeps two locales apart for the same options', () => {
    const options = { maximumFractionDigits: 1 };

    expect(numberFormatter('de-DE', options).format(1.5)).toBe('1,5');
    expect(numberFormatter('en-US', options).format(1.5)).toBe('1.5');
  });

  // A lookup is remembered by a copy of the options it was asked with, so a
  // caller who reuses one object and changes it has asked a new question.
  it('answers again once the caller changes their own options object', () => {
    const options: Intl.NumberFormatOptions = { maximumFractionDigits: 0 };

    expect(numberFormatter('en-US', options).format(1.25)).toBe('1');

    options.maximumFractionDigits = 2;

    expect(numberFormatter('en-US', options).format(1.25)).toBe('1.25');
  });

  it('tells options apart that share their keys but not their values', () => {
    expect(numberFormatter('en-US', { style: 'percent' }).format(0.5)).toBe('50%');
    expect(numberFormatter('en-US', { style: 'decimal' }).format(0.5)).toBe('0.5');
  });

  it('tells options apart when one has a key the other lacks', () => {
    const one = numberFormatter('en-US', { minimumFractionDigits: 2 });
    const two = numberFormatter('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 3 });

    expect(two).not.toBe(one);
    expect(one.format(1.2345)).toBe('1.235');
    expect(two.format(1.2345)).toBe('1.235');
    expect(numberFormatter('en-US', { minimumFractionDigits: 2 })).toBe(one);
  });

  // Past the few it remembers, a lookup falls back to the keyed cache, which
  // still holds the formatter the first one built.
  it('still hands back the same object after more lookups than it remembers', () => {
    const first = numberFormatter('en-US', { maximumSignificantDigits: 1 });

    for (let digits = 2; digits <= 21; digits += 1) {
      numberFormatter('en-US', { maximumSignificantDigits: digits });
    }

    expect(numberFormatter('en-US', { maximumSignificantDigits: 1 })).toBe(first);
    expect(first.format(1234)).toBe('1,000');
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
