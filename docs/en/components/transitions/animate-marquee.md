---
title: AnimateMarquee
order: 9
---

# AnimateMarquee

<p class="neba-lede">Content scrolling steadily past, forever. The content is laid down twice and each copy travels exactly its own length, so there is no seam and no frame where the strip is empty.</p>

<Demo src="animate-marquee/hero" />

```tsx
import { AnimateMarquee } from 'neba';

<AnimateMarquee speed={45} gap="1.5rem">
  {customers.map((name) => (
    <Chip key={name}>{name}</Chip>
  ))}
</AnimateMarquee>;
```

## Props

<PropsTable name="AnimateMarquee" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### speed and reverse

Pixels per second, measured against the strip's own width, so four logos and forty move at the same pace instead of the long one becoming a blur. `duration` is still accepted and overrides the measurement. `reverse` runs it the other way.

<Demo src="animate-marquee/speed">

<<< @/.vitepress/demos/animate-marquee/speed.tsx

</Demo>

### orientation

`vertical` runs the strip down the box instead of across it, for a log or an activity feed. The box needs a height for it to have anywhere to run.

<Demo src="animate-marquee/vertical">

<<< @/.vitepress/demos/animate-marquee/vertical.tsx

</Demo>

### pauseOnHover

On by default, and not decoration: content moving past a pointer cannot be clicked reliably, and a link inside a strip that never stops is a link nobody can follow. The strip answers the focus as well as the pointer, so a link reached by tabbing to it stops travelling too.

<Demo src="animate-marquee/pause">

<<< @/.vitepress/demos/animate-marquee/pause.tsx

</Demo>

### copies and gap

`gap` is the space between items, and also between the last item of one pass and the first of the next. `copies` is how many times the content is laid end to end: two is enough for anything at least as wide as its container, and raising it is the fix for content short enough to leave a hole behind itself.

```tsx
<AnimateMarquee copies={4} gap="3rem">
  <Chip>One short item</Chip>
</AnimateMarquee>
```

## Accessibility

- Only the first copy is read out; the rest carry `aria-hidden`, or a screen reader would announce the whole strip as many times as it was laid down.
- A reduced-motion preference stops the strip and leaves the content in place.
- `pauseOnHover` is what makes anything interactive inside it usable, and it covers both a pointer resting on the strip and the focus landing inside it. Do not turn it off for a strip with links or buttons in it.
