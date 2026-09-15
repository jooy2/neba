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

For a row of actions rather than a choice, use [ButtonGroup](./button-group), and when there are panels underneath, use [Tabs](../surfaces/tabs). More than about five options or long labels want a [Select](./select), and a set that needs a visible label fits a [RadioGroup](./radio-group) better.

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
