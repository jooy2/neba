---
title: AnimateLighting
order: 9
---

# AnimateLighting

<p class="neba-lede">A light travelling around the outside of something. The glow is behind the content rather than on it, so it marks whatever it wraps without altering a single thing about how that is drawn.</p>

<Demo src="animate-lighting/hero" />

```tsx
import { AnimateLighting } from 'neba';

<AnimateLighting size="md">
  <Card title="Analysing 4,281 rows">This usually takes about a minute.</Card>
</AnimateLighting>;
```

## Props

<PropsTable name="AnimateLighting" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

`size` has to agree with the radius of what is inside. The glow follows the wrapper's own corners, so a `lg` card in an `xs` Lighting will show light poking out of four corners the card has already rounded away.

## Examples

### color and glow

`color` is one of the six semantic families. `glow` takes a CSS colour instead, for a light that is decoration rather than a status.

<Demo src="animate-lighting/colors">

<<< @/.vitepress/demos/animate-lighting/colors.tsx

</Demo>

### arc, spread and blur

`arc` is how much of the outline is lit at once, in degrees: small is a travelling spark, large is a sweep. `spread` is how far past the content the light reaches and `blur` is how soft it is — at `0` it reads as a graphic rather than as light.

<Demo src="animate-lighting/shape">

<<< @/.vitepress/demos/animate-lighting/shape.tsx

</Demo>

### trigger="hover"

An infinite effect on `hover` runs while the pointer is on it and stops when it leaves. Keyboard focus counts as a pointer, so the effect is reachable without a mouse.

<Demo src="animate-lighting/hover">

<<< @/.vitepress/demos/animate-lighting/hover.tsx

</Demo>

## Accessibility

- Under a reduced-motion preference the arc stops travelling and becomes an even glow. The decoration survives; the motion does not.
- Because of that, the light is never the only thing saying what is happening. Use it alongside a word — "Analysing", "Live" — rather than instead of one.
- The wrapper adds no role and no name.
