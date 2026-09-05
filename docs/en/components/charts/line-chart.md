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
}
```

A `NebaChartDatum` is a number, a `null`, or a point:

```ts
type NebaChartDatum = number | null | NebaChartPoint;

interface NebaChartPoint {
  x?: string | number | Date; // its place on the category axis
  y: number | null; // the value
  color?: string; // overrides the series colour for this point
  label?: ReactNode; // what the tooltip says instead of the number
}
```

**`null` is a gap, not a zero.** A sensor that was offline and a month with no sales are different facts, and the chart draws them differently: the line breaks at a `null` and the point is not drawn. `connectNulls` bridges it, and should only be used when the gap is an artefact of how the data was collected.

`categories` names the positions along the x axis. Points may carry their own `x` instead: whichever matches the shape the data already has.

<Demo src="line-chart/data">

<<< @/.vitepress/demos/line-chart/data.tsx

</Demo>

## Props

<PropsTable name="LineChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `variant` defaults to `text` and `padded` to `false`, so a chart dropped into a [Card](../surfaces/card) draws no sheet of its own; `variant="outline"` gives it one. See [prop conventions](../../design/prop-conventions) for the shared axes.

### NebaChartAxis

`xAxis` and `yAxis` both take this shape.

<PropsTable name="NebaChartAxis" />

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

### connectNulls

<Demo src="line-chart/gaps">

<<< @/.vitepress/demos/line-chart/gaps.tsx

</Demo>

### valueLabels · gradient · markers

`valueLabels` writes numbers onto the line: `last` names where each series ended up, `extremes` marks each series' own high and low, `all` labels every point. The default is `none`: a number beside every point is the most reliable way to make a chart unreadable.

`markers` puts dots on the points. `auto` draws them while there are fourteen or fewer; the point under the pointer always gets one regardless.

`gradient` fades each line from a paler step of its own hue at the start to the full colour at the end.

<Demo src="line-chart/labels">

<<< @/.vitepress/demos/line-chart/labels.tsx

</Demo>

### legend

The legend appears automatically from two series up and is left off below that. `side` and `align` place it; clicking an entry hides its series, and the survivors keep the colour they had. `legend={false}` removes it, `interactive: false` makes it a key rather than a control.

<Demo src="line-chart/legend">

<<< @/.vitepress/demos/line-chart/legend.tsx

</Demo>

### Colour

Series take palette slots in the order they are passed: eight hues, fixed, never cycled. A ninth series is not a ninth colour; fold the tail into an "Other" series or draw a second chart.

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

## Accessibility

- Every chart renders a **table of its data**, visually hidden and available to assistive technology. `label` becomes its caption and the chart's accessible name. A tooltip never carries a value that is not also in that table.
- The plot is focusable. `←` and `→` step the crosshair between categories, `Home` and `End` jump to the ends, `Escape` clears it, so the tooltip is reachable without a pointer.
- The legend is a list of `aria-pressed` buttons, so which series are drawn is stated rather than implied by colour.
- Identity is never carried by colour alone: the legend is always present from two series up, and the palette's adjacent pairs are verified against simulated protanopia and deuteranopia.
