---
title: Highlight
order: 11
---

# Highlight

<p class="neba-lede">Marks the words a reader is looking for, inside text they were already reading.</p>

<Demo src="highlight/hero" />

```tsx
import { Highlight } from 'neba';

<Highlight query="acrylic">A sheet of cut acrylic.</Highlight>
<Highlight query={['data', 'database']} variant="text" color="primary">…</Highlight>
<Highlight query={/\d+/} caseSensitive>…</Highlight>;
```

## Props

<PropsTable name="Highlight" />

## It is the search, not the styling

`query` is what a search box holds, and everything about **how** the matching is done — case, whole words, a regular expression — is a prop rather than something a caller has to pre-compute into a list of offsets. Nothing here is stateful and nothing measures, so the whole component is a pure function of `children` and `query`: it re-marks on its own the moment the search box changes.

There is no `size`, and that is not an omission. A mark sits inside running text and has to be the size of the text it is inside; a `size` prop would only offer ways to be wrong.

## Examples

### What the mark looks like

`variant` means the weight of a surface here exactly as it does everywhere else: `solid` is the highlighter pen, `outline` a hairline box around the word, `text` the colour alone. `underline` and `weight` are separate axes that combine with all three.

`color` defaults to `warning` and not arbitrarily. It is the one family whose fill is light with dark ink on it — the [colour page](../../guide/color) shows why — so a solid `warning` mark reads as a yellow highlighter over black text. Every other family is a white word on a block of colour.

<Demo src="highlight/variants">

<<< @/.vitepress/demos/highlight/variants.tsx

</Demo>

### What counts as a match

<Demo src="highlight/matching">

<<< @/.vitepress/demos/highlight/matching.tsx

</Demo>

An array is tried **longest first**. Alternation in a regular expression is first-match-wins, so without it `['data', 'database']` would mark `data` and leave `base` outside the mark.

For `wholeWord`, a word is a run of letters, digits and underscores in any script. It does the right thing for `café` and `naïve`, and it means very little for Korean or Japanese, where a phrase is not delimited by spaces at all. That is a property of the writing system rather than of this prop, and is why it is off by default.

### Text inside elements

Most libraries require `children` to be a string, and that breaks on the first search result with a `<strong>` in it. Here the tree is walked into: the text is marked and everything else is left exactly as it was.

<Demo src="highlight/nested">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

## Accessibility

The mark is a real `<mark>`, which is the element for "text of relevance to the reader" and is announced as such. That has one consequence worth knowing: marking eleven words in a paragraph tells a screen reader that eleven things are important, which is a way of saying nothing. A highlight is for a handful of matches.

A `<mark>` also arrives from the browser's own stylesheet with a yellow background and black ink. That is why `variant="text"` still sets its background to `transparent` **explicitly** — "no surface" has to be said out loud, or it turns into the browser's surface.
