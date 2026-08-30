/**
 * The arithmetic a DataTable is made of.
 *
 * Here rather than in the component for the reason `progress.ts` and `color.ts`
 * are here: none of it is layout and none of it is a class name. Sorting rows,
 * matching a query against them, cutting a page out of the result and working
 * out which twenty of forty thousand rows are actually on screen are four
 * questions with numeric answers, and a component file that also has to draw a
 * resize handle is not where they can be read.
 *
 * `color.ts` is the precedent for a single-consumer file: the test is whether
 * the thing is separable, not whether two components happen to want it. Every
 * function below takes plain values and returns plain values — there is no
 * React in this file, and nothing in it knows what a column is.
 */

import type { NebaDensity, NebaSize } from '../types.js';

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/**
 * Row height, in **pixels**, and the one number in the library that has to be a
 * number rather than a class.
 *
 * Virtual scrolling is arithmetic on this value: how far down the list a scroll
 * offset lands, how tall the spacer above the first rendered row is, how many
 * rows fit in the viewport for PageDown. A Tailwind class cannot be added up.
 *
 * The ladder is deliberately below `controlHeightClasses` at every step — 28px
 * at `md` against a Button's 32 — because a DataTable is a hundred rows on one
 * screen and a Table is eight. A row here is the height of the text plus enough
 * air to click, and nothing more; `density` is what takes the last of the air
 * out. A caller who puts a Chip or an Avatar in a cell raises `rowHeight`.
 */
export const dataRowHeights: Record<NebaDensity, Record<NebaSize, number>> = {
  default: { xs: 24, sm: 28, md: 32, lg: 38, xl: 44 },
  compact: { xs: 20, sm: 24, md: 28, lg: 32, xl: 38 }
};

/**
 * The header, one step taller than the rows under it.
 *
 * A fixed number rather than "whatever the content measures", because a sticky
 * header over a group row needs an offset to stick the second row at, and a
 * measured one would be a layout read on every scroll frame.
 */
export const dataHeaderHeights: Record<NebaDensity, Record<NebaSize, number>> = {
  default: { xs: 28, sm: 32, md: 36, lg: 42, xl: 48 },
  compact: { xs: 24, sm: 28, md: 32, lg: 36, xl: 42 }
};

/**
 * The tick column, and the resize handle's grab area.
 *
 * The tick column is `tickSizeClasses` plus the two padding tracks, rounded to
 * a whole pixel: a column narrower than the box in it clips the focus ring.
 */
export const dataTickWidths: Record<NebaSize, number> = {
  xs: 30,
  sm: 34,
  md: 38,
  lg: 42,
  xl: 50
};

/** How wide a column is when neither the caller nor a drag has said. */
export const defaultColumnWidth = 160;

/** How narrow a drag may make one. Below this the heading is a single letter. */
export const minColumnWidth = 48;

/* ---------------------------------------------------------------------------
 * Sorting
 * ------------------------------------------------------------------------- */

export type SortDirection = 'asc' | 'desc';

/** One key of a sort, and which way it runs. */
export interface SortEntry {
  key: string;
  direction: SortDirection;
}

/**
 * The default comparison, for the columns that do not bring one.
 *
 * Empty sorts last in both directions, which is the one asymmetry here and the
 * one every spreadsheet has: a blank is not the smallest value, it is the
 * absence of one, and a descending sort whose first screen is forty blanks has
 * answered the wrong question.
 *
 * Numbers compare as numbers, dates as instants, booleans with `false` first,
 * and everything else through the collator — which is `numeric`, so `item2`
 * comes before `item10` rather than after it.
 */
export function compareValues(a: unknown, b: unknown, collator: Intl.Collator): number {
  const aEmpty = a === null || a === undefined || a === '';
  const bEmpty = b === null || b === undefined || b === '';

  if (aEmpty || bEmpty) {
    return aEmpty && bEmpty ? 0 : aEmpty ? 1 : -1;
  }

  if (typeof a === 'number' && typeof b === 'number') {
    // `NaN` is empty by another name: it compares false against everything, so
    // left to the subtraction below it would make the sort order depend on
    // which rows happened to be next to each other.
    if (Number.isNaN(a) || Number.isNaN(b)) {
      return Number.isNaN(a) && Number.isNaN(b) ? 0 : Number.isNaN(a) ? 1 : -1;
    }

    return a - b;
  }

  if (typeof a === 'boolean' && typeof b === 'boolean') {
    return Number(a) - Number(b);
  }

  if (a instanceof Date && b instanceof Date) {
    return a.getTime() - b.getTime();
  }

  return collator.compare(String(a), String(b));
}

/**
 * Sorts by every key at once, first key outermost.
 *
 * The sort is **stable** — `Array.prototype.sort` has been since ES2019 — which
 * is what makes a multi-key sort composable: sorting by name and then adding
 * date to the end of the list leaves rows with the same date in name order,
 * because that is the order they were already in.
 *
 * `comparatorFor` returns `null` for a key no column claims, so a sort left
 * over from a column that has since been removed is skipped rather than
 * throwing.
 */
