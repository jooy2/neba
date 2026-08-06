---
title: DataTable
order: 17
---

# DataTable

<p class="neba-lede">A table for a lot of rows: it renders only the ones on screen, sorts and searches them, and lets them be chosen the way a file manager does. Reach for it when a grid of data is something to work in rather than something to read.</p>

<Demo src="data-table/hero" minHeight="380" />

```tsx
import { DataTable, type DataTableColumn } from 'neba';

const headers: DataTableColumn<Build>[] = [
  { key: 'id', label: 'Build', width: 90, align: 'end' },
  { key: 'branch', label: 'Branch', width: 180 },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}s` }
];

<DataTable
  headers={headers}
  items={builds}
  getRowKey={(row) => row.id}
  height={280}
  selectionMode="multiple"
  sortable
/>;
```

## Props

<PropsTable name="DataTable" />

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through. Everything else a `<div>` takes — `id`, `data-*`, `onContextMenu` — lands on it too.

Define `headers` outside the component, or memoise it. The search and the sort are keyed on that array's identity, and an inline literal is a new array on every render.

### DataTableColumn

<PropsTable name="DataTableColumn" />

`render` decides what a reader sees; `value` decides what the sort and the search see. A column that draws a Chip needs `render`, and it needs `value` as well the moment it is sortable.

## Examples

### Virtual scrolling

Set a `height` (or a `maxHeight`) and the body scrolls with only the visible rows in the DOM. Without one there is nothing to measure against, so every row is rendered whatever `virtual` says — and `virtual={false}` turns it off for a table small enough that find-in-page matters more than the DOM count.

Every row is `rowHeight` tall and cells truncate rather than wrap, which is what makes the scroll offset arithmetic. Raise `rowHeight` for cells holding an Avatar or two lines.

<Demo src="data-table/virtual" minHeight="400">

<<< @/.vitepress/demos/data-table/virtual.tsx

</Demo>

### Selecting rows

`selectionMode` is `none`, `single` or `multiple`. With `multiple`:

|  |  |
| --- | --- |
| Click | chooses that row and drops the rest |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + click | adds or removes one |
| <kbd>Shift</kbd> + click | takes the run from the last row chosen |
| Click and drag | takes the run under the pointer, scrolling at the edges |
| <kbd>↑</kbd> <kbd>↓</kbd> <kbd>Home</kbd> <kbd>End</kbd> <kbd>PageUp</kbd> <kbd>PageDown</kbd> | move and choose |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + arrows | move without choosing |
| <kbd>Shift</kbd> + arrows | extend the run |
| <kbd>Space</kbd> | choose the row the focus is on; with <kbd>Ctrl</kbd>/<kbd>⌘</kbd>, toggle it |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> | every displayed row |
| <kbd>Esc</kbd> | nothing |
| <kbd>Enter</kbd>, double-click | `onRowActivate` |

`checkboxes` adds a tick column and a header tick that chooses every displayed row at once. `onSelectedChange` reports the keys and the rows behind them, including rows on pages that are not on screen.

<Demo src="data-table/selection" minHeight="380">

<<< @/.vitepress/demos/data-table/selection.tsx

</Demo>

### Sorting

`sortable` makes every column sortable and a column overrides it with its own `sortable`. A heading cycles ascending → descending → unsorted, and `aria-sort` says which.

With `sortMode="multiple"`, a Shift-click adds a column to the sort rather than replacing it; the number beside the arrow is its place in the order. Give a column `compare` when its values do not rank alphabetically, and `value` when the cell is drawn by `render`.

<Demo src="data-table/sorting" minHeight="320">

<<< @/.vitepress/demos/data-table/sorting.tsx

</Demo>

### Column widths and groups

`width` is pixels, and columns that do not state one share whatever is left. `resizable` puts a handle on each boundary; the first drag freezes every column at the width the browser had given it, so pulling one moves one. A double-click on a handle gives that column its original width back.

Adjacent columns carrying the same `group` string are merged under one heading in a second header row. A column with no `group` spans both rows.

<Demo src="data-table/columns" minHeight="260">

<<< @/.vitepress/demos/data-table/columns.tsx

</Demo>

### Pages and the footer

`paging="pages"` cuts the rows into pages and draws a footer: the range, how many rows are chosen, a page-size [Select](../inputs/select) and a [Pagination](../inputs/pagination). `pageSizeOptions` decides what the Select offers, and an empty list drops it.

`footer` shows or hides that bar on its own, so a scrolling table can have the count without the pages.

<Demo src="data-table/pages" minHeight="420">

<<< @/.vitepress/demos/data-table/pages.tsx

</Demo>

### Search and filter

`search` is matched against every column that has not set `searchable: false`, case- and accent-insensitively, against `value` where a column has one. `searchable` draws the field; `toolbar` fills the rest of the bar it sits in. `filter` is your own predicate, applied after the search.

<Demo src="data-table/search" minHeight="440">

<<< @/.vitepress/demos/data-table/search.tsx

</Demo>

### Size and density

`size` sets the type scale, the cell padding and the default `rowHeight`; `density` changes the padding and, here alone, lowers that default with it. The ladder sits one step below the rest of the library — a `md` row is 32px against a Button's 32px height plus its own padding.

<Demo src="data-table/density" minHeight="360">

<<< @/.vitepress/demos/data-table/density.tsx

</Demo>

### Rows from a server

`manual` names the stages the caller has already done — `'sort'`, `'filter'`, `'pages'`, or `true` for all three. The table then draws `items` as they arrive and only reports what was asked for. With `'pages'` in the list, `items` is one page and `rowCount` is how many rows there are altogether.

<Demo src="data-table/manual" minHeight="420">

<<< @/.vitepress/demos/data-table/manual.tsx

</Demo>

## Accessibility

- With a `selectionMode` the table is a `grid` with one tab stop and `aria-activedescendant`, because a virtual row cannot hold the focus — the row that had it is unmounted the moment it scrolls away. Rows carry `aria-selected`.
- Without one it is a plain `table`, and nothing in it takes focus except the sortable headings.
- A sortable heading is a real `<button>`; the `<th>` around it carries `aria-sort`.
- Give the table a `caption` or a `label`. Without either, a screen reader announces an unnamed grid.
- The resize handles are pointer-only and hidden from assistive technology. Column widths are a preference, not information — nothing in the table is unreachable without them.
- Pass `locale` when the markup is rendered on a server: it is what the default sort compares strings with, and a server that disagrees with the browser about the runtime locale produces two different row orders for the same table.
