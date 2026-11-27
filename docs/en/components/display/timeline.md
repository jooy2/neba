---
title: Timeline
order: 12
flutter: true
---

# Timeline

<p class="neba-lede">Lists ordered steps along a sequence of time. Use it where the order is itself the information: an order's fulfilment status, a deployment history.</p>

<Demo src="timeline/hero" />

::: fw react

```tsx
import { Timeline, TimelineItem } from 'neba';

<Timeline active={2}>
  <TimelineItem title="Ordered" meta="12 Jul">
    Payment taken.
  </TimelineItem>
  <TimelineItem title="In transit" meta="14 Jul" />
  <TimelineItem title="Delivered" />
</Timeline>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaTimeline(
  active: 2,
  children: <Widget>[
    NebaTimelineItem(title: Text('Ordered'), meta: Text('12 Jul'), child: Text('Payment taken.')),
    NebaTimelineItem(title: Text('In transit'), meta: Text('14 Jul')),
    NebaTimelineItem(title: Text('Delivered')),
  ],
);
```

:::

## Props

### Timeline

<PropsTable name="Timeline" />

`active` is an **index**, not a value. Items before it are `complete`, that item is `current`, and the rest are `upcoming`. Omit it and every item is `upcoming`; pass the item count and all of them are `complete`.

::: fw flutter

The vertical timeline takes the width it is given; a horizontal one shares it evenly between its steps. There is no `render`: Flutter's semantics have one kind of list.

:::

### TimelineItem

<PropsTable name="TimelineItem" />

## Examples

### bullet

`bullet` takes any <Fw react="node" flutter="widget" />. Numbers suit a procedure a user is walked through; icons suit events that already happened. Omit it and a disc is drawn.

The three states each use a different shape: a filled disc for `complete`, a filled disc with a halo for `current`, and an empty ring for `upcoming`. The state carries even for a reader who cannot tell the colours apart.

<Demo src="timeline/bullets">

::: fw react

<<< @/.vitepress/demos/timeline/bullets.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/bullets.dart

:::

</Demo>

### status and color

`active` describes a sequence that is going to plan. A state an index cannot express (a step that failed and stopped) is set per item with `status` and `color`.

`connector` is the shape of the line to the next item. The line belongs to the step it leaves rather than the one it arrives at, so it is coloured by that step's state. `none` removes it, which is how you group items inside one Timeline.

<Demo src="timeline/status">

::: fw react

<<< @/.vitepress/demos/timeline/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/status.dart

:::

</Demo>

### orientation

`horizontal` is the stepper across the top of a checkout. It has no room for many steps or long labels, so keep them short.

<Demo src="timeline/horizontal">

::: fw react

<<< @/.vitepress/demos/timeline/horizontal.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/horizontal.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders an `<ol>`, so it is announced as an ordered list.
- The `current` item carries `aria-current="step"`.
- A `complete` or `upcoming` item says so in visually hidden text, since its bullet says it only by shape. The words come from `locale`, or from `labels`.

:::

::: fw flutter

- The timeline is a list in the semantics tree and each step an item of it, in order.
- The `current` item is selected, which the web writes as `aria-current="true"`.
- A `complete` or `upcoming` item says so before its title, since its bullet says it only by shape. The words come from `locale`, or from `labels`.

:::
