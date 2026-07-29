---
title: SegmentedButton
order: 19
---

# SegmentedButton

<p class="neba-lede">Joins two or three choices into one control, with exactly one taken. Use it for short labels where every option should stay visible in little space.</p>

<Demo src="segmented-button/hero" />

```tsx
import { Segment, SegmentedButton } from 'neba';

<SegmentedButton aria-label="Range" defaultValue="week">
  <Segment value="day">Day</Segment>
  <Segment value="week">Week</Segment>
  <Segment value="month">Month</Segment>
</SegmentedButton>;
```

## Props

### SegmentedButton

<PropsTable name="SegmentedButton" />

`value` with `onValueChange` makes it controlled; `defaultValue` makes it uncontrolled. The set needs a name, so pass `aria-label` or `aria-labelledby`.

### Segment

<PropsTable name="Segment" />

## Examples

### variant

`solid` rides a filled tile in a trough. `outline` is the same trough with a border, lighting the chosen sheet instead of filling it. `text` drops the trough and gives a surface only to the chosen segment.

<Demo src="segmented-button/variants">

<<< @/.vitepress/demos/segmented-button/variants.tsx

</Demo>

### size

The same control heights as [Button](./button): a `md` segment and a `md` button are both 32px, so the two sit in one toolbar without the row losing its baseline.

<Demo src="segmented-button/sizes">

<<< @/.vitepress/demos/segmented-button/sizes.tsx

</Demo>

### startIcon · disabled · readOnly

`readOnly` shows which one is chosen but does not let it change, draining the saturation. `disabled` drops the colour family for neutral grey. `disabled` can also be set per `Segment`.

<Demo src="segmented-button/states">

<<< @/.vitepress/demos/segmented-button/states.tsx

</Demo>

### fullWidth

Stretches the set to the container width, with the segments sharing the space equally.

## Accessibility

- Renders `role="radiogroup"`. The set takes one tab stop, the arrow keys move within it, and the chosen segment carries `aria-checked`.
- The selection tile moves via `left` · `top` · `width` · `height`, so no label is resampled. The first render and a window resize are not animated.

## When to use something else

- A row of actions rather than a choice is a [ButtonGroup](./button-group).
- More than about five options, or long labels, wants a [Select](./select).
- If there are panels underneath, it is [Tabs](../surfaces/tabs).
- If the set needs a visible label, a [RadioGroup](./radio-group) fits better.
