---
title: DataList
order: 20
flutter: true
---

# DataList

<p class="neba-lede">A list of things and what they are called: a details panel, a summary of a record, the metadata under a heading. Real <code>&lt;dt&gt;</code>/<code>&lt;dd&gt;</code> pairs, so each row is read as "label, value".</p>

<Demo src="data-list/hero" />

::: fw react

```tsx
import { DataList, DataListItem } from 'neba';

<DataList>
  <DataListItem label="Status">Live</DataListItem>
  <DataListItem label="Region">Frankfurt</DataListItem>
</DataList>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaDataList(
  children: <Widget>[
    NebaDataListItem(label: Text('Status'), child: Text('Live')),
    NebaDataListItem(label: Text('Region'), child: Text('Frankfurt')),
  ],
);
```

:::

## Props

<PropsTable name="DataList" />

<Fw react="Every native `<dl>` attribute passes through, apart from `color`." flutter="The list takes the width it is given." /> It draws no surface: put it in a [Card](../surfaces/card) or a [Box](../surfaces/box) when one is wanted.

### DataListItem

<PropsTable name="DataListItem" />

## Examples

### orientation

`horizontal` puts the label in a column of its own beside the value, which is the shape a details panel takes. `vertical` puts it above: for a narrow column, and for values long enough that a label beside them would leave most of the row empty. A stacked label sits closer to its own value than to the pair above it.

<Demo src="data-list/orientation">

::: fw react

<<< @/.vitepress/demos/data-list/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/orientation.dart

:::

</Demo>

### labelWidth

Left out, the label column is as wide as the widest label, which is what makes every value start at the same place, up to half the list's width, past which a label wraps. Set it to hold two lists side by side to the same measure<Fw flutter=", in logical pixels" />.

<Demo src="data-list/label-width">

::: fw react

<<< @/.vitepress/demos/data-list/label-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/label_width.dart

:::

</Demo>

### dividers

A hairline between the rows, for a long list where the pairs need separating. In a `vertical` list it runs between pairs, above each label, and never between a label and its value.

<Demo src="data-list/dividers">

::: fw react

<<< @/.vitepress/demos/data-list/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/dividers.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a real `<dl>` with each pair as a `<dt>` and a `<dd>`, so the label and the value are associated without any ARIA.
- A value can be any node (a [Chip](./chip), a [TextLink](./text-link), an [Avatar](./avatar)), and keeps whatever semantics it brought.

:::

::: fw flutter

- Flutter's semantics have no description list, so each pair is one node that a screen reader reads as its label and then its value.
- A value can be any widget (a [Chip](./chip), a [TextLink](./text-link), an [Avatar](./avatar)), and keeps whatever semantics it brought, as a node of its own inside the pair.

:::
