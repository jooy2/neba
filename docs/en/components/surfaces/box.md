---
title: Box
order: 1
flutter: true
---

# Box

<p class="neba-lede">The basic surface to put content on. It is the plainest sheet in the library: it groups content and lifts it off the page background.</p>

<Demo src="box/hero" />

::: fw react

```tsx
import { Box } from 'neba';

<Box>Content</Box>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaBox(child: Text('Content'));
```

:::

## Props

<PropsTable name="Box" />

::: fw react

Every native `<div>` attribute passes through, `color` excepted.

:::

::: fw flutter

It takes no `className` or `style`: place it by wrapping it, in a `Padding` or a `SizedBox`.

:::

When structure is needed (a title, a footer, dividers), use [Card](./card), which is a Box with those sections laid out on it.

## Examples

### variant

None of the three weights flood the sheet with colour, because what a Box holds is content that arrives with colours of its own. What separates `solid` from `outline` is the sheet's opacity and whether it carries a border. See [Colour](../../design/color#container-surfaces-are-never-dyed) for the whole rule.

`text` has no surface, so `elevation` is ignored.

<Demo src="box/variants">

::: fw react

<<< @/.vitepress/demos/box/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/variants.dart

:::

</Demo>

### color

The surface is white, so `color` reaches **the border only**. That is why the example below is `outline`: on a `solid` Box, which has no border, `color` makes no visible difference.

<Demo src="box/colors">

::: fw react

<<< @/.vitepress/demos/box/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/colors.dart

:::

</Demo>

### size

On a Box, `size` sets neither a height nor a type scale but the size of the **sheet**: its radius and its padding. A Box is as tall as what it holds, and its children bring their own typography.

<Demo src="box/sizes">

::: fw react

<<< @/.vitepress/demos/box/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/sizes.dart

:::

</Demo>

### elevation

<Demo src="box/elevation">

::: fw react

<<< @/.vitepress/demos/box/elevation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/elevation.dart

:::

</Demo>

### <Fw react="padded and render" flutter="padded" />

<Fw react="`padded={false}`" flutter="`padded: false`" /> is for full-bleed content: an image, a table, a list that draws its own rows.<Fw react=" `render` renders the Box as an element other than a `<div>`." />

<Demo src="box/unpadded">

::: fw react

<<< @/.vitepress/demos/box/unpadded.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/unpadded.dart

:::

</Demo>
