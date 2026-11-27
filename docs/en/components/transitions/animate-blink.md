---
title: AnimateBlink
order: 9
flutter: true
---

# AnimateBlink

<p class="neba-lede">Content pulsing between full opacity and a floor. The cycle is symmetric, so however many times it runs it ends where it started.</p>

<Demo src="animate-blink/hero" />

::: fw react

```tsx
import { AnimateBlink } from 'neba';

<AnimateBlink min={0.35}>
  <Chip color="danger" variant="solid">
    Recording
  </Chip>
</AnimateBlink>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateBlink(
  min: 0.35,
  child: NebaChip(color: NebaColor.danger, variant: NebaVariant.solid, child: Text('Recording')),
);
```

:::

## Props

<PropsTable name="AnimateBlink" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

There is no `mode`: the cycle is the same in both directions, so there is nothing for a reversed one to mean.

## Examples

### min

How faint it gets at the bottom of the cycle, between `0` and `1`. At `0` the content disappears; raise it for anything that has to stay readable while it pulses, which is most things.

<Demo src="animate-blink/floor">

::: fw react

<<< @/.vitepress/demos/animate-blink/floor.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_blink/floor.dart

:::

</Demo>

### repeat

It repeats forever unless told otherwise, because a single blink is a flicker rather than an effect. A count is for drawing attention once: three pulses and then still.

<Demo src="animate-blink/counted">

::: fw react

<<< @/.vitepress/demos/animate-blink/counted.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_blink/counted.dart

:::

</Demo>

### paused

`paused` stops the blink at full opacity rather than wherever the pulse had got to, which is how to stop a live indicator without <Fw react="unmounting" flutter="removing" /> it. Let go, it starts over.

::: fw react

```tsx
<AnimateBlink paused={!recording} min={0.35}>
  <Chip color="danger">Recording</Chip>
</AnimateBlink>
```

:::

::: fw flutter

```dart
NebaAnimateBlink(
  paused: !recording,
  min: 0.35,
  child: const NebaChip(color: NebaColor.danger, child: Text('Recording')),
);
```

:::

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, and the content sits at full opacity.
- `duration` is one blink, and anything under 334ms is raised to it: more than three flashes a second can bring on a seizure. The same floor holds for <Fw react='`transition="blink"`' flutter="`NebaTransition.blink`" /> and a blinking `AnimateSplit`.
- Because of that, the blink is never the only thing carrying the message. Say it in words too: a `Chip` that reads "Recording" says it whether or not it is pulsing.
- Something that never stops moving in the corner of a page being read is the one kind of motion this library otherwise refuses. Use it for a state that is genuinely live, and stop it when the state ends.
- It keeps moving past five seconds, so the page needs a way to stop it: put a pause button beside it and bind its state to `paused`. A reduced-motion preference is not enough on its own, since most readers who are distracted by motion never set one.
