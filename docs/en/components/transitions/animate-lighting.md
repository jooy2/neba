---
title: AnimateLighting
order: 9
flutter: true
---

# AnimateLighting

<p class="neba-lede">A light travelling around the outside of something. The glow is behind the content rather than on it, so it marks whatever it wraps without altering a single thing about how that is drawn.</p>

<Demo src="animate-lighting/hero" />

::: fw react

```tsx
import { AnimateLighting } from 'neba';

<AnimateLighting size="md">
  <Card title="Analysing 4,281 rows">This usually takes about a minute.</Card>
</AnimateLighting>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateLighting(
  size: NebaSize.md,
  child: NebaCard(
    title: Text('Analysing 4,281 rows'),
    child: Text('This usually takes about a minute.'),
  ),
);
```

:::

## Props

<PropsTable name="AnimateLighting" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps one `child` and takes its size; the light is drawn past its edges without taking any room." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

`size` has to agree with the radius of what is inside. The glow follows the wrapper's own corners, so a `lg` card in an `xs` Lighting will show light poking out of four corners the card has already rounded away.

## Examples

### color and glow

`color` is one of the six semantic families. `glow` takes <Fw react="a CSS colour" flutter="a `Color`" /> instead, for a light that is decoration rather than a status.

<Demo src="animate-lighting/colors">

::: fw react

<<< @/.vitepress/demos/animate-lighting/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/colors.dart

:::

</Demo>

### arc, spread and blur

`arc` is how much of the outline is lit at once, in degrees: small is a travelling spark, large is a sweep. `spread` is how far past the content the light reaches and `blur` is how soft it is<Fw flutter=", both in logical pixels" />: at `0` it reads as a graphic rather than as light.

<Demo src="animate-lighting/shape">

::: fw react

<<< @/.vitepress/demos/animate-lighting/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/shape.dart

:::

</Demo>

### trigger="hover"

An infinite effect on `hover` runs while the pointer is on it and stops when it leaves. Keyboard focus counts as a pointer, so the effect is reachable without a mouse<Fw flutter=", and a finger counts on a touch screen" />.

<Demo src="animate-lighting/hover">

::: fw react

<<< @/.vitepress/demos/animate-lighting/hover.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/hover.dart

:::

</Demo>

## Accessibility

- Under a reduced-motion preference the arc stops travelling and becomes an even glow. The decoration survives; the motion does not.
- Because of that, the light is never the only thing saying what is happening. Use it alongside a word ("Analysing", "Live"), rather than instead of one.
- The wrapper adds no role and no name.
- It keeps moving past five seconds, so the page needs a way to stop it: put a pause button beside it and bind its state to `paused`. A reduced-motion preference is not enough on its own, since most readers who are distracted by motion never set one.
