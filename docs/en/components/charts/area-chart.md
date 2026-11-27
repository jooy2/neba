---
title: AreaChart
order: 3
flutter: true
---

# AreaChart

<p class="neba-lede">A line with the space under it filled. Use it for a quantity that adds up to something, and stacked, for what that total is made of.</p>

<Demo src="area-chart/hero" />

::: fw react

```tsx
import { AreaChart } from 'neba';

<AreaChart
  label="Storage used by tier"
  categories={['Jan', 'Feb', 'Mar']}
  stacked
  series={[
    { name: 'Hot', data: [120, 138, 149] },
    { name: 'Archive', data: [610, 648, 690] }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAreaChart(
  label: 'Storage used by tier',
  categories: <Object>['Jan', 'Feb', 'Mar'],
  stacked: NebaChartStacking.on,
  series: <NebaChartSeries>[
    NebaChartSeries(name: 'Hot', data: <num>[120, 138, 149]),
    NebaChartSeries(name: 'Archive', data: <num>[610, 648, 690]),
  ],
);
```

:::

The data model is the one every chart shares: `series`, `categories`, and a `null` that means a gap rather than a zero. It is written out on the [LineChart](./line-chart#the-data) page.

The choice between the two is about what the quantity _is_: if it does not add up to anything (a temperature, a rate, a score), the fill under the line is decoration, and two of them overlapping is two washes fighting.

## Props

<PropsTable name="AreaChart" />

::: fw react

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props), and [`brush`](./line-chart#brush), [`references`](./line-chart#references), [`secondaryAxis`](./line-chart#secondaryaxis) and [`exportable`](./line-chart#exportable) work as they do there. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

::: fw flutter

The chart sits on a [Box](../surfaces/box), as a [LineChart](./line-chart#props) does. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take there, and [`references`](./line-chart#references) and [`secondaryAxis`](./line-chart#secondaryaxis) work as they do there; `brush` and `exportable` are not in the Flutter package yet. `stacked` is a `NebaChartStacking`, since Dart has no type for a `bool` or a word: `off`, `on` and `full`. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

## Examples

### stacked

<Fw react="`false`" flutter="`off`" /> overlays the bands, which answers "how big is each". <Fw react="`true`" flutter="`on`" /> stacks them, so the top edge is the total. <Fw react="`'full'`" flutter="`full`" /> normalises every category to 100%, which makes the chart about the mix and stops it being about the size: the value axis becomes a percentage and says so, and the tooltip keeps the original number.

<Demo src="area-chart/stacked">

::: fw react

<<< @/.vitepress/demos/area-chart/stacked.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/area_chart/stacked.dart

:::

</Demo>

### One series

With a single series there is no legend: the card's title already says what is plotted, and a box with one swatch in it would only restate it.

<Demo src="area-chart/single">

::: fw react

<<< @/.vitepress/demos/area-chart/single.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/area_chart/single.dart

:::

</Demo>

### curve · markers · nulls

The same three props [LineChart](./line-chart#curve) has, meaning the same things. `markers` defaults to `none` here rather than `auto`.

On a stacked chart a band that breaks at a gap takes the bands stacked on it with it, so <Fw react='`nulls="zero"`' flutter="`nulls: NebaChartNulls.zero`" /> is usually the one to pass there. It rewrites the data, so the axis, the tooltip and the table say nought too.

::: fw react

```tsx
<AreaChart curve="step" markers="all" nulls="zero" … />
```

:::

::: fw flutter

```dart
NebaAreaChart(
  curve: NebaChartCurve.step,
  markers: NebaChartMarkers.all,
  nulls: NebaChartNulls.zero,
  …
)
```

:::

### Value axis

Unlike a line chart, an area chart keeps zero on its value axis. The fill's thickness _is_ the magnitude, so a cropped baseline would leave the band's height meaning nothing. `yAxis`'s own `min` and `max` still override it where the caller has a reason.

## Accessibility

::: fw react

- The data is also rendered as a **visually hidden table**, captioned with `label`. Past 500 data points, the caption and the header row are written at once and the rows are added in small batches just after the chart first draws, so a server-rendered page does not carry them in its HTML.
- The plot is focusable; `←` / `→` step the crosshair, `Home` / `End` jump to the ends, `Escape` clears it.
- With `stacked="full"`, the tooltip and the table report the value the caller passed, not the percentage: the chart shows the share, and the number is still reachable.

:::

::: fw flutter

- The plot is one image node described by a sentence, and the data is a hidden table captioned with `label`, as on a [LineChart](./line-chart#accessibility), which says what Flutter can and cannot express of it. Past 500 data points the rows are added in idle slices after the first frame.
- The plot takes the focus; `←` / `→` step the crosshair, `Home` / `End` jump to the ends, `Escape` clears it, and the reading is announced as it moves.
- With `stacked: NebaChartStacking.full`, the tooltip and the table report the value the caller passed, not the percentage: the chart shows the share, and the number is still reachable.

:::
