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

Every top-level child becomes one slide. There is no slide sub-component: the snap point, the width and the `role="group"` / `aria-roledescription="slide"` pair are added for you. To show several slides in view at once, use [ScrollZone](../layout/scroll-zone).

## Props

<PropsTable name="Carousel" />

Every native `<div>` attribute passes through.

## Examples

### loop · arrows · indicators

Without `loop`, the arrows go inert at the ends, which suits a set that has a first and a last. `arrows` and `indicators` draw the side arrows and the dots beneath.

The arrows are drawn **over** the frame, so a slide with text near its edges should pad far enough in to clear them: about 3.5rem at `size="md"`.

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

`autoPlay` is off by default. With it on, it pauses on hover, on focus anywhere inside, and in a background tab, and it does not start at all under `prefers-reduced-motion`. The live region announcing the current slide stays silent while it runs, and starts again once the slides are stopped.

Turning it on also draws a button that stops the rotation, in the row under the frame beside the dots. It has no prop to remove it, and `pauseLabel` and `playLabel` name it.

### locale

`locale` sets the language of the region name, the control names and every slide name. It takes a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`, and a tag with no translation falls back to English. `label` and the other `*Label` props write the words out instead.

## Accessibility

- `label` becomes the carousel's accessible name. `previousLabel` · `nextLabel` · `pauseLabel` · `playLabel` · `slideLabel` name the controls.
- `autoPlay` draws its own stop button under the frame, so the rotation can be stopped by a reader who neither hovers nor tabs.
- Each slide carries `role="group"` and `aria-roledescription="slide"`.
- Under `prefers-reduced-motion` a slide change is an instant cut rather than a smooth scroll.
