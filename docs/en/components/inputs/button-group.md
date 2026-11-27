---
title: ButtonGroup
order: 2
flutter: true
---

# ButtonGroup

<p class="neba-lede">Joins several Buttons into one set. The corners that face a neighbour are squared off, and shared props are set once on the group.</p>

<Demo src="button-group/hero" />

::: fw react

```tsx
import { Button, ButtonGroup } from 'neba';

<ButtonGroup variant="outline">
  <Button>Day</Button>
  <Button>Week</Button>
  <Button>Month</Button>
</ButtonGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaButtonGroup(
  variant: NebaVariant.outline,
  children: <Widget>[
    NebaButton(onPressed: day, child: const Text('Day')),
    NebaButton(onPressed: week, child: const Text('Week')),
    NebaButton(onPressed: month, child: const Text('Month')),
  ],
);
```

:::

## Props

<PropsTable name="ButtonGroup" />

::: fw react

Every native `<div>` attribute passes straight through, minus `color`.

:::

::: fw flutter

The buttons are `children`. A button takes its own argument first, then the group's, then `NebaProvider`'s, so `disabled` on a button is `bool?`: left out, it is the group's.

:::

## Examples

### Shared props

`variant` · `size` · `color` · `density` · `elevation` · `disabled` set on the group reach every child [Button](./button). A value set on a button overrides the group's, so one `danger` button can sit in a row of secondary actions.

<Demo src="button-group/shared">

::: fw react

<<< @/.vitepress/demos/button-group/shared.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/shared.dart

:::

</Demo>

### orientation

`vertical` stacks the buttons and squares off the top and bottom corners instead.

<Demo src="button-group/orientation">

::: fw react

<<< @/.vitepress/demos/button-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/orientation.dart

:::

</Demo>

### fullWidth

Stretches the group to the container width, with the buttons sharing the space equally. A button whose label needs more than an even share keeps its own width, and the others share what is left.

<Demo src="button-group/full-width">

::: fw react

<<< @/.vitepress/demos/button-group/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/full_width.dart

:::

</Demo>

## Accessibility

- <Fw react="Renders `role=&quot;group&quot;`. Give it an `aria-label`" flutter="Groups its buttons for a screen reader. Give it a `semanticLabel`" /> when the button labels alone do not say what the set is for.
- It does not manage selection. For one-of-a-set, use [SegmentedButton](./segmented-button) or [RadioGroup](./radio-group).
- The hovered or focused button is raised above its neighbours so its focus ring is never clipped.
