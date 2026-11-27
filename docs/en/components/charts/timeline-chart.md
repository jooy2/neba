---
title: TimelineChart
order: 7
flutter: true
---

# TimelineChart

<p class="neba-lede">Plots work against time, with a row per thing and a bar per stretch of it. It is a Gantt chart: what is happening, on which track, and for how long.</p>

<Demo src="timeline-chart/hero" />

::: fw react

```tsx
import { TimelineChart } from 'neba';

<TimelineChart
  label="Release plan by workstream"
  series={[
    {
      name: 'Design',
      data: [{ start: new Date('2026-02-03'), end: new Date('2026-03-03'), label: 'Wireframes' }]
    }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTimelineChart(
  label: 'Release plan by workstream',
  series: <NebaTimelineSeries>[
    NebaTimelineSeries(
      name: 'Design',
      data: <NebaTimelinePoint>[
        NebaTimelinePoint(
          start: DateTime(2026, 2, 3),
          end: DateTime(2026, 3, 3),
          label: 'Wireframes',
        ),
      ],
    ),
  ],
);
```

:::

This is not [Timeline](../display/timeline). That one is a list of steps with no axis under it, for a sequence of events; this one draws spans against a calendar, for how long each of them took.

## The data

A row is a series and a span is a datum, but a span is not a `NebaChartPoint` (it has two positions on the axis rather than one), so it has a type of its own.

::: fw react

```ts
{ start: new Date('2026-03-02'), end: new Date('2026-03-16'), label: 'Wireframes' }
```

:::

::: fw flutter

```dart
NebaTimelinePoint(start: DateTime(2026, 3, 2), end: DateTime(2026, 3, 16), label: 'Wireframes')
```

:::

`start` and `end` are a <Fw react="`Date`" flutter="`DateTime`" /> or a number of milliseconds. A span written back to front is drawn the right way round.

Spans on one row share it. Two that overlap are given a lane each rather than being drawn over one another, so a row doing two things at once shows both; a row whose spans do not overlap keeps its full thickness.

<PropsTable name="NebaTimelinePoint" />

## Props

<PropsTable name="TimelineChart" />

::: fw react

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. There is no `legend`: a Gantt's rows are its axis, already named down the side. [`references`](./line-chart#references) and [`exportable`](./line-chart#exportable) work as they do on LineChart, and a reference past the spans widens the time axis to hold it; its `value` is a timestamp in milliseconds. There is no `brush`, which would cut by row while the spans on it run past the plot, and no `secondaryAxis`. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

::: fw flutter

The chart sits on a [Box](../surfaces/box), as a [LineChart](./line-chart#props) does. There is no `legend`: a Gantt's rows are its axis, already named down the side. [`references`](./line-chart#references) work as they do on LineChart, and a reference past the spans widens the time axis to hold it; its `value` is a timestamp in milliseconds. `exportable` is not in the Flutter package yet. There is no `brush`, which would cut by row while the spans on it run past the plot, and no `secondaryAxis`. `min` and `max` are an `Object?` holding a `DateTime` or a `num`, since Dart has no union type.

The axis, the tooltip and the table write a date with the month names `NebaDateNames` holds for the chart's `locale`: English unless the app gave `registerNebaDateNames` another language's, since the widgets layer has no `Intl`. A full date and a month of a year take that language's own order; `yAxis.tickFormat` writes the ticks any other way. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

## Examples

### min · max

Left alone, the axis is taken from the spans and rounded outward to a date a calendar has a name for. `min` and `max` pin it (to a quarter, to a sprint, to a working day), and a span that runs past the edge is cut there rather than dragging the whole axis out to meet it.

The tick unit follows the range: seconds, minutes, hours, days, weeks, months, quarters or years. A day-long chart ticks on the hour.

<Demo src="timeline-chart/range">

::: fw react

<<< @/.vitepress/demos/timeline-chart/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline_chart/range.dart

:::

</Demo>

### barSize · rounded · density

`barSize` caps how thick a bar may get; below the cap the bars fill their share of the row. `density` changes the share and nothing else. `rounded` cuts the corners off a span: both ends, unlike a [BarChart](./bar-chart), because a span grows from nothing and neither of its ends is a zero.

<Demo src="timeline-chart/bars">

::: fw react

<<< @/.vitepress/demos/timeline-chart/bars.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline_chart/bars.dart

:::

</Demo>

### xAxis · yAxis

`xAxis` is the row axis and `yAxis` is the time axis, which is the same rule every chart follows: `xAxis` is the category axis and `yAxis` the value axis, whichever way the chart is drawn. The time axis is along the bottom here, and it is still `yAxis`.

`yAxis.tickFormat` writes the ticks, `yAxis.tickCount` asks for roughly a number of them, and `xAxis.hidden` drops the row names.

::: fw react

```tsx
<TimelineChart yAxis={{ tickCount: 4 }} xAxis={{ label: 'Workstream' }} … />
```

:::

::: fw flutter

```dart
NebaTimelineChart(
  yAxis: const NebaChartAxis(tickCount: 4),
  xAxis: const NebaChartAxis(label: 'Workstream'),
  …
)
```

:::

### Colour

A row takes its palette slot from its place in the `series` <Fw react="array" flutter="list" />. `series.color` overrides the slot with a [colour family](../../design/color) or <Fw react="any CSS colour" flutter="any `Color`" />, and a span's own `color` overrides it for that one bar: which is how the one piece of work that is late gets to say so.

## Accessibility

::: fw react

- The data is also rendered as a **visually hidden table**, captioned with `label`, with one row per span under the name of the row it belongs to. Past 500 spans, the caption and the header row are written at once and the rows are added in small batches just after the chart first draws, so a server-rendered page does not carry them in its HTML.
- The plot is focusable; `↑` / `↓` walk the spans in the order the data was given, `Home` / `End` jump to the ends, `Escape` clears the tooltip.
- The pointer picks the span it is **inside** rather than the one with the nearest centre, so a long bar is not stolen by a short neighbour.

:::

::: fw flutter

- The plot is one image node described by a sentence that counts the spans and says when the first starts and the last ends, and the data is a hidden table captioned with `label`, as on a [LineChart](./line-chart#accessibility), which says what Flutter can and cannot express of it. Here it has one row per span under the name of the row it belongs to. Past 500 spans the rows are added in idle slices after the first frame.
- The plot takes the focus; `↑` / `↓` walk the spans in the order the data was given, `Home` / `End` jump to the ends, `Escape` clears the reading, and the reading is announced as it moves.
- The pointer picks the span it is **inside** rather than the one with the nearest centre, so a long bar is not stolen by a short neighbour.

:::
