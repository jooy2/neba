---
title: DataTable
order: 17
flutter: true
---

# DataTable

<p class="neba-lede">A table for a lot of rows: it renders only the ones on screen, sorts and searches them, and lets them be chosen the way a file manager does. Reach for it when a grid of data is something to work in rather than something to read.</p>

<Demo src="data-table/hero" minHeight="380" />

::: fw react

```tsx
import { DataTable, type DataTableColumn } from 'neba';

const headers: DataTableColumn<Build>[] = [
  { key: 'id', label: 'Build', width: 90, align: 'end' },
  { key: 'branch', label: 'Branch', width: 180 },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}s` }
];
const rowKey = (row: Build) => row.id;

<DataTable
  label="Builds"
  headers={headers}
  items={builds}
  getRowKey={rowKey}
  height={280}
  selectionMode="multiple"
  sortable
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

final List<NebaDataTableColumn<Build>> headers = <NebaDataTableColumn<Build>>[
  NebaDataTableColumn<Build>(
    key: 'id',
    label: const Text('Build'),
    width: 90,
    align: NebaAlign.end,
    value: (Build row) => row.id,
  ),
  NebaDataTableColumn<Build>(
    key: 'branch',
    label: const Text('Branch'),
    width: 180,
    value: (Build row) => row.branch,
  ),
  NebaDataTableColumn<Build>(
    key: 'duration',
    label: const Text('Duration'),
    align: NebaAlign.end,
    value: (Build row) => row.duration,
    builder: (BuildContext context, Build row, int index) => Text('${row.duration}s'),
  ),
];

Object rowKey(Build row, int index) => row.id;

