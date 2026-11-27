---
title: Highlight
order: 11
flutter: true
---

# Highlight

<p class="neba-lede">Marks the parts of a text that match a search query. Use it to show what matched in a list of search results or a filtered list.</p>

<Demo src="highlight/hero" />

::: fw react

```tsx
import { Highlight } from 'neba';

<Highlight query="acrylic">A sheet of cut acrylic.</Highlight>
<Highlight query={['data', 'database']} variant="text" color="primary">…</Highlight>
<Highlight query="Neba" caseSensitive>…</Highlight>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaHighlight(query: 'acrylic', child: Text('A sheet of cut acrylic.'));
const NebaHighlight.terms(
  query: <String>['data', 'database'],
  variant: NebaVariant.text,
  color: NebaColor.primary,
  child: Text('…'),
);
const NebaHighlight(query: 'Neba', caseSensitive: true, child: Text('…'));
```

:::

## Props

<PropsTable name="Highlight" />

::: fw react

Pass whatever the search box holds straight into `query`: a string, an array of strings, or a regular expression. There is no need to pre-compute match offsets. The component holds no state, so the marks update when `children` or `query` changes.

:::

::: fw flutter

Pass whatever the search box holds straight into `query`. The constructor says what it is: `NebaHighlight` takes one string, `NebaHighlight.terms` a list of them, and `NebaHighlight.pattern` a `RegExp`. There is no need to pre-compute match offsets. The widget holds no state, so the marks update when `child` or `query` changes. A mark's surface is drawn behind its word a hair wider than it, so the text around it does not move.

:::

There is no `size`: a mark sits inside running text and takes the surrounding type size.

## Examples

### variant · underline · weight

`variant` is the weight of the mark. `solid` fills it like a highlighter pen, `outline` draws a hairline around the word, `text` changes the colour alone. `underline` and `weight` are separate axes that combine with all three.

`color` defaults to `warning`, the one family whose fill is light with dark ink on it, so `solid` reads as a yellow highlighter. Any other family becomes white text on a block of colour.

<Demo src="highlight/variants">

::: fw react

<<< @/.vitepress/demos/highlight/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/variants.dart

:::

</Demo>

### caseSensitive and wholeWord

`caseSensitive` respects case; `wholeWord` matches only at word boundaries. A word here is a run of letters, digits and underscores, so it does very little for Korean or Japanese, where phrases are not delimited by spaces: which is why it is off by default.

A string `query` ignores accents, so `jose` marks `José`, which is what a DataTable's search finds for it. <Fw react="A RegExp is matched as written." flutter="That holds for Latin, Greek and Cyrillic letters; other scripts are matched as written. A `RegExp` is matched as written." />

<Fw react="An array of strings" flutter="A list of terms" /> is tried **longest first**: matching `['data', 'database']` shortest-first would mark `data` and leave `base` outside the mark.

<Demo src="highlight/matching">

::: fw react

<<< @/.vitepress/demos/highlight/matching.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/matching.dart

:::

</Demo>

### Text inside nested elements

::: fw react

`children` does not have to be a string. The React tree is walked into: text nodes are marked and every other element is left exactly as it was.

:::

::: fw flutter

`child` can be a `Text`, a `Text.rich` or a `NebaTypography`. Its spans are walked into: a match inside a styled span is marked and keeps the span's style and gestures, and a widget inside the text is left exactly as it was.

:::

<Demo src="highlight/nested">

::: fw react

<<< @/.vitepress/demos/highlight/nested.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/nested.dart

:::

</Demo>

## Accessibility

::: fw react

- Marks render as real `<mark>` elements, which carry the meaning "text of relevance to the reader". Marking too many words in one paragraph dilutes that meaning.
- A `<mark>` arrives from the browser's own stylesheet with a yellow background, which is why `variant="text"` sets `background` to `transparent` explicitly.

:::

::: fw flutter

- Flutter has no role for a mark, so a screen reader reads the text as it is, without saying which words are marked. Do not rely on the mark alone to say something the reader must know.

:::
