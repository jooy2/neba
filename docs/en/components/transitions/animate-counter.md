---
title: AnimateCounter
order: 9
---

# AnimateCounter

<p class="neba-lede">A number counted up to its value. The one animation in the library whose subject is the content rather than the box around it: a value being interpolated and formatted on every frame, which is not something a keyframe can do.</p>

<Demo src="animate-counter/hero" minHeight="140" />

```tsx
import { AnimateCounter, Statistic } from 'neba';

<Statistic label="Monthly active" value={<AnimateCounter value={128400} />} />;
```

## Props

<PropsTable name="AnimateCounter" />

Every other `<div>` attribute passes through to the root. It has no `easing`, `repeat` or `alternate`: a number may only ever approach its value from one side, so the curve is a fixed ease-out and there is no version of a count that loops.

It pairs with [Statistic](../charts/statistic), whose `value` takes a node for exactly this. A dashboard that draws its numbers instantly and animates everything around them has the emphasis backwards.

## Examples

### format and locale

`Intl.NumberFormat` options, so a currency, a percentage or a compact `1.2M` is a prop rather than a `format` callback: the same prop [Statistic](../charts/statistic) and the progress indicators take.

<Demo src="animate-counter/formats" minHeight="240">

<<< @/.vitepress/demos/animate-counter/formats.tsx

</Demo>

### trigger

`trigger="visible"` is the one worth reaching for on a dashboard below the fold: a count that has already finished by the time it is scrolled to has not been seen. Before it starts, the number sits at `from` rather than at its answer.

```tsx
<AnimateCounter value={128400} trigger="visible" />
```

## Accessibility

- The finished number is in the document from the first frame, in a clipped box for a screen reader; what counts is a visible copy that is `aria-hidden`. A reader who cannot see the count is told the answer rather than a hundred intermediate ones.
- A reduced-motion preference shows the answer straight away.
