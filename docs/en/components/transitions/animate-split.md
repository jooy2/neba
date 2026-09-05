---
title: AnimateSplit
order: 9
---

# AnimateSplit

<p class="neba-lede">A line of text arriving a word (or a letter) at a time. AnimateAppear walks down a list a child at a time; this walks along a sentence.</p>

<Demo src="animate-split/hero" minHeight="140" />

```tsx
import { AnimateSplit } from 'neba';

<AnimateSplit render={<h1 />}>A line arriving a word at a time</AnimateSplit>;
```

## Props

<PropsTable name="AnimateSplit" />

Every other `<div>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Only text is split. Pass a string, or `text`; an element among the children contributes its words and nothing about its markup, because there is no honest way to animate half of a link.

Every piece is an `inline-block` (an inline box cannot be translated up), and each keeps the space that followed it, so a line still breaks between words and never inside the gap.

## Examples

### by and effect

`by` is what one piece is: `word` by default, because a heading of eight words is eight boxes and the same heading by character is forty-six. `effect` is which animation each piece arrives on, in the library's own vocabulary, so a split heading's fade and an [AnimateFade](./animate-fade) are the same fade.

<Demo src="animate-split/by" minHeight="280">

<<< @/.vitepress/demos/animate-split/by.tsx

</Demo>

### stagger

`stagger` is how long after one piece the next one starts, and it is what the effect is made of: `45` milliseconds by default. `durationStep` lengthens each successive piece and `reverse` runs the line from the end.

### locale

Which language the text is in, for finding the boundaries. A word boundary is not a space in Japanese, Thai or Chinese, and splitting those on whitespace produces one piece holding the whole sentence.

## Accessibility

- The whole line is in the document once for a screen reader, in a clipped box, and the pieces are hidden from it. Without that a sentence is read as a list of forty-six separate letters and a find-in-page matches nothing.
- A reduced-motion preference switches the animation off and the line is drawn whole.
