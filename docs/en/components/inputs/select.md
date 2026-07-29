---
title: Select
order: 4
---

# Select

<p class="neba-lede">Chooses one value from a fixed list. The trigger is the same shell as TextField, wearing a chevron.</p>

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

When the options have to be searched, use [Combobox](./combobox); with only two or three, use [RadioGroup](./radio-group) or [SegmentedButton](./segmented-button).

### items

Options are passed as an array rather than composed from components.

```ts
interface SelectOption {
  value: string | number;
  label?: React.ReactNode; // defaults to the value
  disabled?: boolean;
}
```

`value` is a string or a number. It is what gets submitted with a form, so objects are not accepted — keep the identifier here and look the object up at the call site.

## Examples

### variant

The same three weights a [TextField](./text-field) has, drawn on the same shell, so a select and the fields around it never disagree about height or border.

<Demo src="select/variants">

<<< @/.vitepress/demos/select/variants.tsx

</Demo>

### size

<Demo src="select/sizes">

<<< @/.vitepress/demos/select/sizes.tsx

</Demo>

### disabled · readOnly · error

<Demo src="select/states">

<<< @/.vitepress/demos/select/states.tsx

</Demo>

## The popup

The popup renders in a portal at the end of `<body>`, so it leaves any subtree your app scoped a CSS reset to. The positioner carries a `neba-portal` class to hang that reset off. An app with Tailwind's Preflight applied globally needs nothing.

## Accessibility

- The trigger has the `combobox` role, and `label` becomes its accessible name.
- The popup's positioning and flipping at the window edge, focus handling, typeahead and the hidden input for form submission are all handled.
- A `disabled` option stays in the list and reports `aria-disabled`.
