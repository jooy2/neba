'use client';

import * as React from 'react';
import { Box } from '../box/Box.js';
import { Checkbox } from '../checkbox/Checkbox.js';
import { Pagination } from '../pagination/Pagination.js';
import { Select } from '../select/Select.js';
import { TextField } from '../text-field/TextField.js';
import {
  compareValues,
  dataHeaderHeights,
  dataRowHeights,
  dataTickWidths,
  defaultColumnWidth,
  keysBetween,
  minColumnWidth,
  nextSort,
  pageBounds,
  searchText,
  sortRows,
  virtualWindow,
  type SortEntry
} from '../../internal/data-table.js';
import { emptyMessages, fillMessage, tableMessages, useMessages } from '../../internal/i18n.js';
import { ChevronIcon } from '../../internal/icons.js';
import {
  controlTextLeadingClasses,
  cx,
  hasContent,
  metaTextClasses,
  paddingXValues,
  srOnlyClasses
} from '../../internal/styles.js';
import type { NebaAlign, NebaElevation, NebaStyleProps } from '../../types.js';

/* ---------------------------------------------------------------------------
 * Vocabulary
 * ------------------------------------------------------------------------- */

/** Which way a column runs when it is sorted. */
export type DataTableSortDirection = 'asc' | 'desc';

/** One key of the sort, and its direction. A sort is a list of these. */
export interface DataTableSort {
  /** The column's `key`. */
  key: string;
  direction: DataTableSortDirection;
}

/**
 * How many rows may be chosen at once.
 *
 * `none` is the default: a table that highlights a row under the pointer but
 * cannot be selected is a table that has promised something it does not do.
 */
export type DataTableSelectionMode = 'none' | 'single' | 'multiple';

/**
 * Which rows carry the tint, counted the way a reader counts them — `odd` is
 * the first, the third and the fifth.
 */
export type DataTableStripe = 'odd' | 'even';

/**
 * How the rows are handed out.
 *
 * - `scroll` — all of them, in one scrolling body. With a `height` set this is
 *   the virtualized mode, and the one to reach for at any size.
 * - `pages` — a slice at a time, with a footer to step through them. Right when
 *   the row's position in the whole set is information (a ledger, a log), and
 *   the only option when the rows are being fetched a page at a time.
 */
export type DataTablePaging = 'scroll' | 'pages';

/** The three things the table does to the rows before drawing them. */
export type DataTableStage = 'sort' | 'filter' | 'pages';

/**
 * A column: its heading, how wide it is, how to get a value out of a row and
 * how to draw one.
 *
 * The split between `value` and `render` is the whole shape of this type. A
 * `render` decides what a reader sees; a `value` decides what the sort and the
 * search see. Most columns need neither — the cell is `row[key]` and that is
 * what is compared and matched. A column that draws a Chip needs `render`, and
 * it needs `value` as well the moment it is sortable, because a React element
 * has no order.
 */
export interface DataTableColumn<Row> {
  /**
   * Identifies the column — to `sort`, to `columnWidths`, and unless `value` or
   * `render` says otherwise, it names the property to read off each row.
   */
  key: string;
  /** The heading. Defaults to the `key`, which is usually not what you want. */
  label?: React.ReactNode;
  /**
   * The heading above this column and its neighbours.
   *
   * Adjacent columns carrying the same string are drawn under one merged cell
   * in a second header row; a column with no `group` spans both rows. Merging
   * by adjacency rather than by a separate model is deliberate — a group is a
   * run of columns, and a table where "Address" covers columns 2, 5 and 9 is a
   * table whose columns are in the wrong order.
   */
  group?: string;
  /**
   * How wide, in pixels. Columns that do not say share whatever is left.
   *
   * Pixels rather than any CSS length, because the width is a number the resize
   * drag does arithmetic on. A column that has been dragged keeps the dragged
   * width until it is double-clicked.
   */
  width?: number;
  /** How narrow a drag may make it. @default 48 */
  minWidth?: number;
  /**
   * Which edge the cells line up against. Numbers want `end` so their digits
   * line up in a column.
   * @default 'start'
   */
  align?: NebaAlign;
  /** The heading's own alignment, when it should differ from the cells'. */
  headerAlign?: NebaAlign;
  /** Whether this column can be sorted. Defaults to the table's `sortable`. */
  sortable?: boolean;
  /** Whether this column can be dragged wider. Defaults to `resizable`. */
  resizable?: boolean;
  /**
   * Whether the search looks in this column.
   * @default true
   */
  searchable?: boolean;
  /** Leaves the column out without removing it from the list. */
  hidden?: boolean;
  /**
   * The value behind the cell: what is sorted, and what the search is matched
   * against. Defaults to `row[key]`.
   */
  value?: (row: Row) => unknown;
  /**
   * Orders two rows by this column, for a value the default comparison cannot
   * rank — a status that goes `draft`, `review`, `live` rather than
   * alphabetically. Always written ascending; the table reverses it.
   */
  compare?: (a: Row, b: Row) => number;
  /**
   * Draws the cell. `index` is the row's place in the sorted, filtered order,
   * counted from `0` across every page — so `(row, index) => index + 1` is a
   * running row number.
   */
  render?: (row: Row, index: number) => React.ReactNode;
}

