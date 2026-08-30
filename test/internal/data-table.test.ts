/**
 * What a DataTable does to its rows before it draws them.
 *
 * Sorting, paging, the virtual window and a Shift-click's range are arithmetic
 * over arrays, and every one of them has an edge that is expensive to reach
 * through a rendered table and cheap to state here: an empty value in a sorted
 * column, a page number past the end, a scroll offset at the top, a range whose
 * anchor the current filter has hidden.
 */
import { describe, expect, it } from 'vitest';
import {
  compareValues,
  keysBetween,
  nextSort,
  pageBounds,
  sortRows,
  virtualWindow,
  type SortEntry
} from '../../src/internal/data-table.js';

const collator = new Intl.Collator('en', { numeric: true, sensitivity: 'base' });
const compare = (a: unknown, b: unknown) => compareValues(a, b, collator);

describe('compareValues', () => {
  it('orders numbers as numbers rather than as text', () => {
    expect(compare(9, 10)).toBeLessThan(0);
  });

  it('orders text the way a reader counts, not the way a byte does', () => {
    // `numeric` on the collator, which is what puts `item2` before `item10`.
    expect(compare('item2', 'item10')).toBeLessThan(0);
    expect(compare('a', 'B')).toBeLessThan(0);
  });

  it('sends an empty value to the end whichever way the column runs', () => {
    // Sorting a column should not be a way to lose the rows that have nothing
    // in it at the top of the table.
    expect(compare(null, 5)).toBeGreaterThan(0);
    expect(compare(5, undefined)).toBeLessThan(0);
    expect(compare('', 5)).toBeGreaterThan(0);
    expect(compare(null, undefined)).toBe(0);
  });

  it('treats NaN as empty rather than as a number', () => {
    // It compares false against everything, so left to the subtraction the sort
    // order would depend on which rows happened to be next to each other.
    expect(compare(Number.NaN, 5)).toBeGreaterThan(0);
    expect(compare(Number.NaN, Number.NaN)).toBe(0);
  });

  it('orders dates and booleans', () => {
    expect(compare(new Date(2026, 0, 1), new Date(2026, 0, 2))).toBeLessThan(0);
    expect(compare(false, true)).toBeLessThan(0);
  });

  it('keeps zero and false, which are values and not gaps', () => {
    expect(compare(0, 5)).toBeLessThan(0);
    expect(compare(false, null)).toBeLessThan(0);
  });
});

describe('sortRows', () => {
  const rows = [
    { name: 'Ana', team: 'B' },
    { name: 'Bo', team: 'A' },
    { name: 'Cy', team: 'A' }
  ];
  const by = (key: string) => (a: (typeof rows)[number], b: (typeof rows)[number]) =>
    compare(a[key as 'name'], b[key as 'name']);
  const comparator = (key: string) => (key === 'name' || key === 'team' ? by(key) : null);

  it('leaves the rows alone when nothing is sorted', () => {
    expect(sortRows(rows, [], comparator)).toEqual(rows);
  });

  it('reverses for a descending key', () => {
    const sorted = sortRows(rows, [{ key: 'name', direction: 'desc' }], comparator);

    expect(sorted.map((row) => row.name)).toEqual(['Cy', 'Bo', 'Ana']);
  });

  it('sorts by every key at once, first key outermost', () => {
    const sorted = sortRows(
      rows,
      [
        { key: 'team', direction: 'asc' },
        { key: 'name', direction: 'desc' }
      ],
      comparator
    );

    expect(sorted.map((row) => row.name)).toEqual(['Cy', 'Bo', 'Ana']);
  });

  it('is stable, which is what makes a multi-key sort composable', () => {
    const sorted = sortRows(rows, [{ key: 'team', direction: 'asc' }], comparator);

    // `Bo` and `Cy` share a team and were already in that order.
    expect(sorted.map((row) => row.name)).toEqual(['Bo', 'Cy', 'Ana']);
  });

  it('skips a key no column claims rather than throwing', () => {
    // A sort left over from a column that has since been removed.
    expect(sortRows(rows, [{ key: 'gone', direction: 'asc' }], comparator)).toEqual(rows);
  });
});

