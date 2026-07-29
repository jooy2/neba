---
title: Box
order: 1
---

# Box

<p class="neba-lede">The basic surface to put content on. It is the plainest sheet in the library: it groups content and lifts it off the page background.</p>

<Demo src="box/hero" />

```tsx
import { Box } from 'neba';

<Box>Content</Box>;
```

## Props

<PropsTable name="Box" />

Every native `<div>` attribute passes through, `color` excepted.

When structure is needed — a title, a footer, dividers — use [Card](./card), which is a Box with those sections laid out on it.

## Examples

### variant

None of the three weights flood the sheet with colour, because what a Box holds is content that arrives with colours of its own. What separates `solid` from `outline` is the sheet's opacity and whether it carries a border. See [Colour](../../design/color#container-surfaces-are-never-dyed) for the whole rule.

`text` has no surface, so `elevation` is ignored.

<Demo src="box/variants">

<<< @/.vitepress/demos/box/variants.tsx

</Demo>

### color

The surface is white, so `color` reaches **the border only**. That is why the example below is `outline`: on a `solid` Box, which has no border, `color` makes no visible difference.

<Demo src="box/colors">

<<< @/.vitepress/demos/box/colors.tsx

</Demo>

### size

On a Box, `size` sets neither a height nor a type scale but the size of the **sheet** — its radius and its padding. A Box is as tall as what it holds, and its children bring their own typography.

<Demo src="box/sizes">

<<< @/.vitepress/demos/box/sizes.tsx

</Demo>

### elevation

<Demo src="box/elevation">

<<< @/.vitepress/demos/box/elevation.tsx

</Demo>

### padded and render

`padded={false}` is for full-bleed content — an image, a table, a list that draws its own rows. `render` renders the Box as an element other than a `<div>`.

<Demo src="box/unpadded">

<<< @/.vitepress/demos/box/unpadded.tsx

</Demo>