export interface DataTableProps<Row>
  extends
    NebaStyleProps,
    Omit<
      React.ComponentPropsWithoutRef<'div'>,
      'color' | 'children' | 'onSelect' | 'defaultValue'
    > {
  /** The columns, in the order they appear. */
  headers: readonly DataTableColumn<Row>[];
  /** The rows. */
  items: readonly Row[];
  /**
   * A stable identity per row, and the value `selected` is a list of.
   *
   * Defaults to the row's index in `items`, which is enough for a table that
   * only ever displays. The moment rows can be chosen, sorted or filtered it is
   * required in practice: an index identifies a position, and every one of
   * those three changes which row is in it.
   */
  getRowKey?: (row: Row, index: number) => React.Key;

  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * How tall the scrolling body is — a number is pixels, a string any CSS
   * length. **This is what turns virtual scrolling on**: rows can only be left
   * out of the DOM if something bounds the height they would have taken.
   */
  height?: number | string;
  /** The same, as a ceiling: the table is as tall as its rows, up to this. */
  maxHeight?: number | string;
  /**
   * How tall one row is, in pixels. Defaults to the `size`/`density` ladder.
   *
   * Every row is this tall and cells never wrap — which is what makes the
   * scroll position arithmetic rather than a measurement. Raise it for a table
   * whose cells hold an Avatar or two lines of text.
   */
  rowHeight?: number;
  /**
   * Tints every other row. `true` means `even` — the second, the fourth, the
   * sixth — and the parity is counted over the whole set, so it does not change
   * when the rows are scrolled or sorted.
   * @default false
   */
  striped?: boolean | DataTableStripe;
  /**
   * Lights the row under the pointer.
   * @default true
   */
  hoverable?: boolean;
  /**
   * Pins the header while the body scrolls.
   * @default true
   */
  stickyHeader?: boolean;
  /** Shown above the table, and read out as its accessible name. */
  caption?: React.ReactNode;
  /** The name the grid is announced by, when there is no `caption`. */
  label?: string;
  /** What to show instead of rows when there are none. */
  empty?: React.ReactNode;

  /**
   * Leaves the rows that are off screen out of the DOM. Needs a `height` or a
   * `maxHeight` to have anything to measure against; without one every row is
   * rendered whatever this says.
   * @default true
   */
  virtual?: boolean;
  /**
   * How many rows are kept rendered past each edge of the viewport, so a fast
   * scroll does not show a band of nothing.
   * @default 8
   */
  overscan?: number;

  /**
   * Makes every column sortable. A column overrides it either way with its own
   * `sortable`.
   * @default false
   */
  sortable?: boolean;
  /**
   * Whether more than one column can be sorted at a time. With `multiple`, a
   * Shift-click adds a column to the sort instead of replacing it.
   * @default 'single'
   */
  sortMode?: 'single' | 'multiple';
  /** The sort. Use with `onSortChange` for a controlled one. */
  sort?: readonly DataTableSort[];
  /** What it starts as, for an uncontrolled one. */
  defaultSort?: readonly DataTableSort[];
  onSortChange?: (sort: DataTableSort[]) => void;

  /**
   * Lets the headers be dragged wider or narrower. A double-click on the handle
   * gives the column its original width back.
   * @default false
   */
  resizable?: boolean;
  /** The widths, keyed by column. Use with `onColumnWidthsChange`. */
  columnWidths?: Readonly<Record<string, number>>;
  /** What they start as, for an uncontrolled table. */
  defaultColumnWidths?: Readonly<Record<string, number>>;
  onColumnWidthsChange?: (widths: Record<string, number>) => void;

  /**
   * How many rows may be chosen.
   * @default 'none'
   */
  selectionMode?: DataTableSelectionMode;
  /** The chosen rows, as their keys. Use with `onSelectedChange`. */
  selected?: readonly React.Key[];
  /** Which start chosen, for an uncontrolled table. */
  defaultSelected?: readonly React.Key[];
  /** The keys, and the rows behind them — including rows on other pages. */
  onSelectedChange?: (selected: React.Key[], rows: Row[]) => void;
  /**
   * Adds a column of ticks, and one in the header that chooses every displayed
   * row at once. The rows stay clickable either way; this is for a table where
   * choosing is the task rather than something done on the way past.
   * @default false
   */
  checkboxes?: boolean;
  /** Fires on every press of a row, before the selection changes. */
  onRowClick?: (row: Row, index: number, event: React.MouseEvent<HTMLTableRowElement>) => void;
  /** Fires on a double-click, and on Enter. Opening the row is what this is. */
  onRowActivate?: (row: Row, index: number) => void;

  /**
   * Whether the rows arrive all at once or a page at a time.
   * @default 'scroll'
   */
  paging?: DataTablePaging;
  /** The current page, 1-based. Use with `onPageChange`. */
  page?: number;
  /** @default 1 */
  defaultPage?: number;
  onPageChange?: (page: number) => void;
  /** How many rows a page holds. Use with `onPageSizeChange`. */
  pageSize?: number;
  /** @default 25 */
  defaultPageSize?: number;
  onPageSizeChange?: (pageSize: number) => void;
  /**
   * What the footer's page-size Select offers. An empty list drops the control.
   * @default [10, 25, 50, 100]
   */
  pageSizeOptions?: readonly number[];
  /**
   * The bar under the table: how many rows there are, how many are chosen, and
   * the pages. On by default whenever `paging` is `pages`.
   */
  footer?: boolean;

  /**
   * The query every searchable column is matched against. Use with
   * `onSearchChange` for a controlled field.
   */
  search?: string;
  /** What it starts as, for an uncontrolled one. */
  defaultSearch?: string;
  onSearchChange?: (search: string) => void;
  /** Draws the search field above the table. @default false */
  searchable?: boolean;
  /** Overrides the field's placeholder and its accessible name. */
  searchPlaceholder?: string;
  /**
   * A filter of your own, applied after the search. Return `false` to drop a
   * row.
   */
  filter?: (row: Row, index: number) => boolean;
  /** Content at the end of the bar the search field sits in. */
  toolbar?: React.ReactNode;

  /**
   * Which stages the caller has already done — for a table whose rows come from
   * a server a page at a time. `true` is all three.
   *
   * With `pages` in the list, `items` is taken to be one page and `rowCount`
   * says how many rows there are in total.
   * @default false
   */
  manual?: boolean | readonly DataTableStage[];
  /** How many rows there are in total, when the table is not doing the paging. */
  rowCount?: number;

  /**
   * The language the table's own words are in — the search field's placeholder,
   * the ticks' labels, the footer's count.
   *
   * It is also what the default sort compares strings with. Pass it whenever
   * the markup is rendered on a server: without it the comparison follows the
   * runtime's own locale, and a server that disagrees with the browser about
   * that produces two different row orders for the same table.
   */
  locale?: string;
}

/* ---------------------------------------------------------------------------
 * Drawing
 * ------------------------------------------------------------------------- */

/**
 * The row's background is a slot rather than a class, for the reason Table's
 * is: it has a hover state, and an inline style has no `:hover`. Everything
 * inside a cell is inline — see the note on `paddingXValues` — and a slot is
 * the one way a class can still reach in there.
 */
const rowClasses = [
  '[--n-row:transparent]',
  '[transition:background-color_var(--neba-duration)_var(--neba-ease)]'
].join(' ');

/**
 * The zebra, and the one place this component leaves the panel ladder.
 *
 * The ladder is white over whatever is behind it — `--neba-panel` is 66% white
 * and `--neba-panel-hover` is 82% — so a stripe taken from it is a *lighter*
 * sheet, which reads beautifully over the gradient a docs page paints and not
 * at all over the white one a product ships. Zebra striping exists so the eye
 * can track across a wide row; a stripe that is invisible on a white page has
 * not done that.
 *
 * So it is mixed from `--neba-fg` instead: near-black on a light theme and
 * near-white on a dark one, four percent of either, which lands the same amount
 * of separation on both and on any backdrop. It is declared on the sheet rather
 * than on `:root` because a `var()` resolves where it is written, and a token
 * derived once at the top of the document would freeze to the light theme's
 * foreground inside a `.dark` subtree.
 */
const stripeSlot = { '--n-stripe': 'color-mix(in oklab, var(--neba-fg) 4%, transparent)' };

/**
 * The heading, as a control.
 *
 * A real `<button>`, so it is reachable by tab and announced as pressable. The
 * `<th>` around it carries `aria-sort`, which is what says *how* it is sorted;
 * the button only says that pressing changes it.
 */
const sortButtonClasses = [
  'group/sort flex w-full min-w-0 cursor-pointer items-center gap-1',
  'text-inherit [outline:none]',
  '[transition:color_var(--neba-duration)_var(--neba-ease)]',
  'hover:text-(--n-accent)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
  '[&_svg]:pointer-events-none [&_svg]:size-[1.15em] [&_svg]:shrink-0'
].join(' ');

/**
 * The grab area, wider than the line it draws.
 *
 * Eight pixels of target for a one-pixel affordance: a resize handle you have
 * to hit exactly is the reason people give up on resizing columns. It sits half
 * outside its own cell so the target straddles the boundary the way the cursor
 * says it does.
 */