NebaDataTable<Build>(
  semanticLabel: 'Builds',
  headers: headers,
  items: builds,
  rowKey: rowKey,
  height: 280,
  selectionMode: NebaDataTableSelectionMode.multiple,
  sortable: true,
);
```

:::

## Props

<PropsTable name="DataTable" />

::: fw react

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through. Everything else a `<div>` takes (`id`, `data-*`, `onContextMenu`) lands on it too.

Define `headers`, `getRowKey`, `filter` and `manual` outside the component, or memoise them. The row keys, the search and the sort are keyed on their identity, and an inline literal or arrow is a new one on every render, so every row is keyed, searched and sorted again each time the component around the table renders, which a selection or a drag does on every change.

:::

::: fw flutter

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through. `getPageHref` and `exportFileName` have no Flutter counterpart: the package opens no address and starts no download.

Keep `headers`, `rowKey`, `filter` and `manual` outside `build`: a top-level `final`, a field, or a tear-off. The row keys, the search and the sort are kept on their identity, and a list literal or a closure written in `build` is a new one every time, so every row is keyed, searched and sorted again each time the widget around the table builds, which a selection or a drag does on every change.

:::

### DataTableColumn

<PropsTable name="DataTableColumn" />

::: fw react

`render` decides what a reader sees; `value` decides what the sort and the search see. Without `render`, a `Date` is written as a date in the table's `locale`, a boolean as `true` or `false`, and anything else as it is. Give a boolean column `render` for words a reader would use, such as "Yes" or a Chip. A column that draws a Chip needs `render`, and it needs `value` as well the moment it is sortable.

:::

::: fw flutter

`builder` decides what a reader sees; `value` decides what the sort, the search and the editor see, and a cell without a `builder` writes it. A row that is a `Map` needs neither, since the cell is then `row[key]`; any other row, a record or a class, gives each column a `value`. Without a `builder`, a `DateTime` is written as a date such as `Jan 5, 2026`, a boolean as `true` or `false`, a whole number held as a `double` without its `.0`, and anything else as its text.

`editable` is a `bool`, and `editableWhen` decides per row, where React's `editable` takes either.

:::

## Examples

### Virtual scrolling

::: fw react

Set a `height` (or a `maxHeight`) and the body scrolls with only the visible rows in the DOM. Without one there is nothing to measure against, so every row is rendered whatever `virtual` says, and `virtual={false}` turns it off for a table small enough that find-in-page matters more than the DOM count.

A development build warns in the console, once per table, when more than 500 rows are drawn while `virtual` is on and has nothing to work with: no `height` or `maxHeight`, or a `groupBy`. Pass `virtual={false}` when drawing every row is what you meant.

:::

::: fw flutter

Set a `height` (or a `maxHeight`) and the body scrolls with only the visible rows built, a grouped table included. Without one there is nothing to bound the body, so every row is built whatever `virtual` says, and `virtual: false` builds every row of a bounded table too.

A debug build says so once per table, through `debugPrint`, when more than 500 rows are built while `virtual` is on and nothing bounds the height. Pass `virtual: false` when building every row is what you meant.

:::

Every row is `rowHeight` tall, and cells truncate rather than wrap. Raise `rowHeight` for cells holding an Avatar or two lines.

<Demo src="data-table/virtual" minHeight="400">

::: fw react

<<< @/.vitepress/demos/data-table/virtual.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/virtual.dart

:::

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
| <kbd>Home</kbd> <kbd>End</kbd> <kbd>PageUp</kbd> <kbd>PageDown</kbd> | in a bounded table, scroll and move without choosing: what is chosen stays chosen; with <kbd>Shift</kbd>, extend the run |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + arrows | move without choosing |
| <kbd>Shift</kbd> + arrows | extend the run |
| <kbd>Space</kbd> | choose the row the focus is on; with <kbd>Ctrl</kbd>/<kbd>⌘</kbd>, toggle it |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> | every displayed row |
| <kbd>Esc</kbd> | drops every row |
| <kbd>Enter</kbd>, double-click | `onRowActivate` |
| <kbd>F2</kbd> | edits the first editable cell of the active row |

`checkboxes` adds a tick column and a header tick that chooses every displayed row at once. `onSelectedChange` reports the keys and the rows behind them, including rows on pages that are not on screen.

::: fw flutter

A press on a control inside a cell, such as a button a `builder` drew, is that control's: it neither chooses the row nor calls `onRowPressed`.

:::

<Demo src="data-table/selection" minHeight="380">

::: fw react

<<< @/.vitepress/demos/data-table/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/selection.dart

:::

</Demo>

### Sorting

`sortable` makes every column sortable and a column overrides it with its own `sortable`. A heading cycles ascending → descending → unsorted, and <Fw react="`aria-sort` says which" flutter="its button's semantic value says which" />.

With <Fw react="sortMode=&quot;multiple&quot;" flutter="sortMode: NebaDataTableSortMode.multiple" code />, a Shift-click adds a column to the sort rather than replacing it; the number beside the arrow is its place in the order. Give a column `compare` when its values do not rank alphabetically, and `value` when the cell is drawn by <Fw react="render" flutter="builder" code />.

::: fw flutter

The default comparison sorts numbers as numbers, dates as instants and text with its case and accents folded away and its digits compared as numbers, so `item2` comes before `item10`. The widgets layer has no collator, so it knows no language's own order; a column that needs one takes a `compare`.

:::

<Demo src="data-table/sorting" minHeight="320">

::: fw react

<<< @/.vitepress/demos/data-table/sorting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/sorting.dart

:::

</Demo>

### Column widths and groups

::: fw react

`width` is pixels, and columns that do not state one share whatever is left. `resizable` puts a handle on each boundary; the first drag freezes every column at the width the browser had given it, so pulling one moves one. A double-click on a handle gives that column its original width back. Each handle is also a focusable separator, named after its column, and <kbd>←</kbd> <kbd>→</kbd> move it 16px at a time.

:::

::: fw flutter

`width` is logical pixels, and columns that do not state one share whatever is left. A table narrower than its columns scrolls sideways. `resizable` puts a handle on each boundary; the first drag freezes every column at the width it was laid out at, so pulling one moves one. A double press on a handle gives that column its original width back. Each handle is also a focus stop named after its column, which <kbd>←</kbd> <kbd>→</kbd> move 16 logical pixels at a time, and a screen reader adjusts it.

:::

Adjacent columns carrying the same `group` string are merged under one heading in a second header row. A column with no `group` spans both rows.

<Demo src="data-table/columns" minHeight="260">

::: fw react

<<< @/.vitepress/demos/data-table/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/columns.dart

:::

</Demo>

### Pages and the footer

<Fw react="paging=&quot;pages&quot;" flutter="paging: NebaDataTablePaging.pages" code /> cuts the rows into pages and draws a footer: the range, how many rows are chosen, a page-size [Select](../inputs/select) and a [Pagination](../inputs/pagination). `pageSizeOptions` decides what the Select offers, and an empty list drops it.

::: fw react

`getPageHref` gives each page an address, and the page numbers become links a crawler can follow. A press on one still moves the table without leaving the page.

:::

`footer` shows or hides that bar on its own, so a scrolling table can have the count without the pages.

<Demo src="data-table/pages" minHeight="420">

::: fw react

<<< @/.vitepress/demos/data-table/pages.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/pages.dart

:::

</Demo>

### Search and filter

`search` is matched against every column that has not set `searchable: false`, case- and accent-insensitively, against `value` where a column has one. `searchable` draws the field; `toolbar` fills the rest of the bar it sits in. `filter` is your own predicate, applied after the search.

<Demo src="data-table/search" minHeight="440">

::: fw react

<<< @/.vitepress/demos/data-table/search.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/search.dart

:::

</Demo>

### Pinned columns

<Fw react="pinned: 'start' | 'end'" flutter="pinned: NebaDataTablePin.start or NebaDataTablePin.end" code /> on a column freezes it against that edge while the rest scroll past.

Pinning also **moves** the column. Everything pinned to the start is drawn first and everything pinned to the end last, whatever `columnOrder` said.

::: fw react

Give a pinned column a `width`. Without one, the offsets the sticky cells sit at are worked out from a default width rather than the column's real one.

:::

::: fw flutter

A pinned column is held where it was laid out, so it needs no `width` of its own to stay in place.

:::

### Column order and reordering

`columnOrder` is a list of keys. **A key it does not mention keeps its place**, so an order that names two columns moves those two and leaves the rest alone, and a column added to `headers` later appears without the stored order having to be migrated.

`reorderable` lets a header be dragged along the row. It is off by default, and the drag arms at a threshold rather than at the press, so a click meant to sort does not move the column. Pinned headers are not draggable. From the keyboard, <kbd>Alt</kbd> + <kbd>←</kbd> <kbd>→</kbd> on a heading moves its column one place; a heading with no sort button takes the focus itself for that.

### Editing a cell

`onCellEdit` on the table and `editable` on a column, together:

::: fw react

```tsx
<DataTable
  headers={[{ key: 'name', label: 'Name', editable: true }]}
  items={rows}
  onCellEdit={(row, column, value) => save(row.id, column.key, value)}
