---
title: OtpField
order: 20
flutter: true
---

# OtpField

<p class="neba-lede">A row of one-character slots for a short code typed in from somewhere else. Use it for a PIN, a texted verification code, or an invite key.</p>

<Demo src="otp-field/hero" />

::: fw react

```tsx
import { OtpField } from 'neba';

<OtpField label="Verification code" length={6} groupSize={3} onComplete={(code) => verify(code)} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaOtpField(label: const Text('Verification code'), groupSize: 3, onComplete: verify);
```

:::

## Props

<PropsTable name="OtpField" />

::: fw react

Every other `<div>` attribute passes through to the row of slots. The field's own `color`, `defaultValue`, `onChange` and `children` replace the `<div>`'s. The value is reported by `onValueChange`, and the slots are drawn by the field from `length`. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

`label`, `description`, `error` and `separator` are widgets, usually a `Text`. The code is a `String`: `value` with `onValueChange` for a controlled field, or `defaultValue` for one that keeps its own, and the cells are drawn by the field from `length`. There is no `slotLabel` and no `locale`: the cells are one field to a screen reader, which reads the code and where the caret is in it, so no cell needs a name of its own. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

## Examples

### charset

`charset` decides what may be typed. Characters outside it are dropped rather than shown, and `onValueInvalid` reports the text they came in on. `numeric` also puts a number pad in front of a phone; `any` accepts whatever the keyboard produces.

<Demo src="otp-field/charsets">

::: fw react

<<< @/.vitepress/demos/otp-field/charsets.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/charsets.dart

:::

</Demo>

### length and groupSize

`length` is how many characters the code has, clamped to 2–12. `groupSize` splits the row every N slots with a `separator`, which is an en dash unless something else is passed.

<Demo src="otp-field/lengths">

::: fw react

<<< @/.vitepress/demos/otp-field/lengths.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/lengths.dart

:::

</Demo>

### mask, error, readOnly and disabled

`mask` hides the characters. `error` shows a message and re-points the colour family at `danger`, and `invalid` does the same without a message. `readOnly` keeps the code selectable; `disabled` stops every slot answering.

<Demo src="otp-field/states">

::: fw react

<<< @/.vitepress/demos/otp-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/states.dart

:::

</Demo>

### size

<Demo src="otp-field/sizes">

::: fw react

<<< @/.vitepress/demos/otp-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/sizes.dart

:::

</Demo>

### <Fw react="In a form" flutter="onComplete" />

::: fw react

`name` puts the whole value on the form under that name. `autoSubmit` submits the owning form the moment the code is complete, which is the shape a one-field verification screen wants.

```tsx
<form action={verify}>
  <OtpField name="code" length={6} required autoSubmit />
</form>
```

:::

::: fw flutter

`onComplete` is called with the code once every cell is filled, which is the moment to check it. A Flutter field has no form to submit, so there is no `name`, `required` or `autoSubmit`: a one-field verification screen checks the code here.

```dart
NebaOtpField(
  label: const Text('Verification code'),
  onComplete: (String code) => verify(code),
)
```

:::

## Accessibility

::: fw react

- Typing moves to the next slot, Backspace steps back over the previous character, and the arrow keys walk the row.
- Pasting a code spreads it across the slots from wherever the caret is, however it was pasted.
- Clicking lands on the first empty slot rather than on the one under the pointer, so a half-typed code cannot be edited into a gap.
- A clipped input carries the whole value for the form and for a phone's autofill; `autocomplete="one-time-code"` is on it already.
- `label`, `description` and `error` are wired to the slots, so all three are announced with the field.
- The first slot is named by `label`, and every other by its place in the code, as "Character 2 of 6" in the `locale`'s words or through `slotLabel`.

:::

::: fw flutter

- The cells are one field to a screen reader. A `Text` label is its name, the code is its value, dots while it is masked, with how many cells are filled, and a `Text` description and error are read after it.
- Typing moves to the next cell, Backspace steps back over the previous character, Delete takes the one in the cell, and the arrow keys, Home and End walk the row.
- A paste fills the cells from the one the caret is in.
- A press lands on the cell under the pointer, or on the first empty cell when it is past the code, so a half-typed code cannot be edited into a gap.
- One `EditableText` behind the cells carries the whole code with `AutofillHints.oneTimeCode`, so a phone offers a texted code and fills every cell at once.
- The cell the caret is in is ringed whenever the field holds the focus, since the ring is what says where the next character lands.

:::
