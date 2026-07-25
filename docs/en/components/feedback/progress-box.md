---
title: ProgressBox
order: 7
---

# ProgressBox

<p class="neba-lede">A row of acrylic plates that light up.</p>

<Demo src="progress-box/hero" align="center" />

```tsx
import { ProgressBox } from 'neba';

<ProgressBox />
<ProgressBox value={62} label="Migrating" showValue />
```

## Props

<PropsTable name="ProgressBox" />

## Examples

### How many plates

<Demo src="progress-box/counts">

<<< @/.vitepress/demos/progress-box/counts.tsx

</Demo>

### When the thing really has steps

Give `count` the number of steps and the plates stop being a decoration: each one is a step, and the leading plate fills as that step runs.

<Demo src="progress-box/steps">

<<< @/.vitepress/demos/progress-box/steps.tsx

</Demo>

## Why a third shape

A bar and a ring both say "this much of it is done" — they are about the quantity. A row of plates says "this is working" in the library's own vocabulary: the same cut sheet, the same hairline, the same fill. That is what makes it the right one for a loading state inside a Neba surface, where a foreign grey spinner looks borrowed.

It still answers a value when it has one. The plates fill left to right and the leading one fills partially, because four all-or-nothing plates could only ever show 0, 25, 50, 75 or 100 — and a value of 30% would round away to a quarter.

## Colour, not motion

The plates never move. The wave animates the fill and the light edge and nothing else, each plate held back by its own index, so a row of them reads as a surface being written to rather than as something bouncing. Under `prefers-reduced-motion` the cycle simply slows to where it stops reading as motion at all.

## Accessibility

Same as the other two: Base UI's Progress owns `role="progressbar"` and the value attributes, `label` is the accessible name, and an indeterminate row reports itself as indeterminate rather than as zero.
