---
title: AppLogo
order: 20
flutter: true
---

# AppLogo

<p class="neba-lede">A product's mark, at a known size, that is never an empty box. It draws an image, an inline SVG, a letter on a tile, or (with nothing else to go on) the product's name set as the logotype.</p>

<Demo src="app-logo/hero" />

::: fw react

```tsx
import { AppLogo } from 'neba';

<AppLogo name="Neba" src="/logo.svg" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAppLogo(name: 'Neba', image: AssetImage('assets/logo.png'));
```

:::

## Props

<PropsTable name="AppLogo" />

::: fw react

Every native `<a>` attribute passes through, apart from `color`. The shared axes are described under [prop conventions](../../design/prop-conventions).

The artwork is `children` if there is any, otherwise `src`, otherwise the name. Without an `href` it renders a `<span>`.

:::

::: fw flutter

The artwork is `child` if there is any, otherwise `image`, otherwise the name. The whole logo is one node for a screen reader, named once, and a link when it has an `onPressed`.

:::

## Examples

### <Fw react="src · children" flutter="image · child" />

::: fw react

Where the artwork comes from. `src` links a file (a PNG, an SVG, whatever the brand ships), and `children` takes the markup instead, which is what an inline `<svg>` needs in order to inherit the colour around it. `children` wins when both are given. With neither, the tile falls back to the initials of `name`.

:::

::: fw flutter

Where the artwork comes from. `image` is a picture of the mark, an `ImageProvider` (an asset, a file, the network), and `child` takes a drawing instead, which takes the colour around it. A drawing is laid out at the mark's height, so one with no width of its own takes it from an `AspectRatio`. `child` wins when both are given. With neither, the tile falls back to the initials of `name`.

:::

<Demo src="app-logo/artwork" minHeight="120">

::: fw react

<<< @/.vitepress/demos/app-logo/artwork.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/artwork.dart

:::

</Demo>

::: fw react

A file arrives after the page does, and until then a `bare` mark has no width, so the name beside it moves when the file lands. Give `imageProps` the file's own `width` and `height` and the mark takes its width from the start. They set the proportion only: the height drawn is still the one `size` or `height` asks for.

```tsx
<AppLogo name="Neba" src="/wordmark.png" imageProps={{ width: 480, height: 128 }} />
```

:::

::: fw flutter

A picture loaded from the network arrives after the logo is built, and until then a `bare` mark has no width, so the name beside it moves when the picture lands. An asset is there in the first frame; a picture from the network can be given a box of its own width beside the logo.

:::

### shape

How the artwork is framed. `bare` (the default) draws it as it was given, at the height `size` asks for and whatever width that comes to: no plate, no crop, no padding. `app` insets it into a filled tile with the corners cut off, and `circle` is the same tile, round. <Fw react="`padded={false}`" flutter="`padded: false`" /> lets a mark reach the tile's own edges.

<Demo src="app-logo/shape" minHeight="120">

::: fw react

<<< @/.vitepress/demos/app-logo/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/shape.dart

:::

</Demo>

### name

With no artwork at all the name _is_ the mark: the logotype on a `bare` logo, and its initials on a tile. `initials` writes those letters out when the derived ones are wrong.

<Demo src="app-logo/name" minHeight="220">

::: fw react

<<< @/.vitepress/demos/app-logo/name.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/name.dart

:::

</Demo>

### showName

Draws the name beside the mark, as the words half of a lockup. It is off by default. What is drawn becomes the <Fw react="accessible name" flutter="semantics label" /> from then on, so nothing is read out twice.

### variant · color

The weight of the tile behind the artwork, and the family it takes. Neither does anything on `bare`, which draws no tile.

<Demo src="app-logo/variant" minHeight="120">

::: fw react

<<< @/.vitepress/demos/app-logo/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/variant.dart

:::

</Demo>

### <Fw react="href · height · render" flutter="onPressed · height" />

::: fw react

`href` makes the whole lockup a link, which is what a logo in a [Header](../layout/header) nearly always is. A `target` that leaves this tab gets `rel="noopener noreferrer"` merged into whatever `rel` you wrote. `height` overrides `size` with an exact number of pixels or a CSS length. `render` changes the element: `render={<h1 />}` for the one page where the product's name is the page's heading, or a router's own link component.

:::

::: fw flutter

`onPressed` makes the whole lockup a link, which is what a logo in a [Header](../layout/header) nearly always is, and `href` says where it goes to a screen reader and, on the web, the browser. `height` overrides `size` with an exact number of logical pixels. For the one page where the product's name is the page's heading, wrap the logo in `Semantics(header: true, …)`.

:::

<Demo src="app-logo/link" minHeight="120">

::: fw react

<<< @/.vitepress/demos/app-logo/link.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/link.dart

:::

</Demo>

## Accessibility

::: fw react

- The name is in the document exactly once. A drawn name is the accessible name; an image carries it as `alt`; a mark made of markup or of initials is marked decorative and the name is kept in a clipped span beside it.
- `alt` overrides what the artwork says, for the rare logo that means something other than the product.
- With `href`, the link's accessible name is the product's, so a logo that is the way home needs nothing else written on it.

:::

::: fw flutter

- The logo is one node with the name in it exactly once: the drawn name when there is one, otherwise what the artwork means, `semanticLabel` and then `name`. A picture with no drawn name is an image by that name.
- `semanticLabel` overrides what the artwork says, for the rare logo that means something other than the product.
- With `onPressed`, the link's name is the product's, so a logo that is the way home needs nothing else written on it.

:::
