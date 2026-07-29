---
title: SegmentedButton
order: 19
---

# SegmentedButton

<p class="neba-lede">Two or more choices in one pill, exactly one of them taken.</p>

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

<PropsTable name="SegmentedButton" />

### Segment

<PropsTable name="Segment" />

## Underneath it is a radio group

That is the whole accessibility argument. A segmented button **is** "exactly one of these", so it gets `role="radiogroup"`, one tab stop for the set, arrow keys within it, and `aria-checked` on the one that is taken.

Building it out of `aria-pressed` toggles — which is what a row of buttons would give — would announce four independent switches, three of which happen to be off.

The set needs a name: pass `aria-label` or `aria-labelledby`. If it needs a _visible_ label, what you probably want is a [RadioGroup](./radio-group).

## The tile moves and nothing is transformed

The tile slides because its `left`, `top`, `width` and `height` are measured off the chosen segment and animated. No `transform` is involved. The tile is an **empty box**, so no text is resampled while it travels.

It is the same distinction [Tabs](../surfaces/tabs)' indicator draws, and the reason the [no-transform rule](../../guide/design-language) survives a component whose entire point is that something moves. What the rule forbids is not movement — it is a **label** moving.

The first placement is never animated, because a tile that has just mounted has nowhere to travel from. Neither is a resize: what moves then is the container under a tile that was already in the right place, and animating that is a tile that lags behind the window being dragged.

## Examples

### Weight

`solid` is a frosted trough with a filled tile riding in it. `outline` is the same trough with a hairline around it, lighting the sheet rather than filling it. `text` takes the trough away entirely and gives a surface only to the chosen one.

<Demo src="segmented-button/variants">

<<< @/.vitepress/demos/segmented-button/variants.tsx

</Demo>

### Size

A segment sits on the same control ladder as a [Button](./button): a `md` segment and a `md` button are the same 32px, which is what lets the two sit in one toolbar without the row losing its baseline.

<Demo src="segmented-button/sizes">

<<< @/.vitepress/demos/segmented-button/sizes.tsx

</Demo>

### Icons and states

<Demo src="segmented-button/states">

<<< @/.vitepress/demos/segmented-button/states.tsx

</Demo>

`readOnly` shows which one is chosen but does not let it change, and drains the saturation. `disabled` drops the colour family entirely. They are the same two axes everywhere in the library.

## The pill shape

This is the only fully round shape in the library besides [Pill](../surfaces/pill), and for the same reason. The [radius rule](../../guide/design-language) holds every control just short of the 50% that would make it a pill, because the flat run along the top and bottom edge is what reads as a sheet with the corners cut off it. But a segment is not a sheet lying on the page — it is a tile **riding** in a groove cut into one.

## What this is not for

- A row of **actions** rather than a choice is a [ButtonGroup](./button-group), which does not manage selection.
- More than about five options, or long labels, is a [Select](./select). The trough will stretch; it will not stay readable.
- If there are panels underneath, it is not a segmented button — it is [Tabs](../surfaces/tabs), and `variant="solid"` is exactly this shape.
