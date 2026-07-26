---
title: Combobox
order: 12
---

# Combobox

<p class="neba-lede">A field you can type into and also choose from. The text filters the list — and, unless you say otherwise, can become the value itself.</p>

<Demo src="combobox/hero" />

```tsx
import { Combobox } from 'neba';

<Combobox
  label="Framework"
  placeholder="Search or type your own"
  items={[
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue' }
  ]}
/>;
```

## Props

<PropsTable name="Combobox" />

### Options are data

The same shape [Select](./select) takes, with one difference:

```ts
interface ComboboxOption {
  value: string | number;
  label?: string; // a string, not a ReactNode
  disabled?: boolean;
}
```

`label` is a `string` here because the filter types against it and the input writes it out, and neither of those can be done to an element. Values stay strings and numbers — a combobox is a form control and its value is what gets submitted.

## Examples

### Multiple

The chosen values become [Chip](../display/chip)s inside the field, and the input goes on filtering after each one, so a set of tags is built without the field ever closing. Backspace on an empty input reaches back for the last chip.

<Demo src="combobox/multiple">

<<< @/.vitepress/demos/combobox/multiple.tsx

</Demo>

### A value the list does not have

This is what separates a combobox from a searchable select, and it is on by default.

The typed text is offered as its own row at the end of the list rather than committed quietly on blur. That is deliberate: a field that turns a half-finished word into a value the moment focus leaves is a field that invents data. Making it a row means Enter, a click and the arrow keys all reach it the way they reach every other row, and a screen reader announces it as one more option.

The first match lights up as you type, so it still takes one key: type something the list has and Enter picks it, type something it does not and Enter adds it.

Turn it off with `allowCustom={false}` for a field whose values are a closed set — then `emptyMessage` is what a fruitless search says.

<Demo src="combobox/custom">

<<< @/.vitepress/demos/combobox/custom.tsx

</Demo>

### Variants

The same three weights a [TextField](./text-field) has, drawn on the same shell.

<Demo src="combobox/variants">

<<< @/.vitepress/demos/combobox/variants.tsx

</Demo>

### Sizes

A chip inside the field sits one step down the control ladder, and the field's padding is what is left over — so a single-row combobox is exactly as tall as the field beside it. With `multiple` the field grows as the chips wrap; it never has a fixed height.

<Demo src="combobox/sizes">

<<< @/.vitepress/demos/combobox/sizes.tsx

</Demo>

### States

<Demo src="combobox/states">

<<< @/.vitepress/demos/combobox/states.tsx

</Demo>

## The popup

Identical to [Select](./select)'s, because a combobox's list and a select's list are the same list: a floating surface at elevation 3, portalled to the end of `<body>`, with `neba-portal` on the positioner as a hook for a host that scoped its CSS reset to a subtree.

## Accessibility

- Base UI owns the filtering and its collator, the popup's positioning and flipping, the `combobox`/`listbox` wiring, arrow-key navigation across both the list and the chips, and the hidden input that makes the field submit with a form.
- `label` becomes the accessible name.
- A disabled option stays in the list and reports `aria-disabled` — the option exists, it just cannot be picked.
- Each chip's remove button is named through `removeLabel`, which receives the chip's own label so the button says _Remove documentation_ rather than _Remove_.
