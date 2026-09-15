---
title: AnimateShake
order: 9
---

# AnimateShake

<p class="neba-lede">The one effect in the set that says no. A password that was wrong, a form that would not send, a row that could not be dropped where it was let go: every other animation here is content arriving, and this one is an answer.</p>

<Demo src="animate-shake/hero" minHeight="180" />

```tsx
import { AnimateShake } from 'neba';

<AnimateShake play={attempts}>
  <TextField label="Passphrase" error={message} />
</AnimateShake>;
```

## Props

<PropsTable name="AnimateShake" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Unlike every other effect here it defaults to `trigger="manual"`: a shake that runs on mount is decoration, and decoration that moves is what a reader learns to ignore. Bind `play` to a count of the failures. Each new number replays the shake without remounting what is inside it, so the second wrong answer moves as much as the first and the focus stays where it was.

There is no `mode`. It starts and ends where the element sits, so a run that is interrupted leaves nothing off its mark, and never give it a `repeat`.

## Examples

### distance

How far it travels at the widest point: a CSS length, or a number of pixels. `6` by default: this is a head shaken, not a thing thrown.

## Accessibility

- A reduced-motion preference cuts the shake to its last frame, where nothing has moved, so the shake is never the only thing carrying the message. Say it in words too: the `error` on the field is what a screen reader reads.
- Move the focus to the control that failed as well. A reader who is not looking at it has been told nothing by a movement.
