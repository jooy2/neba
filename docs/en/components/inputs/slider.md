---
title: Slider
order: 8
---

# Slider

<p class="neba-lede">A value chosen along a range. Pass an array and it becomes a range slider — there is no separate prop for that, because the shape of the value already says which one this is.</p>

<Demo src="slider/hero" />

```tsx
import { Slider } from 'neba';

<Slider label="Volume" defaultValue={65} showValue />;
```

## Props

<PropsTable name="Slider" />

`onValueChange` fires throughout the drag; `onValueCommitted` fires once, when the value settles. Put the network request on the second one.

## Examples

### Range

<Demo src="slider/range">

<<< @/.vitepress/demos/slider/range.tsx

</Demo>

### Sizes

The thumb is deliberately far larger than the track. It is the only part of the control you can actually hit, and a thumb sized to match a 6px rail is a thumb nobody catches on a touchscreen.

<Demo src="slider/sizes">

<<< @/.vitepress/demos/slider/sizes.tsx

</Demo>

### Vertical

A vertical slider has no length of its own — give it a height. The default is a starting point, not a rule.

<Demo src="slider/vertical">

<<< @/.vitepress/demos/slider/vertical.tsx

</Demo>

## The thumb does not grow

Hovering and dragging put a ring _around_ the thumb rather than scaling it. That is the same no-transform rule the rest of the library follows, and it is not relaxed just because this particular part carries no label: a control whose parts change size under the cursor is the thing that reads as cheap.

The rail and the indicator are pills for the same reason a [Switch](./switch)'s track is — this is a groove something travels along, not a sheet.

## Accessibility

- Each thumb is a real `<input type="range">`, so the arrow keys, Home/End and Page Up/Down all work without any code here.
- `label` becomes the accessible name. Without one, give the slider an `aria-label`.
- `showValue` renders an `<output>`, which is announced as the value changes.