const resizeHandleClasses = [
  'absolute inset-y-0 z-10 w-2 cursor-col-resize select-none',
  'end-0 translate-x-1/2 rtl:-translate-x-1/2',
  'after:absolute after:inset-y-1 after:start-1/2 after:w-px',
  'after:[background:transparent]',
  'after:[transition:background_var(--neba-duration)_var(--neba-ease)]',
  'hover:after:[background:var(--n-accent)]'
].join(' ');

/** The magnifier on the search field. Local: nothing else in the library draws one. */
function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="7.25" cy="7.25" r="4.75" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="m10.75 10.75 2.75 2.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/** A CSS length out of a prop that may be a number of pixels. */
function toLength(value: number | string | undefined): string | undefined {
  return typeof value === 'number' ? `${value}px` : value;
}

/** One row of `items`, with everything the table needs to talk about it. */
interface RowEntry<Row> {
  row: Row;
  /** The caller's key, handed back verbatim by `onSelectedChange`. */
  identity: React.Key;
  /** The same key as a string, which is what the sets and the ranges use. */
  key: string;
  /** Where it sat in `items`, which is what `getRowKey` was told. */
  origin: number;
}

/* ---------------------------------------------------------------------------
 * The component
 * ------------------------------------------------------------------------- */

/**
 * A table for a lot of rows.
 *
 * [Table](../display/table) draws a grid; this one is a place to work. The
 * difference shows up in three decisions and everything else follows from them.
 *
 * **The rows are all the same height, and it is a number.** That is what lets
 * the body render thirty rows out of two hundred thousand and still put the
 * scrollbar in the right place — the offset of a row is its index times a
 * constant, so nothing has to be measured on a scroll frame. It is also why
 * cells truncate instead of wrapping: a cell that decides its own height would
 * make every arithmetic answer above a guess.
 *
 * **Selecting is the file manager's, not the form's.** A click chooses a row
 * and drops the rest, Ctrl adds one, Shift takes the run between, a drag takes
 * the run under the pointer, and the arrow keys do all three with the same
 * modifiers. Ticks are available and are not the default: a column of
 * checkboxes says the task is choosing, and on most tables it is not.
 *
 * **The three stages are one pipeline, and the caller can take over any of
 * them.** Search, then sort, then cut a page out — done here over `items` by
 * default, and skipped stage by stage through `manual` for a table whose server
 * is doing it. Both paths render the same, which is what stops a table that
 * starts local and grows remote from becoming a second component.
 */
