---
title: Switch
order: 7
flutter: true
---

# Switch

<p class="neba-lede">Turns a setting on or off immediately. Use it where the change takes effect the moment it is made.</p>

<Demo src="switch/hero" />

::: fw react

```tsx
import { Switch } from 'neba';

<Switch label="Email alerts" defaultChecked />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaSwitch(label: Text('Email alerts'), defaultChecked: true);
```

:::

## Props

<PropsTable name="Switch" />

::: fw flutter

`label`, `description` and `error` are widgets, usually a `Text`. There is no `name`, because a Flutter switch has no form submission to take part in, and no `labelPlacement`, which the React package keeps only as the old name of `labelSide`. `semanticLabel` names a switch that has no label.

:::

If there is a Save button underneath and the value is submitted with a form, use [Checkbox](./checkbox) instead. That is what separates the two.

## Examples

### checked and onCheckedChange

`checked` with `onCheckedChange` makes it controlled; `defaultChecked` makes it uncontrolled.

### disabled · readOnly

<Demo src="switch/states">

::: fw react

<<< @/.vitepress/demos/switch/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/states.dart

:::

</Demo>

### labelSide

`end` (the default) puts the label after the control, so it reads as a caption. `start` suits a settings list, where the labels form a left column and the switches line up on the right.

::: fw react

It was called `labelPlacement`, which is the name every field uses for where its label is drawn — above it, on its edge, inside it — and which a [NebaProvider](../../guide/provider) fills in for all of them. `labelPlacement` still works here when `labelSide` is left out, and goes in the next minor release.

:::

::: fw flutter

The values are `NebaSwitchLabelSide.start` and `NebaSwitchLabelSide.end`. The switches line up when the column stretches them across its width, as a `NebaFlex` column does by default.

:::

<Demo src="switch/placement">

::: fw react

<<< @/.vitepress/demos/switch/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/placement.dart

:::

</Demo>

### size

<Demo src="switch/sizes">

::: fw react

<<< @/.vitepress/demos/switch/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/sizes.dart

:::

</Demo>

### classNames

::: fw react

`className` lands on the field wrapper, not on the track. The track and the thumb are reached through `classNames`.

```tsx
<Switch label="Email alerts" classNames={{ control: 'w-14', thumb: 'rounded-sm' }} />
```

The slots are `label`, `control`, `thumb`, `description` and `error`. `control` is the track (the pill that fills when the switch is on), and `thumb` is the disc that travels across it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

There are no class names. The label, the description and the error are widgets, so each takes a style of its own; the track and the thumb are the switch's.

:::

## Accessibility

::: fw react

- Renders `role="switch"` with a hidden `<input>` beside it.
- The label is wired to the control, so clicking the text flips it.
- Without a `label`, give it an `aria-label`.
- The thumb's travel becomes instant under `prefers-reduced-motion`.

:::

::: fw flutter

- A screen reader hears one switch, on or off. A `Text` label is its name, and a `Text` description and error are read after it.
- A press on the label flips it, and so does a press on the gap between the label and the track.
- Without a `label`, give it a `semanticLabel`.
- The thumb's travel becomes instant when the platform asks for less motion.

:::
