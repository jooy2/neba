---
title: AnimateFade
order: 9
---

# AnimateFade

<p class="neba-lede">Content arriving or leaving on opacity alone. The plainest effect in the set and the one to reach for first: nothing moves, so nothing reflows and no text is resampled.</p>

<Demo src="animate-fade/hero" />

```tsx
import { AnimateFade } from 'neba';

<AnimateFade>
  <Card title="Deployment finished">Two services restarted, no errors.</Card>
</AnimateFade>;
```

## Props

<PropsTable name="AnimateFade" />

Every other `<div>` attribute passes through to the root.

The settings shared by every `Animate*` — `duration`, `delay`, `easing`, `repeat`, `alternate`, `trigger`, `play`, `once`, `threshold`, `paused` — mean the same thing on all of them, and are defined in [prop conventions](../../design/prop-conventions).

## Examples

### duration and delay

Both are milliseconds. A delay is what turns a set of fades into a sequence, and it is what `AnimateAppear` does for you when the things being delayed are a list.

<Demo src="animate-fade/timing">

<<< @/.vitepress/demos/animate-fade/timing.tsx

</Demo>

### trigger

`mount` is the default and needs nothing from you. `visible` waits until the element is scrolled into view — once, unless `once` is off — and `threshold` is how much of it has to be on screen. `hover` runs while the pointer is on it, restarting on each entry, and keyboard focus counts as a pointer. `manual` runs nothing until `play` says so, and every `false` → `true` starts it over.

<Demo src="animate-fade/triggers">

<<< @/.vitepress/demos/animate-fade/triggers.tsx

</Demo>

### mode

`out` is the same animation run backwards, and it is held there: a faded-out element stays faded out rather than snapping back when the animation ends. With `alternate` it returns instead of jumping, which is what makes a repeating fade a pulse.

<Demo src="animate-fade/mode">

<<< @/.vitepress/demos/animate-fade/mode.tsx

</Demo>

### from

The opacity the fade starts at, between `0` and `1`. Raise it for content that should never be completely gone — a dimming rather than a disappearance.

```tsx
<AnimateFade from={0.4}>
  <Chip>Draft</Chip>
</AnimateFade>
```

## Accessibility

- A reduced-motion preference switches the animation off entirely and the content is simply there. It is never left invisible.
- The wrapper adds no role and no name; whatever is inside keeps its own.
