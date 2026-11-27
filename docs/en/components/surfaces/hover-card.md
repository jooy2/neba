---
title: HoverCard
order: 16
flutter: true
---

# HoverCard

<p class="neba-lede">A card that opens when the pointer rests on something and holds a preview of what is on the other side of it: a person behind a mention, a repository behind a link, a deploy behind an id.</p>

<Demo src="hover-card/hero" />

::: fw react

```tsx
import { HoverCard, TextLink } from 'neba';

<HoverCard trigger={<TextLink href="/people/nadiarowan">@nadiarowan</TextLink>} title="Nadia Rowan">
  Maintainer · 214 commits
</HoverCard>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaHoverCard(
  trigger: NebaButton(
    onPressed: openProfile,
    variant: NebaVariant.text,
    child: const Text('@nadiarowan'),
  ),
  title: const Text('Nadia Rowan'),
  child: const Text('Maintainer · 214 commits'),
);
```

:::

## Props

<PropsTable name="HoverCard" />

::: fw react

Every native `<div>` attribute passes through to the popup, apart from `color`, `title` and `children`, which the component owns. There is no `variant` and no `elevation`.

:::

::: fw flutter

There is no `variant` and no `elevation`. The card is drawn in the app's root `Overlay`, as a [Popover](./popover)'s popup is.

:::

## Examples

### trigger

`trigger` takes one <Fw react="element" flutter="widget" /> rather than children, and the card <Fw react="merges onto it without a wrapper" flutter="wraps it without adding anything to the layout" />, so the layout is unchanged and a link stays a link. It is usually a [TextLink](../display/text-link) or an [Avatar](../display/avatar).

### delay · closeDelay

`delay` is how long the pointer has to rest before the card opens, and `closeDelay` is how long the card stays after the pointer leaves. `closeDelay` is what lets the pointer cross the gap between the trigger and the card.

<Demo src="hover-card/delay">

::: fw react

<<< @/.vitepress/demos/hover-card/delay.tsx

:::

</Demo>

### side · align · arrow

`side` is the edge of the trigger the card appears on, flipping when there is no room; `align` is where it sits along that edge. `arrow` draws the wedge and is off by default.

<Demo src="hover-card/placement" minHeight="200">

::: fw react

<<< @/.vitepress/demos/hover-card/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hover_card/placement.dart

:::

</Demo>

### size

`size` sets the type scale, the inset and how wide the card is allowed to get. `width` overrides the last of those on its own.

<Demo src="hover-card/sizes" minHeight="240">

::: fw react

<<< @/.vitepress/demos/hover-card/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hover_card/sizes.dart

:::

</Demo>

## Accessibility

- Whatever is in the card must also exist on the page the trigger leads to. A keyboard with no hover, a touchscreen with no pointer, and a screen reader all arrive by that route instead, so this can never be the only way to something.
- The card is reachable with the pointer, so a link inside it can be followed; it stays open while the pointer is in it.
- Escape closes it.

::: fw flutter

- It opens on keyboard focus after the same `delay`, never on a touch, and its `title` is drawn rather than announced as the card's name.

:::
