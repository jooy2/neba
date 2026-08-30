---
title: Form
order: 27
---

# Form

<p class="neba-lede">A <code>&lt;form&gt;</code> that knows which of its fields is wrong. A submit collects every field's validity at once, focuses the first that failed, and errors from a server land on the field they belong to.</p>

<Demo src="form/hero" />

```tsx
import { Button, Form, TextField } from 'neba';

<Form onSubmit={(values) => save(values)}>
  <TextField label="Email" name="email" type="email" required />
  <Button type="submit">Create account</Button>
</Form>;
```

## Props

<PropsTable name="Form" />

Every native `<form>` attribute passes through, apart from `onSubmit`, which is handed the values rather than the event. It is not a form _library_: there is no schema, no resolver and no field array here. A project that wants those keeps them and hands the result to `errors`, which is the seam this is built around.

The children are laid out as a column with the gap `size` names. Put a [Grid](../layout/grid) or a [Fieldset](./fieldset) inside for anything else.

## Examples

### onSubmit

Called only when every field is valid, with the form's values keyed by each field's `name`. The native submit event is prevented, so nothing navigates.

### validationMode

`onSubmit` is the default and the only one that does not tell somebody their email is wrong while they are still typing it — after the first submit, fields re-validate on change. `onBlur` validates when a field loses focus, `onChange` on every keystroke.

<Demo src="form/validation-mode">

<<< @/.vitepress/demos/form/validation-mode.tsx

</Demo>

### errors

Errors from outside the browser's own validation — a server, a form action, a schema — keyed by the `name` of the field each belongs to. They render on that field and clear as soon as it changes.

<Demo src="form/errors">

<<< @/.vitepress/demos/form/errors.tsx

</Demo>

## Accessibility

- A failed submit moves focus to the first invalid field, so the reader is taken to the problem rather than told there is one.
- Each message is wired to its own field with `aria-describedby`, and the field carries `aria-invalid`.
- Give the form an `aria-label` where the page holds more than one.
