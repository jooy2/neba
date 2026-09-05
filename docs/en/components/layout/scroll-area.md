---
title: ScrollArea
order: 10
---

# ScrollArea

<p class="neba-lede">A box with a scrollbar of its own. The browser's is drawn by the operating system: a different width on every machine and a different colour from the sheet it is cut into; this one is an element, so it is the same everywhere and made of the library's own tokens.</p>

<Demo src="scroll-area/hero" />

```tsx
import { ScrollArea } from 'neba';

<ScrollArea height={200} fade>
  …
</ScrollArea>;
```

## Props

<PropsTable name="ScrollArea" />

Every native `<div>` attribute passes through to the root, apart from `color`. Underneath it is an ordinary scroll container, so the wheel, the trackpad, momentum and the keyboard are the browser's own.

It is not [ScrollZone](./scroll-zone), which is a _rail_: a strip of items laid out in one direction with buttons that step through them, for a row of cards or a line of chips. This is the plain case: a box too small for what is in it.

## Examples

### height · maxHeight

A vertical scroll area has to be bounded by something or there is nothing to scroll. `height` is a fixed one and `maxHeight` a ceiling; both take a number of pixels or any CSS length. A horizontal one is bounded by its container already.

### orientation

`vertical` is the default. `horizontal` draws the rail along the bottom instead, and `both` draws both with a corner between them.

<Demo src="scroll-area/orientation">

<<< @/.vitepress/demos/scroll-area/orientation.tsx

</Demo>

### fade

Fades the content out at each edge that has more beyond it, and only at those edges, so there is no fade at the top when you are at the top. It is drawn as a mask rather than a gradient over the content, which is what lets it sit on a translucent surface.

<Demo src="scroll-area/fade">

<<< @/.vitepress/demos/scroll-area/fade.tsx

</Demo>

### size · color

`size` is the thickness of the rail: its own ladder, well below the control heights, because a scrollbar is a rail and not a control. `color` is the family the thumb carries, mixed down so it does not read as a second column beside the text.

<Demo src="scroll-area/sizes">

<<< @/.vitepress/demos/scroll-area/sizes.tsx

</Demo>

## Accessibility

- The viewport is focusable and scrolls with the arrow keys, Page Up/Down, Home and End.
- The scrollbar appears while the pointer is over the area or while it is scrolling. The content is reachable without it in every case.
