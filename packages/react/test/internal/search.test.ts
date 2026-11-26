/**
 * What "this matches what I typed" means, for the three components that let a
 * reader type at a list of their own.
 *
 * The fold is shared so a DataTable, a CommandPalette and a Transfer cannot
 * disagree about accents — which they did, before this existed. It is also the
 * fixed cost of typing, so its shape matters: a haystack folded once and a
 * needle folded once, never both on every comparison.
 */
import { describe, expect, it } from 'vitest';
import { searchHaystack, searchText } from '../../src/internal/search.js';

describe('searchText', () => {
  it('folds case', () => {
    expect(searchText('SEOUL')).toBe('seoul');
  });

  it('strips the accents off a letter, so `jose` finds `José`', () => {
    expect(searchText('José')).toBe('jose');
    expect(searchText('Café')).toBe('cafe');
    expect(searchText('Ångström').startsWith('a')).toBe(true);
  });

  it('folds a script the accent rule has no opinion about, and still matches it', () => {
    // Hangul decomposes into jamo under `NFD` and the combining-mark range does
    // not touch them, so what comes back is not the string that went in — which
    // is fine, and is the property that actually matters: both sides of a
    // comparison are folded the same way, so a needle still finds its haystack.
    expect(searchText('서울특별시').includes(searchText('서울'))).toBe(true);
    expect(searchText('東京都').includes(searchText('東京'))).toBe(true);
    expect(searchText('서울').includes(searchText('부산'))).toBe(false);
  });

  it('reads a number and a boolean, which are what a cell usually holds', () => {
    expect(searchText(12)).toBe('12');
    expect(searchText(true)).toBe('true');
    expect(searchText(0)).toBe('0');
    expect(searchText(false)).toBe('false');
  });

  it('answers nothing for what has no text in it', () => {
    // A `Date` is deliberately not formatted: what a reader sees in the cell
    // came out of the caller's own rendering, and guessing a format the search
    // would agree with is how a table stops finding a date that is on screen.
    expect(searchText(null)).toBe('');
    expect(searchText(undefined)).toBe('');
    expect(searchText({})).toBe('');
    expect(searchText(new Date())).toBe('');
  });
});

describe('searchHaystack', () => {
  it('folds every part and joins them', () => {
    const hay = searchHaystack(['Café', 'Seoul', 12]);

    expect(hay).toContain('cafe');
    expect(hay).toContain('seoul');
    expect(hay).toContain('12');
  });

  it('does not let a query span the seam between two fields', () => {
    // Otherwise a row would be found on text that is not next to itself: a
    // "Seoul" in one column and a "Korea" in the next are not "seoul korea".
    expect(searchHaystack(['Seoul', 'Korea'])).not.toContain('seoul korea');
    expect(searchHaystack(['Seoul', 'Korea']).includes(searchText('Seoul'))).toBe(true);
  });

  it('holds a row with nothing in it together', () => {
    expect(searchHaystack([null, undefined])).not.toContain('null');
    expect(searchHaystack([])).toBe('');
  });
});