export function sortRows<T>(
  rows: readonly T[],
  sort: readonly SortEntry[],
  comparatorFor: (key: string) => ((a: T, b: T) => number) | null
): T[] {
  if (sort.length === 0) {
    return rows as T[];
  }

  const steps = sort
    .map((entry) => {
      const compare = comparatorFor(entry.key);

      return compare ? { compare, sign: entry.direction === 'desc' ? -1 : 1 } : null;
    })
    .filter((step): step is { compare: (a: T, b: T) => number; sign: number } => step !== null);

  if (steps.length === 0) {
    return rows as T[];
  }

  return [...rows].sort((a, b) => {
    for (const step of steps) {
      const result = step.compare(a, b);

      if (result !== 0) {
        return result * step.sign;
      }
    }

    return 0;
  });
}

/**
 * What pressing a heading does, given what the sort already says.
 *
 * Three states rather than two — ascending, descending, unsorted — because the
 * order the rows arrived in is a state a caller cannot get back to by pressing
 * anything if the cycle only has two. This is the opposite of the choice
 * TreeView's single select makes, and for the same reason: there, "nothing
 * chosen" is reachable by pressing something else; here it is not.
 *
 * `additive` is what a Shift-click sets. It keeps the column where it already
 * is in the list rather than moving it to the end, so flipping the second key
 * of a two-key sort does not silently make it the first.
 */
export function nextSort(
  current: readonly SortEntry[],
  key: string,
  additive: boolean
): SortEntry[] {
  const existing = current.find((entry) => entry.key === key);
  const direction: SortDirection | null =
    existing === undefined ? 'asc' : existing.direction === 'asc' ? 'desc' : null;

  if (!additive) {
    return direction === null ? [] : [{ key, direction }];
  }

  if (direction === null) {
    return current.filter((entry) => entry.key !== key);
  }

  if (existing === undefined) {
    return [...current, { key, direction }];
  }

  return current.map((entry) => (entry.key === key ? { key, direction } : entry));
}

/* ---------------------------------------------------------------------------
 * Paging
 * ------------------------------------------------------------------------- */

/** Where one page starts and stops, and how many there are. */
export interface PageBounds {
  /** How many pages the rows come to. Never below `1`. */
  pages: number;
  /** The page actually shown, clamped into range. */
  page: number;
  /** Index of the first row on it. */
  start: number;
  /** One past the last. */
  end: number;
}

/**
 * The page arithmetic, with the clamp in it.
 *
 * The clamp is the whole reason this is a function: a filter that cuts a
 * twenty-page table to three leaves the caller's `page` at 14, and a table that
 * answers with an empty screen has told the reader their search found nothing.
 * The page moves to the last one that exists instead.
 */
export function pageBounds(total: number, page: number, pageSize: number): PageBounds {
  const size = Math.max(1, Math.floor(pageSize));
  const pages = Math.max(1, Math.ceil(total / size));
  const current = Math.min(Math.max(Math.floor(page), 1), pages);
  const start = (current - 1) * size;

  return { pages, page: current, start, end: Math.min(start + size, total) };
}

/* ---------------------------------------------------------------------------
 * Virtual scrolling
 * ------------------------------------------------------------------------- */

/** Which rows are rendered, and how much empty space stands in for the rest. */
export interface VirtualWindow {
  /** Index of the first row rendered. */
  start: number;
  /** One past the last. */
  end: number;
  /** The height of the spacer row above, in pixels. */
  before: number;
  /** And of the one below. */
  after: number;
}

/**
 * The rows a scroll offset puts on screen, plus a margin either side.
 *
 * Two spacer rows rather than a translated `<tbody>`: a transform on the body
 * of a table breaks `position: sticky` on the header above it, and the library
 * has a rule about transforms anyway. Padding is also what keeps the scrollbar
 * honest — the scroll height is the real one, so dragging the thumb to the
 * middle lands in the middle of the data.
 *
 * `viewport` of `0` is the first render, before anything has been measured. It
 * cannot mean "no rows" — the layout effect that measures runs after a render
 * and there would be nothing to measure — so it renders a screen's worth on
 * spec and corrects before the frame is painted.
 */
export function virtualWindow(
  scrollTop: number,
  viewport: number,
  rowHeight: number,
  count: number,
  overscan: number
): VirtualWindow {
  const visible = viewport > 0 ? Math.ceil(viewport / rowHeight) : overscan * 3;
  const first = Math.max(0, Math.floor(scrollTop / rowHeight) - overscan);
  const last = Math.min(count, first + visible + overscan * 2);

  return {
    start: first,
    end: last,
    before: first * rowHeight,
    after: Math.max(0, (count - last) * rowHeight)
  };
}

/* ---------------------------------------------------------------------------
 * Selection
 * ------------------------------------------------------------------------- */

/**
 * Every key between two, inclusive, in the order the rows are currently in.
 *
 * "Currently" is the point: a Shift-click selects what the reader can see
 * between the two rows they clicked, so the range is taken from the sorted,
 * filtered order rather than from the order `items` arrived in. Which of the
 * two keys is the anchor does not matter — dragging up selects the same rows as
 * dragging down.
 *
 * A key that is no longer in the list (a row the current filter hides) yields
 * an empty range rather than a range from one end, which is what an index of
 * `-1` would silently produce.
 */
export function keysBetween(order: readonly string[], from: string, to: string): string[] {
  const a = order.indexOf(from);
  const b = order.indexOf(to);

  if (a === -1 || b === -1) {
    return [];
  }

  return order.slice(Math.min(a, b), Math.max(a, b) + 1);
}
