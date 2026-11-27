---
title: AnimateGrow
order: 9
flutter: true
---

# AnimateGrow

<p class="neba-lede">Content unfolding from a point. It starts close to its final size and can be anchored to any edge, so it reads as something opening out of the thing next to it.</p>

<Demo src="animate-grow/hero" />

::: fw react

```tsx
import { AnimateGrow } from 'neba';

<AnimateGrow origin="top">
  <Card title="Filters">Three of nine applied.</Card>
</AnimateGrow>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateGrow(
  origin: Alignment.topCenter,
  child: NebaCard(title: Text('Filters'), child: Text('Three of nine applied.')),
);
```

:::

## Props

<PropsTable name="AnimateGrow" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### origin

::: fw react

Any CSS `transform-origin`: the point that stays put while the rest moves. `top` unfolds downwards, `bottom left` out of a corner, and the default `center` grows evenly in every direction. It is the prop that decides what the growth appears to be coming _out of_.

:::

::: fw flutter

An `Alignment`: the point that stays put while the rest moves. `Alignment.topCenter` unfolds downwards, `Alignment.bottomLeft` out of a corner, and the default `Alignment.center` grows evenly in every direction. It is the prop that decides what the growth appears to be coming _out of_.

:::

<Demo src="animate-grow/origin">

::: fw react

<<< @/.vitepress/demos/animate-grow/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/origin.dart

:::

</Demo>

### from and fade

`from` is the scale it starts at, as a multiple of its final size. Below `1` it opens out; above `1` it arrives oversized and settles down onto the page. `fade` is the opacity ramp that comes with it, and turning it off is right for something already on screen that is only changing size.

<Demo src="animate-grow/settling">

::: fw react

<<< @/.vitepress/demos/animate-grow/settling.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/settling.dart

:::

</Demo>

### mode

<Fw react="`out`" flutter="`NebaAnimateMode.exit`" /> folds it away again: the same animation backwards, held at the end.

::: fw react

```tsx
<AnimateGrow mode="out" origin="top">
  <Card title="Filters">Three of nine applied.</Card>
</AnimateGrow>
```

:::

::: fw flutter

```dart
const NebaAnimateGrow(
  mode: NebaAnimateMode.exit,
  origin: Alignment.topCenter,
  child: NebaCard(title: Text('Filters'), child: Text('Three of nine applied.')),
);
```

:::

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, so the content is simply there at full size, or gone if it was leaving.
- <Fw react="Scale is applied with the standalone `scale` property rather than the `transform` shorthand, so a transform of your own on the same element survives." flutter="Scale is a transform painted around the widget as it is laid out, so nothing beside it moves and a transform of your own inside it survives." />
