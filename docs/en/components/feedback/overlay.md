---
title: Overlay
order: 8
---

# Overlay

<p class="neba-lede">A sheet over the whole page that stops it being used. The scrim on its own, with whatever you put on top of it.</p>

<Demo src="overlay/hero" />

```tsx
import { Overlay, ProgressCircular } from 'neba';

<Overlay open={saving} tone="blur" label="Saving">
  <ProgressCircular size="lg" />
</Overlay>;
```

## Props

<PropsTable name="Overlay" />

### Overlay or Dialog?

The difference is what is _not_ here. An Overlay has no surface, no border, no title and no actions — a [Dialog](./dialog) is a sheet that asks a question, and an Overlay is the plane that sheet would have floated above.

Reach for an Overlay when the page has to stop and there is nothing to answer: something is saving, something is loading, something is being replaced. Reach for a Dialog the moment there is a decision to make.

### It is not dismissible by default

This is the one prop worth reading twice, and it is the other way round from Dialog.

A dialog asks a question and Escape is the universal _no_. An overlay is not asking anything — it is saying _wait_ — and a save that can be dismissed by a stray click is a save the user will believe finished. So `dismissible` starts off, and Escape and a click on the scrim are both refused until you turn it on.

Turn it on for the overlay whose whole job is to catch a click outside something.

<Demo src="overlay/dismissible">

<<< @/.vitepress/demos/overlay/dismissible.tsx

</Demo>

## Examples

### Tones

Four steps on one axis: how legible is what is behind.

Each is tuned with the blur radius as much as with the alpha, because past about 16px a backdrop smears into flat colour and the scrim reads opaque no matter how low its alpha goes.

| Tone | What the page behind does |
| --- | --- |
| `scrim` | Stays readable. It has only stopped being reachable. This is Dialog's own backdrop, so the two never show a seam. |
| `blur` | Present as shape and colour, gone as words. For "this is being replaced". |
| `solid` | Gone. The page surface, opaque. |
| `clear` | Nothing is drawn. Still blocks the pointer — an invisible sheet that catches a click. |

<Demo src="overlay/tones">

<<< @/.vitepress/demos/overlay/tones.tsx

</Demo>

## Accessibility

- Base UI owns the portal, the scroll lock, the focus held inside, the page behind going inert, and focus returning to wherever it came from when the overlay closes.
- The overlay is a `dialog`, and `label` is its accessible name. It has a default rather than being optional: an overlay that holds nothing readable — a bare spinner, a `clear` sheet — still has to say what it is.
- `modal="trap-focus"` leaves the page scrollable and clickable while still holding the focus inside, which is usually what a `clear` overlay wants.
- The fade is opacity only. An overlay that scales or slides drags whatever is written on it across the screen, which is the one thing the [design language](../../guide/design-language) is against.