/>
```

:::

::: fw flutter

```dart
NebaDataTable<Member>(
  headers: <NebaDataTableColumn<Member>>[
    NebaDataTableColumn<Member>(
      key: 'name',
      label: const Text('Name'),
      value: (Member row) => row.name,
      editable: true,
    ),
  ],
  items: rows,
  onCellEdit: (Member row, NebaDataTableColumn<Member> column, Object value) =>
      save(row.id, column.key, value),
)
```

:::

Neither works alone. A column with no handler above it is not editable however `editable` is set. The table holds **no copy of the rows**. It hands the new value over and draws whatever comes back in `items`.

<Fw react="`editable` may be a function" flutter="`editableWhen` decides per row" />, for a locked record or a computed field. <Fw react="editType: 'number'" flutter="editType: NebaDataTableEditType.number" code /> keeps the keypad on a phone and hands back a number rather than a string.

A double-click opens the editor, and so does <kbd>F2</kbd> on the active row; blur and `Enter` commit, `Escape` cancels, and either key hands the focus back to the table. `onRowActivate` does **not** also fire for a double-click that opened an editor.

### Grouping and aggregates

`groupBy` returns a heading for each row, and rows carrying the same one are gathered under it.

::: fw react

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

:::

::: fw flutter

```dart
NebaDataTable<Member>(
  headers: <NebaDataTableColumn<Member>>[
    NebaDataTableColumn<Member>(key: 'name', label: const Text('Name'), value: (Member row) => row.name),
    NebaDataTableColumn<Member>(
      key: 'spend',
      label: const Text('Spend'),
      value: (Member row) => row.spend,
      aggregate: (List<Member> rows) => Text('${sum(rows)}'),
    ),
  ],
  items: rows,
  groupBy: (Member row) => row.team,
)
```

:::

The grouping runs **after** the search and the sort, so a sorted table stays sorted inside each group and a filtered one groups only what is left. Groups keep the order their first row appeared in. The exception is rows `groupBy` returned <Fw react="undefined" flutter="null" code /> for, which go above everything under a heading that reads "No group" in the table's `locale`.

`aggregate` on a column is called with the rows of one group, and what it returns is drawn in the group heading, in that column. It is always a function, with no `'sum' | 'avg'` shorthand.

::: fw react

Grouping turns **virtual scrolling off**.

:::

::: fw flutter

A group's heading is a row tall, so a grouped table with a `height` is still virtual. A heading stays on the page when every group is folded, so the groups can be opened again.

:::

### Exporting

::: fw react

`exportable` adds a button that writes the rows out as a CSV file.

:::

::: fw flutter

`exportable` adds a button that writes the rows out as CSV and hands the text to `onExport`. The package starts no download, so the button is drawn only with an `onExport`, and saving or sharing the file is the app's to do.

:::

The file holds every row the reader is currently looking at, not only the page they are on. The search and the sort are applied, and the paging is not.

`exportValue` on a column is what the file gets. Without one it falls back to `value` and then to `row[key]`, and never to what <Fw react="render" flutter="builder" code /> draws. `exportable: false` on a column leaves it out.

The file leads with a byte-order mark, so Excel reads its non-ASCII text correctly. A text cell that starts with `=`, `+`, `-`, `@`, a tab or a carriage return is written with a `'` in front, so a spreadsheet shows it rather than running it as a formula; <Fw react="exportEscapeFormulas={false}" flutter="exportEscapeFormulas: false" code /> writes it as it is.

