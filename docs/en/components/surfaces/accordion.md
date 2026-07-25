---
title: Accordion
order: 3
---

# Accordion

<p class="neba-lede">A stack of sections that fold. Opening one closes the last.</p>

<Demo src="accordion/hero" />

```tsx
import { Accordion, AccordionItem } from 'neba';

<Accordion defaultValue={['billing']}>
  <AccordionItem value="billing" title="How does billing work?" subtitle="Plans and invoices">
    You are charged on the first of each month.
  </AccordionItem>
  <AccordionItem value="regions" title="Where do builds run?">
    In the region closest to the default branch.
  </AccordionItem>
</Accordion>;
```

## Props

### Accordion

<PropsTable name="Accordion" />

### AccordionItem

<PropsTable name="AccordionItem" />

## Examples

### Variants

The sheet is never dyed — the same as [Box](./box) and [List](../display/list). A container holds other people's content, and that content arrives with its own colours. `text` is the one to reach for inside a card: the card is already a sheet, and a second bordered rectangle inside it is just a second rectangle.

<Demo src="accordion/variants">

<<< @/.vitepress/demos/accordion/variants.tsx

</Demo>

### multiple, dividers, and the control beside the header

<Demo src="accordion/behaviour">

<<< @/.vitepress/demos/accordion/behaviour.tsx

</Demo>

### Sizes

<Demo src="accordion/sizes">

<<< @/.vitepress/demos/accordion/sizes.tsx

</Demo>

## Why `multiple` is off by default

It is the whole difference between an accordion and a stack of collapsibles. Closing the last section as you open the next is what keeps the page from growing under the reader. Turn `multiple` on when the sections are a checklist rather than a set of mutually exclusive answers.

`dividers` takes the opposite default from [List](../display/list). A list of tiles is a list; an accordion of tiles is a stack of cards that happen to fold. The rule is what says the sections are parts of one thing.

## The height moves. Nothing is transformed

The panel's `height` is animated, which looks like an exception to the [rule against moving things](../../guide/design-language) and is not.

Nothing is transformed, no text is resampled, and the content does not shift relative to the panel it is in — the panel is a window opening onto it. An accordion whose sections appear instantly is a page that jumps, which is the failure the rule exists to prevent in the first place.

## A header is two things, not one

`action` sits **outside** the folding button. A header that both folds and holds a switch has two things to press, and one of them cannot be nested inside the other — a `<button>` inside a `<button>` is markup the browser rewrites on parse. It is the same shape [Chip](../display/chip) and [ListItem](../display/list) use.

## Accessibility

Base UI owns the `button` / `region` pairing and the `aria-controls` / `aria-expanded` wiring between them. What is left to decide is whether `title` should be a real heading — for a section that belongs in the document outline, pass `title={<h3>Billing</h3>}`. `.neba-title` strips the browser's own size and margins, so the type scale holds.

`hiddenUntilFound` keeps closed panels in the DOM so the browser's own find-on-page can locate and open them. Worth turning on for an FAQ.
