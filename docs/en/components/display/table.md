---
title: Table
order: 4
---

# Table

<p class="neba-lede">Renders a grid of data from a column definition and a row list. There are no <code>&lt;tr&gt;</code>s or <code>&lt;td&gt;</code>s to write.</p>

<Demo src="table/hero" />

```tsx
import { Table, type TableColumn } from 'neba';

const headers: TableColumn<Deploy>[] = [
  { key: 'environment', label: 'Environment', width: 180 },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}m` }
];

<Table headers={headers} items={deploys} getRowKey={(row) => row.id} />;
```

## Props

<PropsTable name="Table" />

The outer sheet is a [Box](../surfaces/box): `variant` · `size` · `color` · `density` · `elevation` all pass straight through.

### TableColumn

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

## Examples

### width and align

`width` is a **starting** width. The table still balances its columns to fill the available space, so it acts as a proportion rather than a fixed value. It is written onto a `<col>`, so it applies consistently to every row.

Numeric columns usually want `align: 'end'` so their digits line up.

<Demo src="table/columns">

<<< @/.vitepress/demos/table/columns.tsx

</Demo>

### striped · hoverable · onRowClick

`striped` alternates the row background — useful on a wide table where the eye has to track across; on a narrow one it is noise. `onRowClick` makes rows activatable and turns the hover treatment on with it.

`getRowKey` defaults to the row index. Pass it whenever sorting or filtering can reorder the rows.

<Demo src="table/rows">

<<< @/.vitepress/demos/table/rows.tsx

</Demo>

### empty

What to show when `items` is empty. It renders as a single cell spanning every column.

<Demo src="table/empty">

<<< @/.vitepress/demos/table/empty.tsx

</Demo>

### stickyHeader

Pins the header row while the body scrolls. It only does anything if something around the table constrains its height.

## Accessibility

- Renders a real `<table>` with `<th scope="col">` headings.
- A `caption` is read as the table's accessible name.
- The empty state cell uses `colSpan` to cover every column, so it is not announced as short text in the first column.
- With `onRowClick`, a row enters the tab order, answers Enter and Space, and draws a focus-visible ring. Its `role` is left alone, so the column headings and the row's position are still announced.
- A link or a button inside a cell keeps its own keys. The click it raises still bubbles to the row, so call `event.stopPropagation()` in that control's handler if the row should not open with it.
