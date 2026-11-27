---
title: RadioGroup
order: 6
flutter: true
---

# RadioGroup

<p class="neba-lede">A set of options where exactly one is chosen. Use it when each option needs a sentence of its own, or when every option should be visible at once.</p>

<Demo src="radio-group/hero" />

::: fw react

```tsx
import { Radio, RadioGroup } from 'neba';

<RadioGroup label="Plan" defaultValue="team">
  <Radio value="starter" label="Starter" />
  <Radio value="team" label="Team" />
</RadioGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaRadioGroup<String>(
  label: Text('Plan'),
  defaultValue: 'team',
  children: <Widget>[
    NebaRadio<String>(value: 'starter', label: Text('Starter')),
    NebaRadio<String>(value: 'team', label: Text('Team')),
  ],
);
```

:::

## Props

### RadioGroup

<PropsTable name="RadioGroup" />

::: fw react

`value` with `onValueChange` makes it controlled; `defaultValue` makes it uncontrolled.

:::

::: fw flutter

The group is generic over the type of its options' `value`, and a `NebaRadio` inside it has to carry the same type. `value` with `onValueChange` makes it controlled; left `null`, the group keeps its own state from `defaultValue`. An option may sit anywhere below the group, inside a widget of the caller's. There is no `name` or `required`, because a Flutter group has no form submission to take part in.

:::

### Radio

<PropsTable name="Radio" />

A `Radio` has no `size` and no `color` of its own: set them on `RadioGroup` and they reach every option.

With many options to fit into little space, use [Select](./select); to join two or three into one control, use [SegmentedButton](./segmented-button).

## Examples

### description

Each option can carry a sentence. However many lines the description takes, the dot stays aligned to the first line of the label.

<Demo src="radio-group/descriptions">

::: fw react

<<< @/.vitepress/demos/radio-group/descriptions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/descriptions.dart

:::

</Demo>

### orientation

`vertical` by default. Use `horizontal` only with short labels: one long label makes the row hard to read.

<Demo src="radio-group/orientation">

::: fw react

<<< @/.vitepress/demos/radio-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/orientation.dart

:::

</Demo>

### spacing

::: fw react

The gap between the options, on Tailwind's spacing scale: `4` is `1rem`. A horizontal group that wraps puts its lines the same distance apart. Left out, a column follows `size` on the same steps as a [Form](./form)'s fields, `3` (`0.75rem`) at `md`, and a row keeps `5` along it with the column's step between lines. The `spacing` in a [NebaProvider](../../guide/provider)'s `defaults` does not reach it, because that is the gap between separate fields.

:::

::: fw flutter

The gap between the options, on the spacing scale: `4` is 16 logical pixels. A horizontal group that wraps puts its lines the same distance apart. Left out, a column follows `size`, 12 logical pixels at `md`, and a row keeps 20 along it with the column's step between lines. The `spacing` in a [NebaProvider](../../guide/provider)'s `defaults` does not reach it, because that is the gap between separate fields.

:::

<Demo src="radio-group/spacing">

::: fw react

<<< @/.vitepress/demos/radio-group/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/spacing.dart

:::

</Demo>

### disabled · readOnly

Both can be set on the group or on an individual `Radio`. On the group, they reach every option.

<Demo src="radio-group/states">

::: fw react

<<< @/.vitepress/demos/radio-group/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/states.dart

:::

</Demo>

### classNames

::: fw react

The group and one option are styled separately, because they are two components. On RadioGroup, `classNames` takes `label`, `control`, `description` and `error`, where `control` is the element holding the options: the one carrying the row or column direction. On Radio it takes `label`, `control`, `indicator` and `description`, where `control` is the dot.

```tsx
<RadioGroup label="Plan" classNames={{ control: 'ps-6' }}>
  <Radio value="team" label="Team" classNames={{ control: 'rounded-sm' }} />
</RadioGroup>
```

There is no `error` slot on Radio: a validity message belongs to the question, and the question is the group. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

There are no class names. The labels, the descriptions and the error are widgets, so each takes a style of its own, and the ring and the dot are the option's. There is no `error` on Radio: a validity message belongs to the question, and the question is the group.

:::

## Accessibility

::: fw react

- The set takes **one** tab stop and the arrow keys move within it (a roving tab index).
- The group's `label` becomes its accessible name.
- Each `Radio` is wired to its label, so clicking the text selects it.

:::

::: fw flutter

- The set is **one** stop in the focus order, at the chosen option or the first one, and the arrow keys move within it, choosing as they go and passing over a disabled option. In a read-only group they move without choosing.
- A screen reader hears a radio group named by its `Text` label, and each option as a radio in it, chosen or not.
- A press on an option's label chooses it, and so does a press on the gap between the label and the ring.

:::
