---
title: Tooltip
order: 4
flutter: true
---

# Tooltip

<p class="neba-lede">A short label that appears when the pointer rests on something. Use it to supplement a control that shows only an icon.</p>

<Demo src="tooltip/hero" align="center" minHeight="120" />

::: fw react

```tsx
import { Button, Tooltip } from 'neba';

<Tooltip content="Copy the deploy URL">
  <Button variant="outline" startIcon={<LinkIcon />} aria-label="Copy the deploy URL" />
</Tooltip>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTooltip(
  content: const Text('Copy the deploy URL'),
  child: NebaButton(
    onPressed: copy,
    variant: NebaVariant.outline,
    semanticLabel: 'Copy the deploy URL',
    startIcon: const LinkIcon(),
  ),
);
```

:::

## Props

<PropsTable name="Tooltip" />

::: fw react

Native `<div>` attributes pass through to the popup. Only `color`, `content` and `children` are excluded, since the table above spells them differently.

The trigger merges onto `children` rather than rendering a box of its own, so the tooltip costs the layout nothing. `children` must be a single element that accepts a ref and spreads props: every Neba component does.

:::

::: fw flutter

The tooltip wraps `child` rather than merging onto it, so any widget can be the trigger, and it still costs the layout nothing. The label is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s is.

:::

## Examples

### side and align

`side` is where the popup sits relative to the trigger; `align` is its alignment along that axis. The side flips automatically when there is no room at the window edge. `sideOffset` sets the gap and `arrow` draws a pointer.

<Demo src="tooltip/sides" minHeight="120">

::: fw react

<<< @/.vitepress/demos/tooltip/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/sides.dart

:::

</Demo>

### delay and <Fw react="TooltipProvider" flutter="NebaTooltipProvider" />

`delay` is how long the pointer must rest before opening; `closeDelay` is how long the tooltip stays after it leaves.

Wrapping tooltips in a <Fw react="TooltipProvider" flutter="NebaTooltipProvider" code /> makes them share the delay: once one has opened, its neighbours open instantly, and the delay comes back after a pause. That way a row of icon buttons does not make you wait at every stop.

::: fw flutter

The provider takes `delay` and `closeDelay` for every tooltip without its own, and `timeout`, the pause after which the wait comes back, 400 milliseconds by default.

:::

<Demo src="tooltip/grouped" minHeight="120">

::: fw react

<<< @/.vitepress/demos/tooltip/grouped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/grouped.dart

:::

</Demo>

## Accessibility

::: fw react

- The popup carries `role="tooltip"`, and the trigger gets `aria-describedby` pointing at it only while it is open.
- A tooltip is a **description**, never a name. Give an icon-only button its own `aria-label`.
- It opens on keyboard focus but not on focus that arrived from a click, and closes on Escape.
- A `disabled` button takes no focus, so a tooltip on one cannot be opened from the keyboard. Give the [Button](../inputs/button) `focusableWhenDisabled` to keep it in the tab order.
- On a touch screen it cannot be reached by pointer, and anything clickable inside it cannot be clicked. Use a popover if you need either.

:::

::: fw flutter

- A `content` that is a `Text` is the trigger's tooltip to a screen reader, heard after the trigger's own name whether the label is showing or not, and the label is not read a second time. Any other `content` is read where it is drawn, while it is open.
- A tooltip is a **description**, never a name. Give a button with only an icon its own `semanticLabel`.
- It opens at once on keyboard focus but not on a focus a press gave the trigger, and closes on Escape.
- A disabled button takes no focus, so a tooltip on one cannot be opened from the keyboard. Give the [Button](../inputs/button) `focusableWhenDisabled` to keep it in the focus order.
- A touch never opens it, and anything inside it cannot be pressed. Use a popover if you need either.

:::
