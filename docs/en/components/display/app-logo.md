---
title: AppLogo
order: 20
---

# AppLogo

<p class="neba-lede">A product's mark, at a known size, that is never an empty box. It draws an image, an inline SVG, a letter on a tile, or — with nothing else to go on — the product's name set as the logotype.</p>

<Demo src="app-logo/hero" />

```tsx
import { AppLogo } from 'neba';

<AppLogo name="Neba" src="/logo.svg" />;
```

## Props

<PropsTable name="AppLogo" />

Every native `<a>` attribute passes through, apart from `color`. The shared axes are described under [prop conventions](../../design/prop-conventions).

The artwork is `children` if there is any, otherwise `src`, otherwise the name. Without an `href` it renders a `<span>`.

## Examples

### shape

How the artwork is framed. `bare` — the default — draws it as it was given, at the height `size` asks for and whatever width that comes to: no plate, no crop, no padding. `app` insets it into a filled tile with the corners cut off, and `circle` is the same tile, round. `padded={false}` lets a mark reach the tile's own edges.

`bare` is the default because a logo file very often has a background, a margin or the product's name set into it, and a square crop would eat all three.

<Demo src="app-logo/shape" minHeight="120">

<<< @/.vitepress/demos/app-logo/shape.tsx

</Demo>

### name

With no artwork at all the name _is_ the mark: the logotype on a `bare` logo, and its initials on a tile. `initials` writes those letters out when the derived ones are wrong.

<Demo src="app-logo/name" minHeight="220">

<<< @/.vitepress/demos/app-logo/name.tsx

</Demo>

### showName

Draws the name beside the mark, as the words half of a lockup. Off by default, because the common case is a file that already says the name. What is drawn becomes the accessible name from then on, so nothing is read out twice.

### variant · color

The weight of the tile behind the artwork, and the family it takes. Neither does anything on `bare`, which draws no tile.

<Demo src="app-logo/variant" minHeight="120">

<<< @/.vitepress/demos/app-logo/variant.tsx

</Demo>

### href · height · render

`href` makes the whole lockup a link, which is what a logo in a [Header](../layout/header) nearly always is. `height` overrides `size` with an exact number of pixels or a CSS length. `render` changes the element — `render={<h1 />}` for the one page where the product's name is the page's heading, or a router's own link component.

<Demo src="app-logo/link" minHeight="120">

<<< @/.vitepress/demos/app-logo/link.tsx

</Demo>

## Accessibility

- The name is in the document exactly once. A drawn name is the accessible name; an image carries it as `alt`; a mark made of markup or of initials is marked decorative and the name is kept in a clipped span beside it.
- `alt` overrides what the artwork says, for the rare logo that means something other than the product.
- With `href`, the link's accessible name is the product's — so a logo that is the way home needs nothing else written on it.
