---
title: GaugeChart
order: 9
---

# GaugeChart

<p class="neba-lede">One number on a scale that is known in advance, drawn as a dial. For a dashboard tile, where a dial reads at a glance from across a room and a four-pixel bar does not.</p>

<Demo src="gauge-chart/hero" />

```tsx
import { GaugeChart } from 'neba';

<GaugeChart label="Memory" caption="Memory" value={82} />;
```

## Props

<PropsTable name="GaugeChart" />

Every [Box](../surfaces/box) prop passes through, so the dial can be a card of its own. There is no `legend` and no `tooltip`: one value has nothing to distinguish and nothing to uncover — the number is written in the middle.

It is a [Meter](../feedback/meter) bent into an arc, and deliberately the same component in two shapes: `value`, `min`, `max` and `thresholds` mean what they mean there, so a reading can move from a bar to a dial without changing what it says.

It is not a [PieChart](./pie-chart) with `shape="semi"`. A pie is parts of a whole and every slice is a category; this is one value against a scale, and the unfilled part of the arc is not a second category — it is the rest of the dial.

## Examples

### value · min · max

`value` of `null` draws the dial with nothing on it and a dash in the middle, which is the honest picture of an instrument that has not been told anything.

### thresholds

Where the arc changes colour. The last entry the value has reached wins; below all of them `color` stands.

<Demo src="gauge-chart/thresholds">

<<< @/.vitepress/demos/gauge-chart/thresholds.tsx

</Demo>

### sweep

How far round the dial goes, opened symmetrically about twelve o'clock. `180` is the half-dial a tile wants, `270` is the instrument shape, `360` is a ring. The drawing is sized against the box for the sweep it was given, so a half-dial does not leave an empty half above it.

<Demo src="gauge-chart/sweep">

<<< @/.vitepress/demos/gauge-chart/sweep.tsx

</Demo>

### ticks · thickness · showRange

`ticks` draws marks around the dial, ends included; it is off by default, because a gauge on a dashboard is read as a proportion and ticks are for an instrument somebody takes a number off. `thickness` is the arc's weight as a fraction of its radius, and `showRange` writes `min` and `max` at the two ends.

<Demo src="gauge-chart/ticks">

<<< @/.vitepress/demos/gauge-chart/ticks.tsx

</Demo>

### center · caption

The value in the middle is real text — selectable, findable, and in the accessibility tree. `center` replaces it, for the dial whose reading is a word; `caption` is a line under it for the unit.

## Accessibility

- Given a `label`, the dial is one `role="img"` named with the reading and the top of its range. Without one it is a plain box, and the number in the middle is read as the text it already is.
- Colour is never the only carrier: a reading that has crossed a threshold has also filled more of the arc, and the number is written out.
