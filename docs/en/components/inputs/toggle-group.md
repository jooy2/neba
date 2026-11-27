---
title: ToggleGroup
order: 26
flutter: true
---

# ToggleGroup

<p class="neba-lede">A set of toggles that share one state. The corners facing a neighbour are squared off, the set owns the value, and the shared props are set once for every member.</p>

<Demo src="toggle-group/hero" />

::: fw react

```tsx
import { Toggle, ToggleGroup } from 'neba';

<ToggleGroup aria-label="Text alignment" defaultValue={['left']}>
  <Toggle value="left">Left</Toggle>
  <Toggle value="center">Center</Toggle>
  <Toggle value="right">Right</Toggle>
</ToggleGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaToggleGroup(
  semanticLabel: 'Text alignment',
  defaultValue: <String>['left'],
  children: <Widget>[
    NebaToggle(value: 'left', child: Text('Left')),
    NebaToggle(value: 'center', child: Text('Center')),
    NebaToggle(value: 'right', child: Text('Right')),
  ],
);
```

:::

## Props

<PropsTable name="ToggleGroup" />

::: fw react

Every `<div>` attribute passes through. `variant`, `size`, `color`, `density`, `elevation` and `disabled` are passed to every [Toggle](./toggle) in the set; a toggle's own prop still wins, so one danger toggle in a set of neutral ones is a normal thing to write.

:::

::: fw flutter

The toggles are `children`, each named by its `value`. `variant`, `size`, `color`, `density`, `elevation` and `disabled` are passed to every [Toggle](./toggle) in the set; a toggle's own argument still wins, so one danger toggle in a set of neutral ones is a normal thing to write.

:::

## Examples

### value and onValueChange

The value is an array in both the single and the multiple case, so turning `multiple` on does not change its type. `value` with `onValueChange` makes the set controlled; `defaultValue` makes it uncontrolled.

### multiple

Off, which is the default, means turning one toggle on turns the last one off. If what is being chosen is a _value_ rather than a set of states, [SegmentedButton](./segmented-button) or [RadioGroup](./radio-group) is the component that says so.

<Demo src="toggle-group/multiple">

::: fw react

<<< @/.vitepress/demos/toggle-group/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/multiple.dart

:::

</Demo>

### variant

The set's `variant` reaches every toggle in it.

<Demo src="toggle-group/variants">

::: fw react

<<< @/.vitepress/demos/toggle-group/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/variants.dart

:::

</Demo>

### orientation

`vertical` stacks the toggles and squares off the horizontal seams instead. The arrow keys follow the orientation.

<Demo src="toggle-group/orientation">

::: fw react

<<< @/.vitepress/demos/toggle-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/orientation.dart

:::

</Demo>

### fullWidth

Stretches to the container and divides the width evenly between the toggles.

<Demo src="toggle-group/full-width">

::: fw react

<<< @/.vitepress/demos/toggle-group/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/full_width.dart

:::

</Demo>

## Accessibility

- The set is one tab stop; the arrow keys move between the toggles and `loopFocus` decides whether they wrap at the ends.
- A group has no name of its own: give it <Fw react="an `aria-label`" flutter="a `semanticLabel`" />.
