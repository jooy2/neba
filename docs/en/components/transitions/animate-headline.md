---
title: AnimateHeadline
order: 9
---

# AnimateHeadline

<p class="neba-lede">One line replacing the one above it, on a timer. Every line sits in the same grid cell, so the box is as tall as the longest of them from the first frame and never resizes as the reel turns.</p>

<Demo src="animate-headline/hero" />

```tsx
import { AnimateHeadline } from 'neba';

<AnimateHeadline interval={2000}>
  <span>faster</span>
  <span>quieter</span>
  <span>yours</span>
</AnimateHeadline>;
```

## Props

<PropsTable name="AnimateHeadline" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### interval and duration

`interval` is how long a line is held, counted from the moment it arrives rather than from the start of the cycle, so raising `duration`, the length of the transition itself, does not quietly eat the reading time.

<Demo src="animate-headline/breaking">

<<< @/.vitepress/demos/animate-headline/breaking.tsx

</Demo>

### Controlled

Pass `index` and the reel stops turning on its own: it becomes a way of moving between lines that something else decides. A step in a form, a tab, a timer of your own. `onIndexChange` reports the line that has just come up.

<Demo src="animate-headline/controlled">

<<< @/.vitepress/demos/animate-headline/controlled.tsx

</Demo>

### loop and rise

`loop` off stops the reel on the last line and leaves it there. `rise` is how far a line travels as it comes up or leaves: `'100%'`, the default, is one line's own height, and a smaller value is a nudge rather than a replacement.

```tsx
<AnimateHeadline loop={false} rise="0.4rem">
  <span>Uploading…</span>
  <span>Processing…</span>
  <span>Done</span>
</AnimateHeadline>
```

## Accessibility

- Only the line that is showing is on the accessibility tree; the others are `visibility: hidden`, which keeps their space without putting them in the reading order.
- Nothing is announced when the reel turns. This is deliberate (a live region cycling every two seconds is unusable), and it is why the component is for a set of phrases where any one of them would have done, not for content a reader has to see.
- A reduced-motion preference drops the transition. The lines still change, they simply arrive rather than slide.
