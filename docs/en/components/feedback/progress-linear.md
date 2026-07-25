---
title: ProgressLinear
order: 5
---

# ProgressLinear

<p class="neba-lede">A bar that fills. The workhorse of the three.</p>

<Demo src="progress-linear/hero" />

```tsx
import { ProgressLinear } from 'neba';

<ProgressLinear value={64} label="Uploading assets" showValue />
<ProgressLinear />
```

## Props

<PropsTable name="ProgressLinear" />

## Examples

### Sizes

<Demo src="progress-linear/sizes">

<<< @/.vitepress/demos/progress-linear/sizes.tsx

</Demo>

### Ranges that are not 0–100

The value shown is a percentage of `min`…`max`, not of 100 — "3%" for step 3 of 4 is worse than saying nothing. Pass `format` when the number means something the reader would rather see: bytes, files, currency.

<Demo src="progress-linear/values">

<<< @/.vitepress/demos/progress-linear/values.tsx

</Demo>

## Indeterminate is the default

`value` defaults to `null`, and `null` means "something is happening and nobody knows how much of it is left". That is the default on purpose. An indicator that has not been told a value should say so, rather than draw an empty bar — which is a claim that no progress has been made.

The indeterminate bar moves a short segment along the groove with `inset-inline-start` rather than with a transform, which is both why it runs the other way under RTL without being told and why it does not break the house rule about moving surfaces. The cost is a layout pass per frame, confined to a box four pixels tall.

## Fully rounded, on purpose

This is the one place the rule against pills does not apply. At four pixels tall there is no flat run left to preserve, and a square-ended bar reads as a rendering bug rather than as a cut edge. See the [design language](../../guide/design-language) for what the rule is protecting everywhere else.

## Reduced motion

`prefers-reduced-motion` does not switch the animation off — an indeterminate indicator that holds still says the opposite of what it is for. The travelling segment becomes a colour pulse across the whole groove instead, which is the axis every other state in this library already uses.

## Accessibility

Base UI's Progress owns the semantics: `role="progressbar"`, the value and range attributes, and dropping `aria-valuenow` entirely when the bar is indeterminate. `label` becomes the accessible name, and `aria-valuetext` says exactly what the number beside the bar says.
