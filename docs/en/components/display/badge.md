---
title: Badge
order: 6
flutter: true
---

# Badge

<p class="neba-lede">A small marker overlaid on the corner of another element. Use it to report an unread count or a current status without covering what it sits on.</p>

<Demo src="badge/hero" />

::: fw react

```tsx
import { Badge, Button } from 'neba';

<Badge content={4} label="4 unread notifications">
  <Button startIcon={<BellIcon />} aria-label="Notifications" />
</Badge>

<Badge dot color="success" overlap="circle">
  <Avatar />
</Badge>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaBadge.count(
  count: 4,
  semanticLabel: '4 unread notifications',
  child: NebaButton(onPressed: open, semanticLabel: 'Notifications', startIcon: bell),
);

const NebaBadge(
  color: NebaColor.success,
  overlap: NebaBadgeOverlap.circle,
  child: NebaAvatar(name: 'Jane Doe'),
);
```

:::

## Props

<PropsTable name="Badge" />

::: fw react

Given `children`, the wrapping `<span>` becomes the positioning context and the marker pins to its corner. Without `children` the marker lays out inline on its own, which is what a status marker in a table cell is.

:::

::: fw flutter

Given a `child`, the marker pins to its corner and the child is laid out exactly as it would be bare. Without one the marker sits in a row on its own, which is what a status marker in a table cell is. A number goes to the `NebaBadge.count` constructor, which caps it and hides a zero; the default constructor takes a widget as `content`, or nothing for a dot.

:::

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### variant and color

`solid` is a filled marker, `outline` a border over a faint panel, `text` a tinted mark with no edge. `color` picks one of the six role colours.

<Demo src="badge/variants">

::: fw react

<<< @/.vitepress/demos/badge/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/variants.dart

:::

</Demo>

### content and max

<Fw react="`content`" flutter="`content`, or `count` on `NebaBadge.count`," /> is what the marker says. A number past `max` (default `99`) renders as `99+`; <Fw react="a string" flutter="anything else" /> is never truncated.

A `content` of `0` draws nothing by default: turn it on with `showZero`. When there is nothing to count but something to report, leave `content` out and the badge draws a dot, or pass `dot` to draw one over a count; `invisible` hides the marker while keeping the layout intact.

<Demo src="badge/content">

::: fw react

<<< @/.vitepress/demos/badge/content.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/content.dart

:::

</Demo>

### placement and overlap

`placement` is the corner the marker pins to: one of four values built from `top`/`bottom` and `start`/`end`. Because it uses `start`/`end`, the corner flips automatically in RTL.

`overlap` is the shape of the element underneath. `circle` tucks the marker further in, by the amount a circle's corner sits inside its bounding box, so the marker does not float off an avatar.

<Demo src="badge/placement">

::: fw react

<<< @/.vitepress/demos/badge/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/placement.dart

:::

</Demo>

### size

Badge has its own size steps rather than a step off the control heights. `md` is 18px, the smallest at which a two-digit number stays legible.

<Demo src="badge/sizes">

::: fw react

<<< @/.vitepress/demos/badge/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/sizes.dart

:::

</Demo>

## Accessibility

- <Fw react="`content={3}`" flutter="`count: 3`" /> on its own is just "3" to a screen reader. A sentence in <Fw react="`label`" flutter="`semanticLabel`" /> becomes the marker's accessible name instead.

::: fw react

- The marker is drawn beside what it sits on, not inside it, so a reader who tabs to a badged button hears the button's name and nothing about the count. Give the badge an `id` and point the control's `aria-describedby` at it, and the sentence is read with the button.

```tsx
const unread = React.useId();

<Badge id={unread} content={3} label="3 unread notifications">
  <Button startIcon={<BellIcon />} aria-label="Notifications" aria-describedby={unread} />
</Badge>;
```

- Under `dot` the `content` stays in the DOM, clipped rather than removed, so what the dot means is still readable.
- When the badge is `invisible` or has nothing to show, it leaves the DOM entirely, so find-on-page does not turn up text that is not on screen.

:::

::: fw flutter

- The marker is its own node beside what it sits on, so a reader who moves to a badged button hears the button's name and the marker's sentence one after the other.
- Under `dot` the content is still read, so what the dot means is not lost.
- A badge that is `invisible`, or has nothing to show, says nothing and keeps its room.

:::
