---
title: Table
order: 4
---

# Table

<p class="neba-lede">A grid of data, rendered from a column list and a row list. There are no <code>&lt;tr&gt;</code>s to write.</p>

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

The sheet is a [Box](../surfaces/box) — `variant`, `size`, `color`, `density` and `elevation` all pass straight through, so a table is styled on the same axes as everything it might sit next to. What Table adds is the part that is genuinely tabular.

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

This is the whole reason Table takes data rather than markup. A `<td>` written out per row can silently disagree with the `<th>` above it about how many there are or what order they come in; a column list cannot.

## Examples

### Widths and alignment

`width` is a _default_: the table still balances its columns to fill the available space, so this is a starting proportion rather than a guarantee. It is written onto a `<col>` rather than onto the first row's cells — a width set on a `<th>` is a width the browser renegotiates against every other row, and only the column element states it once.

Numbers usually want `align: 'end'` so their digits line up.

<Demo src="table/columns">

<<< @/.vitepress/demos/table/columns.tsx

</Demo>

### Rows

`striped` is for a wide table where the eye has to track across; on a narrow one it is noise. `onRowClick` makes the rows activatable and turns the hover treatment on with it.

<Demo src="table/rows">

<<< @/.vitepress/demos/table/rows.tsx

</Demo>

`getRowKey` defaults to the row's index. That is fine for a static table and wrong for one that sorts or filters — pass it the moment the rows can move.

### Empty

<Demo src="table/empty">

<<< @/.vitepress/demos/table/empty.tsx

</Demo>

## The header row

The header sits one step up the sheet's opacity ladder rather than taking a tint: it is still the container, and a coloured band behind a row of column names is the fastest way to make data look like chrome. The rule under it is the same `--n-line` a [Card](../surfaces/card) scores its sections with.

`stickyHeader` only does anything if something around the table actually constrains its height.

## Accessibility

- Renders a real `<table>` with `<th scope="col">` headings.
- A `caption` is read as the table's accessible name.
- The empty state spans every column, so it is announced as one cell rather than as a short first column.
