---
title: ButtonGroup
order: 2
---

# ButtonGroup

<p class="neba-lede">A row of buttons that belong together. The corners that face a neighbour are squared off, and the shared props are set once for the whole set.</p>

<Demo src="button-group/hero" />

```tsx
import { Button, ButtonGroup } from 'neba';

<ButtonGroup variant="outline">
  <Button>Day</Button>
  <Button>Week</Button>
  <Button>Month</Button>
</ButtonGroup>;
```

## Props

<PropsTable name="ButtonGroup" />

Every native `<div>` attribute passes straight through, minus `color`.

## Examples

### Shared props

Two things are happening here, and only one of them is visual. The corners are the look; the other half is that `variant`, `size`, `color`, `density`, `elevation` and `disabled` are stated once rather than repeated on every button. A group where one button is a size out is the failure this exists to prevent.

A button's own prop still wins — a row of secondary actions with one `danger` button in it is a real thing.

<Demo src="button-group/shared">

<<< @/.vitepress/demos/button-group/shared.tsx

</Demo>

### Orientation

<Demo src="button-group/orientation">

<<< @/.vitepress/demos/button-group/orientation.tsx

</Demo>

### Full width

<Demo src="button-group/full-width">

<<< @/.vitepress/demos/button-group/full-width.tsx

</Demo>

## How the seam works

Only the `outline` group pulls its buttons together by a pixel. Two hairline borders meeting would otherwise draw a seam twice as heavy as every other edge on the page, so the second button is shifted back to share a single line.

A `solid` group must not do that. Its seam _is_ the plate edge — the white inset hairline every filled surface carries — and overlapping would put one button's fill over the neighbour's edge and merge the run into one blob.

## Accessibility

- Renders `role="group"`. Give it an `aria-label` when the buttons alone do not say what the set is for.
- This is **not** a segmented control and it does not manage selection. For one-of-a-set, use a [RadioGroup](./radio-group) — that is what that actually is.
- The hovered or focused button is raised above its neighbours so its focus ring is never clipped.
