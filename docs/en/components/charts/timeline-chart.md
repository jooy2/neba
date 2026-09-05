---
title: TimelineChart
order: 7
---

# TimelineChart

<p class="neba-lede">Plots work against time, with a row per thing and a bar per stretch of it. It is a Gantt chart: what is happening, on which track, and for how long.</p>

<Demo src="timeline-chart/hero" />

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

This is not [Timeline](../display/timeline). That one is a list of steps with no axis under it, for a sequence of events; this one draws spans against a calendar, for how long each of them took.

## The data

A row is a series and a span is a datum, but a span is not a `NebaChartPoint` — it has two positions on the axis rather than one — so it has a type of its own.

```ts
{ start: new Date('2026-03-02'), end: new Date('2026-03-16'), label: 'Wireframes' }
```

`start` and `end` are a `Date` or a number of milliseconds. A span written back to front is drawn the right way round.

Spans on one row share it. Two that overlap are given a lane each rather than being drawn over one another, so a row doing two things at once shows both; a row whose spans do not overlap keeps its full thickness.

<PropsTable name="NebaTimelinePoint" />

## Props

<PropsTable name="TimelineChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. There is no `legend`: a Gantt's rows are its axis, already named down the side. See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### min · max

Left alone, the axis is taken from the spans and rounded outward to a date a calendar has a name for. `min` and `max` pin it — to a quarter, to a sprint, to a working day — and a span that runs past the edge is cut there rather than dragging the whole axis out to meet it.

The tick unit follows the range: seconds, minutes, hours, days, weeks, months, quarters or years. A day-long chart ticks on the hour.

<Demo src="timeline-chart/range">

<<< @/.vitepress/demos/timeline-chart/range.tsx

</Demo>

### barSize · rounded · density

`barSize` caps how thick a bar may get; below the cap the bars fill their share of the row. `density` changes the share and nothing else. `rounded` cuts the corners off a span — both ends, unlike a [BarChart](./bar-chart), because a span grows from nothing and neither of its ends is a zero.

<Demo src="timeline-chart/bars">

<<< @/.vitepress/demos/timeline-chart/bars.tsx

</Demo>

### xAxis · yAxis

`xAxis` is the row axis and `yAxis` is the time axis, which is the same rule every chart follows: `xAxis` is the category axis and `yAxis` the value axis, whichever way the chart is drawn. The time axis is along the bottom here, and it is still `yAxis`.

`yAxis.tickFormat` writes the ticks, `yAxis.tickCount` asks for roughly a number of them, and `xAxis.hidden` drops the row names.

```tsx
<TimelineChart yAxis={{ tickCount: 4 }} xAxis={{ label: 'Workstream' }} … />
```

### Colour

A row takes its palette slot from its place in the `series` array. `series.color` overrides the slot with a [colour family](../../design/color) or any CSS colour, and a span's own `color` overrides it for that one bar — which is how the one piece of work that is late gets to say so.

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`, with one row per span under the name of the row it belongs to.
- The plot is focusable; `←` / `→` walk the spans in the order the data was given, `Home` / `End` jump to the ends, `Escape` clears the tooltip.
- The pointer picks the span it is **inside** rather than the one with the nearest centre, so a long bar is not stolen by a short neighbour.
