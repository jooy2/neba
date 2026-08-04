---
title: Skeleton
order: 9
---

# Skeleton

<p class="neba-lede">The shape of something that has not loaded yet. It reserves the space the real thing will take, so a card does not grow by 200px under the reader when its image arrives.</p>

<Demo src="skeleton/hero" align="center" />

```tsx
import { Skeleton } from 'neba';

<Skeleton shape="circle" size="lg" />
<Skeleton shape="rect" height={120} />
<Skeleton lines={3} />
```

## Props

<PropsTable name="Skeleton" />

Native `<div>` attributes pass through, and `render` swaps the element. The shared axes are described in [prop conventions](../../design/prop-conventions).

## Examples

### shape

The three shapes are the three things a layout is made of. `line` is a run of text, sized off the type scale, so a `md` line is as tall as `md` type. `rect` is a block — an image, a chart, a card — and falls back to a thumbnail height when no `height` is given. `circle` is drawn on the same ladder an [Avatar](../display/avatar) uses, so the two are exactly the same size at the same `size`.

<Demo src="skeleton/shapes">

<<< @/.vitepress/demos/skeleton/shapes.tsx

</Demo>

### lines

`lines` draws a stack of bars with the leading of the type scale between them, and the last one short — the way the last line of a paragraph is. It applies to `shape="line"` and is ignored by the other two.

<Demo src="skeleton/lines">

<<< @/.vitepress/demos/skeleton/lines.tsx

</Demo>

### width and height

`width` and `height` take a number as pixels or a string as a CSS length. A line is full width unless told otherwise, which is what makes a heading placeholder a `width` away.

<Demo src="skeleton/swapping">

<<< @/.vitepress/demos/skeleton/swapping.tsx

</Demo>

### animated

`animated` is the highlight travelling across the placeholder. Turn it off for a page holding dozens of them, or where the wait is long enough that motion becomes noise.

```tsx
<Skeleton animated={false} lines={4} />
```

This is not the accessibility switch: a reduced-motion preference already replaces the sweep with a colour pulse without being asked.

## Accessibility

- A skeleton is `aria-hidden` by default. A dozen placeholders each announcing themselves is worse than silence.
- Give `label` to the **one** skeleton that stands for a whole region and it becomes a `status` with `aria-busy` and that name. Do not label every bar in a stack.
- Prefer a skeleton over a spinner where the layout is known. It is the only loading indicator that keeps the page from reflowing when the content arrives.
