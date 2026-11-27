---
title: Meter
order: 11
flutter: true
---

# Meter

<p class="neba-lede">How much of something there is, on a scale that is known in advance: disk used, seats taken, quota spent. It looks like a progress bar and is not one: the number is already known, and where it sits is what it means.</p>

<Demo src="meter/hero" />

::: fw react

```tsx
import { Meter } from 'neba';

<Meter value={38} label="Storage" showValue />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaMeter(value: 38, label: Text('Storage'), showValue: true);
```

:::

## Props

<PropsTable name="Meter" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

The bar takes the width it is given. `label` is a widget, usually a `Text`, and `semanticLabel` names the meter for a screen reader in its place. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

`value` is required, and that is the difference from [ProgressLinear](./progress-linear). A progress bar is about time: something is happening, it may have no value at all, and it is expected to move on its own. A meter is about quantity: it does not move unless the thing it measures does.

### NebaThreshold

<PropsTable name="NebaThreshold" />

## Examples

### thresholds

Where the bar changes colour. Each entry is a point on the scale and the family the bar takes from there up; the last one the value has reached wins, and below all of them `color` stands. List them smallest `from` first: they are read in the order they are given.

<Demo src="meter/thresholds">

::: fw react

<<< @/.vitepress/demos/meter/thresholds.tsx

:::

</Demo>

### min · max · format

`showValue` prints the reading beside the label. Without a `format` it is a share of `min`…`max`; with one it is the number itself, <Fw react="through `Intl.NumberFormat`" flutter="as the function writes it" />: which is the usual case here, because a meter normally has real units. <Fw react="`locale` is the language that writes it in, and falls back to a provider's, so a server and a browser write the same thing." flutter="The function is handed the value held to the range, in whatever language the app writes it, so there is no `locale`." />

<Demo src="meter/values">

::: fw react

<<< @/.vitepress/demos/meter/values.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/meter/values.dart

:::

</Demo>

### size

`size` is the thickness of the groove, on the same ladder a ProgressLinear uses, so the two line up when a page carries both.

<Demo src="meter/sizes">

::: fw react

<<< @/.vitepress/demos/meter/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/meter/sizes.dart

:::

</Demo>

### thickness

The same prop a [ProgressLinear](./progress-linear) takes, and for the same reason: `size` is a step on the ladder, `thickness` is a number of <Fw react="pixels" flutter="logical pixels" />.

## Accessibility

::: fw react

- Carries `role="meter"` with the value and range attributes.
- `label` becomes the accessible name, and `aria-valuetext` says the same thing as the printed value.

:::

::: fw flutter

- A screen reader hears the reading as the meter's value, the same text `showValue` prints.
- A `Text` given as `label` becomes the name a screen reader hears, and `semanticLabel` replaces it.

:::

- Colour is never the only carrier: a bar that has crossed a threshold is also longer, and the printed value says the number.
