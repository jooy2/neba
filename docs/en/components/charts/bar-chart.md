---
title: BarChart
order: 4
---

# BarChart

<p class="neba-lede">Compares lengths across categories. The mark that says <em>how much</em>, for data whose categories could be shuffled without losing anything.</p>

<Demo src="bar-chart/hero" />

```tsx
import { BarChart } from 'neba';

<BarChart
  label="Deploys per team"
  categories={['Platform', 'Payments', 'Growth']}
  series={[{ name: 'Deploys', data: [318, 264, 197] }]}
  valueLabels="all"
/>;
```

The data model is the one every chart shares — `series`, `categories`, and a `null` that means a gap rather than a zero. It is written out on the [LineChart](./line-chart#the-data) page.

A bar's **length** is its value, which is why its axis starts at zero and cannot be talked out of it: crop the scale and a bar twice as long stops meaning twice as much. Where the categories have a natural order and the shape of the change is the point, a [LineChart](./line-chart) is the better mark.

## Props

<PropsTable name="BarChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props). See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### orientation

`horizontal` is the right answer whenever the category names are words. A vertical chart gives each name the width of one bar; a horizontal one gives it a whole column, and the reading order runs the way a list does.

<Demo src="bar-chart/orientation">

<<< @/.vitepress/demos/bar-chart/orientation.tsx

</Demo>

### stacked

Grouped bars answer "which series is bigger here". Stacked bars answer "what is this total made of". `'full'` normalises every bar to the same length, which asks about the mix instead — the value axis becomes a percentage, and the tooltip keeps the original number.

They are different questions and a chart should be asked only one at a time.

<Demo src="bar-chart/stacked">

<<< @/.vitepress/demos/bar-chart/stacked.tsx

</Demo>

### Negative values

A bar that goes the other way grows down from the same zero the others grow up from — the baseline is drawn where zero is, not at the bottom of the plot.

A point's own `color` overrides its series' for one bar, which is how a single value is marked without spending a second series on it.

<Demo src="bar-chart/negative">

<<< @/.vitepress/demos/bar-chart/negative.tsx

</Demo>

### valueLabels · rounded · barSize

`valueLabels="all"` is defensible here in a way it is not on a line chart: eight bars with their numbers on them is a chart and a table at once. Past about a dozen it stops being either, and `extremes` — the series' own high and low — is the one to reach for.

`rounded` cuts the corners off the **data end** of each bar; the baseline end stays square. `barSize` caps the thickness in pixels — below the cap bars fill their share of the band, above it the leftover stays as air. `density="compact"` widens that share.

```tsx
<BarChart valueLabels="extremes" rounded={false} barSize={12} density="compact" … />
```

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`.
- The plot is focusable; `←` / `→` (or `↑` / `↓` when horizontal) step the crosshair, `Home` / `End` jump to the ends, `Escape` clears it.
- Touching bars are separated by a 2px gap of the surface colour rather than by a stroke, so nothing on the chart is ink that is not data.
