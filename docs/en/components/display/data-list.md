---
title: DataList
order: 20
---

# DataList

<p class="neba-lede">A list of things and what they are called — a details panel, a summary of a record, the metadata under a heading. Real <code>&lt;dt&gt;</code>/<code>&lt;dd&gt;</code> pairs, so each row is read as "label, value".</p>

<Demo src="data-list/hero" />

```tsx
import { DataList, DataListItem } from 'neba';

<DataList>
  <DataListItem label="Status">Live</DataListItem>
  <DataListItem label="Region">Frankfurt</DataListItem>
</DataList>;
```

## Props

<PropsTable name="DataList" />

Every native `<dl>` attribute passes through, apart from `color`. It draws no surface — put it in a [Card](../surfaces/card) or a [Box](../surfaces/box) when one is wanted.

Not a two-column [Table](./table). A table is a grid of rows all of the same shape, walked as a grid; this is a set of pairs, each read as a label and its value.

### DataListItem

<PropsTable name="DataListItem" />

## Examples

### orientation

`horizontal` puts the label in a column of its own beside the value, which is the shape a details panel takes. `vertical` puts it above — for a narrow column, and for values long enough that a label beside them would leave most of the row empty.

<Demo src="data-list/orientation">

<<< @/.vitepress/demos/data-list/orientation.tsx

</Demo>

### labelWidth

Left out, the label column is as wide as the widest label, which is what makes every value start at the same place. Set it to hold two lists side by side to the same measure.

<Demo src="data-list/label-width">

<<< @/.vitepress/demos/data-list/label-width.tsx

</Demo>

### dividers

A hairline between the rows, for a long list where the pairs need separating.

<Demo src="data-list/dividers">

<<< @/.vitepress/demos/data-list/dividers.tsx

</Demo>

## Accessibility

- Renders a real `<dl>` with each pair as a `<dt>` and a `<dd>`, so the label and the value are associated without any ARIA.
- A value can be any node — a [Chip](./chip), a [TextLink](./text-link), an [Avatar](./avatar) — and keeps whatever semantics it brought.
