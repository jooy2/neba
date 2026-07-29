---
title: ProgressCircular
order: 6
---

# ProgressCircular

<p class="neba-lede">Shows progress as a ring. Use it in tight space, where there is no room for a horizontal bar.</p>

<Demo src="progress-circular/hero" align="center" />

```tsx
import { ProgressCircular } from 'neba';

<ProgressCircular value={72} showValue label="Indexing" />
<ProgressCircular />
```

## Props

<PropsTable name="ProgressCircular" />

`value` defaults to `null`, and the ring spins while indeterminate. `min`, `max` and `format` behave exactly as they do on [ProgressLinear](./progress-linear).

## Examples

### size

<Demo src="progress-circular/sizes">

<<< @/.vitepress/demos/progress-circular/sizes.tsx

</Demo>

### Inside a control

The ring sits one step under the control height at every size — an `md` ring is 20px inside a 32px control — so dropping one into a button, a field or a table row never makes the row taller.

<Demo src="progress-circular/inline">

<<< @/.vitepress/demos/progress-circular/inline.tsx

</Demo>

### showValue and label

The value sits beside the ring rather than inside it: at `xs` the ring is fourteen pixels across and a number would not fit. `showValue` and `label` line up in a row with it.

## Accessibility

- The SVG drawing is `aria-hidden`; the value reaches a screen reader through `role="progressbar"` on the element around it.
- `label` becomes the accessible name.
