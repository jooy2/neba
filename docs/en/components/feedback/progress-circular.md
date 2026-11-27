---
title: ProgressCircular
order: 6
flutter: true
---

# ProgressCircular

<p class="neba-lede">Shows progress as a ring. Use it in tight space, where there is no room for a horizontal bar.</p>

<Demo src="progress-circular/hero" align="center" />

::: fw react

```tsx
import { ProgressCircular } from 'neba';

<ProgressCircular value={72} showValue label="Indexing" />
<ProgressCircular />
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaProgressCircular(value: 72, showValue: true, label: Text('Indexing'));
const NebaProgressCircular();
```

:::

## Props

<PropsTable name="ProgressCircular" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

The ring and what sits beside it take only the width they need, and a long `label` is cut short where the room runs out. `semanticLabel` names the ring for a screen reader in place of `label`. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

`value` defaults to `null`, and the ring spins while indeterminate. `min`, `max` and `format` behave exactly as they do on [ProgressLinear](./progress-linear). <Fw react="So does `locale`." />

## Examples

### size

<Demo src="progress-circular/sizes">

::: fw react

<<< @/.vitepress/demos/progress-circular/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/sizes.dart

:::

</Demo>

### thickness

`size` is the ring's diameter; `thickness` is its stroke in <Fw react="pixels" flutter="logical pixels" />, for a dial a screen is actually about. The stroke is held to half the radius, so a hole always remains in the middle.

::: fw react

```tsx
<ProgressCircular value={62} size="xl" thickness={6} />
```

:::

::: fw flutter

```dart
const NebaProgressCircular(value: 62, size: NebaSize.xl, thickness: 6)
```

:::

### Inside a control

The ring sits one step under the control height at every size (an `md` ring is 20px inside a 32px control), so dropping one into a button, a field or a table row never makes the row taller.

<Demo src="progress-circular/inline">

::: fw react

<<< @/.vitepress/demos/progress-circular/inline.tsx

:::

</Demo>

### showValue and label

The value sits beside the ring rather than inside it: at `xs` the ring is fourteen pixels across and a number would not fit. `showValue` and `label` line up in a row with it.

## Accessibility

::: fw react

- The SVG drawing is `aria-hidden`; the value reaches a screen reader through `role="progressbar"` on the element around it.
- `label` becomes the accessible name.

:::

::: fw flutter

- The drawing says nothing itself; a screen reader hears the reading as the ring's value, the same text `showValue` prints, and while indeterminate it hears a busy indicator with no value.
- A `Text` given as `label` becomes the name a screen reader hears, and `semanticLabel` replaces it.

:::
