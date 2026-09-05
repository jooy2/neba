---
title: Avatar
order: 15
---

# Avatar

<p class="neba-lede">A picture of a person or a thing, at a known size. It draws the picture when there is one and stands in for it with initials, a glyph or a silhouette when there is not, so it is never an empty box.</p>

<Demo src="avatar/hero" />

```tsx
import { Avatar } from 'neba';

<Avatar src="/people/jane.jpg" name="Jane Doe" />
<Avatar name="Jane Doe" />
<Avatar shape="square" variant="solid" color="info">N</Avatar>;
```

## Props

<PropsTable name="Avatar" />

Every other `<span>` attribute passes through to the root. The `<img>` takes `src`, `srcSet` and `alt` directly; anything else it needs goes in `imageProps`.

The shared axes (`variant` `size` `color` `elevation`) are defined in [prop conventions](../../design/prop-conventions). `density` is not offered: an avatar has no padding to change.

## Examples

### variant and color

`solid` is a filled circle, `outline` a hairline over a faint panel, `text` (the default) a tinted plate with no edge. `color` picks one of the six role colours. All three are invisible behind a loaded picture, apart from the edge they keep.

<Demo src="avatar/variants">

<<< @/.vitepress/demos/avatar/variants.tsx

</Demo>

### size

The control height ladder, so an avatar and the [Button](../inputs/button) beside it in a row are the same height: 22, 26, 32, 40 and 48px. The initials are sized off the box rather than off the row, at roughly 40% of the diameter.

<Demo src="avatar/sizes">

<<< @/.vitepress/demos/avatar/sizes.tsx

</Demo>

### shape

`circle` is the default crop. `square` cuts the corners off instead, at roughly 28% of the box: use it for a logo or a repository icon, which are drawn to the edges of a rectangle and lose those edges to a round crop.

<Demo src="avatar/shape">

<<< @/.vitepress/demos/avatar/shape.tsx

</Demo>

### name and initials

`name` does three things: it becomes the picture's `alt`, the initials are derived from it, and a screen reader hears it instead of them.

The rule is the first character of the first word plus the first character of the last: `Jane Doe` is `JD`, `jane miriam van doe` is `JD`, `홍길동` is `홍`. Decomposed accents are recomposed first, so `Ängela` is `Ä` and not `A`. When the rule picks the wrong letters, write them out in `initials`.

<Demo src="avatar/initials">

<<< @/.vitepress/demos/avatar/initials.tsx

</Demo>

### children

`children` is the fallback, drawn instead of the initials: an icon, a logo, a single emoji. An `<svg>` inside it is sized to 55% of the box. With no `children`, no `initials` and no `name`, the avatar draws a silhouette.

Which of the three is showing is decided by the picture's loading state. Set `delay` to hold the fallback back for a moment so the initials do not flash up in front of a cached image, and read the state itself with `onLoadingStatusChange`.

<Demo src="avatar/fallback">

<<< @/.vitepress/demos/avatar/fallback.tsx

</Demo>

### Status marks

An avatar carries no status dot of its own. Wrap it in a [Badge](./badge) with `overlap="circle"`, which tucks the marker in by the amount a circle's corner sits inside its bounding box.

<Demo src="avatar/status">

<<< @/.vitepress/demos/avatar/status.tsx

</Demo>

## Accessibility

- `JD` read out loud is two letters, not a person. Given a `name`, the initials are hidden from the accessibility tree and the name becomes the fallback's accessible name instead.
- With neither `name` nor `alt` the `<img>` gets an empty `alt`, so it is skipped rather than read out as a file name. That is the right default for an avatar sitting next to the person's own name; pass `alt` when the picture is the only thing identifying them.
- A `children` glyph with no `name` says nothing. Give the avatar a `name` (or an `aria-label` on whatever wraps it) when the glyph is carrying the meaning on its own.
