---
title: Statistic
order: 8
---

# Statistic

<p class="neba-lede">A number with its name on it, and — when there is something to compare it against — how far it has moved.</p>

<Demo src="statistic/hero" />

```tsx
import { Statistic } from 'neba';

<Statistic label="Monthly recurring revenue" value={48210} prefix="$" previousValue={42800} />;
```

A [Box](../surfaces/box) with a fixed arrangement laid on it, exactly as [Card](../surfaces/card) is. The slots are props rather than compound sub-components for the reason Card gives: the order never varies, so what a caller wants to decide is what goes in each slot.

The delta is a [Chip](./chip) and not a coloured span, which is the whole reason it looks right next to everything else — the same token the rest of the library uses, at the same step down the control ladder, with the same acrylic on it.

## Props

<PropsTable name="Statistic" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop.

## Examples

### The comparison

`betterWhen` is what makes the delta trustworthy. Both cards below went _up_; only one of them is good news, and the colour has to say which. `delta` decides whether the change is written as a proportion, as the difference itself, or as both.

<Demo src="statistic/comparison">

<<< @/.vitepress/demos/statistic/comparison.tsx

</Demo>

The figure and the delta both carry a shape, not only a colour — a rising arrow, a falling one, a dash for a figure that has not moved. A report whose "down" is red and nothing else says nothing at all to a reader who cannot separate red from green.

### Anatomy

An icon on the label, a unit on the figure, and anything of your own underneath — a [ProgressLinear](../feedback/progress-linear) against a target, a sparkline. `align="center"` is for a row of tiles that should read as one band.

<Demo src="statistic/anatomy">

<<< @/.vitepress/demos/statistic/anatomy.tsx

</Demo>

### Formatting

`format` is passed straight to `Intl.NumberFormat`, the same prop the [progress indicators](../feedback/progress-linear) take. Without it a number is grouped by the reader's own locale and otherwise left alone. A string `value` is printed exactly as given, for the figures that are not numbers at all.

```tsx
<Statistic label="Revenue" value={48210} format={{ style: 'currency', currency: 'USD' }} />
<Statistic label="Conversion" value={0.0423} format={{ style: 'percent', maximumFractionDigits: 1 }} />
<Statistic label="Median build" value="3m 12s" />
```

`prefix` and `unit` are two slots and not one adornment with a side, because they are typographically different things and always have been: a currency symbol leads its number and a unit follows it, in every locale that has both.

### When there is nothing to divide by

A percentage against a `previousValue` of `0` is not a large number, it is an undefined one — so the ratio is dropped and the absolute difference is written instead. Reporting `+∞%` because last month was the first month is the kind of thing a dashboard does exactly once before nobody trusts it again.

## Coming from Ant Design

| Ant | Neba |
| --- | --- |
| `title` | `label` — the name of a _value_, which is what the library already calls `label` |
| `value` | The same |
| `precision={2}` | <code v-pre>format={{ minimumFractionDigits: 2, maximumFractionDigits: 2 }}</code> |
| `prefix` / `suffix` | `prefix` / `unit` |
| `valueStyle` | Not offered. `color`, `size` and `variant` are the axes |
| `<Statistic.Countdown />` | Not offered. Pass a formatted string as `value` and tick it yourself |
| — | `previousValue`, `delta`, `betterWhen` — the comparison, which Ant leaves to you |
