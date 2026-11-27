---
title: CheckboxGroup
order: 5
flutter: true
---

# CheckboxGroup

<p class="neba-lede">A set of checkboxes that answer one question, any number of them at once. The group holds one value for the whole set, names it with a label, and can add a checkbox that ticks every option.</p>

<Demo src="checkbox-group/hero" />

::: fw react

```tsx
import { Checkbox, CheckboxGroup } from 'neba';

<CheckboxGroup label="Email me about" defaultValue={['deploys']}>
  <Checkbox value="deploys" label="Failed deploys" />
  <Checkbox value="digest" label="The weekly digest" />
</CheckboxGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCheckboxGroup(
  label: Text('Email me about'),
  defaultValue: <String>['deploys'],
  children: <Widget>[
    NebaCheckbox(value: 'deploys', label: Text('Failed deploys')),
    NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
  ],
);
```

:::

## Props

<PropsTable name="CheckboxGroup" />

::: fw react

The value is an array of the ticked checkboxes' `value`s, so every [Checkbox](./checkbox) inside needs a `value`. `value` with `onValueChange` makes the group controlled; `defaultValue` makes it uncontrolled. `size`, `color` and `readOnly` reach every Checkbox that does not set its own, and `disabled` and an invalid state reach all of them. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

::: fw flutter

The value is a list of the ticked checkboxes' `value`s, so every [Checkbox](./checkbox) inside needs a `value`. `value` with `onValueChange` makes the group controlled; left `null`, the group keeps its own state from `defaultValue`. `size`, `color` and `readOnly` reach every Checkbox that does not set its own, and `disabled` and an invalid state reach all of them. A checkbox may sit anywhere below the group, inside a widget of the caller's. There is no `name`, because a Flutter group has no form submission to name its value for. See [prop conventions](../../design/prop-conventions) for the shared axes.

:::

For exactly one answer, use [RadioGroup](./radio-group).

## Examples

### allValues · parent

`allValues` names every option, and the Checkbox with `parent` ticks or clears all of them at once. It draws itself indeterminate while only some are ticked<Fw react=", and it is not submitted with the form" />.

<Demo src="checkbox-group/parent">

::: fw react

<<< @/.vitepress/demos/checkbox-group/parent.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/parent.dart

:::

</Demo>

### orientation

`vertical` by default. Use `horizontal` only with short labels: one long label makes the row hard to read.

<Demo src="checkbox-group/orientation">

::: fw react

<<< @/.vitepress/demos/checkbox-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/orientation.dart

:::

</Demo>

### spacing

::: fw react

The gap between the checkboxes, on Tailwind's spacing scale: `4` is `1rem`. A horizontal group that wraps puts its lines the same distance apart. Left out, the gaps are RadioGroup's: a column follows `size` on the same steps as a [Form](./form)'s fields, `3` (`0.75rem`) at `md`, and a row keeps `5` along it with the column's step between lines. The `spacing` in a [NebaProvider](../../guide/provider)'s `defaults` does not reach it, because that is the gap between separate fields.

:::

::: fw flutter

The gap between the checkboxes, on the spacing scale: `4` is 16 logical pixels. A horizontal group that wraps puts its lines the same distance apart. Left out, the gaps are RadioGroup's: a column follows `size`, 12 logical pixels at `md`, and a row keeps 20 along it with the column's step between lines. The `spacing` in a [NebaProvider](../../guide/provider)'s `defaults` does not reach it, because that is the gap between separate fields.

:::

<Demo src="checkbox-group/spacing">

::: fw react

<<< @/.vitepress/demos/checkbox-group/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/spacing.dart

:::

</Demo>

### disabled · readOnly · error

`disabled` and `readOnly` can be set on the group or on one Checkbox. On the group, they reach every option. `error` is shown under the set and turns every Checkbox in it to the `danger` family.

<Demo src="checkbox-group/states">

::: fw react

<<< @/.vitepress/demos/checkbox-group/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/states.dart

:::

</Demo>

### name

::: fw react

The ticked values are submitted under the group's `name`, one entry per ticked checkbox. A [Form](./form)'s `onSubmit` is handed them as an array, and an entry in its `errors` under the same name is shown under the set.

```tsx
<Form onSubmit={(values) => save(values.alerts)}>
  <CheckboxGroup name="alerts" label="Email me about">
    <Checkbox value="deploys" label="Failed deploys" />
    <Checkbox value="digest" label="The weekly digest" />
  </CheckboxGroup>
</Form>
```

:::

::: fw flutter

There is no form submission, so there is no name. The group's `onValueChange` hands over the list as it changes, and an `error` shows a message under the set.

```dart
NebaCheckboxGroup(
  label: const Text('Email me about'),
  value: alerts,
  onValueChange: (List<String> next) => setState(() => alerts = next),
  error: alerts.isEmpty ? const Text('Choose at least one.') : null,
  children: const <Widget>[
    NebaCheckbox(value: 'deploys', label: Text('Failed deploys')),
    NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
  ],
)
```

:::

## Accessibility

::: fw react

- The set is a `role="group"` named by `label` and described by `description`.
- Each Checkbox keeps its own label and is its own tab stop, as a checkbox in a set always is.
- A parent checkbox reports `aria-checked="mixed"` while only some of the options are ticked.

:::

::: fw flutter

- The set is a group a screen reader hears by its `Text` label, with a `Text` description and error read after it.
- Each Checkbox keeps its own label and is its own stop in the focus order, as a checkbox in a set always is.
- A parent checkbox is heard as mixed while only some of the options are ticked.

:::
