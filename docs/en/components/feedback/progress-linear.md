---
title: ProgressLinear
order: 5
flutter: true
---

# ProgressLinear

<p class="neba-lede">Shows progress as a horizontal bar. It is the most widely used of the three progress components.</p>

<Demo src="progress-linear/hero" />

::: fw react

```tsx
import { ProgressLinear } from 'neba';

<ProgressLinear value={64} label="Uploading assets" showValue />
<ProgressLinear />
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaProgressLinear(value: 64, label: Text('Uploading assets'), showValue: true);
const NebaProgressLinear();
```

:::

## Props

<PropsTable name="ProgressLinear" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

The bar takes the width it is given. `label` is a widget, usually a `Text`, and `semanticLabel` names the bar for a screen reader in its place. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

`value` defaults to `null`, the indeterminate state: a short segment travels along the groove. A `value` of `0` means something different ("nothing has progressed yet"), so keep the two apart.

## Examples

### size

<Demo src="progress-linear/sizes">

::: fw react

<<< @/.vitepress/demos/progress-linear/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/sizes.dart

:::

</Demo>

### thickness

`size` is a step on the library's ladder; `thickness` is a number of <Fw react="pixels" flutter="logical pixels" />, for the bar a page is actually about. It changes the groove alone — `size` still sets the type scale of the label beside it.

::: fw react

```tsx
<ProgressLinear value={62} thickness={12} />
```

:::

::: fw flutter

```dart
const NebaProgressLinear(value: 62, thickness: 12)
```

:::

### min · max · format

The percentage shown is a proportion of `min`…`max`, not of 100. `showValue` prints it beside the bar, and <Fw react="`format` takes `Intl.NumberFormat` options" flutter="`format` is a function from the value to its text" /> so you can show the number itself: bytes, files, currency.

::: fw react

`locale` is the language that writes it in, and falls back to a provider's, so a server and a browser write the same thing.

:::

::: fw flutter

The function is handed the value held to the range, and writes it in whatever language and with whatever formatter the app already uses, so there is no `locale`.

:::

<Demo src="progress-linear/values">

::: fw react

<<< @/.vitepress/demos/progress-linear/values.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/values.dart

:::

</Demo>

## Reduced motion

<Fw react="`prefers-reduced-motion`" flutter="`MediaQuery.disableAnimations`" /> does not stop the indeterminate animation. The travelling segment is replaced by a colour pulse across the whole groove.

## Accessibility

::: fw react

- Carries `role="progressbar"` with the value and range attributes; `aria-valuenow` is dropped while indeterminate.
- `label` becomes the accessible name, and `aria-valuetext` says the same thing as the printed value.

:::

::: fw flutter

- A screen reader hears the reading as the bar's value, the same text `showValue` prints; while indeterminate there is no value and the bar is announced as a busy indicator.
- A `Text` given as `label` becomes the name a screen reader hears, and `semanticLabel` replaces it.

:::
