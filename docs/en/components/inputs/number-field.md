---
title: NumberField
order: 13
flutter: true
---

# NumberField

<p class="neba-lede">A field that only takes a number, with steppers to nudge the value, range clamping and formatted display.</p>

<Demo src="number-field/hero" />

::: fw react

```tsx
import { NumberField } from 'neba';

<NumberField label="Seats" defaultValue={3} min={1} max={20} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaNumberField(label: const Text('Seats'), defaultValue: 3, min: 1, max: 20);
```

:::

## Props

<PropsTable name="NumberField" />

::: fw react

Native `<div>` attributes pass through to the root, except `aria-label` and `aria-labelledby`, which name the `<input>`. Only `color` and `defaultValue` are excluded, since the table above spells them differently.

`value` is a `number | null`, where `null` means empty. It is never a string you have to parse.

:::

::: fw flutter

`value` is a `double?`, where `null` means empty, and with `onValueChange` it makes a controlled field; leave it out and the field keeps its own number, starting from `defaultValue`. A controlled field whose `value` turns `null` is cleared. `label`, `description`, `error`, `startIcon` and `endIcon` are widgets, usually a `Text`.

There is no `name` and no `required`, since a Flutter field has no form to submit them to. There is no `incrementLabel`, `decrementLabel` or `locale` either: to a screen reader the steppers are the field's increase and decrease actions rather than buttons with names, and the number is written by `format`. `semanticLabel` names a field that has no label.

:::

The shell is identical to [TextField](./text-field)'s, so a field of the same `size` lines up beside it.

## Examples

### steppers

`end` groups the increment and decrement buttons at the end of the field. `split` puts the minus and the plus on either side of the number, for a quantity that is nudged rather than typed. `none` drops the buttons and leaves keyboard input. Holding a stepper repeats the step.

<Demo src="number-field/steppers">

::: fw react

<<< @/.vitepress/demos/number-field/steppers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/steppers.dart

:::

</Demo>

### step · largeStep · smallStep

The arrow keys move by `step`, Shift by `largeStep` and Alt by `smallStep`. `snapOnStep` rounds the result to a multiple of `step`. Home and End go to `min` and `max` when the field has them.

### wheel

`wheel` turns a mouse wheel rolled over the number into a step. It is on by default, and <Fw react="wheel={false}" flutter="wheel: false" code /> turns it off.

Both halves have to be true before anything happens: the field holds the focus, and the pointer is over the number. So the page scrolls as usual over a field nobody has put the caret in, and the gesture is taken from it only while the field is being worked. Turn it off for a field inside something that has to keep scrolling under a pointer resting on it.

### <Fw react="format and locale" flutter="format and parse" />

::: fw react

`format` is `Intl.NumberFormatOptions`. The field can show `$1,240` or `7.5%` while `value` stays `1240` and `0.075`.

:::

::: fw flutter

`format` is a function from the value to its text, and `parse` is the way back. The field can show `$1,240` or `7.5%` while `value` stays `1240` and `0.075`, written by whatever formatter the app already uses.

Without `format` the number is written plainly, with a point, at most three decimals and no grouping. Without `parse` the digits, one point and a leading sign are read and anything else, a grouping comma, a currency sign or a unit, is passed over, so a `format` that writes a decimal comma or a percentage needs a `parse` of its own. What can be typed is the digits, a point, a comma, a space, a sign where the range goes below zero, and the characters `format` writes.

:::

<Demo src="number-field/format">

::: fw react

<<< @/.vitepress/demos/number-field/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/format.dart

:::

</Demo>

### variant

<Demo src="number-field/variants">

::: fw react

<<< @/.vitepress/demos/number-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/variants.dart

:::

</Demo>

### size

The steppers are sized against the number's text, so they track it. The field lines up with a [Button](./button), [TextField](./text-field) or [Select](./select) of the same `size`.

<Demo src="number-field/sizes">

::: fw react

