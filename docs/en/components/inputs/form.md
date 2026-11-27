---
title: Form
order: 27
flutter: true
---

# Form

<p class="neba-lede">A <code>&lt;form&gt;</code> that knows which of its fields is wrong. A submit collects every field's validity at once, focuses the first that failed, and errors from a server land on the field they belong to.</p>

<Demo src="form/hero" />

::: fw react

```tsx
import { Button, Form, TextField } from 'neba';

<Form onSubmit={(values) => save(values)}>
  <TextField label="Email" name="email" type="email" required />
  <Button type="submit">Create account</Button>
</Form>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

final GlobalKey<NebaFormState> form = GlobalKey<NebaFormState>();

NebaForm(
  key: form,
  onSubmit: (Map<String, Object?> values) => save(values),
  children: <Widget>[
    NebaFormField<String>(
      name: 'email',
      validator: (String? value) => value == null || value.isEmpty ? 'Enter your email.' : null,
      builder: (NebaFormFieldState<String> field) => NebaTextField(
        label: const Text('Email'),
        error: field.error,
        onChanged: field.didChange,
      ),
    ),
    NebaButton(onPressed: () => form.currentState!.submit(), child: const Text('Create account')),
  ],
);
```

:::

## Props

<PropsTable name="Form" />

::: fw react

Every native `<form>` attribute passes through, apart from `onSubmit`, which is handed the values rather than the event.

:::

::: fw flutter

A widget tree has no `<form>` and no submit button, so a form is submitted by calling `submit()` on its `NebaFormState`, through a `GlobalKey<NebaFormState>` or `NebaForm.of(context)` from below it; it returns whether every field was valid. A Neba field has no `name` and no constraint of its own, so a field takes part through a `NebaFormField`, below. `semanticLabel` is React's `aria-label`.

:::

It is not a form _library_: there is no schema, no resolver and no field array here. A project that wants those keeps them and hands the result to `errors`, which is the seam this is built around.

The children are laid out as a column<Fw flutter=", stretched to the form's width," />, with the gap `size` names or the one `spacing` gives. Put a [Grid](../layout/grid) or a [Fieldset](./fieldset) inside for anything else.

::: fw flutter

### NebaFormField

<PropsTable name="FormField" />

A `NebaFormField` names one field, holds its value and checks it, and builds the field itself with `builder`, handing it a `NebaFormFieldState`: the field takes its `error` from there and reports each change to `didChange`. This is the shape Flutter's own `FormField` takes. `value` is the value it holds, `errorText` and `invalid` say what is wrong, and `validate()` checks it on demand. There is no browser to check a `required` or an email's shape, so every rule and its words are the `validator`'s.

:::

## Examples

### onSubmit

::: fw react

Called only when every field is valid, with the form's values keyed by each field's `name`. The pickers are fields like any other: a DatePicker, TimePicker, DateTimePicker or ColorPicker hands over the string it submits, and a DateRangePicker, or a TreeSelect with `multiple`, an array. When `onSubmit` is given, the native submit event is prevented, so nothing navigates. Leave it out to let the submit go ahead: a function `action` then runs on React 19, and a URL in `action` on any version, after the same validation.

:::

::: fw flutter

Called only when every field is valid, with each `NebaFormField`'s value under its `name`, of whatever type the field holds: a `String` from a TextField, a `bool` from a Checkbox, the value a Select chose. A field that is `disabled`, or inside a disabled Fieldset, is left out of the check and of the values. Enter in a field submits nothing on its own; the hero's password field passes `onSubmitted` a call to `submit()`.

:::

### validationMode

`onSubmit` is the default and the only one that does not tell somebody their email is wrong while they are still typing it: after the first submit, fields re-validate on change. `onBlur` validates when a field loses focus, `onChange` on every <Fw react="keystroke" flutter="change" />.

<Demo src="form/validation-mode">

::: fw react

<<< @/.vitepress/demos/form/validation-mode.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/validation_mode.dart

:::

</Demo>

### errors

::: fw react

Errors from outside the browser's own validation (a server, a form action, a schema) keyed by the `name` of the field each belongs to. They render on that field and clear as soon as it changes.

:::

::: fw flutter

Errors from outside the fields' validators (a server, a schema) keyed by the `name` of the `NebaFormField` each belongs to: a `String`, or a `List<String>` drawn one message to a line. They render on that field through its `error` and clear as soon as it changes; a new map shows them again. They do not stop a submit.

:::

<Demo src="form/errors">

::: fw react

<<< @/.vitepress/demos/form/errors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/errors.dart

:::

</Demo>

### spacing

::: fw react

The gap between the children as an exact length, on Tailwind's spacing scale: `7` is `1.75rem`, the same step `gap-7` is. Without it the gap follows `size`, `0.75rem` at `md`. Set it once for every Form and [Fieldset](./fieldset) with <code v-pre>defaults={{ spacing: 7 }}</code> on a [NebaProvider](../../guide/provider); a `spacing` on the Form itself still wins.

:::

::: fw flutter

The gap between the children as an exact length, on the spacing scale: `7` is 28 logical pixels. Without it the gap follows `size`, 12 at `md`. Set it once for every Form and [Fieldset](./fieldset) with `NebaDefaults(spacing: 7)` on a [NebaProvider](../../guide/provider); a `spacing` on the Form itself still wins.

:::

<Demo src="form/spacing">

::: fw react

<<< @/.vitepress/demos/form/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/spacing.dart

:::

</Demo>

## Accessibility

::: fw react

- A failed submit moves focus to the first invalid field, so the reader is taken to the problem rather than told there is one.
- Each message is wired to its own field with `aria-describedby`, and the field carries `aria-invalid`.
- Give the form an `aria-label` where the page holds more than one.

:::

::: fw flutter

- A failed submit moves focus to the first invalid field, in the order the fields stand, so the reader is taken to the problem rather than told there is one.
- A screen reader hears each message after its field's name, and the field as invalid, as every Neba field reads its `error`.
- The form is heard with the form role. Give it a `semanticLabel` where the screen holds more than one.

:::
