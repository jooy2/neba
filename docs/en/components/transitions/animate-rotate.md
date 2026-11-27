---
title: AnimateRotate
order: 9
flutter: true
---

# AnimateRotate

<p class="neba-lede">Content turning about a point. Two angles rather than one, so the same component covers both a glyph swinging into place and one that spins without ever landing.</p>

<Demo src="animate-rotate/hero" />

::: fw react

```tsx
import { AnimateRotate } from 'neba';

<AnimateRotate from={-270}>
  <Icon icon={<StarIcon />} size="xl" color="warning" label="Starred" />
</AnimateRotate>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateRotate(
  from: -270,
  child: NebaIcon(
    icon: StarGlyph(),
    size: NebaSize.xl,
    color: NebaColor.warning,
    semanticLabel: 'Starred',
  ),
);
```

:::

## Props

<PropsTable name="AnimateRotate" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### from and to

::: fw react

`from` alone is an arrival: something swings into place and stops. `from` and `to` together with `repeat="infinite"`, `easing="linear"` and `fade={false}` is a spin that never lands: a working mark, a decorative glyph. Negative angles turn anticlockwise.

:::

::: fw flutter

`from` alone is an arrival: something swings into place and stops. `from` and `to` together with `repeat: double.infinity`, `curve: Curves.linear` and `fade: false` is a spin that never lands: a working mark, a decorative glyph. Negative angles turn anticlockwise.

:::

<Demo src="animate-rotate/spin">

::: fw react

<<< @/.vitepress/demos/animate-rotate/spin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_rotate/spin.dart

:::

</Demo>

### origin

<Fw react="Any CSS `transform-origin`." flutter="An `Alignment`." /> Off-centre it becomes a swing rather than a spin, which with `alternate` is a rock back and forth.

<Demo src="animate-rotate/origin">

::: fw react

<<< @/.vitepress/demos/animate-rotate/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_rotate/origin.dart

:::

</Demo>

### fade

On by default, and the first thing to turn off for anything repeating: a fade that runs on every pass of a spin reads as flickering rather than as turning.

::: fw react

```tsx
<AnimateRotate from={0} to={360} repeat="infinite" easing="linear" fade={false}>
  <Icon icon={<GearIcon />} label="Working" />
</AnimateRotate>
```

:::

::: fw flutter

```dart
const NebaAnimateRotate(
  from: 0,
  to: 360,
  repeat: double.infinity,
  curve: Curves.linear,
  fade: false,
  child: NebaIcon(icon: GearGlyph(), semanticLabel: 'Working'),
);
```

:::

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, so the content is simply there, at its `to` angle.
- Do not rotate text. A rotated word is resampled along its whole length, which is exactly what the design language's rule against transforms exists to prevent. Rotation is for glyphs.
- With an endless `repeat` it keeps moving past five seconds, so the page needs a way to stop it: put a pause button beside it and bind its state to `paused`.
