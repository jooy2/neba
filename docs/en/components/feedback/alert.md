---
title: Alert
order: 1
---

# Alert

<p class="neba-lede">A message about something that happened, set into the page it is about.</p>

<Demo src="alert/hero" />

```tsx
import { Alert } from 'neba';

<Alert color="success">Your changes have been saved.</Alert>
<Alert color="danger" title="Deploy failed" onClose={dismiss}>
  The build exited with code 1.
</Alert>;
```

## Props

<PropsTable name="Alert" />

## Examples

### The three shapes are one component

A bare line, a line with a glyph, and a glyph with a headline and the detail under it. They are not three components — they are the same slots, filled to different depths. Nothing about the surface changes between them; only how much of it is used.

<Demo src="alert/shapes">

<<< @/.vitepress/demos/alert/shapes.tsx

</Demo>

### Variants

An alert _is_ the thing being coloured — it is a notice about a severity, not a container holding someone else's content — so unlike a [Box](../surfaces/box) its sheet takes the tint. `text` is the one to reach for inside a form, where a second bordered rectangle among the fields is one rectangle too many.

<Demo src="alert/variants">

<<< @/.vitepress/demos/alert/variants.tsx

</Demo>

### Severities

<Demo src="alert/colors">

<<< @/.vitepress/demos/alert/colors.tsx

</Demo>

### Actions and dismissing

`action` is kept out of `children` so it stays on the first line while the message wraps beside it. Passing `onClose` is what makes the × appear.

<Demo src="alert/dismissing">

<<< @/.vitepress/demos/alert/dismissing.tsx

</Demo>

## The glyph is part of the message

There are three drawings for six families rather than one exclamation mark dyed six ways. Colour alone is not something every reader has, and an alert that says "this went wrong" only in red says it only to some of them. `primary` and `secondary` have no severity to draw, so they take the note the informational alert uses.

Pass `icon={false}` when the surrounding copy already says what kind of message this is, and a node when you have a better drawing for it.

## Accessibility

The severity picks the live region: `warning` and `danger` get `role="alert"`, which interrupts whatever a screen reader is in the middle of saying, and the rest get `role="status"`, which waits for a pause. "This failed" is worth interrupting for and "saved" is not.

A caller who knows better still wins — `role` passes straight through and lands after the default.

`color` is `info` by default rather than `primary`. This is the one place `primary` would be a lie: an alert is not the primary anything, it is a note, and the palette already has a word for that.
