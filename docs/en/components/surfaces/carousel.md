---
title: Carousel
order: 5
---

# Carousel

<p class="neba-lede">A strip of slides, one of which is in view. Swipeable, keyboard-scrollable, and right under RTL — because the mechanism underneath it is the browser's own scrolling.</p>

<Demo src="carousel/hero" />

```tsx
import { Carousel } from 'neba';

<Carousel label="Product highlights">
  <img src="/one.jpg" alt="" />
  <img src="/two.jpg" alt="" />
</Carousel>;
```

**Slides are not a sub-component.** Every top-level child becomes one, so `<Carousel><img /><img /></Carousel>` is the whole API. The wrapper is what carries the snap point, the width and the `role="group"` / `aria-roledescription="slide"` pair a screen reader needs — none of which anybody should have to remember to put on a photograph.

The arrows are drawn **over** the frame, which is right for a photograph and wrong for a paragraph. A slide with words near its edges should pad far enough in to clear them — roughly the control height plus the inset, so about 3.5rem at `size="md"`.

## Props

<PropsTable name="Carousel" />

Every native `<div>` attribute passes through.

## Examples

### Loop, chrome, autoplay

The chrome is optional and the ends are a choice. Without `loop` the arrows go inert at the ends rather than wrapping, which is the honest thing for a set that has a first and a last.

<Demo src="carousel/options">

<<< @/.vitepress/demos/carousel/options.tsx

</Demo>

### Controlled

`value` / `onValueChange` are the usual pair, so the strip can be driven by something else on the page — a wizard's step buttons, a router, a keyboard shortcut. `onValueChange` also fires when the slide changed because somebody swiped.

<Demo src="carousel/controlled">

<<< @/.vitepress/demos/carousel/controlled.tsx

</Demo>

## Why it scrolls rather than slides

The strip is a scroll container with CSS scroll snapping, and everything good about this component follows from that one choice.

- **Swiping works**, on a phone and on a trackpad, because it is the browser's own scrolling and not a gesture handler pretending to be it.
- **It runs the other way under RTL** without being told, because scrolling is directional and `translate` is not.
- **Nothing is transformed.** The [house rule](../../guide/design-language) against moving a surface holds here for free, where a translated track would have had to argue for an exception.
- **The motion is `scroll-behavior: smooth`**, so a reader who has asked for reduced motion gets an instant cut out of the same code path rather than out of a second one written to remember them.

## Autoplay, and why it is off

A carousel that moves while it is being read is the most complained-about pattern on the web. `autoPlay` is off by default, and when it is on it pauses on hover, on focus anywhere inside it, and in a background tab — and it does not start at all for a reader who has asked for reduced motion. The live region that announces the current slide goes silent while it is running, because one that says a new name every five seconds is what makes a screen reader unusable on a page that has one.

If a set of slides is important enough that every one of them should be read, it is important enough not to be a carousel. [Tabs](./tabs) or a plain stack will serve it better.

## What is not offered

- **More than one slide in view.** A peek carousel needs per-breakpoint width arithmetic, and the honest version of that is [Grid](../layout/grid) with `overflow-x-auto` on it.
- **Vertical.** A vertical carousel is a scrolling list, which the page already is.
- **Fade.** The mechanism is scrolling, and a scroll that fades is two mechanisms.

## Coming from other libraries

| Elsewhere                  | Neba                                                           |
| -------------------------- | -------------------------------------------------------------- |
| `<Carousel.Item>`          | Not needed. Every top-level child is a slide                   |
| `activeIndex` / `onSelect` | `value` / `onValueChange` — the pair every Neba component uses |
| `interval={null}` to stop  | `autoPlay={false}`, which is already the default               |
| `wrap`                     | `loop`                                                         |
| `indicators` / `controls`  | `indicators` / `arrows`                                        |
| `slidesPerView`            | Not offered — see above                                        |
