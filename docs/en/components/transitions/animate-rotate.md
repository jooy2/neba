---
title: AnimateRotate
order: 9
---

# AnimateRotate

<p class="neba-lede">Content turning about a point. Two angles rather than one, so the same component covers both a glyph swinging into place and one that spins without ever landing.</p>

<Demo src="animate-rotate/hero" />

```tsx
import { AnimateRotate } from 'neba';

<AnimateRotate from={-270}>
  <Icon icon={<StarIcon />} size="xl" color="warning" label="Starred" />
</AnimateRotate>;
```

## Props

<PropsTable name="AnimateRotate" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### from and to

`from` alone is an arrival: something swings into place and stops. `from` and `to` together with `repeat="infinite"`, `easing="linear"` and `fade={false}` is a spin that never lands — a working mark, a decorative glyph. Negative angles turn anticlockwise.

<Demo src="animate-rotate/spin">

<<< @/.vitepress/demos/animate-rotate/spin.tsx

</Demo>

### origin

Any CSS `transform-origin`. Off-centre it becomes a swing rather than a spin, which with `alternate` is a rock back and forth.

<Demo src="animate-rotate/origin">

<<< @/.vitepress/demos/animate-rotate/origin.tsx

</Demo>

### fade

On by default, and the first thing to turn off for anything repeating: a fade that runs on every pass of a spin reads as flickering rather than as turning.

```tsx
<AnimateRotate from={0} to={360} repeat="infinite" easing="linear" fade={false}>
  <Icon icon={<GearIcon />} label="Working" />
</AnimateRotate>
```

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference switches the animation off entirely and the content is simply there, at its `to` angle.
- Do not rotate text. A rotated word is resampled along its whole length, which is exactly what the design language's rule against transforms exists to prevent. Rotation is for glyphs.
