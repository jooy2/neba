---
title: AnimateZoom
order: 9
flutter: true
---

# AnimateZoom

<p class="neba-lede">Content arriving from the middle of where it will end up. The same arithmetic as AnimateGrow at more than twice the distance and always about the centre, for the one thing on a screen that is meant to interrupt.</p>

<Demo src="animate-zoom/hero" />

::: fw react

```tsx
import { AnimateZoom } from 'neba';

<AnimateZoom>
  <Statistic label="Uptime this quarter" value={99.98} unit="%" />
</AnimateZoom>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateZoom(
  child: NebaStatistic(label: Text('Uptime this quarter'), value: 99.98, unit: Text('%')),
);
```

:::

## Props

<PropsTable name="AnimateZoom" />

<Fw react="Every other `<div>` attribute passes through to the root." flutter="It wraps a `child`, or `children` laid out by `layoutBuilder`." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

There is no `origin`: a zoom anchored to a corner is a grow, and that is [AnimateGrow](./animate-grow).

## Examples

### from

The scale it starts at. Well below `1` it comes up out of nothing; above `1` it arrives oversized and settles back, which reads as coming towards the reader rather than up out of the page.

<Demo src="animate-zoom/strength">

::: fw react

<<< @/.vitepress/demos/animate-zoom/strength.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_zoom/strength.dart

:::

</Demo>

### trigger="visible"

The most common use of a zoom is a figure that lands as the reader reaches it. `threshold` is how much of the element has to be on screen first, from `0` to `1`, and `once` (on by default) is what stops it replaying every time the page scrolls back.

::: fw flutter

While it waits it is drawn unseen where it will land rather than shrunk on its first frame, so what the reader sees of it is the same, and a screen reader and the focus find it in place.

:::

<Demo src="animate-zoom/visible">

::: fw react

<<< @/.vitepress/demos/animate-zoom/visible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_zoom/visible.dart

:::

</Demo>

### mode

<Fw react="`out`" flutter="`NebaAnimateMode.exit`" /> drops it away again, held at the end.

::: fw react

```tsx
<AnimateZoom mode="out" duration={240}>
  <Card title="Dismissed">This card is on its way out.</Card>
</AnimateZoom>
```

:::

::: fw flutter

```dart
const NebaAnimateZoom(
  mode: NebaAnimateMode.exit,
  duration: Duration(milliseconds: 240),
  child: NebaCard(title: Text('Dismissed'), child: Text('This card is on its way out.')),
);
```

:::

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, so the content is simply there at full size, or gone if it was leaving.
- A strong zoom over a large area is the most likely effect in this set to bother a reader who is sensitive to motion. Prefer a small `from`, or a fade, for anything covering much of the viewport.
