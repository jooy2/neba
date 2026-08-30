---
title: Meter
order: 11
---

# Meter

<p class="neba-lede">How much of something there is, on a scale that is known in advance — disk used, seats taken, quota spent. It looks like a progress bar and is not one: the number is already known, and where it sits is what it means.</p>

<Demo src="meter/hero" />

```tsx
import { Meter } from 'neba';

<Meter value={38} label="Storage" showValue />;
```

## Props

<PropsTable name="Meter" />

Native `<div>` attributes pass through to the root. Only `color` and `children` are excluded, since the table above spells them differently.

`value` is required, and that is the difference from [ProgressLinear](./progress-linear). A progress bar is about time — something is happening, it may have no value at all, and it is expected to move on its own. A meter is about quantity: it does not move unless the thing it measures does.

### NebaThreshold

<PropsTable name="NebaThreshold" />

## Examples

### thresholds

Where the bar changes colour. Each entry is a point on the scale and the family the bar takes from there up; the last one the value has reached wins, and below all of them `color` stands. List them smallest `from` first — they are read in the order they are given.

<Demo src="meter/thresholds">

<<< @/.vitepress/demos/meter/thresholds.tsx

</Demo>

### min · max · format

`showValue` prints the reading beside the label. Without a `format` it is a share of `min`…`max`; with one it is the number itself, through `Intl.NumberFormat` — which is the usual case here, because a meter normally has real units.

<Demo src="meter/values">

<<< @/.vitepress/demos/meter/values.tsx

</Demo>

### size

`size` is the thickness of the groove, on the same ladder a ProgressLinear uses, so the two line up when a page carries both.

<Demo src="meter/sizes">

<<< @/.vitepress/demos/meter/sizes.tsx

</Demo>

## Accessibility

- Carries `role="meter"` with the value and range attributes.
- `label` becomes the accessible name, and `aria-valuetext` says the same thing as the printed value.
- Colour is never the only carrier: a bar that has crossed a threshold is also longer, and the printed value says the number.
