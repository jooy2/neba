---
title: AnimateSplit
order: 9
flutter: true
---

# AnimateSplit

<p class="neba-lede">A line of text arriving a word (or a letter) at a time. AnimateAppear walks down a list a child at a time; this walks along a sentence.</p>

<Demo src="animate-split/hero" minHeight="140" />

::: fw react

```tsx
import { AnimateSplit } from 'neba';

<AnimateSplit render={<h1 />}>A line arriving a word at a time</AnimateSplit>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateSplit(text: 'A line arriving a word at a time');
```

:::

## Props

<PropsTable name="AnimateSplit" />

::: fw react

Every other `<span>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Only text is split. Pass a string, or `text`; an element among the children contributes its words and nothing about its markup, because there is no honest way to animate half of a link.

Every piece is an `inline-block` (an inline box cannot be translated up), and each keeps the space that followed it, so a line still breaks between words and never inside the gap. Split by character, the pieces of each word are held together, so a word is never broken across two lines.

:::

::: fw flutter

It takes the line as `text`, set in `style` over the `DefaultTextStyle` around it and aligned by `textAlign`. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Every piece is a widget inline in one paragraph, on the line's baseline, and the whitespace between words stays text, so the line breaks between words where the same text would and never inside a gap. Split by character, the letters of each word are held together, so a word is never broken across two lines. `distance` is in logical pixels, and four tenths of the font size when it is left out.

:::

## Examples

### by and effect

`by` is what one piece is: <Fw react="`word`" flutter="`NebaSplitBy.word`" /> by default, because a heading of eight words is eight boxes and the same heading by character is forty-six. `effect` is which animation each piece arrives on, in the library's own vocabulary, so a split heading's fade and an [AnimateFade](./animate-fade) are the same fade.

<Demo src="animate-split/by" minHeight="280">

::: fw react

<<< @/.vitepress/demos/animate-split/by.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/by.dart

:::

</Demo>

### stagger

`stagger` is how long after one piece the next one starts, and it is what the effect is made of: <Fw react="`45` milliseconds" flutter="`Duration(milliseconds: 45)`" /> by default. `durationStep` lengthens each successive piece and `reverse` runs the line from the end.

### locale

::: fw react

Which language the text is in, for finding the boundaries. A word boundary is not a space in Japanese, Thai or Chinese, and splitting those on whitespace produces one piece holding the whole sentence.

Browsers do not agree on those boundaries, so on a server-rendered page the server and the browser's first render cut the line by a rule every browser shares, and the line is cut by `locale` once the page has hydrated. For a line of words separated by spaces the two cuts are the same; a line in Japanese or Thai starts with a piece per character and its pieces are joined into words after hydration.

:::

::: fw flutter

There is no `locale`. Dart has no word or character segmenter of its own, so the line is always cut by the rule the React package uses before a page hydrates, the same on every platform: a word ends at a space or at punctuation after it, and a script written without spaces, such as Japanese, Chinese or Thai, is a piece per character.

:::

## Accessibility

- <Fw react="The whole line is in the document once for a screen reader, in a clipped box, and the pieces are hidden from it." flutter="A screen reader is told the whole line once, and the pieces are left out of the semantics tree." /> Without that a sentence is read as a list of forty-six separate letters<Fw react=" and a find-in-page matches nothing" />.
- <Fw react="The pieces are drawn rather than written into the document, so the element's text is the sentence once, with its spaces: what a search engine reads, what a copy picks up and what `textContent` returns." flutter="Characters are counted as a reader counts them, so `한` and `e` with its accent are one piece each rather than two." />
- A reduced-motion preference cuts the animation to its last frame, and the line is drawn whole.
