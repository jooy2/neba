---
title: AreaChart
order: 3
---

# AreaChart

<p class="neba-lede">A line with the space under it filled. Use it for a quantity that adds up to something, and stacked, for what that total is made of.</p>

<Demo src="area-chart/hero" />

```tsx
import { AreaChart } from 'neba';

<AreaChart
  label="Storage used by tier"
  categories={['Jan', 'Feb', 'Mar']}
  stacked
  series={[
    { name: 'Hot', data: [120, 138, 149] },
    { name: 'Archive', data: [610, 648, 690] }
  ]}
/>;
```

The data model is the one every chart shares: `series`, `categories`, and a `null` that means a gap rather than a zero. It is written out on the [LineChart](./line-chart#the-data) page.

The choice between the two is about what the quantity _is_: if it does not add up to anything (a temperature, a rate, a score), the fill under the line is decoration, and two of them overlapping is two washes fighting.

## Props

<PropsTable name="AreaChart" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. `xAxis`, `yAxis`, `legend` and `tooltip` take the same shapes they take on [LineChart](./line-chart#props). See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### stacked

`false` overlays the bands, which answers "how big is each". `true` stacks them, so the top edge is the total. `'full'` normalises every category to 100%, which makes the chart about the mix and stops it being about the size: the value axis becomes a percentage and says so, and the tooltip keeps the original number.

<Demo src="area-chart/stacked">

<<< @/.vitepress/demos/area-chart/stacked.tsx

</Demo>

### One series

With a single series there is no legend: the card's title already says what is plotted, and a box with one swatch in it would only restate it.

<Demo src="area-chart/single">

<<< @/.vitepress/demos/area-chart/single.tsx

</Demo>

### curve · markers · connectNulls

The same three props [LineChart](./line-chart#curve) has, meaning the same things. `markers` defaults to `none` here rather than `auto`: a filled band already has a visible edge.

`connectNulls` matters more on an area than on a line: a fill that closes across a missing month paints a made-up number over a larger part of the chart.

```tsx
<AreaChart curve="step" markers="all" connectNulls … />
```

### Value axis

Unlike a line chart, an area chart keeps zero on its value axis. The fill's thickness _is_ the magnitude, so a cropped baseline would leave the band's height meaning nothing. `yAxis`'s own `min` and `max` still override it where the caller has a reason.

## Accessibility

- The data is also rendered as a **visually hidden table**, captioned with `label`.
- The plot is focusable; `←` / `→` step the crosshair, `Home` / `End` jump to the ends, `Escape` clears it.
- With `stacked="full"`, the tooltip and the table report the value the caller passed, not the percentage: the chart shows the share, and the number is still reachable.
