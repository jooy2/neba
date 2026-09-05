---
title: AnimateAppear
order: 9
---

# AnimateAppear

<p class="neba-lede">A list of things settling into place one after another. Each child gets the same short fade and drift, held back by its position, so the effect belongs to the set rather than to any one item.</p>

<Demo src="animate-appear/hero" />

```tsx
import { AnimateAppear } from 'neba';

<AnimateAppear className="flex flex-col gap-2">
  <Card title="Design review">Thursday, 14:00</Card>
  <Card title="Sprint planning">Friday, 10:00</Card>
</AnimateAppear>;
```

## Props

<PropsTable name="AnimateAppear" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

The animation is written onto the children themselves rather than onto wrappers around them, so a row of `<li>`s stays a row of `<li>`s and a grid's cells stay its direct children. Only a bare string has no element to write onto; that one is wrapped in a `<span>`.

## Examples

### stagger

How long after one child the next one starts, in milliseconds. This is the whole effect: everything else is what a single child does.

The stagger is per _child_, which means what you pass matters: eight children are eight steps, and one child holding eight things is one step. That is also how to opt part of a list out: group it.

<Demo src="animate-appear/stagger">

<<< @/.vitepress/demos/animate-appear/stagger.tsx

</Demo>

### from, distance and reverse

`from` is the edge each child drifts in from and `distance` is how far: short on purpose, because this is a settling rather than an entrance from off screen. `reverse` runs the list from the last child to the first.

<Demo src="animate-appear/direction">

<<< @/.vitepress/demos/animate-appear/direction.tsx

</Demo>

### trigger="visible"

The natural pairing: a block of content that settles in as the reader reaches it, once. The whole set shares one observer on the root, so a list of forty is one observer rather than forty.

<Demo src="animate-appear/visible">

<<< @/.vitepress/demos/animate-appear/visible.tsx

</Demo>

## Accessibility

- A reduced-motion preference switches the animation off entirely and the whole list is simply there.
- The wrapper adds no role and no name. Give it a real element with `render` (`render={<ul />}`) when the list is a list.
