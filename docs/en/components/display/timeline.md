---
title: Timeline
order: 12
---

# Timeline

<p class="neba-lede">Lists ordered steps along a sequence of time. Use it where the order is itself the information: an order's fulfilment status, a deployment history.</p>

<Demo src="timeline/hero" />

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

This is not [TimelineChart](../charts/timeline-chart). That one draws spans against a calendar (a Gantt) for how long each piece of work took. This one is a list of steps, and the gaps between them are not to scale.

## Props

### Timeline

<PropsTable name="Timeline" />

`active` is an **index**, not a value. Items before it are `complete`, that item is `current`, and the rest are `upcoming`. Omit it and every item is `upcoming`; pass a number past the item count and all of them are `complete`.

### TimelineItem

<PropsTable name="TimelineItem" />

## Examples

### bullet

`bullet` takes any node. Numbers suit a procedure a user is walked through; icons suit events that already happened. Omit it and a disc is drawn.

The three states each use a different shape (a filled disc (`complete`), a filled disc with a halo (`current`), an empty ring (`upcoming`)), so the state carries even for a reader who cannot tell the colours apart.

<Demo src="timeline/bullets">

<<< @/.vitepress/demos/timeline/bullets.tsx

</Demo>

### status and color

`active` describes a sequence that is going to plan. A state an index cannot express (a step that failed and stopped) is set per item with `status` and `color`.

`connector` is the shape of the line to the next item. The line belongs to the step it leaves rather than the one it arrives at, so it is coloured by that step's state. `none` removes it, which is how you group items inside one Timeline.

<Demo src="timeline/status">

<<< @/.vitepress/demos/timeline/status.tsx

</Demo>

### orientation

`horizontal` is the stepper across the top of a checkout. It has no room for many steps or long labels, so keep them short.

<Demo src="timeline/horizontal">

<<< @/.vitepress/demos/timeline/horizontal.tsx

</Demo>

## Accessibility

- Renders an `<ol>`, so it is announced as an ordered list.
- The `current` item carries `aria-current="step"`.

## When to use something else

- To show current progress rather than a record of what happened, use [ProgressLinear](../feedback/progress-linear).
- If the order carries no meaning, use [List](./list). A Timeline's line asserts that one thing came after another.
