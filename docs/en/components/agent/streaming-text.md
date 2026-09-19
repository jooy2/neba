---
title: StreamingText
order: 8
---

# StreamingText

<p class="neba-lede">Text arriving from somewhere else, a piece at a time. It holds its height before the first word lands, fades each word in as it arrives, and keeps a caret at the end until the stream stops.</p>

<Demo src="streaming-text/hero" />

```tsx
import { StreamingText } from 'neba';

<StreamingText streaming={pending} lines={4}>
  {answer}
</StreamingText>;
```

## Props

<PropsTable name="StreamingText" />

Native `<div>` attributes pass through to the root. Only `color` is excluded, since the table above spells it differently.

[AnimateTyping](../transitions/animate-typing) types out a string it already has: it knows the ending and is spending time on the way there. This is the opposite direction — the string is being handed over a piece at a time, nobody knows how long it will be, and the job is to make that land without the page moving under whoever is reading it.

**There is no `size`.** What this draws is the caller's own text inside the caller's own block — a bubble, a card, a paragraph — and the size of that text is the block's. The caret is sized in `em`, so it tracks it.

## Examples

### lines

How many lines of height to hold before anything has arrived. It is `1lh`, which is the line height the block actually has rather than a guess at one.

The reservation is a floor and stays a floor once the text is there. A height that is given up on arrival is the same jump twice, one out and one back.

<Demo src="streaming-text/reserve">

<<< @/.vitepress/demos/streaming-text/reserve.tsx

</Demo>

### fade

Each word fades in on its own, in `opacity` and nothing else. It is not a flourish: a transition on the block as a whole would replay the _entire_ answer every time a token landed.

It needs no bookkeeping. Words are keyed by position, so a word already on screen keeps its element and never animates a second time, and the last word grows a character at a time inside the element it already has. What it costs is one element per word, which is the case for turning it off on a very long answer.

Only a **string** is cut into words. Anything else is rendered untouched, with the caret and the reserved height still around it.

### cursor

The block at the end, drawn while `streaming`. `false` drops it and a node replaces it — a ring for an answer waiting on a tool, a set of dots, a word.

<Demo src="streaming-text/cursor">

<<< @/.vitepress/demos/streaming-text/cursor.tsx

</Demo>

### Line breaks survive

The block is `white-space: pre-wrap`, so the answer's own line breaks are the ones that render. Collapsing them turns a list into a paragraph.

## Accessibility

- The root carries `aria-busy` while the stream runs, and `data-streaming` for styling.
- It is deliberately **not** a live region. An answer announced token by token would be unusable, and one announced whole on every token would say the beginning again and again. Announcing a finished answer is the application's decision, because only the application knows whether the reader asked for this one.
- The caret is `aria-hidden`.
