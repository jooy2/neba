---
title: AnimateTyping
order: 9
---

# AnimateTyping

<p class="neba-lede">Text appearing one character at a time. The whole string is in the document from the first frame for a screen reader, and what animates is a copy that is hidden from one.</p>

<Demo src="animate-typing/hero" />

```tsx
import { AnimateTyping } from 'neba';

<AnimateTyping speed={18}>Ship the interface, not the design system.</AnimateTyping>;
```

## Props

<PropsTable name="AnimateTyping" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Only text is typed. Pass a string, or strings; an element among the children contributes its text and nothing about its markup, because there is no honest way to reveal half of a link. `text` is the same thing as a prop, and wins when both are given.

## Examples

### speed

Characters per second. A speed rather than a duration, because a long line and a short one should be typed at the same pace rather than in the same time: though `duration` is still accepted, and means the time for the whole string.

<Demo src="animate-typing/speed">

<<< @/.vitepress/demos/animate-typing/speed.tsx

</Demo>

### repeat, hold and erase

`repeat` is how many passes it makes and `hold` is how long the finished text stays up between them. Without `erase` a repeat clears in one frame, which is right for a line being replaced; with it the text is deleted a character at a time, at `eraseSpeed`: twice `speed` by default, which is what a person actually does.

<Demo src="animate-typing/loop">

<<< @/.vitepress/demos/animate-typing/loop.tsx

</Demo>

### delay

Milliseconds before it starts. A delay per line is what turns a stack of typewriters into a transcript.

<Demo src="animate-typing/terminal">

<<< @/.vitepress/demos/animate-typing/terminal.tsx

</Demo>

### caret

The block after the text, on by default. `caretChar` is what it is drawn as: `▌`, `_`, anything.

```tsx
<AnimateTyping caretChar="▌" caret={false}>
  No caret at all
</AnimateTyping>
```

## Accessibility

- The full text is in the document from the first frame, in a clipped box, and the animated copy is `aria-hidden`. A screen reader reads the line once and is not made to sit through the performance.
- A reduced-motion preference shows the whole string immediately, with no typing at all.
- The box is not laid out from the characters that have arrived, so the text around it does not reflow on every frame.
- Characters are counted as graphemes, not code points: `한` and `👩‍👩‍👧` each arrive in one step rather than in three or seven.
