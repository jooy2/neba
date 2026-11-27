---
title: ProgressBox
order: 7
flutter: true
---

# ProgressBox

<p class="neba-lede">Shows progress as a row of plates that fill in turn. It is the shape that fits a loading state on a Neba surface.</p>

<Demo src="progress-box/hero" align="center" />

::: fw react

```tsx
import { ProgressBox } from 'neba';

<ProgressBox />
<ProgressBox value={62} label="Migrating" showValue />
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaProgressBox();
const NebaProgressBox(value: 62, label: Text('Migrating'), showValue: true);
```

:::

## Props

<PropsTable name="ProgressBox" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

The row takes the width of its plates or of the label above them, whichever is wider. `semanticLabel` names it for a screen reader in place of `label`. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

`value`, `min`, `max`, `format` and `showValue` behave as they do on [ProgressLinear](./progress-linear). A `value` of `null` gives the indeterminate state, where the plates light in sequence.

## Examples

### count

How many plates to draw. With a value, they fill left to right and the leading plate fills partially: all-or-nothing plates could only ever show 0, 25, 50, 75 or 100 at a count of four.

<Demo src="progress-box/counts">

::: fw react

<<< @/.vitepress/demos/progress-box/counts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/counts.dart

:::

</Demo>

### Using it as a step indicator

Match `count` to the real number of steps and each plate becomes one step, with the running step's plate shown mid-fill.

<Demo src="progress-box/steps">

::: fw react

<<< @/.vitepress/demos/progress-box/steps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/steps.dart

:::

</Demo>

## Reduced motion

The plates never move; only the fill and the light edge animate. Under <Fw react="`prefers-reduced-motion`" flutter="`MediaQuery.disableAnimations`" /> the cycle slows down.

## Accessibility

::: fw react

- Carries `role="progressbar"` with the value attributes, and `label` becomes the accessible name.
- The indeterminate state reports itself as indeterminate rather than as zero.

:::

::: fw flutter

- A screen reader hears the reading as the row's value, and a `Text` given as `label` becomes its name; `semanticLabel` replaces it.
- The indeterminate state is announced as a busy indicator with no value, rather than as zero.

:::
