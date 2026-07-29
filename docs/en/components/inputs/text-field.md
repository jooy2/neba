---
title: TextField
order: 3
---

# TextField

<p class="neba-lede">Takes single- or multi-line text input. The label, the description and the error message are one component.</p>

<Demo src="text-field/hero" />

```tsx
import { TextField } from 'neba';

<TextField label="Email" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

## Props

<PropsTable name="TextField" />

Every native `<input>` attribute passes straight through. `color` and `size` are omitted because they collide with the ones above, and `onChange` is widened so the same handler types against a `<textarea>` in multiline mode.

## Examples

### variant

None of the three weights flood the sheet with colour. What a field holds is text the user typed, and the caret, the selection and the placeholder all have to stay legible on top of it. `color` shows up in the border, the focus ring and the caret instead.

<Demo src="text-field/variants">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### size

The same heights as [Button](./button), so a field and a button in one row share a baseline.

<Demo src="text-field/sizes">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### multiline · rows · resize

`multiline` renders a `<textarea>` and leaves every other axis alone. `rows={1}` is exactly as tall as the single-line field. `resize` defaults to the vertical axis only — horizontal resizing breaks a form's column alignment.

<Demo src="text-field/multiline">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### startIcon · endIcon · loading

`loading` puts a spinner in the `endIcon` slot and marks the field busy, but typing is still allowed — a field is usually loading because of what was just typed into it.

<Demo src="text-field/icons">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### error · invalid · disabled · readOnly

Give `error` a message and the field also turns invalid, re-pointing the whole field at the `danger` family. To mark it invalid without a message, pass `invalid` directly.

<Demo src="text-field/states">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### value and onChange

Identical to the native `<input>`.

<Demo src="text-field/controlled">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

## Accessibility

- `label`, `description` and `error` are connected to the control with `id` and `aria-describedby`.
- There is no floating-label variant.
- The focus ring belongs to the shell rather than the `<input>` inside it, so it traces the border.
- Clicking the shell's own padding puts the caret in the field.
