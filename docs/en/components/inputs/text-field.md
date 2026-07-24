---
title: TextField
order: 2
---

# TextField

<p class="neba-lede">Single- or multi-line text input. The label, the description and the error are one component, wired together by Base UI's Field.</p>

<Demo src="text-field/hero" />

```tsx
import { TextField } from 'neba';

<TextField label="Email" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

## Props

<PropsTable name="TextField" />

Every native `<input>` attribute passes straight through. `color` and `size` are omitted because they collide with the ones above, and `onChange` is widened so the same handler types against a `<textarea>` in multiline mode.

## Examples

### Variants

Even `solid` is not flooded with the accent colour. What a field holds is user data, and a caret, a text selection and a placeholder all have to stay legible on top of it. The colour family shows up in the edge, the focus ring and the caret instead.

<Demo src="text-field/variants">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### Sizes

The same heights as Button, so a field and a button in one row share a baseline.

<Demo src="text-field/sizes">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### Multiline

`multiline` renders a `<textarea>` and changes nothing else. `rows={1}` is exactly as tall as the single-line field. Horizontal resizing breaks a form's column, so only the vertical axis is on by default.

<Demo src="text-field/multiline">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### Icons and progress

`loading` puts a spinner in the `endIcon` slot and marks the field busy, but typing is deliberately still allowed — a field is usually loading _because of_ what was typed into it.

<Demo src="text-field/icons">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### States

Give `error` any content and the whole field re-points at the `danger` family — edge, focus ring, caret and message all turn over together. To mark it invalid without a message, pass `invalid` directly.

<Demo src="text-field/states">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### Controlled

`value` and `onChange` are the native ones.

<Demo src="text-field/controlled">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

## Accessibility

- Base UI's Field connects the label, description and error to the control with `id` and `aria-describedby`.
- There is no floating-label variant on purpose: floating labels need a `transform`, and controls in this library never transform.
- The focus ring belongs to the shell rather than the control inside it, so it traces the acrylic edge.
- Clicking the shell's own padding puts the caret in the field, the way a native `<input>` behaves.
