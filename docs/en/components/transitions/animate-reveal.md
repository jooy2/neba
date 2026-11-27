---
title: AnimateReveal
order: 9
flutter: true
---

# AnimateReveal

<p class="neba-lede">Content uncovered by an edge travelling across it. Nothing moves and nothing changes colour: the content is already in place at full size, and what changes is how much of it has been let through.</p>

<Demo src="animate-reveal/hero" />

::: fw react

```tsx
import { AnimateReveal } from 'neba';

<AnimateReveal>
  <h2>Nothing moved. It was let through.</h2>
</AnimateReveal>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateReveal(
  child: NebaTypography('Nothing moved. It was let through.', level: NebaTypographyLevel.h2),
);
```

:::

## Props

<PropsTable name="AnimateReveal" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

::: fw react

It is a `clip-path`, so there is no wrapper and no `overflow` box: the element takes exactly the room it always took, and everything around it is laid out against the finished size from the first frame. That makes it the effect for a heading, a rule or a chart's plot area: anything whose position is part of the information.

:::

::: fw flutter

It is a clip painted over the widget as it is laid out: the widget takes exactly the room it always took, and everything around it is laid out against the finished size from the first frame. That makes it the effect for a heading, a rule or a chart's plot area: anything whose position is part of the information.

:::

## Examples

### side

The edge the wipe travels **from**. `left` (the default) uncovers left to right.

<Demo src="animate-reveal/sides" minHeight="260">

::: fw react

<<< @/.vitepress/demos/animate-reveal/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_reveal/sides.dart

:::

</Demo>

### from

Fades as it wipes, from this opacity. `1` (the default) is a wipe and nothing else, which is usually the point of reaching for one. Set it to `0` for both at once.

### mode

<Fw react='`mode="out"`' flutter="`NebaAnimateMode.exit`" /> runs the same edge backwards and holds it there, which covers the content up again.

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, and the content is drawn whole.
- The content is in the <Fw react="document and in the accessibility tree" flutter="semantics tree" /> the entire time. A clip hides pixels, not information.
