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

### shortcuts

`shortcuts` is a map from a key combination to what it does, written the way [Shortcut](../display/shortcut) draws it — so the key a form shows a reader and the key it binds are the same string.

```tsx
<TextField
  label="Message"
  multiline
  shortcuts={{
    'Mod+Enter': (event) => {
      event.preventDefault();
      send();
    },
    Escape: clear
  }}
/>
```

`Mod` is Command on a Mac and Control everywhere else. The modifiers are matched exactly, so `Enter` and `Mod+Enter` are two entries that never both fire.

It is bound to the control, so `event.currentTarget` is the `<input>` or the `<textarea>` and `event.currentTarget.value` is what was typed. Nothing is prevented for you: a `Mod+Enter` that must not also insert a newline calls `preventDefault` itself. `onKeyDown` still sees every keystroke and runs after the map — neither prop replaces the other.

<Demo src="text-field/shortcuts">

<<< @/.vitepress/demos/text-field/shortcuts.tsx

</Demo>

### classNames

`className` lands on the root — the column holding the label, the shell and the two lines under it — so the `<input>` is reached through `classNames` instead. There is no `root` key; that is what `className` already is.

```tsx
<TextField
  label="Email"
  className="w-80"
  classNames={{ label: 'uppercase tracking-wide', control: 'font-mono' }}
/>
```

The slots are `label`, `shell`, `control`, `description` and `error`. `shell` is the framed box wearing the border, the fill and the focus ring; `control` is the `<input>` or `<textarea>` inside it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

## Accessibility

- `label`, `description` and `error` are connected to the control with `id` and `aria-describedby`.
- There is no floating-label variant.
- The focus ring belongs to the shell rather than the `<input>` inside it, so it traces the border.
- Clicking the shell's own padding puts the caret in the field.
