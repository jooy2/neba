---
title: Blockquote
order: 9
---

# Blockquote

<p class="neba-lede">Somebody else's words, set apart from your own. A component about markup before it is about surface.</p>

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

## The markup

A quote has no state, no keyboard contract and nothing to interact with. What it has is **markup that is easy to get wrong**, and getting it right is most of what this component is.

With no attribution it is a `<blockquote>` and nothing else. With one, the whole thing becomes:

```html
<figure>
  <blockquote cite="…">…</blockquote>
  <figcaption>— Author, <cite>Source</cite></figcaption>
</figure>
```

The HTML spec is explicit that the attribution goes **outside** the blockquote: a name inside it claims the speaker said their own name. And `<cite>` is the element for the title of a work rather than for the name of a person, so `author` sits outside it.

The `cite` prop is the URL of the document the quote came from, and lands on the `<blockquote>`'s own `cite` attribute. Nothing but a machine reads it; `source` is the part a reader sees.

## Examples

### Weight

`text` is the default, and a quote in running prose really is a rule in the margin and nothing else — that is what a quote looked like long before there were surfaces to put one on. The other two are for a quote that is the point of the section rather than an aside inside it.

<Demo src="blockquote/variants">

<<< @/.vitepress/demos/blockquote/variants.tsx

</Demo>

### Attribution

`author` on its own, `source` on its own, or both. Either one is enough to make it a `<figure>`.

<Demo src="blockquote/attribution">

<<< @/.vitepress/demos/blockquote/attribution.tsx

</Demo>

### Colour

The sheet is never dyed, for the reason [Box](../surfaces/box) and [List](./list) are not: a quote holds somebody else's words, and those words should not land on a background nobody chose them against. The family shows up in the rule and the mark.

<Demo src="blockquote/colors">

<<< @/.vitepress/demos/blockquote/colors.tsx

</Demo>

## The quotation mark is drawn

The default mark is a drawing rather than a typographic `“`. A real quote character is set in whatever face the page uses, so its shape, its weight and its baseline all change with it — and at 2em it is the largest single glyph in the component, so it changing is the most visible thing that could.

`icon` says three things with one prop: omit it for the house glyph, pass a node to replace it, pass `false` to take it away. [Alert](../feedback/alert) spells the same idea the same way.

## Nothing is drawn on the `<blockquote>`

The surface, the rule and the padding all belong to the element around it. That is not tidiness — it is specificity.

`blockquote` is one of the handful of tags a host stylesheet still styles by name. On this documentation site alone, VitePress's `.vp-doc blockquote` sets a grey `border-left`, a `padding-left` and a `color`, all at a specificity a one-class utility cannot outrank; a rule drawn on the quote itself would silently come out grey and a pixel too thin. Moving the drawing onto a wrapper is what lets the docs' `scope.css` undo VitePress's version without also undoing ours.

It is the same problem [Table](./table) solves by writing its cell styling inline, with the opposite answer. A table cell has to **beat** the host, so it went inline; a quote can **step out of** the argument, so it did.
