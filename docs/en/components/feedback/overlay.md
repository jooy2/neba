---
title: Overlay
order: 8
---

# Overlay

<p class="neba-lede">A sheet over the whole page that blocks interaction. Use it while the user has to wait with nothing to answer — a save, a load, a replacement in progress.</p>

<Demo src="overlay/hero" />

```tsx
import { Overlay, ProgressCircular } from 'neba';

<Overlay open={saving} tone="blur" label="Saving">
  <ProgressCircular size="lg" />
</Overlay>;
```

## Props

<PropsTable name="Overlay" />

An Overlay has no surface, no border, no title and no actions. If there is a decision to make, use [Dialog](./dialog) instead.

## Examples

### tone

Four steps deciding how legible the page behind stays.

| tone | The page behind |
| --- | --- |
| `scrim` | Stays readable; only interaction is blocked. Same value as [Dialog](./dialog)'s backdrop, so the two never show a seam. |
| `blur` | Present as shape and colour, gone as words. For content being replaced. |
| `solid` | Hidden entirely, covered opaquely in the page surface colour. |
| `clear` | Nothing is drawn; only the pointer is blocked. |

<Demo src="overlay/tones">

<<< @/.vitepress/demos/overlay/tones.tsx

</Demo>

### dismissible

Off by default, which is the other way round from [Dialog](./dialog). An Overlay is not asking for an answer, it is saying wait, so Escape and a click on the scrim are both refused. Turn it on for an overlay whose job is to catch a click outside something.

<Demo src="overlay/dismissible">

<<< @/.vitepress/demos/overlay/dismissible.tsx

</Demo>

### modal

`modal="trap-focus"` leaves the page scrollable and clickable while holding focus inside the overlay — a good fit with the `clear` tone.

## Accessibility

- Renders with `role="dialog"`, and `label` is its accessible name. `label` has a default because an overlay holding only a spinner, or a `clear` one, still has to say what it is.
- The portal, the scroll lock, focus held inside, the page behind going inert, and focus returning on close are all handled.
- The entrance animates opacity only.
