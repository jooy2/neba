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

### A range from an array value

Pass an array of numbers as the `value` and you get that many thumbs: a range slider. There is no separate prop for it.

<Demo src="slider/range">

<<< @/.vitepress/demos/slider/range.tsx

</Demo>

### min · max · step

`step` is the interval the thumb settles on. `showValue` prints the current value beside the label.

### marks

`marks` names points along the track: `1 / 100 / 250 / 500` under a count, or the two ends of a style axis. Pass an array of `{ value, label? }`, and a mark with no label is a tick on its own.

`marks` without a value is a tick at every `step`, which is worth pairing with a step you chose — the default `step={1}` over the default range draws a hundred and one of them, and a range of more than a hundred steps draws none at all.

The row is hidden from screen readers: the thumb already announces the value and the range.

<Demo src="slider/marks">

<<< @/.vitepress/demos/slider/marks.tsx

</Demo>

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

### classNames

`className` lands on the root — the column holding the label, the strip and the line under it — and the parts inside are reached through `classNames`.

```tsx
<Slider label="Volume" classNames={{ track: 'h-1', thumb: 'rounded-sm', mark: 'font-mono' }} />
```

The slots are `label`, `control`, `track`, `indicator`, `thumb`, `description` and `mark`. `control` is the whole strip a press lands on, which is taller than the `track` drawn inside it.

## Accessibility

- Each thumb is a real `<input type="range">`, so the arrow keys, Home/End and Page Up/Down all work as they should.
- `label` becomes each thumb's accessible name, and `description` describes it. Without a label, give the slider an `aria-label`, which also lands on the thumbs.
- A range slider's thumbs share the label. Name them apart with `getAriaLabel`, and word their values with `getAriaValueText`.
- `showValue` renders an `<output>`, which is announced as the value changes.
- Hovering and dragging draw a ring around the thumb rather than changing its size.
