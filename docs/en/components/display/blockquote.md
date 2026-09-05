---
title: Blockquote
order: 9
---

# Blockquote

<p class="neba-lede">Presents a quotation set apart from your own prose. Given an attribution, it wraps the quote and its source in the correct semantic markup.</p>

<Demo src="blockquote/hero" />

```tsx
import { Blockquote } from 'neba';

<Blockquote>Perfection is achieved when there is nothing left to take away.</Blockquote>

<Blockquote author="Antoine de Saint-Exupéry" source="Terre des Hommes">
  Perfection is achieved when there is nothing left to take away.
</Blockquote>;
```

## Props

<PropsTable name="Blockquote" />

With no attribution it renders a single `<blockquote>`. Given either `author` or `source`, it wraps that in a `<figure>` and puts the attribution in a `<figcaption>`.

```html
<figure>
  <blockquote cite="…">…</blockquote>
  <figcaption>— Author, <cite>Source</cite></figcaption>
</figure>
```

`author` sits outside the `<cite>`, since `<cite>` is the element for the title of a work.

## Examples

### variant

`text` is the default: a single rule in the margin, sized to sit inside running prose. `outline` and `solid` draw a sheet, for a quote that is the point of the section.

<Demo src="blockquote/variants">

<<< @/.vitepress/demos/blockquote/variants.tsx

</Demo>

### author and source

Pass `author` on its own, `source` on its own, or both. `cite` is the URL of the document the quote came from and lands on the `<blockquote>`'s `cite` attribute: it never appears on screen, only machines read it.

<Demo src="blockquote/attribution">

<<< @/.vitepress/demos/blockquote/attribution.tsx

</Demo>

### color

The quote's background is never dyed. `color` applies to the margin rule and the quotation mark only.

<Demo src="blockquote/colors">

<<< @/.vitepress/demos/blockquote/colors.tsx

</Demo>

### icon

`icon` behaves three ways: omit it for the default quotation glyph, pass a node to replace it, pass `false` to draw none.

```tsx
<Blockquote>Default quotation mark</Blockquote>
<Blockquote icon={<QuoteIcon />}>A glyph of your own</Blockquote>
<Blockquote icon={false}>No glyph</Blockquote>
```
