---
title: Badge
order: 6
---

# Badge

<p class="neba-lede">A small mark in the corner of something else: unread mail on an inbox icon, a status dot on an avatar, a count on a tab.</p>

<Demo src="badge/hero" />

```tsx
import { Badge, Button } from 'neba';

<Badge content={4} label="4 unread notifications">
  <Button startIcon={<BellIcon />} />
</Badge>

<Badge dot color="success" overlap="circle">
  <Avatar />
</Badge>;
```

## Props

<PropsTable name="Badge" />

## Examples

### Variants and colours

<Demo src="badge/variants">

<<< @/.vitepress/demos/badge/variants.tsx

</Demo>

### What it says

A number past `max` becomes `99+` rather than growing. Text is never truncated — a badge cannot know how to shorten a word.

A `content` of `0` draws nothing by default. Zero unread messages is not news, and a badge that never goes away stops meaning anything. When there is nothing to count but something to report, that is what `dot` is.

<Demo src="badge/content">

<<< @/.vitepress/demos/badge/content.tsx

</Demo>

### Which corner, and how far in

`placement` is one word built out of two the library already has — `top`/`bottom` from `NebaSide`, `start`/`end` from `NebaAlign`. A corner is one decision, and splitting it into two props would let a caller write `{ vertical: 'left' }`. Because it says `start`/`end`, the corner flips with the writing direction.

`overlap` is the shape of the thing underneath. A circle's corner is further from its centre than a square's, so a badge that looks right on an icon button hangs off an avatar.

<Demo src="badge/placement">

<<< @/.vitepress/demos/badge/placement.tsx

</Demo>

### Sizes

<Demo src="badge/sizes">

<<< @/.vitepress/demos/badge/sizes.tsx

</Demo>

## A badge is the one thing allowed to be a pill

At 18px tall, `--neba-radius-xs` (10px) is already past the halfway point that would make a shape a pill. So Badge is the only component in the library that reaches for `rounded-full`.

That is not a hole in the [design language](../../guide/design-language), it is the exception the language names. The flat run along a sheet's top and bottom edge is what says "this is a cut surface". A badge is not a surface. It is a mark laid **on** one, and a mark has no edge to cut — which is also why it is the only component that overlaps its neighbour.

## No transform

Every other library positions a corner badge with `translate(50%, -50%)`. This one uses a negative margin of half the marker's own height. It costs two more lines, and the [rule against `transform`](../../guide/design-language) is absolute and worth more than those two lines.

The side effect is not bad either. Vertically the overhang is exactly half; horizontally the pull is half the _height_ rather than half the width, so a wide `99+` tucks in a little further than half — which is what you want anyway.

## Accessibility

`content={3}` beside a bell is just "3" to a screen reader. `label` replaces it with the sentence.

```tsx
<Badge content={3} label="3 unread notifications">
  <Button startIcon={<BellIcon />} aria-label="Notifications" />
</Badge>
```

Under a `dot` the count stays in the DOM — clipped rather than removed — because a quiet corner should not be a silent one. When the marker is `invisible`, or when there is no content to show, nothing is left behind at all: a mark that is not there has nothing to say, and text left in a clipped box is text a find-on-page still turns up.
