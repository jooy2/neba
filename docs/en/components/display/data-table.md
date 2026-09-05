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

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through. Everything else a `<div>` takes (`id`, `data-*`, `onContextMenu`) lands on it too.

Define `headers` outside the component, or memoise it. The search and the sort are keyed on that array's identity, and an inline literal is a new array on every render.

### DataTableColumn

<PropsTable name="DataTableColumn" />

`render` decides what a reader sees; `value` decides what the sort and the search see. A column that draws a Chip needs `render`, and it needs `value` as well the moment it is sortable.

## Examples

### Virtual scrolling

Set a `height` (or a `maxHeight`) and the body scrolls with only the visible rows in the DOM. Without one there is nothing to measure against, so every row is rendered whatever `virtual` says, and `virtual={false}` turns it off for a table small enough that find-in-page matters more than the DOM count.

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
| <kbd>↑</kbd> <kbd>↓</kbd> | move and choose |
| <kbd>Home</kbd> <kbd>End</kbd> <kbd>PageUp</kbd> <kbd>PageDown</kbd> | scroll only: what is chosen stays chosen |
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

### Pinned columns

`pinned: 'start' | 'end'` on a column freezes it against that edge while the rest scroll past.

Pinning also **moves** the column: everything pinned to the start is drawn first and everything pinned to the end last, whatever `columnOrder` said. A frozen column in the middle of the scrolling ones would slide over its neighbours instead of holding still.

Give a pinned column a `width`. The offsets the sticky cells sit at are the sum of the widths before them, and a column that has not said how wide it is has no number to add: it is measured at the default instead, which is a guess.

### Column order and reordering

`columnOrder` is a list of keys. **A key it does not mention keeps its place**, so an order that names two columns moves those two and leaves the rest alone, and a column added to `headers` later appears without the stored order having to be migrated.

`reorderable` lets a header be dragged along the row. It is off by default, and the drag arms at a threshold rather than at the press, so a click meant to sort does not move the column. Pinned headers are not draggable, since where they sit is what pinning decided.

### Editing a cell

`onCellEdit` on the table and `editable` on a column, together:

```tsx
<DataTable
  headers={[{ key: 'name', label: 'Name', editable: true }]}
  items={rows}
  onCellEdit={(row, column, value) => save(row.id, column.key, value)}
/>
```

Neither works alone. A column with no handler above it is not editable however `editable` is set, because the table holds **no copy of the rows**: it hands the new value over and draws whatever comes back in `items`. A table that wrote into its own copy would be a table showing something the application does not know about.

`editable` may be a function, for a locked record or a computed field. `editType: 'number'` keeps the keypad on a phone and hands back a number rather than a string.

A double-click opens the editor; blur and `Enter` commit, `Escape` cancels. `onRowActivate` does **not** also fire for a cell that opened an editor: the cell answered the double-click.

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

The grouping runs **after** the search and the sort, so a sorted table stays sorted inside each group and a filtered one groups only what is left. Groups keep the order their first row appeared in: except rows `groupBy` returned `undefined` for, which go above everything, because a heading that says nothing is not one a reader can interpret.

`aggregate` draws in the group heading, in its own column, which is the whole point: a group's total belongs in the same column as the numbers it is a total of. There is no `'sum' | 'avg'` shorthand: the moment a table has one column needing a weighted mean or a distinct count, half the columns are functions and half are strings.

Grouping turns **virtual scrolling off**. The window arithmetic counts every child of the body as one row of `rowHeight`, and a heading row is one more than that.

### Exporting

`exportable` adds a button that writes the rows out as a CSV file.

**Every row the reader is currently looking at, not the page they are on.** The search and the sort are applied and the paging is not, because a file of page 3 is not a file anybody asked for.

`exportValue` on a column is what the file gets, separate from `render` on purpose: a cell that draws a Chip, an Avatar or a progress bar has no text to put in a file. `exportable: false` on a column leaves it out.

The file leads with a byte-order mark, and that is not decoration: Excel reads a UTF-8 CSV without one as the local code page, so every non-ASCII name in it arrives as mojibake.

`onExport` takes the CSV instead of downloading it.

### Size and density

`size` sets the type scale, the cell padding and the default `rowHeight`; `density` changes the padding and, here alone, lowers that default with it. The ladder sits one step below the rest of the library: a `md` row is 32px against a Button's 32px height plus its own padding.

<Demo src="data-table/density" minHeight="360">

<<< @/.vitepress/demos/data-table/density.tsx

</Demo>

### Rows from a server

`manual` names the stages the caller has already done: `'sort'`, `'filter'`, `'pages'`, or `true` for all three. The table then draws `items` as they arrive and only reports what was asked for. With `'pages'` in the list, `items` is one page and `rowCount` is how many rows there are altogether.

<Demo src="data-table/manual" minHeight="420">

<<< @/.vitepress/demos/data-table/manual.tsx

</Demo>

## Accessibility

- With a `selectionMode` the table is a `grid` with one tab stop and `aria-activedescendant`, because a virtual row cannot hold the focus: the row that had it is unmounted the moment it scrolls away. Rows carry `aria-selected`.
- Without one it is a plain `table`, and nothing in it takes focus except the sortable headings.
- A sortable heading is a real `<button>`; the `<th>` around it carries `aria-sort`.
- Give the table a `caption` or a `label`. Without either, a screen reader announces an unnamed grid.
- The resize handles are pointer-only and hidden from assistive technology. Column widths are a preference, not information: nothing in the table is unreachable without them.
- Pass `locale` when the markup is rendered on a server: it is what the default sort compares strings with, and a server that disagrees with the browser about the runtime locale produces two different row orders for the same table.
