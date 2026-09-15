---
title: Accordion
order: 3
---

# Accordion

<p class="neba-lede">Stacks sections that fold open and shut. Use it to keep long content collapsed to its headings so only what is needed is expanded.</p>

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

`value` with `onValueChange` makes it controlled; `defaultValue` makes it uncontrolled. The value is an array of the open items' `value`s.

### AccordionItem

<PropsTable name="AccordionItem" />

## Examples

### variant

The sheet is never filled with colour. Use `text` inside a [Card](./card): the card is already a sheet, so the borders do not double up.

<Demo src="accordion/variants">

<<< @/.vitepress/demos/accordion/variants.tsx

</Demo>

### multiple · dividers · action

`multiple` is off by default, so opening one section closes the one that was open. Turn it on when the sections are a checklist rather than mutually exclusive answers.

`dividers` rules between the sections, binding them into one block. `action` is a control slot **outside** the folding button, so a header can carry a switch and still fold when pressed.

<Demo src="accordion/behaviour">

<<< @/.vitepress/demos/accordion/behaviour.tsx

</Demo>

### size

<Demo src="accordion/sizes">

<<< @/.vitepress/demos/accordion/sizes.tsx

</Demo>

### headingLevel · lines

`headingLevel` sets the heading level of every section's header, for the whole stack. Use `3` under an `<h2>` and `4` under an `<h3>`.

`lines` on a section cuts the title and the subtitle off after that many lines. Unset, both wrap.

```tsx
<Accordion headingLevel={2}>
  <AccordionItem lines={2} title="What happens to my data when I close my account?">
    …
  </AccordionItem>
</Accordion>
```

### hiddenUntilFound and keepMounted

`hiddenUntilFound` is on by default. A closed panel stays in the DOM as `hidden="until-found"`, so its answer is in a server render and a crawler's index, and the browser's find-on-page can locate it and open the section. Turn it off for panels that are expensive to build and only need to exist while open; `keepMounted` then keeps a closed panel's React tree alive without it being found.

## Accessibility

- The header button and its panel are wired together with `aria-controls` and `aria-expanded`.
- Each header is a real heading element, at `headingLevel` (`3` by default), so the sections are in the document outline. Pass plain text as `title`: a heading passed in would be nested inside that one.
