---
title: Select
order: 4
---

# Select

<p class="neba-lede">One value chosen from a list. The trigger is a TextField's shell wearing a chevron — on purpose.</p>

<Demo src="select/hero" />

```tsx
import { Select } from 'neba';

<Select
  label="Region"
  placeholder="Pick a region"
  items={[
    { value: 'icn', label: 'Seoul' },
    { value: 'nrt', label: 'Tokyo' }
  ]}
/>;
```

## Props

<PropsTable name="Select" />

### Options are data

There is no `<Select.Option>` to compose. What a caller has is almost always an array already, and the list has to be available to the trigger _before_ the popup has ever been opened — that is how `Seoul` shows up for `value="icn"` on first paint.

```ts
interface SelectOption {
  value: string | number;
  label?: React.ReactNode; // defaults to the value
  disabled?: boolean;
}
```

Values are strings and numbers, not arbitrary objects. A select is a form control and its value is what gets submitted; keep the identifier here and look the object up on the other side.

## Examples

### Variants

The same three weights a [TextField](./text-field) has, drawn on the same shell. A form where the select is a different height, radius or colour from the fields around it is a form that looks assembled rather than designed.

<Demo src="select/variants">

<<< @/.vitepress/demos/select/variants.tsx

</Demo>

### Sizes

<Demo src="select/sizes">

<<< @/.vitepress/demos/select/sizes.tsx

</Demo>

### States

<Demo src="select/states">

<<< @/.vitepress/demos/select/states.tsx

</Demo>

## The popup

The popup is the one surface in the library that is _supposed_ to float, so unlike everything else it carries a shadow without being asked — at level 3, which is as far as the scale goes without hovering.

It renders in a portal, at the end of `<body>`, which means it leaves any subtree your app scoped a CSS reset to. The positioner carries a `neba-portal` class for exactly that case: it is a hook to hang the reset off, not a style of its own. An app with Tailwind's Preflight applied globally needs nothing.

## Accessibility

- Base UI owns the popup's positioning and flipping, the focus trap, typeahead and the hidden input that makes the select submit with a form.
- `label` becomes the accessible name; the trigger is a `combobox`.
- A disabled option stays in the list and reports `aria-disabled` — the option exists, it just cannot be picked.
