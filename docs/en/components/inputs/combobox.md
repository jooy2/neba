---
title: Combobox
order: 12
---

# Combobox

<p class="neba-lede">A field that filters a list as you type. Use it when there are too many options for a Select, or when a value outside the list has to be accepted.</p>

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

### items

The same array shape [Select](./select) takes; only `label`'s type differs.

```ts
interface ComboboxOption {
  value: string | number;
  label?: string; // a string, not a ReactNode
  disabled?: boolean;
}
```

It has to be a `string` because the filter matches against it and the input writes it out.

## Examples

### multiple

Chosen values appear as [Chip](../display/chip)s inside the field, and the input goes on filtering after each one. Backspace on an empty input moves focus to the last chip.

<Demo src="combobox/multiple">

<<< @/.vitepress/demos/combobox/multiple.tsx

</Demo>

### allowCustom · customLabel · emptyMessage

`allowCustom` is on by default. The typed text is offered as its own row at the end of the list, so Enter, a click and the arrow keys all reach it the way they reach every other row. It is never committed quietly on blur.

Turn it off with `allowCustom={false}` for a closed set of values; then `emptyMessage` is shown when nothing matches.

<Demo src="combobox/custom">

<<< @/.vitepress/demos/combobox/custom.tsx

</Demo>

### variant

The same three weights a [TextField](./text-field) has, drawn on the same shell.

<Demo src="combobox/variants">

<<< @/.vitepress/demos/combobox/variants.tsx

</Demo>

### size

A single-select Combobox is exactly as tall as a [TextField](./text-field) of the same `size`. With `multiple` the field grows as the chips wrap, so it has no fixed height.

<Demo src="combobox/sizes">

<<< @/.vitepress/demos/combobox/sizes.tsx

</Demo>

### disabled · readOnly · error

<Demo src="combobox/states">

<<< @/.vitepress/demos/combobox/states.tsx

</Demo>

### clearable · limit

`clearable` adds a button that empties the value. `limit` caps how many items the popup shows at once.

## The popup

Identical to [Select](./select)'s: portalled to the end of `<body>`, with `neba-portal` on the positioner.

## Accessibility

- The trigger has the `combobox` role and the list the `listbox` role; `label` becomes the accessible name.
- Filtering, the popup's positioning and flipping, arrow-key navigation across both the list and the chips, and the hidden input for form submission are all handled.
- A `disabled` option stays in the list and reports `aria-disabled`.
- Each chip's remove button is named through `removeLabel`, which receives the chip's own label.
- `locale` decides the no-matches line and the names of the clear and remove buttons; `emptyMessage`, `clearLabel` and `removeLabel` write them out instead.
