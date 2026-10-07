---
title: LineChart
order: 2
---

# LineChart

<p class="neba-lede">Plots one or more series against an ordered category axis. Reach for it when two neighbouring points are part of one continuous change, such as a value over time or a curve over a range, rather than two separate facts.</p>

<Demo src="line-chart/hero" />

```tsx
import { LineChart } from 'neba';

<LineChart
  label="Weekly active users by month"
  categories={['Jan', 'Feb', 'Mar']}
  series={[
    { name: 'Web', data: [1820, 1960, 2140] },
    { name: 'Mobile', data: [940, 1120, 1310] }
  ]}
/>;
```

## The data

Every chart in the library takes the same two props, so a dashboard tile can be switched from one chart to another without rewriting its data.

`series` is an array of `NebaChartSeries`. Each entry is one line:

```ts
interface NebaChartSeries {
  name?: string; // its name in the legend, tooltip and table
  data: readonly NebaChartDatum[]; // the values, in category order
  color?: NebaColor | string; // overrides the palette slot
  hidden?: boolean; // starts hidden; the legend turns it back on
  axis?: 'primary' | 'secondary'; // the value axis it is measured against
}
```

A `NebaChartDatum` is a number, a `null`, or a point:

```ts
type NebaChartDatum = number | null | NebaChartPoint;

interface NebaChartPoint {
  x?: string | number | Date; // its place on the category axis
  y: number | null; // the value
  z?: number; // a second magnitude: a bubble's radius, a tile's weight
  color?: string; // overrides the series colour for this point
  label?: ReactNode; // what the tooltip says instead of the number
}
```

**`null` is a gap, not a zero.** A sensor that was offline and a month with no sales are different facts, and the chart draws them differently: the line breaks at a `null` and the point is not drawn. `nulls` is how a caller says otherwise.

`categories` names the positions along the x axis. Points may carry their own `x` instead: whichever matches the shape the data already has.

<Demo src="line-chart/data">

<<< @/.vitepress/demos/line-chart/data.tsx

</Demo>

## Props

<PropsTable name="LineChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `variant` defaults to `text` and `padded` to `false`, so a chart dropped into a [Card](../surfaces/card) draws no sheet of its own; `variant="outline"` gives it one. See [prop conventions](../../design/prop-conventions) for the shared axes.

### NebaChartSeries

<PropsTable name="NebaChartSeries" />

### NebaChartAxis

`xAxis` and `yAxis` both take this shape.

<PropsTable name="NebaChartAxis" />

### NebaChartBrush

<PropsTable name="NebaChartBrush" />

### NebaChartReference

Every entry of `references` takes this shape.

<PropsTable name="NebaChartReference" />

### NebaChartLegend

<PropsTable name="NebaChartLegend" />

### NebaChartTooltip

<PropsTable name="NebaChartTooltip" />

## Examples

### curve

`curve` decides how the line gets from one point to the next. `linear` is the default and claims nothing the data did not say. `smooth` is a monotone cubic: curved, but it will never dip below a value both of its neighbours are above. `step` holds each value until the next reading, which is what a rate limit or a plan tier actually did in between.

<Demo src="line-chart/curve">

<<< @/.vitepress/demos/line-chart/curve.tsx

</Demo>

### xAxis · yAxis

A line chart crops its value axis to the data, because a line encodes a _position_ and cropping moves every point by the same amount. Pass `yAxis` with a `min` of `0` when zero belongs on the scale.

`min`, `max` and `tickCount` set the range; `tickFormat` writes each tick; `grid: false` drops the gridlines; `hidden` drops the axis entirely and gives its band back to the plot.

<Demo src="line-chart/axes">

<<< @/.vitepress/demos/line-chart/axes.tsx

</Demo>

### tickAngle

Turns the category labels, between `-90` and `90` degrees. Negative tilts them up to the right, positive tilts them down, and `-90` stands them on end.

Flat, a long category name has one slot to fit in, so the axis cuts it to an ellipsis and then starts dropping every other one. Turned, each label only has to clear its neighbour across its own height, and the room a name needs stops depending on how long the name is. The band under the plot grows to hold them, up to a cap; past that they are still cut.

Only the category axis reads it, and only where that axis runs along the bottom — a `horizontal` [BarChart](./bar-chart) already gives each name a row of its own.

<Demo src="line-chart/ticks">

<<< @/.vitepress/demos/line-chart/ticks.tsx

</Demo>

### nulls

What the line does where a value is missing.