export function DataTable<Row>({
  headers,
  items,
  getRowKey,

  variant = 'outline',
  size = 'sm',
  color = 'primary',
  density = 'compact',
  elevation = 0,
  height,
  maxHeight,
  rowHeight: rowHeightProp,
  striped = false,
  hoverable = true,
  stickyHeader = true,
  caption,
  label,
  empty,

  virtual = true,
  overscan = 8,

  sortable = false,
  sortMode = 'single',
  sort: sortProp,
  defaultSort,
  onSortChange,

  resizable = false,
  columnWidths,
  defaultColumnWidths,
  onColumnWidthsChange,

  selectionMode = 'none',
  selected,
  defaultSelected,
  onSelectedChange,
  checkboxes = false,
  onRowClick,
  onRowActivate,

  paging = 'scroll',
  page: pageProp,
  defaultPage = 1,
  onPageChange,
  pageSize: pageSizeProp,
  defaultPageSize = 25,
  onPageSizeChange,
  pageSizeOptions = [10, 25, 50, 100],
  footer,

  search: searchProp,
  defaultSearch,
  onSearchChange,
  searchable = false,
  searchPlaceholder,
  filter,
  toolbar,

  manual = false,
  rowCount,

  locale,
  className,
  style,
  ...boxProps
}: DataTableProps<Row>) {
  const messages = useMessages(tableMessages, locale);
  const emptyText = useMessages(emptyMessages, locale);
  const reactId = React.useId();

  const rowHeight = rowHeightProp ?? dataRowHeights[density][size];
  const headerHeight = dataHeaderHeights[density][size];
  const padX = paddingXValues[density][size];

  const stages = React.useMemo<ReadonlySet<DataTableStage>>(
    () => new Set(manual === true ? (['sort', 'filter', 'pages'] as const) : manual || []),
    [manual]
  );

  const columns = React.useMemo(() => headers.filter((column) => !column.hidden), [headers]);
  const hasGroups = columns.some((column) => column.group !== undefined);

  const selects = selectionMode !== 'none';
  const multiple = selectionMode === 'multiple';
  const showTicks = selects && checkboxes;

  /* -- The rows, and the three stages ------------------------------------- */

  const entries = React.useMemo<RowEntry<Row>[]>(
    () =>
      items.map((row, index) => {
        const identity = getRowKey ? getRowKey(row, index) : index;

        return { row, identity, key: String(identity), origin: index };
      }),
    [items, getRowKey]
  );

  const [uncontrolledSearch, setUncontrolledSearch] = React.useState(defaultSearch ?? '');
  const query = (searchProp ?? uncontrolledSearch).trim();

  const filtered = React.useMemo(() => {
    if (stages.has('filter')) {
      return entries;
    }

    const needle = searchText(query);
    const searched = columns.filter((column) => column.searchable !== false);

    let result = entries;

    if (needle !== '' && searched.length > 0) {
      result = result.filter((entry) =>
        searched.some((column) => {
          const value = column.value
            ? column.value(entry.row)
            : (entry.row as Record<string, unknown>)[column.key];

          return searchText(value).includes(needle);
        })
      );
    }

    return filter ? result.filter((entry) => filter(entry.row, entry.origin)) : result;
  }, [entries, columns, query, filter, stages]);

  /*
   * The collator is built once per locale rather than per comparison: building
   * one is the expensive half of `localeCompare`, and a sort of a hundred
   * thousand rows calls it a million times.
   */
  const collator = React.useMemo(
    () => new Intl.Collator(locale, { numeric: true, sensitivity: 'base' }),
    [locale]
  );

  const [uncontrolledSort, setUncontrolledSort] = React.useState<readonly DataTableSort[]>(
    defaultSort ?? []
  );
  const sort = sortProp ?? uncontrolledSort;

  const sorted = React.useMemo(() => {
    if (stages.has('sort')) {
      return filtered;
    }

    return sortRows<RowEntry<Row>>(filtered, sort as readonly SortEntry[], (key) => {
      const column = columns.find((entry) => entry.key === key);

      if (!column) {
        return null;
      }

      if (column.compare) {
        return (a, b) => column.compare!(a.row, b.row);
      }

      const read = column.value
        ? column.value
        : (row: Row) => (row as Record<string, unknown>)[column.key];

      return (a, b) => compareValues(read(a.row), read(b.row), collator);
    });
  }, [filtered, sort, columns, collator, stages]);

  /* -- Paging -------------------------------------------------------------- */

  const [uncontrolledPage, setUncontrolledPage] = React.useState(defaultPage);
  const [uncontrolledPageSize, setUncontrolledPageSize] = React.useState(defaultPageSize);
  const pageSize = pageSizeProp ?? uncontrolledPageSize;
  const total = stages.has('pages') ? (rowCount ?? sorted.length) : sorted.length;
  const bounds = pageBounds(total, pageProp ?? uncontrolledPage, pageSize);

  const paged = React.useMemo(() => {
    if (paging !== 'pages' || stages.has('pages')) {
      return sorted;
    }

    return sorted.slice(bounds.start, bounds.end);
  }, [sorted, paging, stages, bounds.start, bounds.end]);

  /** Where a displayed row sits in the sorted, filtered order — what `render` is told. */
  const displayOffset = paging === 'pages' ? bounds.start : 0;

  /*
   * The displayed keys, once.
   *
   * Everything about selecting is a question about this list — is the range
   * between these two, is every one of them chosen, how many are — and in
   * `scroll` mode it is every row the table has. Recomputing it inside a
   * pointermove handler is the difference between a drag that keeps up and one
   * that walks a hundred thousand strings sixty times a second.
   */
  const pagedKeys = React.useMemo(() => paged.map((entry) => entry.key), [paged]);
  const byKey = React.useMemo(() => new Map(entries.map((entry) => [entry.key, entry])), [entries]);

  /* -- Selection ----------------------------------------------------------- */

  const [uncontrolledSelected, setUncontrolledSelected] = React.useState<readonly React.Key[]>(
    defaultSelected ?? []
  );
  const selectedValues = selected ?? uncontrolledSelected;
  const selectedKeys = React.useMemo(() => new Set(selectedValues.map(String)), [selectedValues]);

  const [activeKey, setActiveKey] = React.useState<string | null>(null);
  const anchorRef = React.useRef<string | null>(null);

  /*
   * The pointer handlers and the two window listeners a drag installs all need
   * the current rows, and none of them can be re-bound on every render without
   * tearing a drag in half. They read this instead.
   */
  const latest = React.useRef({ paged, pagedKeys, byKey, selectedKeys, multiple });
  // Read by handlers and by window listeners, never during a render — and
  // re-binding those per render is what a drag cannot survive.
  // eslint-disable-next-line react-hooks/refs
  latest.current = { paged, pagedKeys, byKey, selectedKeys, multiple };

  /**
   * Turns a set of string keys back into what the caller handed over.
   *
   * The keys are strings because that is what a `Set` and a range can be built
   * out of, and `2` and `'2'` are the same string — so the identity that goes
   * back out has to be looked up rather than cast, exactly as TreeView keeps
   * its values beside its keys.
   */
  const commitSelection = React.useCallback(
    (keys: readonly string[]) => {
      const chosen: React.Key[] = [];
      const rows: Row[] = [];

      for (const key of keys) {
        const entry = latest.current.byKey.get(key);

        if (entry) {
          chosen.push(entry.identity);
          rows.push(entry.row);
        }
      }

      if (selected === undefined) {
        setUncontrolledSelected(chosen);
      }

      onSelectedChange?.(chosen, rows);
    },
    [selected, onSelectedChange]
  );

  /** Replaces the selection with one row, which is what a plain click does. */
  const selectOnly = React.useCallback(
    (key: string) => {
      anchorRef.current = key;
      commitSelection([key]);
    },
    [commitSelection]
  );

  const toggleKey = React.useCallback(
    (key: string) => {
      const current = latest.current.selectedKeys;
      const next = new Set(current);

      if (next.has(key)) {
        next.delete(key);
      } else {
        next.add(key);
      }

      anchorRef.current = key;
      commitSelection([...next]);
    },
    [commitSelection]
  );

  /** Shift: the run between the anchor and here, replacing what was chosen. */
  const selectRange = React.useCallback(
    (key: string, additive: boolean) => {
      const order = latest.current.pagedKeys;
      const anchor = anchorRef.current ?? order[0];

      if (anchor === undefined) {
        return;
      }

      const run = keysBetween(order, anchor, key);

      if (run.length === 0) {
        return;
      }

      commitSelection(additive ? [...new Set([...latest.current.selectedKeys, ...run])] : run);
    },
    [commitSelection]
  );

  /* -- The scrolling body -------------------------------------------------- */

  const viewportRef = React.useRef<HTMLDivElement | null>(null);
  const bodyRef = React.useRef<HTMLTableSectionElement | null>(null);
  const tableRef = React.useRef<HTMLTableElement | null>(null);

  const [viewportHeight, setViewportHeight] = React.useState(0);
  const [scrollTop, setScrollTop] = React.useState(0);

  const bounded = height !== undefined || maxHeight !== undefined;
  const virtualized = virtual && bounded && paged.length > 0;

  React.useLayoutEffect(() => {
    const node = viewportRef.current;

    if (!node || !virtualized) {
      return;
    }

    const observer = new ResizeObserver(([entry]) => {
      setViewportHeight(entry.contentRect.height);
    });

    observer.observe(node);
    setViewportHeight(node.clientHeight);

    return () => observer.disconnect();
  }, [virtualized]);

  /*
   * The offset is quantized to whole rows before it becomes state. The window
   * only changes when the offset crosses a row boundary, so storing the raw
   * pixel would re-render sixty times a second to produce the same thirty rows;
   * setting the same value back is a bail-out React already knows how to make.
   */
  const handleScroll = React.useCallback(
    (event: React.UIEvent<HTMLDivElement>) => {
      if (!virtualized) {
        return;
      }

      const next = Math.floor(event.currentTarget.scrollTop / rowHeight) * rowHeight;

      setScrollTop((previous) => (previous === next ? previous : next));
    },
    [virtualized, rowHeight]
  );

  const window_ = virtualized
    ? virtualWindow(scrollTop, viewportHeight, rowHeight, paged.length, overscan)
    : { start: 0, end: paged.length, before: 0, after: 0 };

  const rendered = paged.slice(window_.start, window_.end);
  const activeRendered =
    selects && activeKey !== null && rendered.some((entry) => entry.key === activeKey);

  /* -- Column widths ------------------------------------------------------- */

  const [uncontrolledWidths, setUncontrolledWidths] = React.useState<Record<string, number>>(
    defaultColumnWidths ?? {}
  );
  const widths = columnWidths ?? uncontrolledWidths;

  const setWidths = React.useCallback(
    (next: Record<string, number>) => {
      if (columnWidths === undefined) {
        setUncontrolledWidths(next);
      }

      onColumnWidthsChange?.(next);
    },
    [columnWidths, onColumnWidthsChange]
  );

  const headRefs = React.useRef(new Map<string, HTMLTableCellElement>());

  /**
   * A drag freezes every column, not just the one being pulled.
   *
   * Until the first drag most columns have no width of their own and share
   * what is left — which means widening one would narrow all the others by the
   * same amount, and the reader would watch four columns move to resize one. So
   * the first `pointerdown` reads what the browser has actually laid out and
   * writes all of it down; from then on every column is explicit and a drag
   * moves exactly one boundary.
   */
  const startResize = (key: string, event: React.PointerEvent<HTMLSpanElement>) => {
    event.preventDefault();
    event.stopPropagation();

    const handle = event.currentTarget;
    const frozen: Record<string, number> = { ...widths };

    for (const column of columns) {
      const cell = headRefs.current.get(column.key);

      if (cell && frozen[column.key] === undefined) {
        frozen[column.key] = Math.round(cell.getBoundingClientRect().width);
      }
    }

    const rtl = getComputedStyle(handle).direction === 'rtl';
    const startX = event.clientX;
    const startWidth = frozen[key] ?? defaultColumnWidth;
    const floor = columns.find((column) => column.key === key)?.minWidth ?? minColumnWidth;

    handle.setPointerCapture(event.pointerId);

    const move = (moveEvent: PointerEvent) => {
      const delta = (moveEvent.clientX - startX) * (rtl ? -1 : 1);

      setWidths({ ...frozen, [key]: Math.max(floor, Math.round(startWidth + delta)) });
    };

    const stop = () => {
      handle.removeEventListener('pointermove', move);
      handle.removeEventListener('pointerup', stop);
      handle.removeEventListener('pointercancel', stop);
    };

    handle.addEventListener('pointermove', move);
    handle.addEventListener('pointerup', stop);
    handle.addEventListener('pointercancel', stop);
  };

  /** A double-click gives the column back whatever width it had before. */
  const resetWidth = (key: string) => {
    const next = { ...widths };

    delete next[key];
    setWidths(next);
  };

  /* -- Sorting ------------------------------------------------------------- */

  const applySort = (key: string, additive: boolean) => {
    const next = nextSort(sort as readonly SortEntry[], key, additive && sortMode === 'multiple');

    if (sortProp === undefined) {
      setUncontrolledSort(next);
    }

    onSortChange?.(next);
  };

  const sortFor = (key: string) => sort.find((entry) => entry.key === key);

  /* -- Moving about -------------------------------------------------------- */

  /**
   * Puts a row on screen by arithmetic rather than by `scrollIntoView`.
   *
   * The row may not be in the DOM at all — that is the whole point of the
   * virtual mode — and even when it is, `scrollIntoView` would slide it under
   * the sticky header, which is not "in view".
   */
  const revealRow = React.useCallback(
    (index: number) => {
      const node = viewportRef.current;

      if (!node || !bounded) {
        return;
      }

      const headerTotal = stickyHeader ? headerHeight * (hasGroups ? 2 : 1) : 0;
      const top = index * rowHeight;
      const above = node.scrollTop + headerTotal;

      if (top < above) {
        node.scrollTop = Math.max(0, top - headerTotal);
      } else if (top + rowHeight > node.scrollTop + node.clientHeight) {
        node.scrollTop = top + rowHeight - node.clientHeight;
      }
    },
    [bounded, stickyHeader, headerHeight, hasGroups, rowHeight]
  );

  const moveActive = (index: number, event: React.KeyboardEvent) => {
    const rows = latest.current.paged;
    const target = Math.min(Math.max(index, 0), rows.length - 1);
    const entry = rows[target];

    if (!entry) {
      return;
    }

    event.preventDefault();
    setActiveKey(entry.key);
    revealRow(target);

    if (event.shiftKey && latest.current.multiple) {
      selectRange(entry.key, false);
    } else if (!event.ctrlKey && !event.metaKey) {
      selectOnly(entry.key);
    }
  };

  function handleKeyDown(event: React.KeyboardEvent<HTMLTableElement>) {
    // Only when the *table* has the focus. A sortable heading is a real button
    // inside this element, and its Enter and its Space belong to it — a table
    // that answered them here would sort a column and open a row at once.
    if (!selects || event.target !== event.currentTarget) {
      return;
    }

    const rows = latest.current.paged;

    if (rows.length === 0) {
      return;
    }

    const index = activeKey === null ? -1 : latest.current.pagedKeys.indexOf(activeKey);
    const perScreen = Math.max(1, Math.floor((viewportHeight || rowHeight * 10) / rowHeight) - 1);

    switch (event.key) {
      case 'ArrowDown':
        moveActive(index + 1, event);
        break;
      case 'ArrowUp':
        moveActive(index === -1 ? 0 : index - 1, event);
        break;
      case 'Home':
        moveActive(0, event);
        break;
      case 'End':
        moveActive(rows.length - 1, event);
        break;
      case 'PageDown':
        moveActive(index === -1 ? 0 : index + perScreen, event);
        break;
      case 'PageUp':
        moveActive(index === -1 ? 0 : index - perScreen, event);
        break;
      case ' ':
        // Space is the one key that chooses without moving, and the reason the
        // arrows can be told to move without choosing.
        if (index !== -1) {
          event.preventDefault();

          if ((event.ctrlKey || event.metaKey) && multiple) {
            toggleKey(rows[index].key);
          } else {
            selectOnly(rows[index].key);
          }
        }
        break;
      case 'a':
      case 'A':
        if ((event.ctrlKey || event.metaKey) && multiple) {
          event.preventDefault();
          commitSelection(latest.current.pagedKeys);
        }
        break;
      case 'Escape':
        event.preventDefault();
        commitSelection([]);
        break;
      case 'Enter':
        if (index !== -1 && onRowActivate) {
          event.preventDefault();
          onRowActivate(rows[index].row, displayOffset + index);
        }
        break;
      default:
        break;
    }
  }

  /* -- Dragging a range ---------------------------------------------------- */

  /**
   * Which row a pointer is over, worked out from where the body starts.
   *
   * Every row is `rowHeight` tall and the spacer standing in for the rows above
   * is a whole number of them, so the whole `<tbody>` is a linear map from a
   * y coordinate to an index — including over the rows that are not rendered.
   * That is what makes a drag that scrolls work at all: hit-testing the DOM
   * would find nothing where the spacer is.
   */
  const rowIndexAt = React.useCallback(
    (clientY: number) => {
      const body = bodyRef.current;
      const rows = latest.current.paged;

      if (!body || rows.length === 0) {
        return null;
      }

      const top = body.getBoundingClientRect().top;
      const index = Math.floor((clientY - top) / rowHeight);

      return Math.min(Math.max(index, 0), rows.length - 1);
    },
    [rowHeight]
  );

  /**
   * A drag in progress: where the pointer is, how fast the body is running
   * under it, and the frame that keeps doing both.
   *
   * `stop` is stored beside them rather than rebuilt, because the listeners a
   * drag installs have to be removed with the *same* function objects. A
   * `useCallback` cannot promise that — a re-render mid-drag (and the selection
   * changing is one) would hand back a new identity and leave the old listener
   * on the window for the rest of the page's life.
   */
  const dragRef = React.useRef<{
    y: number;
    speed: number;
    frame: number | null;
    stop: () => void;
  } | null>(null);

  /** Takes the run from the anchor to whichever row the pointer is over. */
  const dragTo = React.useCallback(
    (clientY: number) => {
      const index = rowIndexAt(clientY);
      const entry = index === null ? undefined : latest.current.paged[index];

      if (entry) {
        setActiveKey(entry.key);
        selectRange(entry.key, false);
      }
    },
    [rowIndexAt, selectRange]
  );

  const dragToRef = React.useRef(dragTo);
  // The two window listeners a drag installs must not be re-bound while it is
  // running, or the drag tears in half. They read the latest callback through
  // this instead. Nothing renders from it, so a stale read shows nothing stale.
  // eslint-disable-next-line react-hooks/refs
  dragToRef.current = dragTo;

  /**
   * A drag that reaches the edge keeps going.
   *
   * Without it, dragging a range can only ever take what was already on screen
   * — and a table with a bounded height is exactly the one where the run you
   * want is longer than the viewport. The speed is how far past the edge the
   * pointer is, capped, so easing off slows the scroll instead of stopping it.
   */
  const startDrag = (clientY: number) => {
    if (dragRef.current) {
      return;
    }

    const move = (event: PointerEvent) => {
      const drag = dragRef.current;
      const node = viewportRef.current;

      if (!drag) {
        return;
      }

      drag.y = event.clientY;
      dragToRef.current(drag.y);

      if (!node || !bounded) {
        return;
      }

      const rect = node.getBoundingClientRect();
      const above = rect.top + rowHeight - drag.y;
      const below = drag.y - (rect.bottom - rowHeight);

      drag.speed = above > 0 ? -Math.min(above, 40) : below > 0 ? Math.min(below, 40) : 0;

      if (drag.speed !== 0 && drag.frame === null) {
        drag.frame = requestAnimationFrame(step);
      }
    };

    const step = () => {
      const drag = dragRef.current;
      const node = viewportRef.current;

      if (!drag || !node || drag.speed === 0) {
        if (drag) {
          drag.frame = null;
        }

        return;
      }

      node.scrollTop += drag.speed;
      // The rows have moved under a pointer that has not, so the run has to be
      // taken again from where it now points.
      dragToRef.current(drag.y);
      drag.frame = requestAnimationFrame(step);
    };

    const stop = () => {
      const drag = dragRef.current;

      if (drag?.frame !== null && drag?.frame !== undefined) {
        cancelAnimationFrame(drag.frame);
      }

      dragRef.current = null;
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', stop);
      window.removeEventListener('pointercancel', stop);
    };

    dragRef.current = { y: clientY, speed: 0, frame: null, stop };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', stop);
    window.addEventListener('pointercancel', stop);
  };

  // A table that unmounts mid-drag would otherwise leave both listeners and a
  // running frame behind.
  React.useEffect(() => () => dragRef.current?.stop(), []);

  /* -- Pressing a row ------------------------------------------------------ */

  function handleRowPointerDown(
    entry: RowEntry<Row>,
    event: React.PointerEvent<HTMLTableRowElement>
  ) {
    if (!selects) {
      return;
    }

    // Anything pressable inside a cell keeps its press: a tick, a row menu, a
    // link. The row is what is left over.
    if (
      (event.target as HTMLElement).closest('button, a, input, select, textarea, [role="button"]')
    ) {
      return;
    }

    // The table is the tab stop, not the row — a virtual body cannot hold one,
    // because the row that had it is unmounted the moment it scrolls away.
    tableRef.current?.focus({ preventScroll: true });
    setActiveKey(entry.key);

    if (event.button === 2) {
      // A right-click on a row outside the selection takes the selection with
      // it, so the menu that follows is about what was pressed. On a row that
      // is already chosen it changes nothing, which is what keeps "act on all
      // of these" possible.
      if (!latest.current.selectedKeys.has(entry.key)) {
        selectOnly(entry.key);
      }

      return;
    }

    if (event.button !== 0) {
      return;
    }

    if (event.shiftKey && multiple) {
      event.preventDefault();
      selectRange(entry.key, event.ctrlKey || event.metaKey);

      return;
    }

    if ((event.ctrlKey || event.metaKey) && multiple) {
      toggleKey(entry.key);

      return;
    }

    selectOnly(entry.key);

    if (multiple) {
      startDrag(event.clientY);
    }
  }

  /* -- The tick column ----------------------------------------------------- */

  const chosenHere = React.useMemo(
    () => pagedKeys.reduce((count, key) => (selectedKeys.has(key) ? count + 1 : count), 0),
    [pagedKeys, selectedKeys]
  );
  const allChosen = pagedKeys.length > 0 && chosenHere === pagedKeys.length;

  /*
   * The header tick works on the rows that are *displayed*, not on every row
   * there is. On page 3 of a filtered table it chooses page 3 — which is what
   * the tick is sitting above — and a row chosen on page 2 stays chosen, which
   * is why it unticks by subtraction rather than by emptying the set.
   */
  const toggleAll = () => {
    if (allChosen) {
      const here = new Set(pagedKeys);

      commitSelection([...selectedKeys].filter((key) => !here.has(key)));
    } else {
      commitSelection([...new Set([...selectedKeys, ...pagedKeys])]);
    }
  };

  /* -- Geometry ------------------------------------------------------------ */

  const tickWidth = dataTickWidths[size];
  const explicitWidth = (column: DataTableColumn<Row>) => widths[column.key] ?? column.width;
  const minTableWidth =
    (showTicks ? tickWidth : 0) +
    columns.reduce((sum, column) => sum + (explicitWidth(column) ?? minColumnWidth), 0);

  /**
   * An empty column at the end, once every real column has a width of its own.
   *
   * With `table-layout: fixed`, space the columns do not claim is handed back
   * to them — so on a wide screen a 120px column is not 120px, and dragging one
   * boundary would move all of them. The filler claims the slack instead, which
   * is what makes a dragged width the width it says it is. It only exists when
   * there is slack to claim: a table with any flexible column has none.
   */
  const filler =
    columns.length > 0 && columns.every((column) => explicitWidth(column) !== undefined);

  const columnCount = columns.length + (showTicks ? 1 : 0) + (filler ? 1 : 0);

  /** Adjacent columns carrying the same `group`, merged into one heading. */
  const groupRuns = React.useMemo(() => {
    const runs: { label: string | undefined; span: number; from: number }[] = [];

    columns.forEach((column, index) => {
      const previous = runs[runs.length - 1];

      if (previous && previous.label !== undefined && previous.label === column.group) {
        previous.span += 1;
      } else {
        runs.push({ label: column.group, span: 1, from: index });
      }
    });

    return runs;
  }, [columns]);

  /* -- Styles -------------------------------------------------------------- */

  const cellStyle: React.CSSProperties = {
    padding: `0 ${padX}`,
    borderBottom: '1px solid var(--n-line)',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap'
  };

  const headCellStyle: React.CSSProperties = {
    ...cellStyle,
    height: `${headerHeight}px`,
    backgroundColor: 'var(--n-panel-press)'
  };

  const stripeIndex = striped === 'odd' ? 0 : 1;

  /* -- The footer ---------------------------------------------------------- */

  const number = React.useMemo(() => new Intl.NumberFormat(locale), [locale]);
  const showFooter = footer ?? paging === 'pages';

  const rangeText = fillMessage(messages.range, {
    start: number.format(total === 0 ? 0 : (paging === 'pages' ? bounds.start : 0) + 1),
    end: number.format(paging === 'pages' ? bounds.end : total),
    total: number.format(total)
  });

  const goToPage = (next: number) => {
    if (pageProp === undefined) {
      setUncontrolledPage(next);
    }

    onPageChange?.(next);
  };

  /* -- Render -------------------------------------------------------------- */

  const heading = (column: DataTableColumn<Row>, index: number, rowSpan?: number) => {
    const canSort = column.sortable ?? sortable;
    const canResize = column.resizable ?? resizable;
    const entry = sortFor(column.key);
    const order = entry ? sort.findIndex((item) => item.key === column.key) + 1 : 0;
    const align = column.headerAlign ?? column.align ?? 'start';

    return (
      <th
        key={column.key}
        ref={(node) => {
          if (node) {
            headRefs.current.set(column.key, node);
          } else {
            headRefs.current.delete(column.key);
          }
        }}
        scope="col"
        rowSpan={rowSpan}
        aria-sort={entry ? (entry.direction === 'asc' ? 'ascending' : 'descending') : undefined}
        className={cx(
          'relative font-semibold select-none',
          entry ? 'text-(--n-accent)' : 'text-(--neba-muted-fg)',
          stickyHeader ? 'sticky z-20 [backdrop-filter:var(--neba-blur)]' : ''
        )}
        style={{
          ...headCellStyle,
          top: stickyHeader ? (rowSpan === 2 || !hasGroups ? 0 : headerHeight) : undefined,
          textAlign: align
        }}
      >
        {canSort ? (
          <button
            type="button"
            className={cx(
              sortButtonClasses,
              align === 'end'
                ? 'justify-end'
                : align === 'center'
                  ? 'justify-center'
                  : 'justify-start'
            )}
            onClick={(event) => applySort(column.key, event.shiftKey)}
          >
            <span className="min-w-0 truncate">{column.label ?? column.key}</span>

            {/*
              Turned, not moved — the one allowance the no-transform rule makes.

              The box is always there and the arrow inside it is not always
              painted, which is what keeps a heading from jumping sideways the
              moment it is pointed at. Unpainted means `text-transparent`, a
              colour: the state is carried on the colour axis like every other
              one in the library, and not on `opacity`. Unsorted, it points the
              way the next press will sort — which is how a reader finds out
              that a column sorts at all.

              Going back to `text-inherit` rather than to a colour of its own is
              what keeps the arrow the same colour as the label it belongs to,
              and it wins over the `text-transparent` beside it on specificity
              rather than on the order the two happen to be generated in.
            */}
            <span
              aria-hidden="true"
              className={cx(
                'flex items-center',
                entry?.direction === 'desc' ? 'rotate-0' : 'rotate-180',
                entry
                  ? ''
                  : 'text-transparent group-hover/sort:text-inherit group-focus-visible/sort:text-inherit'
              )}
            >
              <ChevronIcon />
            </span>

            {order > 1 ? (
              <span aria-hidden="true" className="text-[0.85em] tabular-nums">
                {order}
              </span>
            ) : null}
          </button>
        ) : (
          <span className="block truncate">{column.label ?? column.key}</span>
        )}

        {canResize && index < columns.length - 1 ? (
          <span
            aria-hidden="true"
            className={resizeHandleClasses}
            onPointerDown={(event) => startResize(column.key, event)}
            onDoubleClick={() => resetWidth(column.key)}
          />
        ) : null}
      </th>
    );
  };

  /*
   * The tick is centred by a flex box around it rather than by `align-middle`
   * on the Checkbox itself: Checkbox's own root already carries `align-top`,
   * and two Tailwind utilities of equal specificity resolve by their order in
   * the generated stylesheet rather than by which one was written last.
   */
  const tickBox = (control: React.ReactNode) => (
    <span className="flex items-center justify-center">{control}</span>
  );

  const tickCell = (entry: RowEntry<Row>) => (
    <td
      role={selects ? 'gridcell' : undefined}
      style={{ ...cellStyle, padding: 0, overflow: 'visible' }}
    >
      {tickBox(
        <Checkbox
          size={size}
          color={color}
          checked={selectedKeys.has(entry.key)}
          aria-label={messages.selectRow}
          onCheckedChange={() => {
            if (multiple) {
              toggleKey(entry.key);
            } else {
              selectOnly(entry.key);
            }
          }}
        />
      )}
    </td>
  );

  const selectAllTick = multiple
    ? tickBox(
        <Checkbox
          size={size}
          color={color}
          checked={allChosen}
          indeterminate={chosenHere > 0 && !allChosen}
          aria-label={messages.selectAll}
          onCheckedChange={toggleAll}
        />
      )
    : null;

  /** The filler's cells: no content, no rule of their own, just the slack. */
  const fillerHead = filler ? (
    <th
      aria-hidden="true"
      className={cx(stickyHeader ? 'sticky top-0 z-20 [backdrop-filter:var(--neba-blur)]' : '')}
      style={{ ...headCellStyle, padding: 0 }}
    />
  ) : null;

  const spacer = (key: string, size_: number) =>
    size_ > 0 ? (
      <tr key={key} aria-hidden="true" style={{ height: `${size_}px` }}>
        <td colSpan={columnCount} style={{ padding: 0, border: 0 }} />
      </tr>
    ) : null;

  return (
    <Box
      variant={variant}
      size={size}
      color={color}
      density={density}
      elevation={elevation}
      padded={false}
      className={cx(
        'flex flex-col overflow-hidden',
        selects
          ? 'has-[:focus-visible]:[outline:2px_solid_var(--n-ring)] has-[:focus-visible]:outline-offset-2'
          : '',
        className
      )}
      style={{ ...stripeSlot, ...style } as React.CSSProperties}
      {...boxProps}
    >
      {searchable || hasContent(toolbar) ? (
        <div
          className="flex items-center gap-2"
          style={{ padding: `${padX} ${padX}`, borderBottom: '1px solid var(--n-line)' }}
        >
          {searchable ? (
            <TextField
              size={size}
              color={color}
              density={density}
              variant="outline"
              type="search"
              className="w-full max-w-64"
              startIcon={<SearchIcon />}
              placeholder={searchPlaceholder ?? messages.search}
              aria-label={searchPlaceholder ?? messages.search}
              value={searchProp ?? uncontrolledSearch}
              onChange={(event) => {
                const next = event.target.value;

                if (searchProp === undefined) {
                  setUncontrolledSearch(next);
                }

                // A query that cuts the table to three pages has to take the
                // reader with it, or page 14 answers a search with nothing.
                goToPage(1);
                onSearchChange?.(next);
              }}
            />
          ) : null}

          {hasContent(toolbar) ? (
            <div className="ms-auto flex items-center gap-2">{toolbar}</div>
          ) : null}
        </div>
      ) : null}

      {/* `flex-auto`, never `flex-1`. Tailwind's `flex-1` is `flex: 1 1 0%`, and
          a `flex-basis` of zero is what decides an item's main size — the
          `height` written beside it would be ignored, which on this component
          means the one prop that turns virtual scrolling on does nothing.
          `flex: 1 1 auto` takes its base size from that height and still grows
          into a taller sheet when there is one. */}
      <div
        ref={viewportRef}
        className="min-h-0 flex-auto overflow-auto overscroll-contain"
        style={{ height: toLength(height), maxHeight: toLength(maxHeight) }}
        onScroll={handleScroll}
      >
        <table
          ref={tableRef}
          role={selects ? 'grid' : undefined}
          aria-label={label}
          aria-multiselectable={multiple || undefined}
          aria-rowcount={virtualized ? paged.length + 1 : undefined}
          // Only while the row it names is actually rendered. A wheel can carry
          // the active row out of the virtual window, and pointing the
          // attribute at an id that is no longer in the document is worse than
          // pointing it nowhere.
          aria-activedescendant={activeRendered ? `${reactId}-${activeKey}` : undefined}
          tabIndex={selects ? 0 : undefined}
          className={cx(
            'w-full text-start [outline:none]',
            controlTextLeadingClasses[size],
            'text-(--neba-fg)',
            selects ? 'select-none' : ''
          )}
          style={{
            tableLayout: 'fixed',
            borderCollapse: 'separate',
            borderSpacing: 0,
            minWidth: `${minTableWidth}px`
          }}
          onKeyDown={handleKeyDown}
        >
          {caption ? (
            <caption
              className={cx(metaTextClasses[size], 'text-(--neba-muted-fg)')}
              style={{ padding: `0.5rem ${padX}`, textAlign: 'start' }}
            >
              {caption}
            </caption>
          ) : null}

          {/* Widths belong on a `<col>`: a width on a `<th>` is a width the
              browser renegotiates against every row under it. */}
          <colgroup>
            {showTicks ? <col style={{ width: `${tickWidth}px` }} /> : null}
            {columns.map((column) => {
              const width = explicitWidth(column);

              return (
                <col
                  key={column.key}
                  style={width === undefined ? undefined : { width: `${width}px` }}
                />
              );
            })}
            {filler ? <col /> : null}
          </colgroup>

          <thead>
            {hasGroups ? (
              <tr style={{ height: `${headerHeight}px` }}>
                {showTicks ? (
                  <th
                    scope="col"
                    rowSpan={2}
                    className={cx(
                      stickyHeader ? 'sticky top-0 z-20 [backdrop-filter:var(--neba-blur)]' : ''
                    )}
                    style={{ ...headCellStyle, padding: 0, overflow: 'visible' }}
                  >
                    {selectAllTick}
                  </th>
                ) : null}

                {groupRuns.map((run) =>
                  run.label === undefined ? (
                    // A column outside every group spans both rows rather than
                    // sitting under an empty band, so its heading stays on the
                    // same line as the ones that are grouped.
                    heading(columns[run.from], run.from, 2)
                  ) : (
                    <th
                      key={`group-${run.from}`}
                      scope="colgroup"
                      colSpan={run.span}
                      className={cx(
                        'font-semibold text-(--neba-muted-fg) select-none',
                        stickyHeader ? 'sticky top-0 z-20 [backdrop-filter:var(--neba-blur)]' : ''
                      )}
                      style={{ ...headCellStyle, textAlign: 'center' }}
                    >
                      {run.label}
                    </th>
                  )
                )}

                {filler ? React.cloneElement(fillerHead!, { rowSpan: 2 }) : null}
              </tr>
            ) : null}

            <tr style={{ height: `${headerHeight}px` }}>
              {showTicks && !hasGroups ? (
                <th
                  scope="col"
                  className={cx(
                    stickyHeader ? 'sticky top-0 z-20 [backdrop-filter:var(--neba-blur)]' : ''
                  )}
                  style={{ ...headCellStyle, padding: 0, overflow: 'visible' }}
                >
                  {selectAllTick}
                </th>
              ) : null}

              {columns.map((column, index) =>
                hasGroups && column.group === undefined ? null : heading(column, index)
              )}

              {filler && !hasGroups ? fillerHead : null}
            </tr>
          </thead>

          <tbody ref={bodyRef}>
            {paged.length === 0 ? (
              <tr>
                <td
                  colSpan={columnCount}
                  className="text-(--neba-muted-fg)"
                  style={{ padding: `2rem ${padX}`, textAlign: 'center' }}
                >
                  {empty ?? emptyText.title}
                </td>
              </tr>
            ) : (
              <>
                {spacer('before', window_.before)}

                {rendered.map((entry, offset) => {
                  const index = window_.start + offset;
                  const isSelected = selectedKeys.has(entry.key);
                  const isActive = activeKey === entry.key;

                  return (
                    <tr
                      key={entry.key}
                      id={`${reactId}-${entry.key}`}
                      aria-selected={selects ? isSelected : undefined}
                      aria-rowindex={virtualized ? index + 2 : undefined}
                      data-neba-row={entry.key}
                      className={cx(
                        rowClasses,
                        // An if/else, not stacked variants: two Tailwind classes
                        // of equal specificity resolve by their order in the
                        // generated stylesheet, not by the order written here.
                        isSelected
                          ? '[--n-row:var(--n-soft-press)]'
                          : striped !== false && index % 2 === stripeIndex
                            ? '[--n-row:var(--n-stripe)]'
                            : '',
                        !isSelected && hoverable ? 'hover:[--n-row:var(--n-soft)]' : '',
                        isActive && selects ? '[box-shadow:inset_0_0_0_1px_var(--n-ring)]' : '',
                        selects || onRowClick ? 'cursor-default' : ''
                      )}
                      style={{ height: `${rowHeight}px`, backgroundColor: 'var(--n-row)' }}
                      onPointerDown={(event) => handleRowPointerDown(entry, event)}
                      onClick={(event) => onRowClick?.(entry.row, displayOffset + index, event)}
                      onDoubleClick={() => onRowActivate?.(entry.row, displayOffset + index)}
                    >
                      {showTicks ? tickCell(entry) : null}

                      {columns.map((column) => (
                        <td
                          key={column.key}
                          role={selects ? 'gridcell' : undefined}
                          style={{ ...cellStyle, textAlign: column.align ?? 'start' }}
                        >
                          {column.render
                            ? column.render(entry.row, displayOffset + index)
                            : ((entry.row as Record<string, unknown>)[
                                column.key
                              ] as React.ReactNode)}
                        </td>
                      ))}

                      {filler ? (
                        <td aria-hidden="true" style={{ ...cellStyle, padding: 0 }} />
                      ) : null}
                    </tr>
                  );
                })}

                {spacer('after', window_.after)}
              </>
            )}
          </tbody>
        </table>
      </div>

      {showFooter ? (
        <div
          className={cx('flex flex-wrap items-center gap-3', metaTextClasses[size])}
          style={{ padding: `0.375rem ${padX}`, borderTop: '1px solid var(--n-line)' }}
        >
          <span className="text-(--neba-muted-fg) tabular-nums">{rangeText}</span>

          {selects && selectedKeys.size > 0 ? (
            <span className="text-(--n-accent) tabular-nums">
              {fillMessage(messages.selected, {
                count: number.format(selectedKeys.size)
              })}
            </span>
          ) : null}

          <div className="ms-auto flex items-center gap-2">
            {paging === 'pages' && pageSizeOptions.length > 0 ? (
              <>
                {/* The label is the Select's own rather than a `<span>` beside
                    it: Base UI's Field is what wires a label to a trigger that
                    is a button rather than an input, and a sentence sitting
                    next to a control is not attached to it. */}
                <Select
                  size={size}
                  color={color}
                  density={density}
                  variant="outline"
                  label={messages.rowsPerPage}
                  items={pageSizeOptions.map((value) => ({ value }))}
                  value={pageSize}
                  onValueChange={(value) => {
                    const next = Number(value);

                    if (pageSizeProp === undefined) {
                      setUncontrolledPageSize(next);
                    }

                    // The reader is somewhere in the data, not on a page
                    // number: showing twice as many rows should not move them
                    // twice as far down the table.
                    goToPage(Math.floor(bounds.start / next) + 1);
                    onPageSizeChange?.(next);
                  }}
                />
              </>
            ) : null}

            {paging === 'pages' ? (
              <Pagination
                size={size}
                color={color}
                count={bounds.pages}
                page={bounds.page}
                siblingCount={0}
                onPageChange={goToPage}
              />
            ) : null}
          </div>
        </div>
      ) : null}

      {/* How many rows there are, when the body cannot be counted by reading it
          and there is no footer saying so. A table that renders every one of
          its rows has already answered this, and repeating it into a live
          region would interrupt the reader to say nothing. */}
      {!showFooter && virtualized ? (
        <span className={srOnlyClasses} aria-live="polite">
          {rangeText}
        </span>
      ) : null}
    </Box>
  );
}
