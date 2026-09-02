---
title: AnimateScramble
order: 9
---

# AnimateScramble

<p class="neba-lede">Text arriving through noise, one character at a time. AnimateTyping's sibling: a typewriter reveals a string from an empty line, this one resolves it out of a line that was already the right length.</p>

<Demo src="animate-scramble/hero" minHeight="120" />

```tsx
import { AnimateScramble } from 'neba';

<AnimateScramble text="RESOLVING SIGNAL" />;
```

## Props

<PropsTable name="AnimateScramble" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

The box never changes size, which is the whole reason to choose this over [AnimateTyping](./animate-typing): nothing around it reflows, and a heading does not push the page down as it lands.

Whitespace is never scrambled. A space that flickered into a letter and back would read as the words having moved, which is the one thing this effect exists to avoid.

## Examples

### speed, duration and tick

`speed` is how many characters settle per second; `duration` is the whole run and wins when it is given, so the per-character delay falls out of it rather than being asked for twice. `tick` is how often an unsettled character is redrawn — below about 30 milliseconds it stops reading as characters at all.

<Demo src="animate-scramble/pool" minHeight="240">

<<< @/.vitepress/demos/animate-scramble/pool.tsx

</Demo>

### characters

The pool an unsettled character is drawn from. Keep the glyphs one height: a pool with tall and short characters in it makes the line jump as it settles.

## Accessibility

- The finished string is in the document from the first frame, in a clipped box for a screen reader; the noise is a visible copy that is `aria-hidden`.
- A reduced-motion preference shows the text straight away.
- Do not scramble something a reader has to act on quickly. It is legible only at the end.
