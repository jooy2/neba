---
title: Slider
order: 8
---

# Slider

<p class="neba-lede">Picks a value by dragging along a range. Use it where the relative magnitude matters more than the exact number.</p>

<Demo src="slider/hero" />

```tsx
import { Slider } from 'neba';

<Slider label="Volume" defaultValue={65} showValue />;
```

## Props

<PropsTable name="Slider" />

`onValueChange` fires throughout the drag; `onValueCommitted` fires once, when the value settles. Put the network request on the latter.

When an exact number has to be typed, use [NumberField](./number-field).

## Examples

### An array value makes it a range

Pass an array of numbers as the `value` and you get that many thumbs: a range slider. There is no separate prop for it.

<Demo src="slider/range">

<<< @/.vitepress/demos/slider/range.tsx

</Demo>

### min · max · step

`step` is the interval the thumb settles on. `showValue` prints the current value beside the label.

### size

The thumb is drawn larger than the track: it is the part you actually hit, so it needs a real touch target.

<Demo src="slider/sizes">

<<< @/.vitepress/demos/slider/sizes.tsx

</Demo>

### orientation

A `vertical` slider has no length of its own; give it a height.

<Demo src="slider/vertical">

<<< @/.vitepress/demos/slider/vertical.tsx

</Demo>

## Accessibility

- Each thumb is a real `<input type="range">`, so the arrow keys, Home/End and Page Up/Down all work as they should.
- `label` becomes the accessible name. Without one, give the slider an `aria-label`.
- `showValue` renders an `<output>`, which is announced as the value changes.
- Hovering and dragging draw a ring around the thumb rather than changing its size.
