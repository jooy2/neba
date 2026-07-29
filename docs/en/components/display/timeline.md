---
title: Timeline
order: 12
---

# Timeline

<p class="neba-lede">A sequence of steps, in the order they happen in. A list whose order is the content.</p>

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

## Props

<PropsTable name="Timeline" />

### TimelineItem

<PropsTable name="TimelineItem" />

## `active` is an index

An index rather than a value, because a timeline has **no selection**. Nothing here is chosen, and the only question is how far along reality has got. Everything before `active` is `complete`, that item is `current`, and everything after it is `upcoming`.

Omit it and every item is `upcoming` — a plan that has not started. Pass the item count and the whole sequence is done.

The numbering happens on the Timeline. An item that had to be told its own position would be an item every caller could put in the wrong place, and inserting a step in the middle would mean renumbering every one after it.

## Examples

### Bullets

Anything can go in a bullet. Numbers suit a sequence somebody is being walked through; icons suit one that already happened. Pass nothing and the bullet is a plain disc, which is what a step with nothing to say about itself should be.

<Demo src="timeline/bullets">

<<< @/.vitepress/demos/timeline/bullets.tsx

</Demo>

The three states each get their **own axis** rather than three opacities: a filled disc, a filled disc with a halo, an empty ring. A reader who cannot tell the colours apart still has three shapes. It is the same rule the [design language](../../guide/design-language) applies everywhere else.

### When it does not go to plan

`active` describes a sequence that is going well. A step that failed and stopped it is not something an index can say, which is what the per-item `status` and `color` overrides are for.

<Demo src="timeline/status">

<<< @/.vitepress/demos/timeline/status.tsx

</Demo>

`connector` decides the line to the next item. The line belongs to the step it **leaves** rather than the one it arrives at, so it is coloured by whether that step has been reached. `none` takes it away, which is useful for grouping inside one timeline.

### Horizontal

`horizontal` is the stepper across the top of a checkout. It is worth remembering that it is only honest while every label is short — a horizontal timeline has no room for many steps, or for much to say about each of them.

<Demo src="timeline/horizontal">

<<< @/.vitepress/demos/timeline/horizontal.tsx

</Demo>

## The markup

It is an `<ol>`, for the reason the component exists at all: the order is the content. A screen reader announcing "list, 5 items" over an unordered list would be describing something else. The `current` item carries `aria-current="step"`.

There is no Base UI primitive underneath and there should not be. A timeline has no selection, no roving focus and no keyboard contract of its own — it is a list, and reaching for a composite primitive to draw one would hand a consumer's record of events the semantics of a widget. [List](./list) makes the same choice for the same reason.

## What this is not for

- If the question is **how far along something is right now** rather than what happened, that is [ProgressLinear](../feedback/progress-linear).
- If the rows have no order, that is [List](./list). A timeline's line is a claim that one thing came after another, and it should not be drawn when the claim is not true.
