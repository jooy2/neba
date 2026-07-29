---
title: Highlight
order: 11
---

# Highlight

<p class="neba-lede">Marks the parts of a text that match a search query. Use it to show what matched in a list of search results or a filtered list.</p>

<Demo src="highlight/hero" />

```tsx
import { Highlight } from 'neba';

<Highlight query="acrylic">A sheet of cut acrylic.</Highlight>
<Highlight query={['data', 'database']} variant="text" color="primary">…</Highlight>
<Highlight query={/\d+/} caseSensitive>…</Highlight>;
```

## Props

<PropsTable name="Highlight" />

Pass whatever the search box holds straight into `query` — a string, an array of strings, or a regular expression. There is no need to pre-compute match offsets. The component holds no state, so the marks update when `children` or `query` changes.

There is no `size`: a mark sits inside running text and takes the surrounding type size.

## Examples

### variant · underline · weight

`variant` is the weight of the mark. `solid` fills it like a highlighter pen, `outline` draws a hairline around the word, `text` changes the colour alone. `underline` and `weight` are separate axes that combine with all three.

`color` defaults to `warning`, the one family whose fill is light with dark ink on it, so `solid` reads as a yellow highlighter. Any other family becomes white text on a block of colour.

<Demo src="highlight/variants">

<<< @/.vitepress/demos/highlight/variants.tsx

</Demo>

### caseSensitive and wholeWord

`caseSensitive` respects case; `wholeWord` matches only at word boundaries. A word here is a run of letters, digits and underscores, so it does very little for Korean or Japanese, where phrases are not delimited by spaces — which is why it is off by default.

An array of strings is tried **longest first**: matching `['data', 'database']` shortest-first would mark `data` and leave `base` outside the mark.

<Demo src="highlight/matching">

<<< @/.vitepress/demos/highlight/matching.tsx

</Demo>

### Text inside nested elements

`children` does not have to be a string. The React tree is walked into: text nodes are marked and every other element is left exactly as it was.

<Demo src="highlight/nested">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

## Accessibility

- Marks render as real `<mark>` elements, which carry the meaning "text of relevance to the reader". Marking too many words in one paragraph dilutes that meaning.
- A `<mark>` arrives from the browser's own stylesheet with a yellow background, which is why `variant="text"` sets `background` to `transparent` explicitly.
