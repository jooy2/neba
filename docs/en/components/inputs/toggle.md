---
title: Toggle
order: 25
flutter: true
---

# Toggle

<p class="neba-lede">A button that stays down. It holds a state rather than running an action: bold on the selected words, the grid on the canvas, a filter on the list.</p>

<Demo src="toggle/hero" />

::: fw react

```tsx
import { Toggle } from 'neba';

<Toggle defaultPressed>Bold</Toggle>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaToggle(defaultPressed: true, child: Text('Bold'));
```

:::

## Props

<PropsTable name="Toggle" />

::: fw react

Every `<button>` attribute passes through except `value`, which identifies the toggle inside a [ToggleGroup](./toggle-group), and `color`, which is the semantic family. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

The label is `child`. `value` identifies the toggle inside a [ToggleGroup](./toggle-group), and the shared axes are described in [prop conventions](../../design/prop-conventions). A toggle reads its own argument first, then its group's, then `NebaProvider`'s, so `disabled` is `bool?`.

:::

A [Switch](./switch) changes a setting and the change itself is the point; a [Checkbox](./checkbox) is an answer that goes in a form. This is neither: it is a control that acts on whatever is beside it.

## Examples

### pressed and onPressedChange

`pressed` with `onPressedChange` makes it controlled; `defaultPressed` makes it uncontrolled.

<Demo src="toggle/controlled">

::: fw react

<<< @/.vitepress/demos/toggle/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/controlled.dart

:::

</Demo>

### variant

`variant` says how the toggle looks while it is **off**. `outline` is the default, `solid` is a filled plate that fills with the accent, and `text` has no surface at all until it is hovered or on.

An off toggle carries no colour family in any of the three: the plate is neutral and the label is muted. Turning it on moves the plate, the label and the hairline into the accent together.

<Demo src="toggle/variants">

::: fw react

<<< @/.vitepress/demos/toggle/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/variants.dart

:::

</Demo>

### Icon-only

With no <Fw react="`children`" flutter="`child`" /> the toggle goes square around whatever `startIcon` it was given, which is the shape a toolbar wants. An icon carries no accessible name, so give it <Fw react="an `aria-label`" flutter="a `semanticLabel`" />.

<Demo src="toggle/icons">

::: fw react

<<< @/.vitepress/demos/toggle/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/icons.dart

:::

</Demo>

### size

`size` is the same control height a Button, a TextField and a Chip use, so a toggle keeps the baseline in a mixed row.

<Demo src="toggle/sizes">

::: fw react

<<< @/.vitepress/demos/toggle/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/sizes.dart

:::

</Demo>

### color

`color` is what the toggle turns when it goes on. Off it is neutral in every family.

<Demo src="toggle/colors">

::: fw react

<<< @/.vitepress/demos/toggle/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/colors.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a `<button>` carrying `aria-pressed`.
- An icon-only toggle needs an `aria-label`; there is no text to take a name from.

:::

::: fw flutter

- It is a button to a screen reader, which also hears whether it is on.
- An icon-only toggle needs a `semanticLabel`; there is no text to take a name from.

:::

- Inside a [ToggleGroup](./toggle-group) the set is one tab stop and the arrow keys move between the members.
