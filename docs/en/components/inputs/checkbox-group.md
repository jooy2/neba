---
title: CheckboxGroup
order: 5
---

# CheckboxGroup

<p class="neba-lede">A set of checkboxes that answer one question, any number of them at once. The group holds one value for the whole set, names it with a label, and can add a checkbox that ticks every option.</p>

<Demo src="checkbox-group/hero" />

```tsx
import { Checkbox, CheckboxGroup } from 'neba';

<CheckboxGroup label="Email me about" defaultValue={['deploys']}>
  <Checkbox value="deploys" label="Failed deploys" />
  <Checkbox value="digest" label="The weekly digest" />
</CheckboxGroup>;
```

## Props

<PropsTable name="CheckboxGroup" />

The value is an array of the ticked checkboxes' `value`s, so every [Checkbox](./checkbox) inside needs a `value`. `value` with `onValueChange` makes the group controlled; `defaultValue` makes it uncontrolled. `size`, `color` and `readOnly` reach every Checkbox that does not set its own, and `disabled` and an invalid state reach all of them. See [prop conventions](../../design/prop-conventions) for the shared axes.

For exactly one answer, use [RadioGroup](./radio-group).

## Examples

### allValues · parent

`allValues` names every option, and the Checkbox with `parent` ticks or clears all of them at once. It draws itself indeterminate while only some are ticked, and it is not submitted with the form.

<Demo src="checkbox-group/parent">

<<< @/.vitepress/demos/checkbox-group/parent.tsx

</Demo>

### orientation

`vertical` by default. Use `horizontal` only with short labels: one long label makes the row hard to read.

<Demo src="checkbox-group/orientation">

<<< @/.vitepress/demos/checkbox-group/orientation.tsx

</Demo>

### spacing

The gap between the checkboxes, on Tailwind's spacing scale: `4` is `1rem`. A horizontal group that wraps puts its lines the same distance apart. Left out, the gaps are RadioGroup's: `2` (`0.5rem`) in a column, and `5` along a row with `2` between lines. The `spacing` in a [NebaProvider](../../guide/provider)'s `defaults` does not reach it, because that is the gap between separate fields.

<Demo src="checkbox-group/spacing">

<<< @/.vitepress/demos/checkbox-group/spacing.tsx

</Demo>

### disabled · readOnly · error

`disabled` and `readOnly` can be set on the group or on one Checkbox. On the group, they reach every option. `error` is shown under the set and turns every Checkbox in it to the `danger` family.

<Demo src="checkbox-group/states">

<<< @/.vitepress/demos/checkbox-group/states.tsx

</Demo>

### name

The ticked values are submitted under the group's `name`, one entry per ticked checkbox. A [Form](./form)'s `onSubmit` is handed them as an array, and an entry in its `errors` under the same name is shown under the set.

```tsx
<Form onSubmit={(values) => save(values.alerts)}>
  <CheckboxGroup name="alerts" label="Email me about">
    <Checkbox value="deploys" label="Failed deploys" />
    <Checkbox value="digest" label="The weekly digest" />
  </CheckboxGroup>
</Form>
```

## Accessibility

- The set is a `role="group"` named by `label` and described by `description`.
- Each Checkbox keeps its own label and is its own tab stop, as a checkbox in a set always is.
- A parent checkbox reports `aria-checked="mixed"` while only some of the options are ticked.
