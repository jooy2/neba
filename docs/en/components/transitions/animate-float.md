---
title: AnimateFloat
order: 9
---

# AnimateFloat

<p class="neba-lede">A slow drift with nowhere to get to. It says that something is not fixed to the page (an illustration, a floating card, a mark above a hero), and it runs for as long as the page is open.</p>

<Demo src="animate-float/hero" />

```tsx
import { AnimateFloat } from 'neba';

<AnimateFloat>
  <Card>Not fixed to the page.</Card>
</AnimateFloat>;
```

## Props

<PropsTable name="AnimateFloat" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

It repeats forever and turns round at both ends, so there is never a frame where it jumps back. There is no `mode`: a drift has no direction to be reversed.

It is `translate` rather than a `transform`, so it composes with anything the element is already scaled or rotated by.

## Examples

### from and distance

`from` is which way it drifts and `distance` is how far it gets: a CSS length, or a number of pixels. Short on purpose: past about a centimetre it stops reading as something resting and starts reading as something moving.

<Demo src="animate-float/distance" minHeight="300">

<<< @/.vitepress/demos/animate-float/distance.tsx

</Demo>

### stagger

`stagger` puts a set of floating things out of step with each other, which is what stops four of them reading as one block. It works the same way here as on [AnimateFade](./animate-fade).

### paused

`paused` holds the drift where it is, without unmounting anything.

## Accessibility

- A reduced-motion preference switches the animation off and the content sits where the layout put it.
- Do not float a control. Something that is never quite where it was is harder to press, and this is the one effect in the set with no end.
