---
title: AnimateFloat
order: 9
flutter: true
---

# AnimateFloat

<p class="neba-lede">A slow drift with nowhere to get to. It says that something is not fixed to the page (an illustration, a floating card, a mark above a hero), and it runs for as long as the page is open.</p>

<Demo src="animate-float/hero" />

::: fw react

```tsx
import { AnimateFloat } from 'neba';

<AnimateFloat>
  <Card>Not fixed to the page.</Card>
</AnimateFloat>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateFloat(child: NebaCard(child: Text('Not fixed to the page.')));
```

:::

## Props

<PropsTable name="AnimateFloat" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

It repeats forever and turns round at both ends, so there is never a frame where it jumps back. There is no `mode`: a drift has no direction to be reversed.

<Fw react="It is `translate` rather than a `transform`, so it composes with anything the element is already scaled or rotated by." flutter="It is a translation painted over the widget as it is laid out, so it composes with anything the widget is already scaled or rotated by." />

## Examples

### from and distance

`from` is which way it drifts and `distance` is how far it gets: <Fw react="a CSS length, or a number of pixels" flutter="a number of logical pixels" />. Short on purpose: past about a centimetre it stops reading as something resting and starts reading as something moving.

<Demo src="animate-float/distance" minHeight="300">

::: fw react

<<< @/.vitepress/demos/animate-float/distance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_float/distance.dart

:::

</Demo>

### stagger

`stagger` puts a set of floating things out of step with each other, which is what stops four of them reading as one block. It works the same way here as on [AnimateFade](./animate-fade).

### paused

`paused` holds the drift where it is, without <Fw react="unmounting" flutter="removing" /> anything.

## Accessibility

- A reduced-motion preference switches the animation off and the content sits where the layout put it.
- Do not float a control. Something that is never quite where it was is harder to press, and this is the one effect in the set with no end.
- It keeps moving past five seconds, so the page needs a way to stop it: put a pause button beside it and bind its state to `paused`. A reduced-motion preference is not enough on its own, since most readers who are distracted by motion never set one.
