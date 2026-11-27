---
title: AnimateSlide
order: 9
flutter: true
---

# AnimateSlide

<p class="neba-lede">Content travelling in from one edge. The default distance is the element's own size, so it starts exactly out of frame and is never half drawn somewhere it does not belong.</p>

<Demo src="animate-slide/hero" />

::: fw react

```tsx
import { AnimateSlide } from 'neba';

<div className="overflow-hidden">
  <AnimateSlide from="left">
    <Alert color="success" title="Invitation sent" />
  </AnimateSlide>
</div>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const ClipRect(
  child: NebaAnimateSlide(
    from: NebaSide.left,
    child: NebaAlert(color: NebaColor.success, title: Text('Invitation sent')),
  ),
);
```

:::

## Props

<PropsTable name="AnimateSlide" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### from

Which edge it travels from: `top`, `right`, `bottom` or `left`. Physical rather than logical, as `NebaSide` is everywhere in the library: a panel sliding down from the top comes from the top in every writing direction.

Put it in <Fw react="a box with `overflow: hidden`" flutter="a `ClipRect`" /> and the effect is a panel appearing from behind that box's edge.

<Demo src="animate-slide/edges">

::: fw react

<<< @/.vitepress/demos/animate-slide/edges.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_slide/edges.dart

:::

</Demo>

### distance

::: fw react

A CSS length or a number in pixels. `'100%'` (the default) is the element's own width or height. A short distance is a nudge rather than an entrance; for a whole list of those, one after another, use [AnimateAppear](./animate-appear).

Until it has arrived, the default holds the element a whole width or height past where it belongs, which can be outside its container: on a phone, a slide from the right widens the page for that long. A box with `overflow: hidden` around it keeps it inside.

:::

::: fw flutter

A number of logical pixels. Left out (the default), it is the widget's own width or height. A short distance is a nudge rather than an entrance; for a whole list of those, one after another, give it `children` and a `stagger`.

Until it has arrived, the default draws the widget a whole width or height past where it belongs, over whatever is there. It never widens the page, since it is painted there rather than laid out there, and a `ClipRect` around it keeps it inside.

:::

<Demo src="animate-slide/distance">

::: fw react

<<< @/.vitepress/demos/animate-slide/distance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_slide/distance.dart

:::

</Demo>

### mode

<Fw react="`out`" flutter="`NebaAnimateMode.exit`" /> sends it back the way it came, held off screen at the end.

::: fw react

```tsx
<AnimateSlide mode="out" from="right">
  <Toolbar>…</Toolbar>
</AnimateSlide>
```

:::

::: fw flutter

```dart
NebaAnimateSlide(mode: NebaAnimateMode.exit, from: NebaSide.right, child: toolbar);
```

:::

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, so the content is simply there in place, or gone if it was leaving.
- The element is moved with <Fw react="`translate`" flutter="a translation painted over its layout" />, so nothing on the page reflows while it runs and no layout under it changes.
