---
title: AnimateMarquee
order: 9
flutter: true
---

# AnimateMarquee

<p class="neba-lede">Content scrolling steadily past, forever. The content is laid down twice and each copy travels exactly its own length, so there is no seam and no frame where the strip is empty.</p>

<Demo src="animate-marquee/hero" />

::: fw react

```tsx
import { AnimateMarquee } from 'neba';

<AnimateMarquee speed={45} gap="1.5rem">
  {customers.map((name) => (
    <Chip key={name}>{name}</Chip>
  ))}
</AnimateMarquee>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaAnimateMarquee(
  speed: 45,
  gap: 24,
  children: <Widget>[for (final String name in customers) NebaChip(child: Text(name))],
);
```

:::

## Props

<PropsTable name="AnimateMarquee" />

::: fw react

Every other `<span>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

It takes the width it is given, or its content's length where the width is unbounded, and is as tall as its content; a vertical strip takes the height it is given. `gap` is in logical pixels. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Each copy builds `children` again, so none of them may carry a `GlobalKey` or a `FocusNode` of its own: a node handed to two widgets belongs to whichever was built last, which is a copy that cannot take the focus.

:::

## Examples

### speed and reverse

Pixels per second, measured against the strip's own width, so four logos and forty move at the same pace instead of the long one becoming a blur. `duration` is still accepted and overrides the measurement. `reverse` runs it the other way.

<Demo src="animate-marquee/speed">

::: fw react

<<< @/.vitepress/demos/animate-marquee/speed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/speed.dart

:::

</Demo>

### orientation

<Fw react="`vertical`" flutter="`NebaOrientation.vertical`" /> runs the strip down the box instead of across it, for a log or an activity feed. The box needs a height for it to have anywhere to run.

<Demo src="animate-marquee/vertical">

::: fw react

<<< @/.vitepress/demos/animate-marquee/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/vertical.dart

:::

</Demo>

### pauseOnHover

On by default, and not decoration: content moving past a pointer cannot be clicked reliably, and a link inside a strip that never stops is a link nobody can follow. The strip answers the focus as well as the pointer, so a link reached by tabbing to it stops travelling too. With <Fw react='`trigger="hover"`' flutter="`NebaAnimateTrigger.hover`" /> it does not apply, because the pointer and the focus are what start the strip.

<Demo src="animate-marquee/pause">

::: fw react

<<< @/.vitepress/demos/animate-marquee/pause.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/pause.dart

:::

</Demo>

### copies and gap

`gap` is the space between items, and also between the last item of one pass and the first of the next. `copies` is how many times the content is laid end to end: two is enough for anything at least as wide as its container, and raising it is the fix for content short enough to leave a hole behind itself.

::: fw react

```tsx
<AnimateMarquee copies={4} gap="3rem">
  <Chip>One short item</Chip>
</AnimateMarquee>
```

:::

::: fw flutter

```dart
const NebaAnimateMarquee(
  copies: 4,
  gap: 48,
  children: <Widget>[NebaChip(child: Text('One short item'))],
);
```

:::

## Accessibility

- Only the first copy is read out and reached; the rest <Fw react="carry `aria-hidden` and `inert`" flutter="are left out of the semantics tree, the focus order and the pointer" />, or a screen reader would announce the whole strip as many times as it was laid down and a keyboard would stop at each link as many times.
- A reduced-motion preference stops the strip, draws its content once instead of `copies` times, and lets it wrap onto more lines rather than cutting it off at the edge.
- `pauseOnHover` is what makes anything interactive inside it usable, and it covers both a pointer resting on the strip and the focus landing inside it. Do not turn it off for a strip with links or buttons in it.
- A pointer resting on the strip is not something a touch screen can do, and the strip keeps moving past five seconds. Put a pause button beside it and bind its state to `paused`.
