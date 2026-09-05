---
title: AnimateBlink
order: 9
---

# AnimateBlink

<p class="neba-lede">Content pulsing between full opacity and a floor. The cycle is symmetric, so however many times it runs it ends where it started.</p>

<Demo src="animate-blink/hero" />

```tsx
import { AnimateBlink } from 'neba';

<AnimateBlink min={0.35}>
  <Chip color="danger" variant="solid">
    Recording
  </Chip>
</AnimateBlink>;
```

## Props

<PropsTable name="AnimateBlink" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

There is no `mode`: the cycle is the same in both directions, so there is nothing for a reversed one to mean.

## Examples

### min

How faint it gets at the bottom of the cycle, between `0` and `1`. At `0` the content disappears; raise it for anything that has to stay readable while it pulses, which is most things.

<Demo src="animate-blink/floor">

<<< @/.vitepress/demos/animate-blink/floor.tsx

</Demo>

### repeat

It repeats forever unless told otherwise, because a single blink is a flicker rather than an effect. A count is for drawing attention once: three pulses and then still.

<Demo src="animate-blink/counted">

<<< @/.vitepress/demos/animate-blink/counted.tsx

</Demo>

### paused

`paused` holds the animation where it is, which is how to stop a live indicator without unmounting it.

```tsx
<AnimateBlink paused={!recording} min={0.35}>
  <Chip color="danger">Recording</Chip>
</AnimateBlink>
```

### stagger

`stagger`, `durationStep` and `reverse` hand the effect to the children one at a time instead of running it on the box. They work the same way here as on [AnimateFade](./animate-fade), where they are set out in full.

## Accessibility

- A reduced-motion preference switches the animation off entirely and the content sits at full opacity.
- Because of that, the blink is never the only thing carrying the message. Say it in words too: a `Chip` that reads "Recording" says it whether or not it is pulsing.
- Something that never stops moving in the corner of a page being read is the one kind of motion this library otherwise refuses. Use it for a state that is genuinely live, and stop it when the state ends.
