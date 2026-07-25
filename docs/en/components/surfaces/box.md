---
title: Box
order: 1
---

# Box

<p class="neba-lede">A sheet of acrylic with content on it. The plainest surface in the library: it groups things, and that is all it does.</p>

<Demo src="box/hero" />

```tsx
import { Box } from 'neba';

<Box>Content</Box>;
```

Anything structural — a title, a footer, dividers — belongs to [Card](./card), which is a Box with those sections laid out on it.

## Props

<PropsTable name="Box" />

Every native `<div>` attribute passes through, `color` excepted.

## Examples

### Variants

`solid` does not flood the surface with colour, for the same reason TextField doesn't. What a box holds is other people's content, and it arrives with its own colours: body text, links, buttons, fields. On an accent fill every one of them would need an on-fill treatment, which is the opposite of what a container is for.

The sheet is not dyed at all. What separates `solid` from `outline` is not colour but **how much light the sheet holds** — its opacity — and whether it carries a hairline. See [Colour](../../guide/color#container-surfaces-are-never-dyed) for the whole rule.

<Demo src="box/variants">

<<< @/.vitepress/demos/box/variants.tsx

</Demo>

`text` has no surface, so `elevation` is ignored rather than drawing a shadow around an invisible rectangle.

### Colours

The surface is white, so the family reaches **the hairline only**. That is why the example below is `outline`: on a `solid` Box, which has no border, `color` makes no visible difference.

<Demo src="box/colors">

<<< @/.vitepress/demos/box/colors.tsx

</Demo>

### Sizes

Unlike every other component, `size` on a Box sets neither a height nor a type scale. A box is as tall as what it holds, and its children bring their own typography — a container that reset the type scale would render the same paragraph at two sizes depending on what it was wrapped in. So here `size` means the size of the _sheet_: its radius and its padding.

<Demo src="box/sizes">

<<< @/.vitepress/demos/box/sizes.tsx

</Demo>

### Elevation

<Demo src="box/elevation">

<<< @/.vitepress/demos/box/elevation.tsx

</Demo>

### Unpadded, and as another element

`padded={false}` is for full-bleed content — an image, a table, a list that draws its own rows. `render` is Base UI's own escape hatch, so a box can be any element.

<Demo src="box/unpadded">

<<< @/.vitepress/demos/box/unpadded.tsx

</Demo>
