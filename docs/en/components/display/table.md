---
title: Table
order: 4
flutter: true
---

# Table

<p class="neba-lede">Renders a grid of data from a column definition and a row list. There are no <code>&lt;tr&gt;</code>s or <code>&lt;td&gt;</code>s to write.</p>

<Demo src="table/hero" />

::: fw react

```tsx
import { Table, type TableColumn } from 'neba';

const headers: TableColumn<Deploy>[] = [
  { key: 'environment', label: 'Environment', width: 180 },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}m` }
];

<Table headers={headers} items={deploys} getRowKey={(row) => row.id} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

final List<NebaTableColumn<Deploy>> headers = <NebaTableColumn<Deploy>>[
  NebaTableColumn<Deploy>(
    key: 'environment',
    label: const Text('Environment'),
    width: 180,
    builder: (BuildContext context, Deploy row, int index) => Text(row.environment),
  ),
  NebaTableColumn<Deploy>(
    key: 'duration',
    label: const Text('Duration'),
    align: NebaAlign.end,
    builder: (BuildContext context, Deploy row, int index) => Text('${row.duration}m'),
  ),
];

NebaTable<Deploy>(headers: headers, items: deploys);
```

:::

## Props

<PropsTable name="Table" />

::: fw react

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through.

:::

::: fw flutter

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` · `transition` all pass straight through. The rows are a Flutter `Table`, which a screen reader reads as a table of rows and cells.

:::

### TableColumn

::: fw react

```ts
interface TableColumn<Row> {
  key: string; // identifies the column, and names the property to read
  label?: React.ReactNode; // the heading; defaults to the key
  width?: number | string; // a number is pixels, a string is any CSS length
  align?: 'start' | 'center' | 'end';
  render?: (row: Row, index: number) => React.ReactNode;
}
```

With `render` you draw the cell yourself; without it, `row[key]` is printed as-is.

:::

::: fw flutter

```dart
class NebaTableColumn<T> {
  final String key; // names the column, and the field read from a row that is a Map
  final Widget? label; // the heading; defaults to the key
  final double? width; // logical pixels
  final NebaAlign align;
  final Widget Function(BuildContext context, T row, int index)? builder;
}
```

With `builder` you build the cell yourself; without it, a row that is a `Map` has `row[key]` printed as it is and any other row prints nothing, so a typed row gives every column a builder.

:::

## Examples

### width and align

::: fw react

`width` is a **starting** width. The table still balances its columns to fill the available space, so it acts as a proportion rather than a fixed value. It is written onto a `<col>`, so it applies consistently to every row.

:::

::: fw flutter

`width` fixes the column at that many logical pixels. The columns without one share the rest by their content, as a table laid out by the browser does.

:::

Numeric columns usually want <Fw react="align: 'end'" flutter="align: NebaAlign.end" code /> so their digits line up.

<Demo src="table/columns">

::: fw react

<<< @/.vitepress/demos/table/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/columns.dart

:::

</Demo>

### striped · hoverable · <Fw react="onRowClick" flutter="onRowPressed" />

`striped` alternates the row background: useful on a wide table where the eye has to track across; on a narrow one it is noise. <Fw react="onRowClick" flutter="onRowPressed" code /> makes rows activatable and turns the hover treatment on with it.

<Fw react="getRowKey" flutter="rowKey" code /> defaults to the row index. Pass it whenever sorting or filtering can reorder the rows.

<Demo src="table/rows">

::: fw react

<<< @/.vitepress/demos/table/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/rows.dart

:::

</Demo>

### empty

What to show when `items` is empty. It renders as <Fw react="a single cell spanning every column" flutter="one line across the width under the header" />.

<Demo src="table/empty">

::: fw react

<<< @/.vitepress/demos/table/empty.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/empty.dart

:::

</Demo>

### stickyHeader

::: fw react

Pins the header row while the body scrolls. The sheet the table draws is what scrolls, so limit it with `maxHeight`, a number of pixels or any CSS length. A height limited on a box around the table scrolls that box instead, and the header scrolls away with the rows.

:::

::: fw flutter

Pins the header row while the body scrolls, in a table held to `maxHeight`. The header is laid out apart from the rows then, so the columns without a `width` share the width equally rather than by their content; give the columns widths where that matters.

:::

### classNames

::: fw react

`className` is the sheet (the Box the table scrolls horizontally inside), so the `<table>` and everything in it are reached through `classNames`.

```tsx
<Table
  headers={headers}
  items={items}
  classNames={{
    table: 'tabular-nums',
    headCell: '[--n-cell-ink:var(--neba-fg)]',
    row: 'align-top'
  }}
/>
```

The slots are `table`, `caption`, `head`, `headCell`, `body`, `row`, `cell` and `empty`.

One thing to know before reaching for `cell`: a cell's padding, alignment and background are written as inline styles rather than as utilities, because a host stylesheet's `td` rule outranks any one-class utility. A class you hand to `headCell`, `cell` or `empty` can add anything the component does not already set inline (a font, a border), but changing one of those three needs an important utility (`p-4!`). The ink of a header cell and of the empty line is inline too, and reads the `--n-cell-ink` slot, so a class sets that slot rather than a `text-*` colour, as in the example above. See [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

A Flutter table has no class names. A cell is styled by what its column's `builder` returns, and a header by its column's `label`.

:::

## Accessibility

::: fw react

- Renders a real `<table>` with `<th scope="col">` headings.
- A `caption` is read as the table's accessible name.
- The empty state cell uses `colSpan` to cover every column, so it is not announced as short text in the first column.
- With `onRowClick`, a row enters the tab order, answers Enter and Space, and draws a focus-visible ring. Its `role` is left alone, so the column headings and the row's position are still announced.
- A link or a button inside a cell keeps its own keys. The click it raises still bubbles to the row, so call `event.stopPropagation()` in that control's handler if the row should not open with it.
- `locale` decides what an empty table says; `empty` writes it out instead.

:::

::: fw flutter

- The rows are a Flutter `Table`, which a screen reader reads as a table of rows and cells; the header cells are column headers.
- The empty line is one line under the header, not a short cell in the first column.
- With `onRowPressed`, each row is a focus stop that answers Enter and Space and is ringed after a key.
- A control inside a cell takes its own press; the row is pressed only by a press nothing in the cell took.
- `locale` decides what an empty table says; `empty` writes it out instead.

:::
