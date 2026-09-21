---
title: PieChart
order: 5
---

# PieChart

<p class="neba-lede">Shows parts of a whole as slices of a circle. It answers one question well (is one of these most of it?), and everything finer than that belongs in a bar chart.</p>

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

A pie has one series, so it takes `data` directly rather than an array of series. The slices are the entities here: each one takes a palette slot of its own, and the legend lists them.

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

Slices are drawn in the order they are given and are not re-sorted. A slice's colour follows its place in `data`, so a filter that drops one moves every slice after it onto the next colour; a point's own `color` holds it.

A negative value draws no slice and adds nothing to the total. It stays in the table and the legend, as it does on a treemap.

## Props

<PropsTable name="PieChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props). See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### shape

`pie` is a filled disc. `donut` opens a hole for the total. `semi` draws half a ring from the bottom of the box, which fits a dashboard tile that is wider than it is tall.

<Demo src="pie-chart/shapes">

<<< @/.vitepress/demos/pie-chart/shapes.tsx

</Demo>

### hole · gap

`shape` already sets how much of the middle is cut out — `0` for a `pie`, `0.62` for a `donut` and a `semi` — and `hole` is the dial behind it, from `0` to `0.92` of the radius. Reach for it when the default ring is the wrong weight: a thin one reads as a progress track and a thick one as a pie with a hole punched in it. Setting one on a `pie` is also how that shape gets a `center`.

`gap` is the surface showing between two touching slices, in pixels. A length rather than an angle, because the gap is a constant on screen: one that looked right on a 300px chart is a wedge out of a 60px one. `0` closes it, and it is never taken off a slice too narrow to spare it.

<Demo src="pie-chart/ring">

<<< @/.vitepress/demos/pie-chart/ring.tsx

</Demo>

### center

`center` is drawn in the hole of a `donut` or a `semi`. Put the total there, or the one figure the chart is about.

```tsx
<PieChart shape="donut" center={<Typography level="h4">38.6K</Typography>} … />
```

### valueLabels

`all` writes each slice's **share** on it rather than its value, which stays in the tooltip. A label is only drawn where the slice is wide enough for the text with room on both sides; one that does not fit is dropped rather than clipped, and the tooltip and the table still have it.

### Colour

Slices take palette slots in the order they are passed. A point's own `color` overrides that. Use it when the slices _mean_ something, such as passed and failed.

<Demo src="pie-chart/colors">

<<< @/.vitepress/demos/pie-chart/colors.tsx

</Demo>

### legend · startAngle

The legend appears from two slices up and is interactive by default: clicking a slice's entry removes it and the rest renormalise to fill the circle. `startAngle` turns the whole thing, in degrees clockwise from twelve o'clock.

```tsx
<PieChart legend={{ side: 'right', align: 'center' }} startAngle={-30} … />
```

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`. The plot itself is described by one sentence with the number of values and their range, so a focus does not read the table out.
- The plot is focusable; `←` and `→` step between slices, `Home` and `End` go to the first and the last, and `Escape` clears the selection, so the tooltip is reachable without a pointer. On a touch screen a tap keeps the slice's tooltip up until a tap lands outside the plot.
- A share written with `valueLabels="all"` takes the ink that reads best on its slice. A slice given a literal colour, such as `#ffe066`, gets black or white by contrast.
- Slices are separated by a gap of the surface colour, sized to stay 2px on screen at any radius, rather than by a stroke around each one.
