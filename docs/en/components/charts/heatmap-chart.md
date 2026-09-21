---
title: HeatmapChart
order: 8
---

# HeatmapChart

<p class="neba-lede">A magnitude per cell, coloured rather than measured. Two shapes of one idea: a grid, for two categorical axes and one number; and a treemap, for parts of a whole with more parts than a pie can hold.</p>

<Demo src="heatmap-chart/hero" />

```tsx
import { HeatmapChart } from 'neba';

<HeatmapChart
  label="Sessions by hour and weekday"
  categories={['00', '06', '12', '18']}
  series={[
    { name: 'Mon', data: [4, 24, 51, 18] },
    { name: 'Tue', data: [3, 27, 55, 20] }
  ]}
/>;
```

## The data

The `series` shape is the one every chart shares: see [LineChart](./line-chart#the-data) for the full definition. Here a series is a **row** of the grid. A treemap packs every series' tiles together by size, so there a series names its tiles in the table rather than keeping them in one place. `y` is the magnitude, and `x` names the column or the tile.

A `null` is a gap, and the cell is left as surface rather than drawn as the bottom of the scale.

The scale runs across every cell in the chart rather than per row, so a colour means the same number wherever it appears. `min` and `max` pin the ends where a comparison needs a fixed frame.

## Props

<PropsTable name="HeatmapChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### shape

`grid` is the shape for two categorical axes and one number: hours against weekdays, a cohort against a week. `treemap` packs a tile per datum into the box, sized by its share and kept as close to square as it can be.

A treemap has no axes (every tile is named on its own face), and a negative value has no area to be, so it stays in the table and off the picture.

<Demo src="heatmap-chart/treemap">

<<< @/.vitepress/demos/heatmap-chart/treemap.tsx

</Demo>

### scale

`sequential` is one hue from pale to deep, and it is right whenever more is simply more. `diverging` is two hues either side of a neutral grey, for a value with a **middle** that means something: over and under target, gained and lost. `midpoint` says where that middle is.

Reach for `diverging` only when there is a real zero to diverge about. Neither ramp takes its colours from the eight-slot [categorical palette](../../design/color).

<Demo src="heatmap-chart/diverging">

<<< @/.vitepress/demos/heatmap-chart/diverging.tsx

</Demo>

### valueLabels · min · max

`valueLabels="all"` writes each value on its cell, where the cell is big enough for the text with room either side; a label that does not fit is dropped rather than clipped. Inside a filled cell the label picks its ink from the step underneath it, so it stays readable at both ends of the ramp.

`min` and `max` pin the scale. Left out, the ends come from the data, so two charts of different data are comparable only once they are given the same bounds. On a sequential scale whose values are all the same there is no range to spread, so zero or less takes the lightest step and anything above zero the darkest.

<Demo src="heatmap-chart/labels">

<<< @/.vitepress/demos/heatmap-chart/labels.tsx

</Demo>

### xAxis · yAxis

A `grid` has two **category** axes: `xAxis` names the columns along the bottom and `yAxis` names the rows down the side. What the magnitude is drawn on is the colour ramp, which the scale legend describes rather than an axis — so `min`, `max`, `tickCount` and `grid` mean nothing here and are not read. The chart's own `min` and `max` are the ones that set the ramp.

`label` names the axis, `tickFormat` writes each name, `hidden` drops the band and gives it back to the cells, and `thickness` pins it so two grids on a dashboard line up. `xAxis.tickAngle` turns the column names, which is what lets a grid of long stage names keep all of them; `yAxis` does not read it, because a row already has a line of its own.

A `treemap` names its tiles on their own faces and reads neither axis.

<Demo src="heatmap-chart/axes">

<<< @/.vitepress/demos/heatmap-chart/axes.tsx

</Demo>

### legend

The legend is a scale bar with its two ends labelled, not a list of swatches. On a `diverging` scale the midpoint is named under the middle of the bar. `legend={false}` leaves it off, and `legend`'s own `side` moves it.

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`, one row per series and one column per category. A treemap's columns are every tile name its groups use, and each value sits under its own name. The plot itself is described by one sentence with the number of values and their range, so a focus does not read the table out.
- The plot is focusable. On a grid `←` / `→` walk the cells row by row and `↑` / `↓` keep the column and change the row; on a treemap every arrow walks the tiles from the largest to the smallest. `Escape` clears the tooltip. On a touch screen a tap keeps a cell's tooltip up until a tap lands outside the plot.
- The scale legend gives the two ends of the range as numbers, so the ramp never has to be read by eye alone.
