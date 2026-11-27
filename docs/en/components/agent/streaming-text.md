---
title: StreamingText
order: 8
flutter: true
---

# StreamingText

<p class="neba-lede">Text arriving from somewhere else, a piece at a time. It holds its height before the first word lands, fades each word in as it arrives, and keeps a caret at the end until the stream stops.</p>

<Demo src="streaming-text/hero" />

::: fw react

```tsx
import { StreamingText } from 'neba';

<StreamingText streaming={pending} lines={4}>
  {answer}
</StreamingText>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaStreamingText(streaming: pending, lines: 4, child: Text(answer));
```

:::

## Props

<PropsTable name="StreamingText" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` is excluded, since the table above spells it differently.

:::

::: fw flutter

The text is a `Text` handed over as `child`, whose style, alignment and wrapping are kept. `showCursor: false` is React's `cursor={false}`. There is no `render`: the block is the `Text` itself.

:::

[AnimateTyping](../transitions/animate-typing) types out a string it already has: it knows the ending and is spending time on the way there. This is the opposite direction — the string is being handed over a piece at a time, nobody knows how long it will be, and the job is to make that land without the page moving under whoever is reading it.

**There is no `size`.** What this draws is the caller's own text inside the caller's own block — a bubble, a card, a paragraph — and the size of that text is the block's. The caret is sized in `em`, so it tracks it.

## Examples

### lines

::: fw react

How many lines of height to hold before anything has arrived. It is `1lh`, which is the line height the block actually has rather than a guess at one.

:::

::: fw flutter

How many lines of height to hold before anything has arrived, measured in the line height of the text's own style rather than a guess at one.

:::

The reservation is a floor and stays a floor once the text is there. A height that is given up on arrival is the same jump twice, one out and one back.

<Demo src="streaming-text/reserve">

::: fw react

<<< @/.vitepress/demos/streaming-text/reserve.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/streaming_text/reserve.dart

:::

</Demo>

### fade

Each word that arrives during a stream fades in on its own, in `opacity` and nothing else.

::: fw react

A word already on screen never fades a second time. Each streamed word is an element of its own while the stream runs, so turn `fade` off for a very long answer. Once `streaming` is off and the last word has faded in, the answer is drawn as plain text again, with no element per word.

Text that is not arriving is drawn as plain text, with no element per word and no fade: what the block is drawn with while `streaming` is off, such as a message loaded from history, what the server rendered, and what was already on screen when a stream started. Words that land in the same render that turns `streaming` off still fade.

Only a **string** is cut into words. Anything else is rendered untouched, with the caret and the reserved height still around it. Words are cut at whitespace, and a run in a script written without spaces, such as Japanese, Chinese or Thai, is cut again with `Intl.Segmenter`. A browser without it (Firefox before 125) fades such a run in as one piece.

:::

::: fw flutter

A word already on screen never fades a second time, and a word whose fade is over joins the plain text in front of it, so only the words still arriving are drawn as pieces of their own.

Text that is not arriving is drawn as plain text, with no fade: what the block is first built with while `streaming` is off, such as a message loaded from history, and what was already on screen when a stream started. Words that land in the same build that turns `streaming` off still fade. Under reduced motion every word lands at once.

Only a plain **`Text`** is cut into words. Any other widget is drawn untouched, with the caret and the reserved height still around it. Words are cut at whitespace, and a run in a script written without spaces, such as Japanese, Chinese or Thai, fades in a character at a time, since the widgets layer has no word segmenter.

:::

### cursor

The block at the end, drawn while `streaming`. <Fw react="false" flutter="showCursor: false" code /> drops it and <Fw react="a node" flutter="a widget" /> replaces it — a ring for an answer waiting on a tool, a set of dots, a word.

<Demo src="streaming-text/cursor">

::: fw react

<<< @/.vitepress/demos/streaming-text/cursor.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/streaming_text/cursor.dart

:::

</Demo>

### Line breaks

<Fw react="The block is white-space: pre-wrap, so the line breaks" flutter="The text keeps its own line breaks, so the ones" /> in the text are drawn as they are.

## Accessibility

::: fw react

- The root carries `aria-busy` while the stream runs, and `data-streaming` for styling.
- It is deliberately **not** a live region. An answer announced token by token would be unusable, and one announced whole on every token would say the beginning again and again. Announcing a finished answer is the application's decision, because only the application knows whether the reader asked for this one.
- The caret is `aria-hidden`.

:::

::: fw flutter

- It is deliberately **not** a live region. An answer announced token by token would be unusable, and one announced whole on every token would say the beginning again and again. Announcing a finished answer is the application's decision, because only the application knows whether the reader asked for this one.
- The caret is drawn and not read, and the text is read whole, however many pieces it is drawn in.

:::