describe('nextSort', () => {
  const asc: SortEntry[] = [{ key: 'name', direction: 'asc' }];

  it('walks a column through ascending, descending and off', () => {
    expect(nextSort([], 'name', false)).toEqual(asc);
    expect(nextSort(asc, 'name', false)).toEqual([{ key: 'name', direction: 'desc' }]);
    expect(nextSort([{ key: 'name', direction: 'desc' }], 'name', false)).toEqual([]);
  });

  it('replaces the sort when it is not additive', () => {
    expect(nextSort(asc, 'team', false)).toEqual([{ key: 'team', direction: 'asc' }]);
  });

  it('adds to the end of the sort when it is', () => {
    expect(nextSort(asc, 'team', true)).toEqual([...asc, { key: 'team', direction: 'asc' }]);
  });

  it('drops one key out of an additive sort without touching the rest', () => {
    const both: SortEntry[] = [...asc, { key: 'team', direction: 'desc' }];

    expect(nextSort(both, 'team', true)).toEqual(asc);
  });

  it('keeps a key in its place when it only turns around', () => {
    const both: SortEntry[] = [...asc, { key: 'team', direction: 'asc' }];

    expect(nextSort(both, 'name', true)).toEqual([
      { key: 'name', direction: 'desc' },
      { key: 'team', direction: 'asc' }
    ]);
  });
});

describe('pageBounds', () => {
  it('slices a page out of the middle', () => {
    expect(pageBounds(100, 3, 10)).toEqual({ pages: 10, page: 3, start: 20, end: 30 });
  });

  it('stops the last page at the end rather than past it', () => {
    expect(pageBounds(95, 10, 10)).toMatchObject({ start: 90, end: 95 });
  });

  it('pulls a page number back into range', () => {
    // A search that cuts a table to three pages has to take a reader on page 14
    // with it, and answering with an empty page is not that.
    expect(pageBounds(25, 99, 10).page).toBe(3);
    expect(pageBounds(25, 0, 10).page).toBe(1);
    expect(pageBounds(25, -5, 10).page).toBe(1);
  });

  it('is one empty page rather than none when there is nothing at all', () => {
    expect(pageBounds(0, 1, 10)).toEqual({ pages: 1, page: 1, start: 0, end: 0 });
  });

  it('survives a page size of zero', () => {
    expect(pageBounds(10, 1, 0).pages).toBeGreaterThan(0);
    expect(Number.isFinite(pageBounds(10, 1, 0).end)).toBe(true);
  });
});

describe('virtualWindow', () => {
  it('renders the rows on screen plus the overscan', () => {
    const window_ = virtualWindow(0, 300, 30, 1000, 5);

    expect(window_.start).toBe(0);
    expect(window_.end).toBeGreaterThanOrEqual(10);
    expect(window_.before).toBe(0);
  });

  it('reserves exactly the height of the rows it left out', () => {
    const rowHeight = 30;
    const count = 1000;
    const window_ = virtualWindow(3000, 300, rowHeight, count, 5);

    expect(window_.before).toBe(window_.start * rowHeight);
    expect(window_.after).toBe((count - window_.end) * rowHeight);
  });

  it('never starts before the first row or ends past the last', () => {
    expect(virtualWindow(-500, 300, 30, 40, 5).start).toBe(0);
    expect(virtualWindow(99999, 300, 30, 40, 5).end).toBeLessThanOrEqual(40);
    expect(virtualWindow(99999, 300, 30, 40, 5).after).toBeGreaterThanOrEqual(0);
  });

  it('renders something before the viewport has been measured', () => {
    // The first frame: the observer has not answered yet, and a window of zero
    // rows is a table that draws nothing and never asks again.
    expect(virtualWindow(0, 0, 30, 1000, 5).end).toBeGreaterThan(0);
  });
});

describe('keysBetween', () => {
  const order = ['a', 'b', 'c', 'd'];

  it('takes the run between two keys, inclusive', () => {
    expect(keysBetween(order, 'b', 'd')).toEqual(['b', 'c', 'd']);
  });

  it('does not care which end the drag started at', () => {
    expect(keysBetween(order, 'd', 'b')).toEqual(keysBetween(order, 'b', 'd'));
  });

  it('is one key when both ends are the same row', () => {
    expect(keysBetween(order, 'c', 'c')).toEqual(['c']);
  });

  it('answers nothing for a key the current filter is hiding', () => {
    // Rather than the range from one end that an index of `-1` would silently
    // produce — which is every row up to the one that was clicked.
    expect(keysBetween(order, 'zz', 'c')).toEqual([]);
    expect(keysBetween(order, 'c', 'zz')).toEqual([]);
  });
});
