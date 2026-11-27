---
title: AnimateFade
order: 9
flutter: true
---

# AnimateFade

<p class="neba-lede">Content arriving or leaving on opacity alone. The plainest effect in the set and the one to reach for first: nothing moves, so nothing reflows and no text is resampled.</p>

<Demo src="animate-fade/hero" />

::: fw react

```tsx
import { AnimateFade } from 'neba';

<AnimateFade>
  <Card title="Deployment finished">Two services restarted, no errors.</Card>
</AnimateFade>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateFade(
  child: NebaCard(
    title: Text('Deployment finished'),
    child: Text('Two services restarted, no errors.'),
  ),
);
```

:::

## Props

<PropsTable name="AnimateFade" />

::: fw react

Every other `<div>` attribute passes through to the root.

:::

::: fw flutter

It wraps a `child`, or lays out `children` with `layoutBuilder`, in a `Column` unless that says otherwise. It draws nothing of its own and adds nothing a screen reader hears.

:::

The settings shared by every `Animate*` (`duration`, `delay`, <Fw react="easing" flutter="curve" code />, `repeat`, `alternate`, `trigger`, `play`, `once`, `threshold`, `paused`) mean the same thing on all of them, and are defined in [prop conventions](../../design/prop-conventions).

## Examples

### duration and delay

::: fw react

Both are milliseconds. A delay is what turns a set of fades into a sequence, and it is what `AnimateAppear` does for you when the things being delayed are a list.

:::

::: fw flutter

Both are a `Duration`. A delay is what turns a set of fades into a sequence, and `stagger`, below, does it for you when the things being delayed are a list.

:::

<Demo src="animate-fade/timing">

::: fw react

<<< @/.vitepress/demos/animate-fade/timing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/timing.dart

:::

</Demo>

### trigger

`mount` is the default and needs nothing from you. `visible` waits until the element is scrolled into view (once, unless `once` is off), and `threshold` is how much of it has to be on screen. `hover` runs while the pointer is on it, restarting on each entry, and keyboard focus counts as a pointer. `manual` runs nothing until `play` says so, and every `false` → `true` starts it over.

::: fw react

Content in the first screen of a page should keep the default `mount`, or take `timeline="view"`. Both run from the stylesheet alone, while `visible` waits for the page's script to load and measure the element, so a heading or a picture above the fold that waits for it is drawn late.

:::

::: fw flutter

On a touch screen, where nothing hovers, a finger down on it counts as the pointer arriving and lifting it as the pointer leaving. `visible` measures the widget where the layout put it, against every clip above it and the window, after each frame in which a scroll view around it moves, so it starts on the frame after it comes into view. `play` is a `bool`, or a number that replays the effect each time it changes.

:::

<Demo src="animate-fade/triggers">

::: fw react

<<< @/.vitepress/demos/animate-fade/triggers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/triggers.dart

:::

</Demo>

### mode

<Fw react="`out`" flutter="`NebaAnimateMode.exit`" /> is the same animation run backwards, and it is held there: a faded-out element stays faded out rather than snapping back when the animation ends. With `alternate` it returns instead of jumping, which is what makes a repeating fade a pulse.

<Demo src="animate-fade/mode">

::: fw react

<<< @/.vitepress/demos/animate-fade/mode.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/mode.dart

:::

</Demo>

### from

The opacity the fade starts at, between `0` and `1`. Raise it for content that should never be completely gone: a dimming rather than a disappearance.

::: fw react

```tsx
<AnimateFade from={0.4}>
  <Chip>Draft</Chip>
</AnimateFade>
```

:::

::: fw flutter

```dart
const NebaAnimateFade(from: 0.4, child: NebaChip(child: Text('Draft')));
```

:::

### stagger, durationStep and reverse

::: fw react

`stagger` is how long after one child the next one starts, in milliseconds. At `0` (the default), the box itself is what fades, and the children are left alone. Above it the effect moves onto each child in turn and nothing is written on the box, so a list of five arrives one row at a time.

`durationStep` adds that many milliseconds to each successive child's `duration`; a negative value speeds them up down the list, and a duration never goes below zero. `reverse` runs the children last-to-first: only the order reverses, each child still plays forwards.

:::

::: fw flutter

`stagger` is how long after one of `children` the next one starts. At zero (the default), `children` fade as one, laid out by `layoutBuilder`. Above it the effect moves onto each child in turn, inside the same layout, so a list of five arrives one row at a time.

`durationStep` adds that much to each successive child's `duration`; a negative one speeds them up down the list, and a duration never goes below zero. `reverse` runs the children last-to-first: only the order reverses, each child still plays forwards.

:::

The step is per _child_, so what you pass matters: five children are five steps, and one child holding five things is one step. Grouping is how part of a list opts out.

<Demo src="animate-fade/stagger" minHeight="360">

::: fw react

<<< @/.vitepress/demos/animate-fade/stagger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/stagger.dart

:::

</Demo>

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, so content arriving is simply there and content leaving is gone. <Fw react="An element still waiting for its trigger is shown as it is, and is never left invisible. The same holds in a browser with scripting turned off." flutter="A widget still waiting for its trigger is drawn as it is, and is never left invisible." />
- The wrapper adds no role and no name; whatever is inside keeps its own.
