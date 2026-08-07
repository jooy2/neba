---
title: ScatterChart
order: 6
---

# ScatterChart

<p class="neba-lede">Two measures per point, drawn against each other, for reading whether they move together. A point that also carries a third number is drawn as a bubble, so a scatter plot and a bubble chart are one component.</p>

<Demo src="scatter-chart/hero" />

```tsx
import { ScatterChart } from 'neba';

<ScatterChart
  label="Pages read against session length"
  xAxis={{ label: 'Seconds on site' }}
  yAxis={{ label: 'Pages' }}
  series={[
    {
      name: 'Organic',
      data: [
        { x: 22, y: 2 },
        { x: 41, y: 3 },
        { x: 55, y: 4 }
      ]
    }
  ]}
/>;
```

## The data

The `series` shape is the one every chart shares — see [LineChart](./line-chart#the-data) for the full definition — with one requirement of its own: **every point carries an `x`**, and that `x` is a number or a `Date`. Both axes measure here, so a bare number as a datum has nothing to be placed against; a point given a string `x` is not on a number line and the chart draws its empty state rather than a row of marks at zero.

```ts
{ x: 22, y: 2 }              // a dot
{ x: 22, y: 2, z: 180 }      // a bubble
{ x: 22, y: null }           // a gap: no mark, and an empty cell in the table
```

`categories` supplies the `x` of a point that does not carry one, found by index.

`z` is optional and is read as an **area**. A point without it is drawn at `pointRadius`; a point with it is scaled under `maxRadius` by the square root of its share, so a value four times as large draws a bubble twice as wide.

## Props

<PropsTable name="ScatterChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props). See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### Bubbles

A `z` on a point turns it into a bubble. `maxRadius` is the radius of the largest one and everything else is scaled under it; leave it out and it is a twelfth of the plot's short side.

The scale is taken across every series and does not move when the legend is filtered, so two bubbles the same size mean the same number wherever they are.

<Demo src="scatter-chart/bubble">

<<< @/.vitepress/demos/scatter-chart/bubble.tsx

</Demo>

### shape

Scatter is the form where any two marks can end up side by side, so the palette has to separate on **every** pair rather than on the pairs that touch — and run that way it separates three series. Past three, `shape="auto"` gives each series a mark of its own, in the fixed order circle, square, triangle, diamond, cross. The legend shows the same shapes.

`shape="varied"` turns that on from the first series, which is what a chart that will be printed or read in greyscale wants. Naming one of the five shapes uses it for every mark; on four or more series that is opting out of the second channel, so do it only when each series carries a `color` of its own.

<Demo src="scatter-chart/shape">

<<< @/.vitepress/demos/scatter-chart/shape.tsx

</Demo>

### xAxis · yAxis

The x axis is a value axis here, not a category axis: it ticks at rounded numbers rather than at the data, and it casts a grid — reading a mark's x off the picture is half of what the chart is for. Setting `grid` to `false` on `xAxis` turns it off.

Neither axis is forced through zero. What a position encodes is a place, so cropping a scale slides every mark by the same amount and the shape of the cloud survives; `min` and `max` pin an axis where a comparison needs a fixed frame.

`format` belongs to the value axis, so `xAxis.tickFormat` is how the x ticks are written.

<Demo src="scatter-chart/axes">

<<< @/.vitepress/demos/scatter-chart/axes.tsx

</Demo>

### tooltip

There are no shared categories to gather, so the tooltip is always about one mark: the pointer picks the nearest one within its own radius plus 24px, and there is no crosshair. The panel's heading is the mark's `x` and its row is the series and the `y`; a point's own `label` replaces the value, and `tooltip.render` replaces the panel.

```tsx
<ScatterChart tooltip={{ render: ({ category, items }) => … }} … />
```

### Colour

A series takes its palette slot from its place in the `series` array, so filtering the legend never repaints the survivors. `series.color` overrides the slot with a [colour family](../../design/color) or any CSS colour, and a point's own `color` overrides it for that one mark.

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`, with one row per point and its columns named from the axis labels.
- The plot is focusable; `←` / `→` walk the marks in the order the data was given, `Home` / `End` jump to the ends, `Escape` clears the tooltip.
- Past three series, identity is carried by shape as well as by colour — which is what makes the chart readable under colour vision deficiency, in greyscale and in print.
