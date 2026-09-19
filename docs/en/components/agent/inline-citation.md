---
title: InlineCitation
order: 7
---

# InlineCitation

<p class="neba-lede">A numbered footnote in the body of an answer, with the source behind it a hover away. The mark is the same square a Sources row draws, so a reader who sees 2 in a sentence finds 2 in the list underneath.</p>

<Demo src="inline-citation/hero" />

```tsx
import { InlineCitation } from 'neba';

<InlineCitation index={1} title="The design language" site="neba.cdget.com" href="/design" />;
```

## Props

<PropsTable name="InlineCitation" />

Native `<a>` attributes pass through to the mark. `color`, `title` and `children` are excluded, since the table above spells them differently.

## Examples

### index

The caller's number, not one counted here. A citation sits inside a paragraph and the list it points at is somewhere else on the page, so there is no parent that could number it — and a component that numbered itself by render order would renumber the whole answer whenever a sentence moved.

It is also the only thing the mark itself says, which is why the accessible name is the sentence "Source 2" rather than the digit.

### preview

On, and drawn by [HoverCard](../surfaces/hover-card), so it opens on focus as well as on hover and the gap between the mark and the card is crossable. It needs a `title`: a citation with nothing to preview is a bare link, and turning the card on for it would be an empty box that opens under the pointer.

<Demo src="inline-citation/preview">

<<< @/.vitepress/demos/inline-citation/preview.tsx

</Demo>

### href

A real link, with the same scheme check a [Sources](./sources) row makes: anything outside `http`, `https`, `mailto` and `tel` leaves the mark as plain text rather than writing the URL out. A `target` that leaves the tab gains `rel="noopener noreferrer"`.

### color · size

The mark is sized in `em` and takes its tint from `color`, so it tracks whatever sentence it interrupts at whatever scale that sentence is set. `size` is the preview's type scale and not the mark's.

It is deliberately not a `<sup>`. A superscript would shrink the number a second time on top of the `0.8em` the mark already is, and a digit in a tinted box at that size is a smudge rather than something a reader can act on.

<Demo src="inline-citation/color">

<<< @/.vitepress/demos/inline-citation/color.tsx

</Demo>

## Accessibility

- The mark carries an accessible name in words — "Source 2" — because a digit on its own tells a screen reader nothing about what it is for.
- The preview is Base UI's hover card, so it opens on keyboard focus and not only under a pointer.
