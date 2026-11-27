---
title: Fieldset
order: 28
flutter: true
---

# Fieldset

<p class="neba-lede">A group of controls that answer one question together, with a name on it. It groups the controls without drawing a surface of its own.</p>

<Demo src="fieldset/hero" />

::: fw react

```tsx
import { Fieldset, TextField } from 'neba';

<Fieldset legend="Billing address" description="Where the card statement goes.">
  <TextField label="Street" name="street" />
  <TextField label="City" name="city" />
</Fieldset>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaFieldset(
  legend: Text('Billing address'),
  description: Text('Where the card statement goes.'),
  children: <Widget>[
    NebaTextField(label: Text('Street')),
    NebaTextField(label: Text('City')),
  ],
);
```

:::

## Props

<PropsTable name="Fieldset" />

::: fw react

Every native `<fieldset>` attribute passes through, apart from `color`. The browser's own border, padding and margin are cleared: for a surface, put this inside a [Card](../surfaces/card) or a [Box](../surfaces/box).

:::

::: fw flutter

`legend` and `description` are widgets, usually a `Text`. The controls are its `children`, laid out one under the other and stretched to its width, as a column of fields in a form is. It draws nothing but the legend: for a surface, put it inside a [Card](../surfaces/card) or a [Box](../surfaces/box). `semanticLabel` names a group whose legend is not a `Text`.

:::

## Examples

### legend · description

The legend becomes the accessible name of <Fw react="every control inside" flutter="the group" />, so it has to be a phrase that still reads correctly in front of each of them: "Billing address", not "Where should we send it?". `description` is a line under it.

### disabled

::: fw react

The one thing only a real `<fieldset>` can do: it reaches every control inside, including ones a component three levels down rendered and never heard of it. The field components — TextField, NumberField, OtpField, Select, Combobox, Checkbox, RadioGroup, Switch and the date and time pickers — also draw themselves disabled inside it.

:::

::: fw flutter

It reaches every Neba control inside, including ones a widget three levels down built and never heard of it, and wins over a control's own `disabled`. TextField, NumberField, OtpField, Select, Combobox, DatePicker, TreeSelect, FilePicker, Checkbox, CheckboxGroup, RadioGroup, Switch, Slider, Rating, SegmentedButton, Toggle, ToggleGroup, [Button](./button) and IconButton are each drawn disabled inside it and take no input. A widget from outside the library does not hear it, since a widget tree has no `<fieldset>` to stop it.

:::

<Demo src="fieldset/disabled">

::: fw react

<<< @/.vitepress/demos/fieldset/disabled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/disabled.dart

:::

</Demo>

### size

`size` is the type scale of the legend and, unless `spacing` is given, the gap the controls stand at. It does not reach the controls themselves: a group of `sm` fields is written as `sm` fields.

<Demo src="fieldset/sizes">

::: fw react

<<< @/.vitepress/demos/fieldset/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/sizes.dart

:::

</Demo>

### spacing

The gap between the controls as an exact length, on <Fw react="Tailwind's spacing scale: `6` is `1.5rem`" flutter="the spacing scale: `6` is 24 logical pixels" />. The legend keeps the type scale `size` gives it. A `spacing` in a [NebaProvider](../../guide/provider)'s `defaults` reaches every Fieldset and [Form](./form) at once. For a column of checkboxes, use a [CheckboxGroup](./checkbox-group) instead: it gives the set one value, a label and an error of its own.

<Demo src="fieldset/spacing">

::: fw react

<<< @/.vitepress/demos/fieldset/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/spacing.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a real `<fieldset>` with `role="group"`, named by the legend through `aria-labelledby` and described by `description` through `aria-describedby`.
- A screen reader reads the legend before each control inside, which is why the legend is written as a phrase rather than a question.

:::

::: fw flutter

- Builds one semantics node around the controls, named by a `Text` legend and described by a `Text` description, with each control a node of its own inside it.
- A screen reader hears the legend as it reaches the group, which is why the legend is written as a phrase rather than a question.

:::
