---
title: AnimateZoom
order: 9
---

# AnimateZoom

<p class="neba-lede">Content arriving from the middle of where it will end up. The same arithmetic as AnimateGrow at more than twice the distance and always about the centre, for the one thing on a screen that is meant to interrupt.</p>

<Demo src="animate-zoom/hero" />

```tsx
import { AnimateZoom } from 'neba';

<AnimateZoom>
  <Statistic label="Uptime this quarter" value={99.98} unit="%" />
</AnimateZoom>;
```

## Props

<PropsTable name="AnimateZoom" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

There is no `origin`: a zoom anchored to a corner is a grow, and that is [AnimateGrow](./animate-grow).

## Examples

### from

The scale it starts at. Well below `1` it comes up out of nothing; above `1` it arrives oversized and settles back, which reads as coming towards the reader rather than up out of the page.

<Demo src="animate-zoom/strength">

<<< @/.vitepress/demos/animate-zoom/strength.tsx

</Demo>

### trigger="visible"

The most common use of a zoom is a figure that lands as the reader reaches it. `threshold` is how much of the element has to be on screen first, from `0` to `1`, and `once` — on by default — is what stops it replaying every time the page scrolls back.

<Demo src="animate-zoom/visible">

<<< @/.vitepress/demos/animate-zoom/visible.tsx

</Demo>

### mode

`out` drops it away again, held at the end.

```tsx
<AnimateZoom mode="out" duration={240}>
  <Card title="Dismissed">This card is on its way out.</Card>
</AnimateZoom>
```

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference switches the animation off entirely and the content is simply there, at full size.
- A strong zoom over a large area is the most likely effect in this set to bother a reader who is sensitive to motion. Prefer a small `from`, or a fade, for anything covering much of the viewport.
