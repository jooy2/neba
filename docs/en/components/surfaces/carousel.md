---
title: Carousel
order: 5
---

# Carousel

<p class="neba-lede">Steps through slides one at a time. Swiping, keyboard navigation and RTL are all supported.</p>

<Demo src="carousel/hero" />

```tsx
import { Carousel } from 'neba';

<Carousel label="Product highlights">
  <img src="/one.jpg" alt="" />
  <img src="/two.jpg" alt="" />
</Carousel>;
```

Every top-level child becomes one slide. There is no slide sub-component: the snap point, the width and the `role="group"` / `aria-roledescription="slide"` pair are added for you.

## Props

<PropsTable name="Carousel" />

Every native `<div>` attribute passes through.

Underneath it is a scroll container with CSS scroll snapping. That is what makes swiping the browser's own behaviour, flips the direction automatically under RTL, and puts the transition on `scroll-behavior: smooth` — which becomes an instant cut under `prefers-reduced-motion` through the same code path.

## Examples

### loop · arrows · indicators

Without `loop`, the arrows go inert at the ends, which suits a set that has a first and a last. `arrows` and `indicators` draw the side arrows and the dots beneath.

The arrows are drawn **over** the frame, so a slide with text near its edges should pad far enough in to clear them — about 3.5rem at `size="md"`.

<Demo src="carousel/options">

<<< @/.vitepress/demos/carousel/options.tsx

</Demo>

### Photographs

A picture fills the frame, so there is nothing to pad in and the arrows sit over the image. Each slide is one [Image](../display/image) with a `ratio`, which keeps the strip one height while the files load.

<Demo src="carousel/photos">

<<< @/.vitepress/demos/carousel/photos.tsx

</Demo>

### value and onValueChange

Controlled, the strip can be driven by something else on the page. `onValueChange` also fires when the slide changed because somebody swiped.

<Demo src="carousel/controlled">

<<< @/.vitepress/demos/carousel/controlled.tsx

</Demo>

### autoPlay and interval

`autoPlay` is off by default. With it on, it pauses on hover, on focus anywhere inside, and in a background tab, and it does not start at all under `prefers-reduced-motion`. The live region announcing the current slide stays silent while it runs.

If every slide has to be read, consider [Tabs](./tabs) or a plain vertical stack instead.

## Accessibility

- `label` becomes the carousel's accessible name. `previousLabel` · `nextLabel` · `slideLabel` name the controls.
- Each slide carries `role="group"` and `aria-roledescription="slide"`.

## What is not offered

- **More than one slide in view** — use [Grid](../layout/grid) with `overflow-x-auto`.
- **Vertical** — a scrolling list already does that.
- **Fade** — it cannot be combined with a scroll-based implementation.
- `locale` decides the region name, the arrows and every slide name; `label` and `slideLabel` write them out instead.