- `gap` — breaks at it. The default, and the only one that claims nothing.
- `connect` — joins the two sides with a straight segment. For a gap that came from the collection rather than from the world; a bridged gap is a value the chart made up.
- `zero` — reads the gap as a nought. It rewrites the data rather than the drawing, so the axis takes the nought into its range and the tooltip and the table say `0` too. Reach for it when a missing row genuinely means none happened, which is what an event count usually means and what a rate never does.

`connectNulls` is the old spelling of `connect` and still works; it is read only when `nulls` is left out.

<Demo src="line-chart/gaps">

<<< @/.vitepress/demos/line-chart/gaps.tsx

</Demo>

### brush

A strip under the plot with the whole series on it, and a window the reader drags to choose which part the chart draws.

It is for a series too long to read at the width of the plot, such as a year of hourly readings. LineChart, AreaChart and BarChart take it; a ScatterChart and a TimelineChart do not, since a window cut by index is not a range of a cloud's x or of a timeline's rows.

Drag the window to pan and either handle to resize; both handles are `role="slider"` buttons, so the arrow keys move them one category at a time, `Page Up` and `Page Down` a tenth of the series, and `Home` and `End` jump to the ends. The strip is a group named after the chart. `defaultRange` sets where the window starts, `range` and `onRangeChange` hand it to the caller, and `height` sizes the strip — which is drawn **inside** the chart's own height, like the axis labels.

The window narrows the picture and nothing else: the hidden table and the exported file still hold every point.

<Demo src="line-chart/brush">

<<< @/.vitepress/demos/line-chart/brush.tsx

</Demo>

### secondaryAxis

A second value axis, drawn on the far edge — the right of a vertical chart, the top of one turned on its side. The series that carry `axis: 'secondary'` are measured against it; passing `secondaryAxis` is what turns the split on, so a series asking for it on a chart with one axis is measured on that one rather than half-applied.

Its `tickFormat` writes its series' numbers **everywhere they appear**: the ticks, the tooltip and the table.

It draws no gridlines of its own. Its range is cut into as many intervals as the first axis has, in clean steps, so each of its ticks sits on a rule already there and both axes are read against one grid. A `tickCount` of its own opts out of that: the axis then rounds to its own ticks, which fall between the rules.

**Not read on a stacked chart.** A stack is a total, and a total across two units is not a number.

<Demo src="line-chart/two-axes">

<<< @/.vitepress/demos/line-chart/two-axes.tsx

</Demo>

### references

Lines and bands drawn across the plot at values the data has none of — a target, an SLA, a budget, the window a forecast covers. Every cartesian chart takes them.

`value` places one. `to` turns it into a band. `axis: 'category'` reads the numbers against the other axis, for a rule that says _when_ rather than _how much_: on an axis of columns that number is the column's index, and on one of dates or numbers it is a point on that scale. The index counts from the first category of the whole series, so it stays on its column when a `brush` narrows the plot. A rule outside what the plot draws is left out, and a band is cut at the plot's edge.

The **scale widens to hold them**, so a target above everything measured is still on the chart. They are drawn under the marks and over the grid, dashed and neutral unless told otherwise. One that names itself is read out with the data.

<Demo src="line-chart/references">

<<< @/.vitepress/demos/line-chart/references.tsx

</Demo>

### valueLabels · gradient · markers

`valueLabels` writes numbers onto the line: `last` names where each series ended up, `extremes` marks each series' own high and low, `all` labels every point. The default is `none`.

Each number wears its own series' colour, taken one step toward the page's ink so a small label keeps its contrast.

`markers` puts dots on the points. `auto` draws them while there are fourteen or fewer; the point under the pointer always gets one regardless.

`gradient` fades each line from a paler step of its own hue at the start to the full colour at the end.

<Demo src="line-chart/labels">

<<< @/.vitepress/demos/line-chart/labels.tsx

</Demo>

### exportable

Adds a small button in the corner that writes the chart's data out as a CSV file — the same numbers the hidden table under the plot holds. Every chart with a hidden table takes it.

`exportFileName` names the file. `onExport` takes the CSV string instead of downloading it, for posting it somewhere or putting a sheet around it.

The module that writes the file is **fetched when the button is pressed**, so a page that never turns this on downloads none of it. A `GaugeChart` does not take these three.

<Demo src="line-chart/export">

<<< @/.vitepress/demos/line-chart/export.tsx

</Demo>

### legend

