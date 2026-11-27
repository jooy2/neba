---
title: Combobox
order: 12
flutter: true
---

# Combobox

<p class="neba-lede">A field that filters a list as you type. Use it when there are too many options for a Select, or when a value outside the list has to be accepted.</p>

<Demo src="combobox/hero" minHeight="300" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCombobox<String>(
  label: const Text('Framework'),
  placeholder: 'Search or type your own',
  items: const <NebaComboboxOption<String>>[
    NebaComboboxOption<String>(value: 'react', label: 'React'),
    NebaComboboxOption<String>(value: 'vue', label: 'Vue'),
  ],
);
```

:::

## Props

<PropsTable name="Combobox" />

::: fw react

Native `<div>` attributes pass through to the root, except `aria-label` and `aria-labelledby`, which name the `<input>`. Only `color` and `defaultValue` are excluded, since the table above spells them differently.

The popup is the same as [Select](./select)'s. It renders in a portal at the end of `<body>`, with `neba-portal` on the positioner.

:::

::: fw flutter

`NebaCombobox` is generic over the type of its values, and `label`, `description` and `error` are widgets, usually a `Text`. `NebaCombobox.multiple` is the combobox that holds a list: its `value`, `defaultValue` and `onValueChange` speak in lists, which is why it is a constructor of its own rather than a `multiple` flag. `value` left `null` means the combobox keeps its own state.

The text in the field is the combobox's own: the chosen option's label in a single combobox, and empty after each choice in a multiple one. `onInputValueChange` reports it as it is typed, and `focusNode` drives the focus. `name`, `autoComplete`, `required`, `inputRef` and `classNames` are not there, since nothing submits a Flutter form for it. The list is the same as [Select](./select)'s, drawn in the app's root `Overlay`.

:::

### items

The same <Fw react="array" flutter="list" /> shape [Select](./select) takes; only `label`'s type differs.

::: fw react

```ts
interface ComboboxOption {
  value: string | number;
  label?: string; // a string, not a ReactNode
  disabled?: boolean;
}
```

:::

::: fw flutter

```dart
const NebaComboboxOption<String>(
  value: 'react',
  label: 'React', // a String, not a widget
  disabled: false,
);
```

:::

It has to be a <Fw react="string" flutter="String" code /> because the filter matches against it and the input writes it out.

## Examples

### multiple

Chosen values appear as [Chip](../display/chip)s inside the field, and the input goes on filtering after each one.

::: fw react

Backspace on an empty input moves focus to the last chip.

:::

::: fw flutter

`NebaCombobox.multiple` makes one. Backspace in an empty field takes the last chip out, and a chip's × takes out its own; the × is pressed, never tabbed to. From the caret's start, the left arrow (the right one in a right-to-left field) moves onto the last chip, the arrows walk the chips and step back into the field off either end, and Backspace or Delete takes out the chip that holds the focus. The field is as wide as twenty characters after its chips, and wraps them onto further lines once it is narrower than that.

:::

<Demo src="combobox/multiple" minHeight="300">

::: fw react

<<< @/.vitepress/demos/combobox/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/multiple.dart

:::

</Demo>

### allowCustom · customLabel · emptyMessage

`allowCustom` is on by default. The typed text is offered as its own row at the end of the list, so Enter, a <Fw react="click" flutter="press" /> and the arrow keys all reach it the way they reach every other row. It is never committed quietly on blur.

Turn it off with <Fw react="allowCustom={false}" flutter="allowCustom: false" code /> for a closed set of values; then `emptyMessage` is shown when nothing matches.

::: fw flutter

What was typed is a `String`, so only a combobox whose values a `String` can be, one over `String` or `Object?`, offers the row. Over `int` or an enum it is never offered, whatever `allowCustom` says.

:::

<Demo src="combobox/custom" minHeight="260">

::: fw react

<<< @/.vitepress/demos/combobox/custom.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/custom.dart

:::

</Demo>

### variant

The same three weights a [TextField](./text-field) has, drawn on the same shell.

<Demo src="combobox/variants" minHeight="220">

::: fw react

<<< @/.vitepress/demos/combobox/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/variants.dart

:::

</Demo>

### size

A single-select Combobox is exactly as tall as a [TextField](./text-field) of the same `size`. With `multiple` the field grows as the chips wrap, so it has no fixed height.

<Demo src="combobox/sizes" minHeight="300">

::: fw react

<<< @/.vitepress/demos/combobox/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/sizes.dart

:::

</Demo>

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). In a `multiple` combobox a `float` label rests only while nothing is chosen and nothing is typed.

<Demo src="combobox/label-placement" minHeight="240">

::: fw react

<<< @/.vitepress/demos/combobox/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/label_placement.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="combobox/states">

::: fw react

<<< @/.vitepress/demos/combobox/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/states.dart

:::

</Demo>

### clearable · limit

`clearable` adds a button that empties the value. `limit` caps how many options the popup shows at once. The row that offers to add what was typed is drawn beyond it, so a full list can still take a new value.

### filter

By default the typed text narrows the list here, accent- and case-insensitively, against each option's label.

::: fw react

**A list the server has already narrowed needs `filter={false}`.** A search that matched on a keyword, a description or a synonym sends back rows whose visible label does not contain the query at all, and filtering them a second time drops exactly the results the search was for. Fetch on `onInputValueChange`, hand the answer to `items`, and let it through:

```tsx
<Combobox
  items={results}
  filter={false}
  onInputValueChange={(query) => search(query)}
  label="Customer"
