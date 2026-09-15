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
const rowKey = (row: Build) => row.id;

<DataTable
  headers={headers}
  items={builds}
  getRowKey={rowKey}
  height={280}
  selectionMode="multiple"
  sortable
/>;
```

## Props

<PropsTable name="DataTable" />

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through. Everything else a `<div>` takes (`id`, `data-*`, `onContextMenu`) lands on it too.

Define `headers`, `getRowKey`, `filter` and `manual` outside the component, or memoise them. The row keys, the search and the sort are keyed on their identity, and an inline literal or arrow is a new one on every render, so every row is keyed, searched and sorted again each time the component around the table renders, which a selection or a drag does on every change.

### DataTableColumn

<PropsTable name="DataTableColumn" />

`render` decides what a reader sees; `value` decides what the sort and the search see. Without `render`, a `Date` is written as a date in the table's `locale`, and anything else as it is. A column that draws a Chip needs `render`, and it needs `value` as well the moment it is sortable.

## Examples

### Virtual scrolling

Set a `height` (or a `maxHeight`) and the body scrolls with only the visible rows in the DOM. Without one there is nothing to measure against, so every row is rendered whatever `virtual` says, and `virtual={false}` turns it off for a table small enough that find-in-page matters more than the DOM count.

Every row is `rowHeight` tall, and cells truncate rather than wrap. Raise `rowHeight` for cells holding an Avatar or two lines.

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
| Tap | chooses that row once the finger lifts, so a finger that scrolls the table chooses nothing |
| <kbd>↑</kbd> <kbd>↓</kbd> | move and choose |
| <kbd>Home</kbd> <kbd>End</kbd> <kbd>PageUp</kbd> <kbd>PageDown</kbd> | scroll only: what is chosen stays chosen |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + arrows | move without choosing |
| <kbd>Shift</kbd> + arrows | extend the run |
| <kbd>Space</kbd> | choose the row the focus is on; with <kbd>Ctrl</kbd>/<kbd>⌘</kbd>, toggle it |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> | every displayed row |
| <kbd>Esc</kbd> | drops every row |
| <kbd>Enter</kbd>, double-click | `onRowActivate` |
| <kbd>F2</kbd> | edits the first editable cell of the active row |

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

### Pinned columns

`pinned: 'start' | 'end'` on a column freezes it against that edge while the rest scroll past.

Pinning also **moves** the column. Everything pinned to the start is drawn first and everything pinned to the end last, whatever `columnOrder` said.

Give a pinned column a `width`. Without one, the offsets the sticky cells sit at are worked out from a default width rather than the column's real one.

### Column order and reordering

`columnOrder` is a list of keys. **A key it does not mention keeps its place**, so an order that names two columns moves those two and leaves the rest alone, and a column added to `headers` later appears without the stored order having to be migrated.

`reorderable` lets a header be dragged along the row. It is off by default, and the drag arms at a threshold rather than at the press, so a click meant to sort does not move the column. Pinned headers are not draggable.

### Editing a cell

`onCellEdit` on the table and `editable` on a column, together:

```tsx
<DataTable
  headers={[{ key: 'name', label: 'Name', editable: true }]}
  items={rows}
  onCellEdit={(row, column, value) => save(row.id, column.key, value)}
/>
```

Neither works alone. A column with no handler above it is not editable however `editable` is set. The table holds **no copy of the rows**. It hands the new value over and draws whatever comes back in `items`.

`editable` may be a function, for a locked record or a computed field. `editType: 'number'` keeps the keypad on a phone and hands back a number rather than a string.

A double-click opens the editor, and so does <kbd>F2</kbd> on the active row; blur and `Enter` commit, `Escape` cancels, and either key hands the focus back to the table. `onRowActivate` does **not** also fire for a double-click that opened an editor.

### Grouping and aggregates

`groupBy` returns a heading for each row, and rows carrying the same one are gathered under it.

```tsx
<DataTable
  headers={[
    { key: 'name', label: 'Name' },
    { key: 'spend', label: 'Spend', aggregate: (rows) => sum(rows) }
  ]}
  items={rows}
  groupBy={(row) => row.team}
/>
```

The grouping runs **after** the search and the sort, so a sorted table stays sorted inside each group and a filtered one groups only what is left. Groups keep the order their first row appeared in. The exception is rows `groupBy` returned `undefined` for, which go above everything under a heading that reads "No group" in the table's `locale`.

`aggregate` on a column is called with the rows of one group, and what it returns is drawn in the group heading, in that column. It is always a function, with no `'sum' | 'avg'` shorthand.

Grouping turns **virtual scrolling off**.

### Exporting

`exportable` adds a button that writes the rows out as a CSV file.

The file holds every row the reader is currently looking at, not only the page they are on. The search and the sort are applied, and the paging is not.

`exportValue` on a column is what the file gets. Without one it falls back to `value` and then to `row[key]`, and never to what `render` draws. `exportable: false` on a column leaves it out.

The file leads with a byte-order mark, so Excel reads its non-ASCII text correctly. A text cell that starts with `=`, `+`, `-`, `@`, a tab or a carriage return is written with a `'` in front, so a spreadsheet shows it rather than running it as a formula; `exportEscapeFormulas={false}` writes it as it is.

`onExport` takes the CSV instead of downloading it.

### Size and density

`size` sets the type scale, the cell padding and the default `rowHeight`; `density` changes the padding and, here alone, lowers that default with it. A `md` row is 32px, the same height as a `md` Button, and `compact` takes it to 28px.

<Demo src="data-table/density" minHeight="360">

<<< @/.vitepress/demos/data-table/density.tsx

</Demo>

### Rows from a server

`manual` names the stages the caller has already done: `'sort'`, `'filter'`, `'pages'`, or `true` for all three. The table then draws `items` as they arrive and only reports what was asked for. With `'pages'` in the list, `items` is one page and `rowCount` is how many rows there are altogether. Rows chosen on one page stay chosen while the reader chooses on another; `onSelectedChange` hands over their keys, and no row for a key whose page the table is not holding.

<Demo src="data-table/manual" minHeight="420">

<<< @/.vitepress/demos/data-table/manual.tsx

</Demo>

## Accessibility

- With a `selectionMode` the table is a `grid` with one tab stop, and `aria-activedescendant` points at the active row. Rows carry `aria-selected`.
- Without one it is still a `grid` with a tab stop when a row opens something (`onRowActivate`) or a cell edits, so the arrows move an active row, <kbd>Enter</kbd> opens it and <kbd>F2</kbd> edits it, and nothing is chosen. With none of those it is a plain `table`, and nothing in it takes focus except the sortable headings.
- A sortable heading is a real `<button>`; the `<th>` around it carries `aria-sort`.
- Give the table a `caption` or a `label`. Without either, a screen reader announces an unnamed grid.
- The resize handles are pointer-only and hidden from assistive technology. Nothing in the table is out of reach without them.
- Pass `locale` when the markup is rendered on a server: it is what the default sort compares strings with, and a server that disagrees with the browser about the runtime locale produces two different row orders for the same table.
