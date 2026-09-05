---
title: AnimateSlide
order: 9
---

# AnimateSlide

<p class="neba-lede">Content travelling in from one edge. The default distance is the element's own size, so it starts exactly out of frame and is never half drawn somewhere it does not belong.</p>

<Demo src="animate-slide/hero" />

```tsx
import { AnimateSlide } from 'neba';

<div className="overflow-hidden">
  <AnimateSlide from="left">
    <Alert color="success" title="Invitation sent" />
  </AnimateSlide>
</div>;
```

## Props

<PropsTable name="AnimateSlide" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### from

Which edge it travels from: `top`, `right`, `bottom` or `left`. Physical rather than logical, as `NebaSide` is everywhere in the library: a panel sliding down from the top comes from the top in every writing direction.

Put it in a box with `overflow: hidden` and the effect is a panel appearing from behind that box's edge.

<Demo src="animate-slide/edges">

<<< @/.vitepress/demos/animate-slide/edges.tsx

</Demo>

### distance

A CSS length or a number in pixels. `'100%'` (the default) is the element's own width or height. A short distance is a nudge rather than an entrance; for a whole list of those, one after another, use [AnimateAppear](./animate-appear).

<Demo src="animate-slide/distance">

<<< @/.vitepress/demos/animate-slide/distance.tsx

</Demo>

### mode

`out` sends it back the way it came, held off screen at the end.

```tsx
<AnimateSlide mode="out" from="right">
  <Toolbar>…</Toolbar>
</AnimateSlide>
```

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference switches the animation off entirely and the content is simply there, in place.
- The element is moved with `translate`, so nothing on the page reflows while it runs and no layout under it changes.
