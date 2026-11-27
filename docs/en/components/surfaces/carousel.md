---
title: Carousel
order: 5
flutter: true
---

# Carousel

<p class="neba-lede">Steps through slides one at a time. Swiping, keyboard navigation and RTL are all supported.</p>

<Demo src="carousel/hero" />

::: fw react

```tsx
import { Carousel } from 'neba';

<Carousel label="Product highlights">
  <img src="/one.jpg" alt="" />
  <img src="/two.jpg" alt="" />
</Carousel>;
```

Every top-level child becomes one slide. There is no slide sub-component: the snap point, the width and the `role="group"` / `aria-roledescription="slide"` pair are added for you. To show several slides in view at once, use [ScrollZone](../layout/scroll-zone).

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCarousel(
  semanticLabel: 'Product highlights',
  children: <Widget>[Image.asset('one.jpg'), Image.asset('two.jpg')],
);
```

Every child becomes one slide, as wide as the frame, and the slides are all as tall as the tallest of them. There is no slide widget: each slide is named "Slide 2 of 3" for a screen reader. To show several slides in view at once, use [ScrollZone](../layout/scroll-zone).

:::

## Props

<PropsTable name="Carousel" />

::: fw react

Every native `<div>` attribute passes through.

:::

::: fw flutter

A slide steps on with the arrows over the frame, the dots under it, a swipe, and the arrow keys while the strip holds the focus.

:::

## Examples

### loop · arrows · indicators

Without `loop`, the arrows go inert at the ends, which suits a set that has a first and a last. `arrows` and `indicators` draw the side arrows and the dots beneath.

The arrows are drawn **over** the frame, so a slide with text near its edges should pad far enough in to clear them: about 3.5rem at `size="md"`.

<Demo src="carousel/options">

::: fw react

<<< @/.vitepress/demos/carousel/options.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/options.dart

:::

</Demo>

### Photographs

A picture fills the frame, so there is nothing to pad in and the arrows sit over the image. Each slide is one [Image](../display/image) with a `ratio`, which keeps the strip one height while the files load.

<Demo src="carousel/photos">

<<< @/.vitepress/demos/carousel/photos.tsx

</Demo>

### value and onValueChange

Controlled, the strip can be driven by something else on the page. `onValueChange` also fires when the slide changed because somebody swiped.

::: fw react

A server-rendered strip opens on `value` or `defaultValue` from the first paint in Chrome and Edge 133 and later. Other browsers show the first slide until the page hydrates and then move to it; [browser support](../../browser-support#differences-inside-the-range) lists the difference.

:::

::: fw flutter

The strip opens on `value` or `defaultValue` from its first frame.

:::

<Demo src="carousel/controlled">

::: fw react

<<< @/.vitepress/demos/carousel/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/controlled.dart

:::

</Demo>

### autoPlay and interval

::: fw react

`autoPlay` is off by default. With it on, it pauses on hover, on focus anywhere inside, in a background tab and while the carousel is scrolled out of view, and it does not start at all under `prefers-reduced-motion`. Scrolled back into view, it holds the slide it stopped on for a full `interval` before moving on. The live region announcing the current slide stays silent while it runs, and starts again once the slides are stopped.

:::

::: fw flutter

`autoPlay` is off by default. With it on, it pauses on hover, on focus anywhere inside, while the app is in the background and while the carousel is scrolled out of the scroll view it is in, and it does not start at all for a reader who asked for less motion. Scrolled back into view, it holds the slide it stopped on for a whole `interval` before moving on. A screen reader is told the current slide whenever the reader moved it, and nothing while it turns on its own.

:::

Turning it on also draws a button that stops the rotation, in the row under the frame beside the dots. It has no prop to remove it, and `pauseLabel` and `playLabel` name it.

### locale

::: fw react

`locale` sets the language of the region name, the control names and every slide name. It takes a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`, and a tag with no translation falls back to English. `label` and the other `*Label` props write the words out instead.

:::

::: fw flutter

`locale` sets the language of the carousel's name, the control names and every slide name, by `NebaProvider`'s and then the app's. `semanticLabel` and the other `*Label` arguments write the words out instead.

:::

## Accessibility

::: fw react

- `label` becomes the carousel's accessible name. `previousLabel` · `nextLabel` · `pauseLabel` · `playLabel` · `slideLabel` name the controls.
- `autoPlay` draws its own stop button under the frame, so the rotation can be stopped by a reader who neither hovers nor tabs.
- Each slide carries `role="group"` and `aria-roledescription="slide"`.
- Under `prefers-reduced-motion` a slide change is an instant cut rather than a smooth scroll.

:::

::: fw flutter

- `semanticLabel` names the carousel. `previousLabel` · `nextLabel` · `pauseLabel` · `playLabel` · `slideLabel` name the controls.
- `autoPlay` draws its own stop button under the frame, so the rotation can be stopped by a reader who neither hovers nor uses a keyboard.
- Each slide is a node named by its place, "Slide 2 of 3".
- For a reader who asked for less motion a slide change is an instant cut rather than a scroll.

:::
