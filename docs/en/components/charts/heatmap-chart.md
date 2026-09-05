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

The `series` shape is the one every chart shares: see [LineChart](./line-chart#the-data) for the full definition. Here a series is a **row** of the grid or a **group** of the treemap, `y` is the magnitude, and `x` names the column or the tile.

A `null` is a gap and the cell is left as surface. It is not drawn as the bottom of the scale, because "nothing happened" and "the least of anything" are two different readings and only one of them is in the data.

The scale runs across every cell in the chart rather than per row. A colour has to mean the same number wherever it appears, which is the whole promise a heatmap makes; `min` and `max` pin the ends where a comparison needs a fixed frame.

## Props

<PropsTable name="HeatmapChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### shape

`grid` is the shape for two categorical axes and one number: hours against weekdays, a cohort against a week. `treemap` packs a tile per datum, sized by its share, and fills the box.

A treemap is squarified rather than sliced: tiles are laid in rows and each row is closed the moment its aspect ratios stop improving. Sliced, twenty values end as slivers a pixel wide, and a sliver's area is unreadable however exact it is.

A treemap has no axes (every tile is named on its own face), and a negative value has no area to be, so it stays in the table and off the picture.

<Demo src="heatmap-chart/treemap">

<<< @/.vitepress/demos/heatmap-chart/treemap.tsx

</Demo>

### scale

`sequential` is one hue from pale to deep, and it is right whenever more is simply more. `diverging` is two hues either side of a neutral grey, for a value with a **middle** that means something: over and under target, gained and lost. `midpoint` says where that middle is.

Reach for `diverging` only when there is a real zero to diverge about. On a plain magnitude it invents a boundary the data has none of, and the reader spends the chart looking for what changed at the grey.

Neither ramp is the eight-slot [categorical palette](../../design/color): colour here encodes size, not identity, and a heatmap in eight hues says its cells are eight unrelated things.

<Demo src="heatmap-chart/diverging">

<<< @/.vitepress/demos/heatmap-chart/diverging.tsx

</Demo>

### valueLabels · min · max

`valueLabels="all"` writes each value on its cell, where the cell is big enough for the text with room either side; a label that does not fit is dropped rather than clipped. Inside a filled cell the label picks its ink from the step underneath it, so it stays readable at both ends of the ramp.

`min` and `max` pin the scale. Left out, the ends come from the data: which means two charts of different data are not comparable until they are given the same bounds.

<Demo src="heatmap-chart/labels">

<<< @/.vitepress/demos/heatmap-chart/labels.tsx

</Demo>

### legend

The legend is a scale bar with its two ends labelled, not a list of swatches: nothing here has a name, and the order is the meaning. On a `diverging` scale the midpoint is named under the middle of the bar. `legend={false}` leaves it off, and `legend`'s own `side` moves it.

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`, one row per series and one column per category.
- The plot is focusable; `←` / `→` walk the cells, `Escape` clears the tooltip.
- The scale legend gives the two ends of the range as numbers, so the ramp never has to be read by eye alone.
