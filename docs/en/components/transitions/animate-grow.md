---
title: AnimateGrow
order: 9
---

# AnimateGrow

<p class="neba-lede">Content unfolding from a point. It starts close to its final size and can be anchored to any edge, so it reads as something opening out of the thing next to it.</p>

<Demo src="animate-grow/hero" />

```tsx
import { AnimateGrow } from 'neba';

<AnimateGrow origin="top">
  <Card title="Filters">Three of nine applied.</Card>
</AnimateGrow>;
```

## Props

<PropsTable name="AnimateGrow" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### origin

Any CSS `transform-origin`: the point that stays put while the rest moves. `top` unfolds downwards, `bottom left` out of a corner, and the default `center` grows evenly in every direction. It is the prop that decides what the growth appears to be coming _out of_.

<Demo src="animate-grow/origin">

<<< @/.vitepress/demos/animate-grow/origin.tsx

</Demo>

### from and fade

`from` is the scale it starts at, as a multiple of its final size. Below `1` it opens out; above `1` it arrives oversized and settles down onto the page. `fade` is the opacity ramp that comes with it, and turning it off is right for something already on screen that is only changing size.

<Demo src="animate-grow/settling">

<<< @/.vitepress/demos/animate-grow/settling.tsx

</Demo>

### mode

`out` folds it away again: the same animation backwards, held at the end.

```tsx
<AnimateGrow mode="out" origin="top">
  <Card title="Filters">Three of nine applied.</Card>
</AnimateGrow>
```

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference switches the animation off entirely and the content is simply there, at full size.
- Scale is applied with the standalone `scale` property rather than the `transform` shorthand, so a transform of your own on the same element survives.
