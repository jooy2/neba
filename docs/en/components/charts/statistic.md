---
title: Statistic
order: 8
---

# Statistic

<p class="neba-lede">Displays a single named figure. Given a previous value, it works out the change and shows it alongside.</p>

<Demo src="statistic/hero" />

```tsx
import { Statistic } from 'neba';

<Statistic label="Monthly recurring revenue" value={48210} prefix="$" previousValue={42800} />;
```

## Props

<PropsTable name="Statistic" />

Every native `<div>` attribute passes through, along with every [Box](../surfaces/box) prop. The delta renders as a [Chip](../display/chip).

## Examples

### previousValue · delta · betterWhen

Pass `previousValue` and the change against the current value is calculated and shown. `delta` decides whether that change is written as a proportion, as the difference, or as both.

`betterWhen` says which direction is good news. Revenue is better up, churn is better down — without it there is no way to colour the delta.

<Demo src="statistic/comparison">

<<< @/.vitepress/demos/statistic/comparison.tsx

</Demo>

The figure and the delta change shape as well as colour — a rising arrow, a falling one, a short dash when nothing moved. Direction is never carried by colour alone.

### icon · unit · caption · align

`icon` sits before the label and `unit` after the figure. `children` is the slot under the figure, for a [ProgressLinear](../feedback/progress-linear) against a target or a [Sparkline](./sparkline). `align="center"` is for a row of tiles laid out as one band.

`prefix` and `unit` are separate props because they are typographically different: a currency symbol leads its number, a unit follows it.

<Demo src="statistic/anatomy">

<<< @/.vitepress/demos/statistic/anatomy.tsx

</Demo>

### format

`format` is passed straight through as `Intl.NumberFormat` options. Without it a number is only digit-grouped for the reader's locale. A string `value` is printed unformatted, so figures that are not numbers still work.

```tsx
<Statistic label="Revenue" value={48210} format={{ style: 'currency', currency: 'USD' }} />
<Statistic label="Conversion" value={0.0423} format={{ style: 'percent', maximumFractionDigits: 1 }} />
<Statistic label="Median build" value="3m 12s" />
```

A `previousValue` of `0` makes the proportion undefined, so the absolute difference is shown regardless of the `delta` setting.

### locale

`locale` decides which language the figure and its delta are written in. It is the same prop every chart takes, so one dashboard can set the same value on a Statistic and on the [LineChart](./line-chart) beside it. Without it the reader's own locale is used.

```tsx
<Statistic label="Revenue" value={1234.5} locale="de-DE" format={{ minimumFractionDigits: 1 }} />
```