The legend appears automatically from two series up and is left off below that. `side` and `align` place it; clicking an entry hides its series, and the survivors keep the colour they had. A hidden series stays hidden when new data puts the series in another order, as long as it keeps its `name`. `legend={false}` removes it, `interactive: false` makes it a key rather than a control.

The legend takes a row of its own outside `height`, or a column beside the plot, so a chart that gains its legend after the first render grows by it and moves what is around it. That happens when the series arrive after the chart first appears, or when a second series is added to one. Hand the chart its series from the first render, with their `name`s and an empty `data` while the numbers load, or set `legend` to `true` to draw it for a single series as well.

`showValue` writes each series' value at the active column beside its name. Each row keeps room for the widest value its series holds while no column is active too, so the legend stays the same size as the pointer comes and goes.

<Demo src="line-chart/legend">

<<< @/.vitepress/demos/line-chart/legend.tsx

</Demo>

### Colour

Series take palette slots in the order they are passed: eight hues, fixed. From a ninth series the slots repeat, and a development build says so once in the console. A ninth series is not a ninth colour; fold the tail into an "Other" series or draw a second chart.

`series.color` overrides the slot with a `NebaColor` family or any CSS colour, and a point's own `color` overrides that for one mark. See [colour](../../design/color) for the ramp and what it is solved for.

```tsx
<LineChart
  series={[
    { name: 'Errors', data: errors, color: 'danger' },
    { name: 'Warnings', data: warnings, color: 'warning' }
  ]}
/>
```

### format

`format` takes `Intl.NumberFormat` options and applies everywhere a number appears: the axis, the tooltip, the value labels, the table. Without it, axis ticks past ten thousand are compacted (`12.4K`).

```tsx
<LineChart format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }} … />
<LineChart format={{ style: 'percent', maximumFractionDigits: 1 }} … />
```

On a server-rendered page, pass `locale` too. A chart with no `locale`, its own or a `NebaProvider`'s, writes its numbers and dates in `en-US` on the server and while the page hydrates, then switches to the reader's language; with one, it writes that language from the first render. `locale` fixes the language but not the time zone: a `Date` is written in the time zone of whatever renders it, so `new Date('2026-03-03')` is `Mar 3` on a server running in UTC and `Mar 2` in a browser in Los Angeles. When the server and the readers can be in different time zones, pass date categories as strings you have formatted yourself, with an explicit `timeZone`.

```tsx
const day = new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', timeZone: 'UTC' });

<LineChart locale="en-US" categories={dates.map((date) => day.format(date))} … />
```

### initialWidth

A chart is laid out in pixels, and a server has no box to measure, so a server-rendered chart is an empty box of the right height until the page has hydrated: the drawing is not in the first paint or in the HTML a crawler reads. `initialWidth` is a width in pixels to draw at on the server and while the page hydrates. Once the chart has measured its box it is drawn at the real width.

Pass the width the chart is usually shown at: the closer it is, the less the drawing changes when the measured width replaces it. Every chart takes it, a [Sparkline](./sparkline) included. It is ignored when `height` is a CSS length, which has to be measured as well, and a chart mounted in the browser never draws at it, since it measures itself before its first paint.

The drawing makes the server's HTML larger, and by how many marks there are: a BarChart of a dozen categories adds about 10 kB, a [ScatterChart](./scatter-chart) of a thousand points close to 400 kB. Reach for it on the charts a reader sees first.

```tsx
<LineChart initialWidth={720} label="Weekly active users by month" … />
```

## Accessibility

- Every chart renders a **table of its data**, visually hidden and available to assistive technology. `label` becomes its caption and the chart's accessible name. A tooltip never carries a value that is not also in that table. Past 500 data points, the caption and the header row are written at once and the rows are added in small batches just after the chart first draws, so a server-rendered page does not carry them in its HTML. The plot is described by one sentence with the number of values and their range rather than by the table, so a focus does not read every number out. With a `secondaryAxis`, the series on it get a second sentence in that axis' format.
- The plot is focusable. `←` and `→` step the crosshair between categories, `Home` and `End` jump to the ends, `Escape` clears it, so the tooltip is reachable without a pointer.
- On a touch screen a tap shows the tooltip of the nearest point and keeps it up; a tap anywhere outside the plot puts it down. The same holds on every chart with a tooltip.
- The legend is a list of `aria-pressed` buttons, so which series are drawn is stated rather than implied by colour.
- Identity is never carried by colour alone: the legend is always present from two series up, and the palette's adjacent pairs are verified against simulated protanopia and deuteranopia.
