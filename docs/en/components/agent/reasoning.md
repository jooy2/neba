---
title: Reasoning
order: 3
---

# Reasoning

<p class="neba-lede">A thinking panel that the stream opens and closes. It fills while the model is working, folds itself away when the working stops, and leaves one line saying that it happened and how long it took.</p>

<Demo src="reasoning/hero" />

```tsx
import { Reasoning } from 'neba';

<Reasoning streaming={thinking}>{thoughts}</Reasoning>;
```

## Props

<PropsTable name="Reasoning" />

Native `<div>` attributes pass through to the root. `color` and `onChange` are excluded, since the table above spells them differently.

A [Spoiler](../surfaces/spoiler) and a [Collapsible](../surfaces/collapsible) are the other two folds in the library, and on both of them the reader owns the open state: they covered it, they uncover it. Here the stream owns it.

## Examples

### streaming

The one prop that drives the rest. While it is true the header says so, the mark turns, the root carries `data-streaming` and `aria-busy`, and the panel is open. When it goes false the panel folds away and the header becomes a summary.

A Reasoning that _mounts_ while `streaming` is already true starts open: there is no edge coming to open it, and a panel that stayed shut would hide the one thing arriving on the screen.

<Demo src="reasoning/streaming">

<<< @/.vitepress/demos/reasoning/streaming.tsx

</Demo>

### duration

Milliseconds, and the header reads "Thought for 4.2s". Leave it out and the panel counts its own from the moment `streaming` went true, keeping the last figure once it stops — the count ticks once a second, so a stretch shorter than that never gets a number and the header says "Finished thinking" instead.

### autoOpen

On. Turning it off keeps the header's sentence and the mark and leaves the panel exactly where the reader put it, which is what a page wants when the thinking is the content rather than an aside.

The panel follows the _edges_ of `streaming` rather than its value either way, so a reader who folds it away mid-stream is not overruled on the next token. Passing `open` turns all of it off: a controlled Reasoning is where its caller says it is.

### variant

`text` is the default here and nowhere else in the library. Thinking is an aside, and a bordered box around every aside in a conversation is a conversation made of boxes. Reach for a sheet when the panel is the only thing on the screen.

<Demo src="reasoning/variant">

<<< @/.vitepress/demos/reasoning/variant.tsx

</Demo>

## Accessibility

- The header is a real button, wired to the panel with `aria-expanded` and `aria-controls` by Base UI.
- The root carries `aria-busy` while the stream runs.
- The panel is deliberately **not** a live region. Thinking is long and is revised as it arrives, and a screen reader reading every revision aloud would bury the answer it is on the way to.
