---
title: ProgressBox
order: 7
---

# ProgressBox

<p class="neba-lede">Shows progress as a row of plates that fill in turn. It is the shape that fits a loading state on a Neba surface.</p>

<Demo src="progress-box/hero" align="center" />

```tsx
import { ProgressBox } from 'neba';

<ProgressBox />
<ProgressBox value={62} label="Migrating" showValue />
```

## Props

<PropsTable name="ProgressBox" />

`value`, `min`, `max`, `format` and `showValue` behave as they do on [ProgressLinear](./progress-linear). A `value` of `null` gives the indeterminate state, where the plates light in sequence.

## Examples

### count

How many plates to draw. With a value, they fill left to right and the leading plate fills partially — all-or-nothing plates could only ever show 0, 25, 50, 75 or 100 at a count of four.

<Demo src="progress-box/counts">

<<< @/.vitepress/demos/progress-box/counts.tsx

</Demo>

### Using it as a step indicator

Match `count` to the real number of steps and each plate becomes one step, with the running step's plate shown mid-fill.

<Demo src="progress-box/steps">

<<< @/.vitepress/demos/progress-box/steps.tsx

</Demo>

## Reduced motion

The plates never move; only the fill and the light edge animate. Under `prefers-reduced-motion` the cycle slows down.

## Accessibility

- Carries `role="progressbar"` with the value attributes, and `label` becomes the accessible name.
- The indeterminate state reports itself as indeterminate rather than as zero.