::: fw react

`onExport` takes the CSV instead of downloading it.

:::

### Size and density

`size` sets the type scale, the cell padding and the default `rowHeight`; `density` changes the padding and, here alone, lowers that default with it. A `md` row is 32px, the same height as a `md` Button, and `compact` takes it to 28px.

<Demo src="data-table/density" minHeight="360">

::: fw react

<<< @/.vitepress/demos/data-table/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/density.dart

:::

</Demo>

### Rows from a server

`manual` names the stages the caller has already done: <Fw react="`'sort'`, `'filter'`, `'pages'`, or `true` for all three" flutter="a set of `NebaDataTableStage.sort`, `filter` and `pages`, or `NebaDataTableStage.values.toSet()` for all three" />. The table then draws `items` as they arrive and only reports what was asked for. With <Fw react="'pages'" flutter="pages" code /> in the list, `items` is one page and `rowCount` is how many rows there are altogether. Rows chosen on one page stay chosen while the reader chooses on another; `onSelectedChange` hands over their keys, and no row for a key whose page the table is not holding.

<Demo src="data-table/manual" minHeight="420">

::: fw react

<<< @/.vitepress/demos/data-table/manual.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/manual.dart

:::

</Demo>

## Accessibility

::: fw react

- With a `selectionMode` the table is a `grid` with one tab stop, and `aria-activedescendant` points at the active row. Rows carry `aria-selected`.
- With `checkboxes`, a row's tick is out of the tab order, since <kbd>Space</kbd> already chooses the active row, and it is named after the row: "Select row" and then the row's first cell.
- Without one it is still a `grid` with a tab stop when a row opens something (`onRowActivate`) or a cell edits, so the arrows move an active row that `aria-activedescendant` points at, <kbd>Enter</kbd> opens it and <kbd>F2</kbd> edits it, and nothing is chosen. With none of those it is a plain `table`, and nothing in it takes focus except the sortable headings.
- A sortable heading is a real `<button>`; the `<th>` around it carries `aria-sort`. With `sortMode="multiple"` only the first key's heading carries it, and the button of every later key ends with its place and direction, "sort 2, descending", in the `locale`'s words.
- The range and the count of chosen rows are a `status`: in the footer when there is one, and visually hidden when there is not. A screen reader hears the new numbers after a search, a page change or a selection.
- Give the table a `caption` or a `label`. Without either, a screen reader announces an unnamed grid.
- A resize handle is a `separator` in the tab order, named "Resize" and the column's label, with its width in `aria-valuenow`. The heading around it is still named by its label alone.
- A heading that moves carries `aria-keyshortcuts` for <kbd>Alt</kbd> + <kbd>←</kbd> <kbd>→</kbd>.
- A cell cuts its text rather than wrapping. A screen reader reads it whole; under the pointer a cut cell without `render` shows its whole text as a tooltip, and a keyboard reader widens the column through its handle.
- Pass `locale` when the markup is rendered on a server: it is what the default sort compares strings with, and a server that disagrees with the browser about the runtime locale produces two different row orders for the same table.

:::

::: fw flutter

- With a `selectionMode`, an `onRowActivate` or a cell that edits, the table is one focus stop and the arrows move an active row, ringed inside its edges, which the table keeps on screen. With none of those the table takes no focus, and nothing in it does except the sortable headings.
- Each row is a semantics node of its own, its cells read as its label, heard as selected or not with a `selectionMode` and answering a tap with one or with `onRowPressed`.
- With `checkboxes`, a row's tick is out of the focus order, since <kbd>Space</kbd> already chooses the active row, and it is named after the row: "Select row" and then the first column's value.
- A sortable heading is a button whose semantic value is its place and direction in the sort, "sort 1, ascending", in the `locale`'s words, for the first key as for the rest.
- The range and the count of chosen rows are a live status: in the footer when there is one, and visually hidden when there is not. A screen reader hears the new numbers after a search, a page change or a selection.
- Give the table a `semanticLabel`, or a `caption` that is a `Text`. Without either, a screen reader announces it unnamed.
- A resize handle is a focus stop named "Resize" and the column's label, with its width as its value, which a screen reader adjusts as it does a slider. The heading beside it is still named by its label alone.
- A cell cuts its text rather than wrapping, and a screen reader reads it whole; a keyboard reader widens the column through its handle. A cut cell shows no tooltip of its whole text.

:::
