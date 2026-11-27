---
title: AnimateAppear
order: 9
flutter: true
---

# AnimateAppear

<p class="neba-lede">A list of things settling into place one after another. Each child gets the same short fade and drift, held back by its position, so the effect belongs to the set rather than to any one item.</p>

<Demo src="animate-appear/hero" />

::: fw react

```tsx
import { AnimateAppear } from 'neba';

<AnimateAppear className="flex flex-col gap-2">
  <Card title="Design review">Thursday, 14:00</Card>
  <Card title="Sprint planning">Friday, 10:00</Card>
</AnimateAppear>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateAppear(
  children: <Widget>[
    NebaCard(title: Text('Design review'), child: Text('Thursday, 14:00')),
    NebaCard(title: Text('Sprint planning'), child: Text('Friday, 10:00')),
  ],
);
```

:::

## Props

<PropsTable name="AnimateAppear" />

::: fw react

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

The animation is written onto the children themselves rather than onto wrappers around them, so a row of `<li>`s stays a row of `<li>`s and a grid's cells stay its direct children. Only a bare string has no element to write onto; that one is wrapped in a `<span>`.

:::

::: fw flutter

It takes `children` and lays them out with `layoutBuilder`, in a `Column` unless that says otherwise, so a row of chips is laid out as the same row would be without it. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Each child runs the effect on its own, even with a `stagger` of zero, and nothing is drawn around the set. `distance` is in logical pixels.

:::

## Examples

### stagger

How long after one child the next one starts, <Fw react="in milliseconds" flutter="as a `Duration`" />. This is the whole effect: everything else is what a single child does.

The stagger is per _child_, which means what you pass matters: eight children are eight steps, and one child holding eight things is one step. That is also how to opt part of a list out: group it.

<Demo src="animate-appear/stagger">

::: fw react

<<< @/.vitepress/demos/animate-appear/stagger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/stagger.dart

:::

</Demo>

### from, distance and reverse

`from` is the edge each child drifts in from and `distance` is how far: short on purpose, because this is a settling rather than an entrance from off screen. `reverse` runs the list from the last child to the first.

<Demo src="animate-appear/direction">

::: fw react

<<< @/.vitepress/demos/animate-appear/direction.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/direction.dart

:::

</Demo>

### trigger="visible"

The natural pairing: a block of content that settles in as the reader reaches it, once. <Fw react="The whole set shares one observer on the root, so a list of forty is one observer rather than forty." flutter="The whole set is measured as one, so a list of forty is one measurement rather than forty." />

<Demo src="animate-appear/visible">

::: fw react

<<< @/.vitepress/demos/animate-appear/visible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/visible.dart

:::

</Demo>

## Accessibility

- A reduced-motion preference cuts the animation to its last frame, so the whole list is simply there.
- The wrapper adds no role and no name. <Fw react="Give it a real element with `render` (`render={<ul />}`) when the list is a list." flutter="Whatever is inside keeps its own." />
