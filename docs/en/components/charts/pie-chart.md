---
title: PieChart
order: 5
---

# PieChart

<p class="neba-lede">Shows parts of a whole as slices of a circle. It answers one question well — is one of these most of it? — and everything finer than that belongs in a bar chart.</p>

<Demo src="pie-chart/hero" />

```tsx
import { PieChart } from 'neba';

<PieChart
  label="Sessions by traffic source"
  shape="donut"
  categories={['Organic', 'Direct', 'Paid']}
  data={[18420, 9260, 6140]}
/>;
```

## The data

A pie has one series, so it takes `data` directly rather than an array of series. The slices are the entities here — each one takes a palette slot of its own, and the legend lists them.

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

Slices are drawn in the order they are given and are not re-sorted, so a chart that is refiltered keeps every category the colour and the position it had.

## Props

<PropsTable name="PieChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props). See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### shape

`pie` is a filled disc. `donut` opens a hole for the total. `semi` draws half a ring from the bottom of the box, which fits a dashboard tile that is wider than it is tall.

<Demo src="pie-chart/shapes">

<<< @/.vitepress/demos/pie-chart/shapes.tsx

</Demo>

### center

Whatever goes in the hole of a `donut` or a `semi`. A ring with nothing in the middle is a pie with a bite out of it; the total, or the one figure the chart is about, is what it was drawn around.

```tsx
<PieChart shape="donut" center={<Typography level="h4">38.6K</Typography>} … />
```

### valueLabels

`all` writes each slice's **share** on it — a share is what a pie is a picture of, and the value is one hover away. A label is only drawn where the slice is wide enough for the text with room on both sides; one that does not fit is dropped rather than clipped, and the tooltip and the table still have it.

### Colour

Slices take palette slots in the order they are passed. A point's own `color` overrides that, which is the right move when the slices _mean_ something — passed and failed are not "series one" and "series two".

<Demo src="pie-chart/colors">

<<< @/.vitepress/demos/pie-chart/colors.tsx

</Demo>

### legend · startAngle

The legend appears from two slices up and is interactive by default: clicking a slice's entry removes it and the rest renormalise to fill the circle. `startAngle` turns the whole thing, in degrees clockwise from twelve o'clock.

```tsx
<PieChart legend={{ side: 'right', align: 'center' }} startAngle={-30} … />
```

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`.
- The plot is focusable; `←` and `→` step between slices and `Escape` clears the selection, so the tooltip is reachable without a pointer.
- Slices are separated by a gap of the surface colour, sized to stay 2px on screen at any radius, rather than by a stroke around each one.

## When not to use it

An angle is a poor thing to compare: two slices within a few percent of each other are indistinguishable, and no reader can rank six of them. Past six slices, or when the question is "how do these rank", use a [BarChart](./bar-chart). A two-slice pie is a [Statistic](./statistic).
