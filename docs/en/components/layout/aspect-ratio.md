---
title: AspectRatio
order: 8
---

# AspectRatio

<p class="neba-lede">A box that keeps a proportion whatever width it is given. It draws nothing of its own — it reserves the space and holds what is inside it to the shape.</p>

<Demo src="aspect-ratio/hero" align="center" />

```tsx
import { AspectRatio } from 'neba';

<AspectRatio ratio={16 / 9} rounded>
  <img src={src} alt="A ridge of hills under a low sun" />
</AspectRatio>;
```

## Props

<PropsTable name="AspectRatio" />

Native `<div>` attributes pass through, and `render` swaps the element. The shared axes are described in [prop conventions](../../design/prop-conventions).

## Examples

### ratio

`ratio` is CSS's own `aspect-ratio`, so a number (`1.5`) or a ratio (`'16 / 9'`) both reach it untouched and there is nothing to translate.

<Demo src="aspect-ratio/ratios">

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

</Demo>

### fit

`fit` is `object-fit` applied to a single piece of media that is a direct child — an `img`, a `video`, a `canvas`, an `svg` or an `iframe`. The media is stretched to the box first, which is the pair of declarations every use of this component would otherwise start with. `cover` crops, `contain` letterboxes, `fill` squashes.

<Demo src="aspect-ratio/fit">

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

</Demo>

### Reserving the space

The proportion holds whether or not the content has arrived, so a [Skeleton](../feedback/skeleton) inside an AspectRatio occupies exactly the box the image will. Nothing below it moves when the image loads.

<Demo src="aspect-ratio/reserving">

<<< @/.vitepress/demos/aspect-ratio/reserving.tsx

</Demo>

### rounded

`rounded` cuts the corners to the `size` step of the house radius ladder. It is off by default — a layout component draws nothing — and it is the one exception, because a photograph in a card almost always wants it.

```tsx
<AspectRatio ratio={4 / 3} rounded size="lg">
  <img src={src} alt="" />
</AspectRatio>
```

## Accessibility

- The box adds no role and no name. It is a shape, and what a reader hears is whatever is inside it.
- An `img` inside still needs its own `alt`. A decorative image takes `alt=""`.
