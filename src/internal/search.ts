/**
 * What "this matches what I typed" means, once.
 *
 * Three components let a reader type at a list of their own — DataTable,
 * CommandPalette and Transfer — and each had a `matches` of its own. They
 * disagreed: a DataTable found `José` for `jose` and the other two did not,
 * which is not a preference anybody chose. A reader who learns what the search
 * box in one part of a product does has learned the wrong thing about the rest
 * of it.
 *
 * It is also the fixed cost of typing. `String.prototype.normalize` is the
 * expensive call in here by a wide margin, so the shape of the API is built
 * around folding a haystack *once* and a needle *once* rather than folding both
 * on every comparison — which is what a `matches(item, query)` signature
 * quietly asks for, and what put a `normalize` on every cell of every row of a
 * DataTable on every keystroke.
 */

/** The combining marks `NFD` splits an accented letter into. */
const COMBINING = /[\u0300-\u036f]/g;

/**
 * What a haystack's parts are joined on: a character no keyboard produces, so a
 * query cannot span the seam between two fields and find a row on text that is
 * not next to itself.
 */
const SEAM = '\u0000';

/**
 * A value as something a query can be matched against.
 *
 * Case-folded and stripped of combining marks, so `jose` finds `José` and
 * `SEOUL` finds `Seoul`. `NFD` splits an accented letter into the letter and
 * its accent and the range then deletes the accent; a search field is the one
 * place where losing that distinction is the point.
 *
 * A `Date` is deliberately *not* formatted here. What a reader sees in a cell
 * came out of the caller's own rendering, and guessing a format the search
 * would agree with is how a table ends up not finding a date that is on the
 * screen — a column that wants its dates searchable gives them a `value`.
 */
export function searchText(value: unknown): string {
  if (value === null || value === undefined || typeof value === 'object') {
    return '';
  }

  return String(value).normalize('NFD').replace(COMBINING, '').toLowerCase();
}

/** Every string a row can be found by, folded once and joined into one haystack. */
export function searchHaystack(values: readonly unknown[]): string {
  return values.map(searchText).join(SEAM);
}