<<< @/.vitepress/demos/number-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/sizes.dart

:::

</Demo>

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). A `float` label rests in the field until it takes the focus or holds a number. A `startIcon` and <Fw react="steppers=&quot;split&quot;" flutter="NebaNumberFieldSteppers.split" code /> both keep it in the notch, because they sit where it would rest.

<Demo src="number-field/label-placement">

::: fw react

<<< @/.vitepress/demos/number-field/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/label_placement.dart

:::

</Demo>

### disabled · readOnly · error

`readOnly` removes the steppers rather than leaving them disabled. The number stays selectable so it can be copied out.

<Demo src="number-field/states">

::: fw react

<<< @/.vitepress/demos/number-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/states.dart

:::

</Demo>

### shortcuts

::: fw react

`shortcuts` maps a key combination to what it does, written the way [Shortcut](../display/shortcut) draws it. `Mod` is Command on a Mac and Control everywhere else, and the modifiers are matched exactly: `Enter` and `Mod+Enter` never both fire.

```tsx
<NumberField label="Quantity" shortcuts={{ Enter: commit }} />
```

It is bound to the `<input>` rather than to the root, which is what makes it worth having here: `className` and a plain `onKeyDown` both land on the column holding the label and the two lines under it, so their `currentTarget` is not the field.

Nothing is prevented for you. A shortcut on `ArrowUp` fires _and_ the field still steps; call `preventDefault` in the handler if it should not.

:::

::: fw flutter

`shortcuts` maps a `ShortcutActivator` to what it does, bound while the field holds the focus, as on [TextField](./text-field#shortcuts). The modifiers are matched exactly.

```dart
NebaNumberField(
  label: const Text('Quantity'),
  shortcuts: <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.enter): commit,
  },
)
```

A bound key is taken, except the keys that step: a binding on Up fires _and_ the field still steps after it.

:::

### <Fw react="classNames" flutter="style" />

::: fw react

`className` lands on the root (the column holding the label, the shell and the two lines under it), so the `<input>` is reached through `classNames.control`.

```tsx
<NumberField label="Seats" classNames={{ control: 'text-right', stepper: 'rounded-none' }} />
```

The slots are `label`, `shell`, `control`, `description`, `error` and `stepper`. `stepper` is both buttons rather than one each: a pair of steppers that do not match is not a thing anyone is building. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

`style` is laid over the number inside the field, which is React's `classNames.control`; the number is set in tabular figures unless the style says otherwise. The label, the description and the error are widgets, so they take a style of their own.

```dart
NebaNumberField(label: const Text('Seats'), style: const TextStyle(fontWeight: FontWeight.w600))
```

:::

## Accessibility

::: fw react

- The visible control is a text input with `inputmode="numeric"` and an `aria-roledescription`; beside it a hidden `<input type="number">` holds `min`, `max` and `step` and handles form submission and browser validation. Keeping the two apart is what lets the visible field show `$1,240`.
- `label` becomes the accessible name; the steppers are named by `incrementLabel` and `decrementLabel`.
- The steppers stay out of the tab order, because the arrow keys on the field do the same job.
- A stepper that has reached `min` or `max` becomes `disabled`.
- `locale` names the two steppers, so a plain BCP 47 string keeps the digits and the buttons in one language.

:::

::: fw flutter

- The field is one node to a screen reader: a `Text` label is its name, its text is its value, and a `Text` description and error are read after it.
- The steppers are not nodes of their own. What they do is the field's increase and decrease actions, which say the number a step would write, so a reader adjusts the field with the screen reader's own gesture.
- The steppers stay out of the focus order, because the arrow keys on the field do the same job.
- A stepper that has reached `min` or `max` goes grey, and the action in its direction goes with it.
- A mouse pressing a stepper puts the caret in the field; a finger does not, so the on-screen keyboard does not come up for a nudge.
- A touch screen shows the number keyboard, with a sign key where the range goes below zero.

:::
