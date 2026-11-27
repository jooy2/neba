---
title: Select
order: 4
flutter: true
---

# Select

<p class="neba-lede">Chooses one value from a fixed list. The trigger is the same shell as TextField, wearing a chevron.</p>

<Demo src="select/hero" minHeight="280" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSelect<String>(
  label: const Text('Region'),
  placeholder: const Text('Pick a region'),
  items: const <NebaSelectOption<String>>[
    NebaSelectOption<String>(value: 'icn', label: Text('Seoul')),
    NebaSelectOption<String>(value: 'nrt', label: Text('Tokyo')),
  ],
);
```

:::

## Props

<PropsTable name="Select" />

::: fw react

Native `<div>` attributes pass through to the root, except `aria-label` and `aria-labelledby`, which name the trigger. Only `color` and `defaultValue` are excluded, since the table above spells them differently.

The popup renders in a portal at the end of `<body>`, so it leaves any subtree your app scoped a CSS reset to. The positioner carries a `neba-portal` class to hang that reset off. An app with Tailwind's Preflight applied globally needs nothing.

:::

::: fw flutter

`NebaSelect` is generic over the type of its values, and `label`, `placeholder`, `description` and `error` are widgets, usually a `Text`. `value` left `null` means the select keeps its own state, so a controlled select passes the value it holds and sets it again in `onValueChange`, which hands over the chosen value and never `null`. `semanticLabel` names a select with no label of its own, as `aria-label` does.

`name`, `autoComplete`, `required` and `classNames` are not there: nothing submits a Flutter form for the select, and its parts are styled through the shared props. The list is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s is.

:::

When the options have to be searched, use [Combobox](./combobox); with only two or three, use [RadioGroup](./radio-group) or [SegmentedButton](./segmented-button).

### items

Options are passed as <Fw react="an array" flutter="a list" /> rather than composed from components.

::: fw react

```ts
interface SelectOption {
  value: string | number;
  label?: React.ReactNode; // defaults to the value
  disabled?: boolean;
  group?: string;
}
```

`value` is a string or a number. It is what gets submitted with a form, so objects are not accepted. Keep the identifier here and look the object up at the call site.

:::

::: fw flutter

```dart
const NebaSelectOption<String>(
  value: 'icn',
  label: Text('Seoul'), // defaults to the value's own text
  disabled: false,
  group: 'Asia',
);
```

`value` is any `T`, compared with `==`, and the select's width, its list and its typeahead read the `label`. A label that is a `Text` is also what typeahead matches and what a screen reader reads; any other widget is matched and read by its value's text.

:::

## Examples

### variant

The same three weights a [TextField](./text-field) has, drawn on the same shell, so a select and the fields around it never disagree about height or border.

<Demo src="select/variants" minHeight="220">

::: fw react

<<< @/.vitepress/demos/select/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/variants.dart

:::

</Demo>

### size

<Demo src="select/sizes" minHeight="240">

::: fw react

<<< @/.vitepress/demos/select/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/sizes.dart

:::

</Demo>

### labelPlacement

`notch` puts the label on the trigger's top edge, in a gap cut out of the border. `float` puts it inside the trigger in place of the placeholder, and moves it up into the notch once something is chosen, the trigger takes the focus or the list opens. A `startIcon` keeps a `float` label in the notch. [TextField](./text-field#labelplacement) has the details every field shares.

<Demo src="select/label-placement" minHeight="230">

::: fw react

<<< @/.vitepress/demos/select/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/label_placement.dart

:::

</Demo>

### group

`group` puts a heading over an option and the ones next to it that name the same group: time zones under their region, fonts under their family. The heading cannot be highlighted, chosen or reached by typeahead.

A group is a **run of adjacent options**, so the <Fw react="array's" flutter="list's" /> order is the list's order and nothing is moved out from under you. Two separate runs naming the same group draw two headings. Options with no `group` render on their own, wherever the <Fw react="array" flutter="list" /> puts them.

<Demo src="select/groups" minHeight="380">

::: fw react

<<< @/.vitepress/demos/select/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/groups.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="select/states">

::: fw react

<<< @/.vitepress/demos/select/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/states.dart

:::

</Demo>

::: fw react

### autoComplete

`autoComplete` tells the browser what the select holds, so its autofill can fill it in with the rest of an address form. It is written on the hidden input that submits the value, and a filled-in value that matches an option's `value` or label chooses that option.

```tsx
<Select label="Country" name="country" autoComplete="country" items={countries} />
```

### classNames

`className` lands on the root (the column holding the label, the trigger and the two lines under it), so the trigger is reached through `classNames.control`.

```tsx
<Select
  items={plans}
  label="Plan"
  classNames={{ control: 'font-mono', popup: 'max-h-40', item: 'rounded-none' }}
/>
```

The slots are `label`, `control`, `description`, `error`, `popup` and `item`. `popup` and `item` render at the end of `<body>`, so a descendant selector written against the root will not reach them, and these two slots are the only way in. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

## Accessibility

::: fw react

- The trigger has the `combobox` role, and `label` becomes its accessible name.
- The popup's positioning and flipping at the window edge, focus handling, typeahead and the hidden input for form submission are all handled.
- A `disabled` option stays in the list and reports `aria-disabled`.

:::

::: fw flutter

- The trigger is one node to a screen reader: a button named by a `Text` label, which says the chosen option's words as its value and is heard as collapsed or expanded. A `Text` description and error are read after the name.
- A press, the arrow keys, Enter or Space open the list on the chosen option and move the focus into it. The arrow keys, Home and End move the highlight there, past a disabled option and round at the ends; typing the first letters of an option reaches it; Enter, Space or a press chooses. Typing at a closed trigger chooses the option it reaches.
- Escape, Tab, a press outside and a choice close the list and give the focus back to the trigger, and Tab then moves on from it.
- Each option says whether it is selected, and a `disabled` one stays in the list, heard as unavailable.
- The trigger's focus ring shows for keyboard focus only, as a button's does; its edge still answers any focus.

:::
