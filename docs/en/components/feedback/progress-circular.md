---
title: ProgressCircular
order: 6
---

# ProgressCircular

<p class="neba-lede">A ring that fills, for where there is no room for a bar.</p>

<Demo src="progress-circular/hero" align="center" />

```tsx
import { ProgressCircular } from 'neba';

<ProgressCircular value={72} showValue label="Indexing" />
<ProgressCircular />
```

## Props

<PropsTable name="ProgressCircular" />

## Examples

### Sizes

<Demo src="progress-circular/sizes">

<<< @/.vitepress/demos/progress-circular/sizes.tsx

</Demo>

### Inside a control

The ring lands just under the control ladder at every step — a `md` ring is 20px inside a 32px control — so dropping one into a button, a field or a table row never makes the row taller than it already was.

<Demo src="progress-circular/inline">

<<< @/.vitepress/demos/progress-circular/inline.tsx

</Demo>

## The number goes beside it

A percentage in the middle of a dial is the picture everyone has of this component, and it only works at two of the five sizes: at `xs` the ring is fourteen pixels across and there is nowhere for "40%" to go. Beside the ring, every size reads — so `showValue` and `label` sit in a row with it.

## The one rotation in the library

The house style is against transforms on a control because scaling or moving one resamples its label. A ring has no label inside it: what turns is a glyph, which is the same allowance the [Select](../inputs/select) chevron takes.

The arc's _starting_ point is an SVG geometry attribute rather than a CSS transform. Without it a determinate ring would fill from three o'clock, which is not what anyone means by "72%".

## Accessibility

The drawing is `aria-hidden`; the value reaches a screen reader through Base UI's `role="progressbar"` on the element around it, exactly as it does on the bar. `label` becomes the accessible name.
