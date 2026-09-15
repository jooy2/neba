---
title: ProgressLinear
order: 5
---

# ProgressLinear

<p class="neba-lede">Shows progress as a horizontal bar. It is the most widely used of the three progress components.</p>

<Demo src="progress-linear/hero" />

```tsx
import { ProgressLinear } from 'neba';

<ProgressLinear value={64} label="Uploading assets" showValue />
<ProgressLinear />
```

## Props

<PropsTable name="ProgressLinear" />

Native `<div>` attributes pass through to the root. Only `color` and `children` are excluded, since the table above spells them differently.

`value` defaults to `null`, the indeterminate state: a short segment travels along the groove. A `value` of `0` means something different ("nothing has progressed yet"), so keep the two apart.

## Examples

### size

<Demo src="progress-linear/sizes">

<<< @/.vitepress/demos/progress-linear/sizes.tsx

</Demo>

### thickness

`size` is a step on the library's ladder; `thickness` is a number of pixels, for the bar a page is actually about. It changes the groove alone — `size` still sets the type scale of the label beside it.

```tsx
<ProgressLinear value={62} thickness={12} />
```

### min · max · format

The percentage shown is a proportion of `min`…`max`, not of 100. `showValue` prints it beside the bar, and `format` takes `Intl.NumberFormat` options so you can show the number itself: bytes, files, currency. `locale` is the language that writes it in, and falls back to a provider's, so a server and a browser write the same thing.

<Demo src="progress-linear/values">

<<< @/.vitepress/demos/progress-linear/values.tsx

</Demo>

## Reduced motion

`prefers-reduced-motion` does not stop the indeterminate animation. The travelling segment is replaced by a colour pulse across the whole groove.

## Accessibility

- Carries `role="progressbar"` with the value and range attributes; `aria-valuenow` is dropped while indeterminate.
- `label` becomes the accessible name, and `aria-valuetext` says the same thing as the printed value.
