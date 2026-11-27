---
title: AspectRatio
order: 8
flutter: true
---

# AspectRatio

<p class="neba-lede">A box that keeps a proportion whatever width it is given. It draws nothing of its own: it reserves the space and holds what is inside it to the shape.</p>

<Demo src="aspect-ratio/hero" align="center" />

::: fw react

```tsx
import { AspectRatio } from 'neba';

<AspectRatio ratio={16 / 9} rounded>
  <img src={src} alt="A still alpine lake at dawn" />
</AspectRatio>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaAspectRatio(
  ratio: 16 / 9,
  rounded: true,
  child: Image.asset(path, semanticLabel: 'A still alpine lake at dawn'),
);
```

:::

## Props

<PropsTable name="AspectRatio" />

::: fw react

Native `<div>` attributes pass through, and `render` swaps the element. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

It draws nothing and takes no `className` or `style`; a background or an edge goes on a widget around it or inside it. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

## Examples

### ratio

::: fw react

`ratio` is CSS's own `aspect-ratio`, so a number (`1.5`) or a ratio (`'16 / 9'`) both reach it untouched and there is nothing to translate.

:::

::: fw flutter

`ratio` is width over height, a `double`, so `16 / 9` is written as it is said. The box is as wide as it may be and as tall as the ratio makes it, unless the height it is given is shorter.

:::

<Demo src="aspect-ratio/ratios">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/ratios.dart

:::

</Demo>

### fit

::: fw react

`fit` is `object-fit` applied to a single piece of media that is a direct child: an `img`, a `picture`, a `video` or a `canvas`. The media is stretched to the box first. An `svg` or an `iframe` is stretched to the box too and lays its own content out; an `svg` fits itself through `preserveAspectRatio`. `cover` crops, `contain` letterboxes, `fill` squashes. `none` keeps the file's own size, and `scale-down` is whichever of `none` and `contain` draws the media smaller, so a small file is never enlarged.

:::

::: fw flutter

`fit` is a `BoxFit` applied to a child that is an `Image`, which is stretched to the box first; anything else is stretched to the box and lays its own content out, and an image inside another widget takes its own `fit`. `BoxFit.cover` crops, `contain` letterboxes, `fill` squashes. `none` keeps the image's own size, and `scaleDown` is whichever of `none` and `contain` draws it smaller, so a small image is never enlarged. `fitWidth` and `fitHeight` are Flutter's own two more.

:::

<Demo src="aspect-ratio/fit">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/fit.dart

:::

</Demo>

### Reserving the space

The proportion holds whether or not the content has arrived, so a [Skeleton](../feedback/skeleton) inside an AspectRatio occupies exactly the box the image will. Nothing below it moves when the image loads.

<Demo src="aspect-ratio/reserving">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/reserving.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/reserving.dart

:::

</Demo>

### rounded

`rounded` cuts the corners to the `size` step of the radius ladder, and it is off by default.

::: fw react

```tsx
<AspectRatio ratio={4 / 3} rounded size="lg">
  <img src={src} alt="" />
</AspectRatio>
```

:::

::: fw flutter

```dart
NebaAspectRatio(
  ratio: 4 / 3,
  rounded: true,
  size: NebaSize.lg,
  child: Image.asset(path, excludeFromSemantics: true),
);
```

:::

## Accessibility

::: fw react

- The box adds no role and no name. It is a shape, and what a reader hears is whatever is inside it.
- An `img` inside still needs its own `alt`. A decorative image takes `alt=""`.

:::

::: fw flutter

- The box adds no semantics. It is a shape, and what a reader hears is whatever is inside it.
- An `Image` inside still needs its own `semanticLabel`. A decorative image takes `excludeFromSemantics: true`.

:::
