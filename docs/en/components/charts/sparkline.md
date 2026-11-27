---
title: Sparkline
order: 1
flutter: true
---

# Sparkline

<p class="neba-lede">A word-sized picture of a trend, with no axes, no grid and no legend. It goes beside a number, inside a sentence or in a table cell, and says which way something has been going.</p>

<Demo src="sparkline/hero" />

::: fw react

```tsx
import { Sparkline } from 'neba';

<Sparkline data={[18, 22, 19, 27, 24, 31, 29, 36]} label="Signups, last eight weeks" endDot />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaSparkline(
  data: <num>[18, 22, 19, 27, 24, 31, 29, 36],
  label: 'Signups, last eight weeks',
  endDot: true,
);
```

:::

It is not a small chart. Every number it could label is one the surrounding text already has, which is why it labels none of them, and why it takes `data` directly instead of a `series` array.

::: fw react

`data` is an array of `NebaChartDatum`, the same shape every chart takes: a number, a `null` for a gap, or a point. See [LineChart](./line-chart#the-data) for the full definition.

:::

::: fw flutter

`data` is a `List<Object?>` of the values every chart takes: a `num`, a `null` for a gap, or a `NebaChartPoint`. Anything else is read as a gap. See [LineChart](./line-chart#the-data) for the full definition.

:::

## Props

<PropsTable name="Sparkline" />

::: fw react

Every native `<div>` attribute passes through. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

::: fw flutter

The strip fills the width it is given, or 120 logical pixels in a row that gives it none. A `width` of its own is kept inside a parent that would stretch it. `initialWidth` has no counterpart: a Flutter widget is laid out before it is first drawn, so there is never a frame without its width. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

## Examples

### shape · curve · endDot · baseline

`shape` picks the mark: a line for a trend, an area for a quantity, bars for a count of discrete things. `endDot` puts a dot on the last point: the one direct label a strip this small has room for. `baseline` draws a rule across it at a target or a budget.

<Demo src="sparkline/variants">

::: fw react

<<< @/.vitepress/demos/sparkline/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/variants.dart

:::

</Demo>

### nulls

What the strip does where a value is missing: `gap` breaks at it, `connect` bridges it, `zero` reads it as a nought. The same three answers a [LineChart](./line-chart#nulls) gives.

`zero` rewrites the values, so the range the strip scales itself to takes the nought in and the numbers read out to a screen reader say `0` as well.

<Demo src="sparkline/gaps">

<<< @/.vitepress/demos/sparkline/gaps.tsx

</Demo>

### min · max

A sparkline fills itself with its own range, which is what makes it legible at twenty pixels tall, and it is also the trap. Two sparklines side by side are drawn on two different scales unless they are given the same `min` and `max`; pass those and a column of them becomes a small-multiples chart.

<Demo src="sparkline/shapes">

<<< @/.vitepress/demos/sparkline/shapes.tsx

</Demo>

### size · color · width

`size` sets the height, on a ladder measured against the line of text beside it rather than against the page. `width` defaults to filling the container; a number pins it.

`color` takes a `NebaColor` family or <Fw react="any CSS colour" flutter="any `Color`" />: unlike the full charts, this one takes it directly, since a sparkline has one series and no legend for a palette to hand out.

::: fw react

```tsx
<Sparkline data={data} size="xs" color="success" width={72} />
```

:::

::: fw flutter

```dart
NebaSparkline(data: data, size: NebaSize.xs, color: NebaColor.success, width: 72)
```

:::

## Accessibility

::: fw react

- A Sparkline with a `label` renders its values as visually hidden text and is exposed as an image with that name, in a server render as well as in the browser. Without a `label` it is hidden from assistive technology entirely: which is correct when the strip sits beside a [Statistic](./statistic) that already says the number, and wrong anywhere else.

:::

::: fw flutter

- A Sparkline with a `label` is one image node with that name, followed by a hidden text node with its values, a gap read as `—`. Without a `label` it is left out of the semantics tree entirely: which is correct when the strip sits beside a [Statistic](./statistic) that already says the number, and wrong anywhere else.

:::

- Nothing in it is interactive and nothing in it is reachable only by pointer.
