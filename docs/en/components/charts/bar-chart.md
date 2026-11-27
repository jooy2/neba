---
title: BarChart
order: 4
flutter: true
---

# BarChart

<p class="neba-lede">Compares lengths across categories. The mark that says <em>how much</em>, for data whose categories could be shuffled without losing anything.</p>

<Demo src="bar-chart/hero" />

::: fw react

```tsx
import { BarChart } from 'neba';

<BarChart
  label="Deploys per team"
  categories={['Platform', 'Payments', 'Growth']}
  series={[{ name: 'Deploys', data: [318, 264, 197] }]}
  valueLabels="all"
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaBarChart(
  label: 'Deploys per team',
  categories: <Object>['Platform', 'Payments', 'Growth'],
  series: <NebaChartSeries>[
    NebaChartSeries(name: 'Deploys', data: <num>[318, 264, 197]),
  ],
  valueLabels: NebaChartValueLabels.all,
);
```

:::

The data model is the one every chart shares: `series`, `categories`, and a `null` that means a gap rather than a zero. It is written out on the [LineChart](./line-chart#the-data) page.

A bar's **length** is its value, which is why its axis includes zero by default. `yAxis.min` and `yAxis.max` still pin the ends, but a cropped scale makes a bar twice as long stop meaning twice as much. Where the categories have a natural order and the shape of the change is the point, a [LineChart](./line-chart) is the better mark.

## Props

<PropsTable name="BarChart" />

::: fw react

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props), and [`brush`](./line-chart#brush), [`references`](./line-chart#references), [`secondaryAxis`](./line-chart#secondaryaxis) and [`exportable`](./line-chart#exportable) work as they do there. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

::: fw flutter

The chart sits on a [Box](../surfaces/box), as a [LineChart](./line-chart#props) does. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take there, and [`references`](./line-chart#references) and [`secondaryAxis`](./line-chart#secondaryaxis) work as they do there; `brush` and `exportable` are not in the Flutter package yet. `orientation` is a `NebaOrientation`, and `stacked` is a `NebaChartStacking`, since Dart has no type for a `bool` or a word: `off`, `on` and `full`. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

## Examples

### orientation

<Fw react="`horizontal`" flutter="`NebaOrientation.horizontal`" /> is the right answer whenever the category names are words. A vertical chart gives each name the width of one bar; a horizontal one gives it a whole column, and the reading order runs the way a list does.

<Demo src="bar-chart/orientation">

::: fw react

<<< @/.vitepress/demos/bar-chart/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/orientation.dart

:::

</Demo>

### stacked

Grouped bars answer "which series is bigger here". Stacked bars answer "what is this total made of". <Fw react="`'full'`" flutter="`full`" /> normalises every bar to the same length, which asks about the mix instead: the value axis becomes a percentage, and the tooltip keeps the original number.

They are different questions and a chart should be asked only one at a time.

<Demo src="bar-chart/stacked">

::: fw react

<<< @/.vitepress/demos/bar-chart/stacked.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/stacked.dart

:::

</Demo>

### Negative values

A bar that goes the other way grows down from the same zero the others grow up from: the baseline is drawn where zero is, not at the bottom of the plot.

A point's own `color` overrides its series' for one bar, which is how a single value is marked without spending a second series on it.

<Demo src="bar-chart/negative">

::: fw react

<<< @/.vitepress/demos/bar-chart/negative.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/negative.dart

:::

</Demo>

### valueLabels · rounded · barSize

<Fw react='`valueLabels="all"`' flutter="`NebaChartValueLabels.all`" /> is defensible here in a way it is not on a line chart: eight bars with their numbers on them is a chart and a table at once. Past about a dozen it stops being either, and `extremes` (the series' own high and low) is the one to reach for.

`rounded` cuts the corners off the **data end** of each bar; the baseline end stays square. `barSize` caps the thickness in pixels: below the cap bars fill their share of the band, above it the leftover stays as air. <Fw react='`density="compact"`' flutter="`NebaDensity.compact`" /> widens that share.

::: fw react

```tsx
<BarChart valueLabels="extremes" rounded={false} barSize={12} density="compact" … />
```

:::

::: fw flutter

```dart
NebaBarChart(
  valueLabels: NebaChartValueLabels.extremes,
  rounded: false,
  barSize: 12,
  density: NebaDensity.compact,
  …
)
```

:::

## Accessibility

::: fw react

- The data is also rendered as a **visually hidden table**, captioned with `label`. Past 500 data points, the caption and the header row are written at once and the rows are added in small batches just after the chart first draws, so a server-rendered page does not carry them in its HTML.
- The plot is focusable; `←` / `→` (or `↑` / `↓` when horizontal) step the crosshair, `Home` / `End` jump to the ends, `Escape` clears it.
- Touching bars are separated by a 2px gap of the surface colour rather than by a stroke, so nothing on the chart is ink that is not data.

:::

::: fw flutter

- The plot is one image node described by a sentence, and the data is a hidden table captioned with `label`, as on a [LineChart](./line-chart#accessibility), which says what Flutter can and cannot express of it. Past 500 data points the rows are added in idle slices after the first frame.
- The plot takes the focus; `←` / `→` (or `↑` / `↓` when horizontal) step the crosshair, `Home` / `End` jump to the ends, `Escape` clears it, and the reading is announced as it moves.
- Touching bars are separated by a 2-pixel gap of the surface colour rather than by a stroke, so nothing on the chart is ink that is not data.

:::
