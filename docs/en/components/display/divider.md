---
title: Divider
order: 2
flutter: true
---

# Divider

<p class="neba-lede">A thin rule that separates content. It can carry a label to name the section it opens.</p>

<Demo src="divider/hero" />

::: fw react

```tsx
import { Divider } from 'neba';

<Divider />
<Divider>OR</Divider>
<Divider orientation="vertical" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaDivider();
const NebaDivider(child: Text('OR'));
const NebaDivider(orientation: NebaOrientation.vertical);
```

:::

## Props

<PropsTable name="Divider" />

::: fw react

There is no `variant` and no `elevation`. The rule is drawn as a single border edge, so it takes no layout beyond its own thickness.

:::

::: fw flutter

There is no `variant` and no `elevation`. The label is `child`, and a rule takes no room beyond its own thickness across it.

:::

## Examples

### length and thickness

`length` is how far the rule runs (the width of a horizontal divider, the height of a vertical one), and `thickness` is how heavy it is. <Fw react="Both take a number of pixels or any CSS length." flutter="Both are in logical pixels; a fraction of the room is a `FractionallySizedBox` around the divider." /> Left out, a horizontal rule fills <Fw react="its container" flutter="the width it is given" /> and a vertical one stretches to <Fw react="the flex row it is in" flutter="the height its row is given" />.

<Demo src="divider/size">

::: fw react

<<< @/.vitepress/demos/divider/size.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/size.dart

:::

</Demo>

### textAlign

A label in <Fw react="`children`" flutter="`child`" /> splits the rule around it. `center` halves the line; `start` and `end` leave a short stub on the near side, so the label reads as set into the rule rather than floating above it.

<Demo src="divider/labels">

::: fw react

<<< @/.vitepress/demos/divider/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/labels.dart

:::

</Demo>

### orientation

`vertical` has no height of its own and stretches to <Fw react="its flex parent" flutter="the height its row is given, so a row of fixed height or `CrossAxisAlignment.stretch` decides it" />: the shape to use between control groups in a toolbar. A vertical label turns with the rule.

<Demo src="divider/vertical">

::: fw react

<<< @/.vitepress/demos/divider/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/vertical.dart

:::

</Demo>

### color

`color` applies to the rule only, and faintly.

<Demo src="divider/colors">

::: fw react

<<< @/.vitepress/demos/divider/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/colors.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders with `role="separator"`.
- `separator` does not take its accessible name from content, so a **string** label is also passed through as `aria-label`. A node is left alone, since only the caller knows which part of it is the name: set `aria-label` yourself if you need one.

:::

::: fw flutter

- A divider without a label says nothing to a screen reader.
- A `Text` label is what a screen reader hears. Any other label is read as it is, since only the caller knows which part of it is the name.

:::
