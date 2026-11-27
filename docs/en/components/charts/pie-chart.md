---
title: PieChart
order: 5
flutter: true
---

# PieChart

<p class="neba-lede">Shows parts of a whole as slices of a circle. It answers one question well (is one of these most of it?), and everything finer than that belongs in a bar chart.</p>

<Demo src="pie-chart/hero" />

::: fw react

```tsx
import { PieChart } from 'neba';

<PieChart
  label="Sessions by traffic source"
  shape="donut"
  categories={['Organic', 'Direct', 'Paid']}
  data={[18420, 9260, 6140]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaPieChart(
  label: 'Sessions by traffic source',
  shape: NebaPieShape.donut,
  categories: <Object>['Organic', 'Direct', 'Paid'],
  data: <num>[18420, 9260, 6140],
);
```

:::

## The data

A pie has one series, so it takes `data` directly rather than an array of series. The slices are the entities here: each one takes a palette slot of its own, and the legend lists them.

::: fw react

`data` is an array of `NebaChartDatum`: a number, a `null`, or a point that carries its own name and colour. `categories` names the slices; points may carry their own `x` instead.

```tsx
<PieChart categories={['Free', 'Pro', 'Team']} data={[4820, 2140, 890]} />

<PieChart
  data={[
    { x: 'Passed', y: 1284, color: 'success' },
    { x: 'Failed', y: 96, color: 'danger' }
  ]}
/>
```

:::

::: fw flutter

`data` is a `List<Object?>`: each entry a `num`, a `null`, or a `NebaChartPoint` that carries its own name and colour. `categories` names the slices; points may carry their own `x` instead.

```dart
const NebaPieChart(categories: <Object>['Free', 'Pro', 'Team'], data: <num>[4820, 2140, 890]);

const NebaPieChart(
  data: <Object>[
    NebaChartPoint(x: 'Passed', y: 1284, color: NebaColor.success),
    NebaChartPoint(x: 'Failed', y: 96, color: NebaColor.danger),
  ],
);
```

:::

Slices are drawn in the order they are given and are not re-sorted. A slice's colour follows its place in `data`, so a filter that drops one moves every slice after it onto the next colour; a point's own `color` holds it.

A negative value draws no slice and adds nothing to the total. It stays in the table and the legend, as it does on a treemap.

## Props

<PropsTable name="PieChart" />

::: fw react

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props). See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

::: fw flutter

The chart sits on a [Box](../surfaces/box), as a [LineChart](./line-chart#props) does, and `legend` and `tooltip` take the same shapes they take there; `exportable` is not in the Flutter package yet. `shape` is a `NebaPieShape`, and `valueLabels` takes the `NebaChartValueLabels` every chart shares, of which a pie reads `none` and `all`. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

## Examples

### shape

<Fw react="`pie`" flutter="`NebaPieShape.pie`" /> is a filled disc. `donut` opens a hole for the total. `semi` draws half a ring from the bottom of the box, which fits a dashboard tile that is wider than it is tall.

<Demo src="pie-chart/shapes">

::: fw react

<<< @/.vitepress/demos/pie-chart/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/shapes.dart

:::

</Demo>

### hole · gap

`shape` already sets how much of the middle is cut out — `0` for a `pie`, `0.62` for a `donut` and a `semi` — and `hole` is the dial behind it, from `0` to `0.92` of the radius. Setting one on a `pie` is also how that shape gets a `center`.

`gap` is the surface showing between two touching slices, in pixels, so it is the same width on a small chart as on a large one. `0` closes it, and it is never taken off a slice too narrow to spare it.

<Demo src="pie-chart/ring">

::: fw react

<<< @/.vitepress/demos/pie-chart/ring.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/ring.dart

:::

</Demo>

### center

`center` is drawn in the hole of a `donut` or a `semi`. Put the total there, or the one figure the chart is about.

::: fw react

```tsx
<PieChart shape="donut" center={<Typography level="h4">38.6K</Typography>} … />
```

:::

::: fw flutter

```dart
NebaPieChart(
  shape: NebaPieShape.donut,
  center: const NebaTypography('38.6K', level: NebaTypographyLevel.h4),
  …
)
```

:::

### valueLabels

<Fw react="`all`" flutter="`NebaChartValueLabels.all`" /> writes each slice's **share** on it rather than its value, which stays in the tooltip. A label is only drawn where the slice is wide enough for the text with room on both sides; one that does not fit is dropped rather than clipped, and the tooltip and the table still have it.

### Colour

Slices take palette slots in the order they are passed. A point's own `color` overrides that. Use it when the slices _mean_ something, such as passed and failed.

<Demo src="pie-chart/colors">

::: fw react

<<< @/.vitepress/demos/pie-chart/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/colors.dart

:::

</Demo>

### legend · startAngle

The legend appears from two slices up and is interactive by default: <Fw react="clicking" flutter="pressing" /> a slice's entry removes it and the rest renormalise to fill the circle. `startAngle` turns the whole thing, in degrees clockwise from twelve o'clock.

::: fw react

```tsx
<PieChart legend={{ side: 'right', align: 'center' }} startAngle={-30} … />
```

:::

::: fw flutter

```dart
NebaPieChart(
  legend: const NebaChartLegend(side: NebaSide.right, align: NebaAlign.center),
  startAngle: -30,
  …
)
```

:::

## Accessibility

::: fw react

- The data is also rendered as a **visually hidden table**, captioned with `label`. The plot itself is described by one sentence with the number of values and their range, so a focus does not read the table out.
- The plot is focusable; `←` and `→` step between slices, `Home` and `End` go to the first and the last, and `Escape` clears the selection, so the tooltip is reachable without a pointer. On a touch screen a tap keeps the slice's tooltip up until a tap lands outside the plot.
- A share written with `valueLabels="all"` takes the ink that reads best on its slice. A slice given a literal colour, such as `#ffe066`, gets black or white by contrast.
- Slices are separated by a gap of the surface colour, sized to stay 2px on screen at any radius, rather than by a stroke around each one.

:::

::: fw flutter

- The plot is one image node named by `label` and described by one sentence with the number of values and their range, and the data is a hidden table captioned with `label`, a row per slice, as on a [LineChart](./line-chart#accessibility), which says what Flutter can and cannot express of it.
- The plot takes the focus; `←` and `→` step between slices, `Home` and `End` go to the first and the last, `Escape` clears the selection, and the reading is announced as it moves. On a touch screen a tap keeps the slice's tooltip up until a tap lands outside the plot.
- A share written with `NebaChartValueLabels.all` takes the ink that reads best on its slice. A slice given a `Color` of its own, such as `Color(0xFFFFE066)`, gets black or white by contrast.
- Slices are separated by a gap of the surface colour, sized to stay 2 pixels on screen at any radius, rather than by a stroke around each one.

:::