/>
```

:::

::: fw flutter

**A list the server has already narrowed needs a filter that keeps everything.** A search that matched on a keyword, a description or a synonym sends back rows whose visible label does not contain the query at all, and filtering them a second time drops exactly the results the search was for. Fetch on `onInputValueChange`, hand the answer to `items`, and let it through:

```dart
NebaCombobox<String>(
  items: results,
  filter: (NebaComboboxOption<String> option, String query) => true,
  onInputValueChange: search,
  label: const Text('Customer'),
)
```

:::

A function decides per option instead — matching the `value` as well as the label, or matching from the start of a word rather than anywhere in it. The row that offers to add what was typed is never filtered out.

### shortcuts

::: fw react

`shortcuts` maps a key combination to what it does, written the way [Shortcut](../display/shortcut) draws it. `Mod` is Command on a Mac and Control everywhere else, and the modifiers are matched exactly.

```tsx
<Combobox label="Framework" items={frameworks} shortcuts={{ 'Mod+Enter': createAndOpen }} />
```

The arrows move the highlight, `Escape` closes the popup and `Enter` commits. Those keys never reach an `onKeyDown` written on the root, so on a Combobox `shortcuts` is the only way to act on them.

A shortcut is bound to the `<input>` and runs before the list acts on the key, but it does not _replace_ what the list does. A shortcut on `Enter` fires alongside the commit, not instead of it. Bind a combination the list does not use when you need the key to yourself.

:::

::: fw flutter

`shortcuts` maps a `ShortcutActivator` to what it does, as [TextField](./text-field#shortcuts)'s does, and the modifiers are matched exactly.

```dart
NebaCombobox<String>(
  label: const Text('Framework'),
  items: frameworks,
  shortcuts: <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.enter, control: true): createAndOpen,
  },
)
```

The arrows move the highlight, `Escape` closes the list and `Enter` chooses. A shortcut runs while the field holds the focus and before the list acts on the key, but it does not _replace_ what the list does. A shortcut on `Enter` runs alongside the choice, not instead of it. Bind a combination the list does not use when you need the key to yourself.

:::

::: fw react

### autoComplete

`autoComplete` tells the browser what the field holds, so its autofill can fill it in with the rest of an address form. It is written on the hidden input that submits the value, and a filled-in value that matches an option's `value` or label chooses that option. The `<input>` the reader types into keeps `autocomplete="off"`, so the browser's list of past entries does not open over the combobox's own. A `multiple` combobox takes no autofill.

```tsx
<Combobox label="City" name="city" autoComplete="address-level2" items={cities} />
```

### classNames

`className` lands on the root (the column holding the label, the shell and the two lines under it), so the `<input>` is reached through `classNames.control`.

```tsx
<Combobox
  items={frameworks}
  label="Framework"
  multiple
  classNames={{ control: 'font-mono', chip: 'rounded-none', popup: 'max-h-40' }}
/>
```

The slots are `label`, `shell`, `control`, `description`, `error`, `chip`, `popup` and `item`. `chip` is one token in front of the input in multiple mode. `popup` and `item` render at the end of `<body>`, so nothing written against the root reaches them. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

## Accessibility

::: fw react

- The trigger has the `combobox` role and the list the `listbox` role; `label` becomes the accessible name.
- Filtering, the popup's positioning and flipping, arrow-key navigation across both the list and the chips, and the hidden input for form submission are all handled.
- A `disabled` option stays in the list and reports `aria-disabled`.
- Each chip's remove button is named through `removeLabel`, which receives the chip's own label.
- `locale` decides the no-matches line and the names of the clear and remove buttons; `emptyMessage`, `clearLabel` and `removeLabel` write them out instead.

:::

::: fw flutter

- The field is one text field to a screen reader, named by a `Text` label and heard as collapsed or expanded, with a `Text` description and error read after the name.
- Typing, a press on the field or the chevron and the arrow keys open the list; the arrow keys move the highlight, past a disabled option and round at the ends, and the first match lights up as you type, so Enter chooses it. Escape closes the list, and Escape again empties the field. The focus stays in the field throughout, and the list closes when it leaves.
- Each option says whether it is selected, and a `disabled` one stays in the list, heard as unavailable.
- The chevron, the × and each chip's × are buttons named by the label, `clearLabel` and `removeLabel`, and none of them takes the focus from the field. The chips themselves take it from the arrow keys and never from Tab.
- `locale` decides the no-matches line, the row that adds what was typed and the names of the clear and remove buttons; `emptyMessage`, `customLabel`, `clearLabel` and `removeLabel` write them out instead.

:::
