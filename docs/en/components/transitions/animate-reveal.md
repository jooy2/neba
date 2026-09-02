---
title: AnimateReveal
order: 9
---

# AnimateReveal

<p class="neba-lede">Content uncovered by an edge travelling across it. Nothing moves and nothing changes colour — the content is already in place at full size, and what changes is how much of it has been let through.</p>

<Demo src="animate-reveal/hero" />

```tsx
import { AnimateReveal } from 'neba';

<AnimateReveal>
  <h2>Nothing moved. It was let through.</h2>
</AnimateReveal>;
```

## Props

<PropsTable name="AnimateReveal" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

It is a `clip-path`, so there is no wrapper and no `overflow` box: the element takes exactly the room it always took, and everything around it is laid out against the finished size from the first frame. That makes it the effect for a heading, a rule or a chart's plot area — anything whose position is part of the information.

## Examples

### side

The edge the wipe travels **from**. `left` — the default — uncovers left to right.

<Demo src="animate-reveal/sides" minHeight="260">

<<< @/.vitepress/demos/animate-reveal/sides.tsx

</Demo>

### from

Fades as it wipes, from this opacity. `1` — the default — is a wipe and nothing else, which is usually the point of reaching for one. Set it to `0` for both at once.

### mode

`mode="out"` runs the same edge backwards and holds it there, which covers the content up again.

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference switches the animation off and the content is drawn whole, which is what it was always going to be.
- The content is in the document and in the accessibility tree the entire time. A clip hides pixels, not information.
