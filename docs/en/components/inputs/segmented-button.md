---
title: SegmentedButton
order: 19
flutter: true
---

# SegmentedButton

<p class="neba-lede">Joins two or three choices into one control, with exactly one taken. Use it for short labels where every option should stay visible in little space.</p>

<Demo src="segmented-button/hero" />

::: fw react

```tsx
import { Segment, SegmentedButton } from 'neba';

<SegmentedButton aria-label="Range" defaultValue="week">
  <Segment value="day">Day</Segment>
  <Segment value="week">Week</Segment>
  <Segment value="month">Month</Segment>
</SegmentedButton>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaSegmentedButton<String>(
  semanticLabel: 'Range',
  defaultValue: 'week',
  children: <NebaSegment<String>>[
    NebaSegment<String>(value: 'day', child: Text('Day')),
    NebaSegment<String>(value: 'week', child: Text('Week')),
    NebaSegment<String>(value: 'month', child: Text('Month')),
  ],
);
```

:::

## Props

### SegmentedButton

<PropsTable name="SegmentedButton" />

::: fw react

`value` with `onValueChange` makes it controlled; `defaultValue` makes it uncontrolled. The set needs a name, so pass `aria-label` or `aria-labelledby`.

:::

::: fw flutter

The segments are `children`, a list of `NebaSegment`, and the set is generic over the type of their `value`. `value` with `onValueChange` makes it controlled; left `null`, the set keeps its own state from `defaultValue`. The set needs a name, so pass `semanticLabel`. There is no `name`, because a Flutter set has no form submission to name its value for.

:::

For a row of actions rather than a choice, use [ButtonGroup](./button-group), and when there are panels underneath, use [Tabs](../surfaces/tabs). More than about five options or long labels want a [Select](./select), and a set that needs a visible label fits a [RadioGroup](./radio-group) better.

### Segment

<PropsTable name="Segment" />

## Examples

### variant

`solid` rides a filled tile in a trough. `outline` is the same trough with a border, lighting the chosen sheet instead of filling it. `text` drops the trough and gives a surface only to the chosen segment.

<Demo src="segmented-button/variants">

::: fw react

<<< @/.vitepress/demos/segmented-button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/variants.dart

:::

</Demo>

### size

The same control heights as [Button](./button): a `md` segment and a `md` button are both 32px, so the two sit in one toolbar without the row losing its baseline.

<Demo src="segmented-button/sizes">

::: fw react

<<< @/.vitepress/demos/segmented-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/sizes.dart

:::

</Demo>

### startIcon · disabled · readOnly

`readOnly` shows which one is chosen but does not let it change, draining the saturation. `disabled` drops the colour family for neutral grey. `disabled` can also be set per `Segment`.

<Demo src="segmented-button/states">

::: fw react

<<< @/.vitepress/demos/segmented-button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/states.dart

:::

</Demo>

### fullWidth

Stretches the set to the container width, with the segments sharing the space equally.

## Accessibility

::: fw react

- Renders `role="radiogroup"`. The set takes one tab stop, the arrow keys move within it, and the chosen segment carries `aria-checked`.

:::

::: fw flutter

- A screen reader hears a radio group, with each segment a radio and the chosen one checked. The set takes one tab stop, the arrow keys move within it and choose as they go, and Space or Enter chooses the focused segment.

:::
