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

The sheet is never filled with colour. Use `text` inside a [Card](./card) — the card is already a sheet, so the borders do not double up.

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

### hiddenUntilFound and keepMounted

`hiddenUntilFound` keeps closed panels in the DOM so the browser's find-on-page can locate and open them — worth turning on for an FAQ. `keepMounted` keeps a closed panel's React tree alive.

## Accessibility

- The header button and its panel are wired together with `aria-controls` and `aria-expanded`.
- Pass a real heading as `title` to put the section in the document outline — `title={<h3>Billing</h3>}`. It inherits the Accordion's type scale.
- The panel opens by animating its `height`; the content does not shift inside the panel.
