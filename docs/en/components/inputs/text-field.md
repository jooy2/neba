---
title: TextField
order: 3
flutter: true
---

# TextField

<p class="neba-lede">Takes single- or multi-line text input. The label, the description and the error message are one component.</p>

<Demo src="text-field/hero" />

::: fw react

```tsx
import { TextField } from 'neba';

<TextField label="Email" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTextField(label: const Text('Email'), onChanged: (String value) => email = value);
```

:::

## Props

<PropsTable name="TextField" />

::: fw react

Every native `<input>` attribute passes straight through. `color` and `size` are omitted because they collide with the ones above, and `onChange` is widened so the same handler types against a `<textarea>` in multiline mode.

:::

::: fw flutter

`label`, `description` and `error` are widgets, usually a `Text`. The text is held by a `TextEditingController`, the caller's `controller` or the field's own, and `initialValue` is React's `defaultValue`. What React passes to the `<input>` as attributes, Flutter passes to the `EditableText` underneath: `keyboardType`, `textInputAction`, `obscureText` for `type="password"`, `autofillHints`, `inputFormatters` and `maxLength`. `semanticLabel` names a field that has no label.

:::

## Examples

### variant

None of the three weights flood the sheet with colour. What a field holds is text the user typed, and the caret, the selection and the placeholder all have to stay legible on top of it. `color` shows up in the border, the focus ring and the caret instead.

<Demo src="text-field/variants">

::: fw react

<<< @/.vitepress/demos/text-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/variants.dart

:::

</Demo>

### size

The same heights as [Button](./button), so a field and a button in one row share a baseline. On a field the height is a **floor** rather than a fixed row: text set larger than the step — a cron expression, a code, a figure — grows the shell instead of being clipped by it.

<Demo src="text-field/sizes">

::: fw react

<<< @/.vitepress/demos/text-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/sizes.dart

:::

</Demo>

### labelPlacement

`top`, the default, puts the label above the field. `notch` puts it on the field's top edge, in a gap cut out of the border. `float` puts it inside the field where the placeholder would be, and moves it up into the notch when the field takes the focus or holds a value; the placeholder shows only once the label has moved. A `startIcon` keeps a `float` label in the notch, since the icon is where it would rest. A resting label stops short of an `endIcon`, and a field that is only as wide as its label is widened to hold it at the size it rests at.

A label in the notch stands half a line above the field rather than a full line, so leave room for it above the first field in a container that clips.

<Demo src="text-field/label-placement">

::: fw react

<<< @/.vitepress/demos/text-field/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/label_placement.dart

:::

</Demo>

### <Fw react="multiline · rows · resize" flutter="multiline · rows" />

::: fw react

`multiline` renders a `<textarea>` and leaves every other axis alone. `rows={1}` is exactly as tall as the single-line field. `resize` defaults to the vertical axis only: horizontal resizing breaks a form's column alignment.

:::

::: fw flutter

`multiline` takes more than one line and leaves every other axis alone. `rows` is the fewest lines the field shows, and `rows: 1` is exactly as tall as the single-line field. Past that the field grows with the text, since there is no corner to drag.

:::

<Demo src="text-field/multiline">

::: fw react

<<< @/.vitepress/demos/text-field/multiline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/multiline.dart

:::

</Demo>

### startIcon · endIcon · loading

`loading` puts <Fw react="a spinner" flutter="a turning ring" /> in the `endIcon` slot<Fw react=" and marks the field busy" />, but typing is still allowed: a field is usually loading because of what was just typed into it.

<Demo src="text-field/icons">

::: fw react

<<< @/.vitepress/demos/text-field/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/icons.dart

:::

</Demo>

### error · invalid · disabled · readOnly

Give `error` a message and the field also turns invalid, re-pointing the whole field at the `danger` family. To mark it invalid without a message, pass `invalid` directly.

<Demo src="text-field/states">

::: fw react

<<< @/.vitepress/demos/text-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/states.dart

:::

</Demo>

### <Fw react="value and onChange" flutter="controller and onChanged" />

::: fw react

Identical to the native `<input>`.

:::

::: fw flutter

`onChanged` reports the text on every change and `onSubmitted` when the reader presses the keyboard's action key. To read or set the text from outside, hand the field a `TextEditingController`; without one it keeps its own.

:::

<Demo src="text-field/controlled">

::: fw react

<<< @/.vitepress/demos/text-field/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/controlled.dart

:::

</Demo>

### shortcuts

::: fw react

`shortcuts` is a map from a key combination to what it does, written the way [Shortcut](../display/shortcut) draws it, so the key a form shows a reader and the key it binds are the same string.

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

It is bound to the control, so `event.currentTarget` is the `<input>` or the `<textarea>` and `event.currentTarget.value` is what was typed. Nothing is prevented for you: a `Mod+Enter` that must not also insert a newline calls `preventDefault` itself. `onKeyDown` still sees every keystroke and runs after the map: neither prop replaces the other.

:::

::: fw flutter

`shortcuts` is a map from a `ShortcutActivator` to what it does, the way `CallbackShortcuts` takes one, bound while the field holds the focus.

```dart
NebaTextField(
  label: const Text('Message'),
  multiline: true,
  shortcuts: <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.enter, control: true): send,
    const SingleActivator(LogicalKeyboardKey.escape): clear,
  },
)
```

The modifiers are matched exactly, so `Enter` and `Control+Enter` are two entries that never both fire. There is no `Mod`: the demo binds `meta` on Apple platforms and `control` everywhere else. A bound key is taken, so a `Control+Enter` that sends does not also break the line; a key nobody bound reaches the field as usual.

:::

<Demo src="text-field/shortcuts">

::: fw react

<<< @/.vitepress/demos/text-field/shortcuts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/shortcuts.dart

:::

</Demo>

### <Fw react="classNames" flutter="style" />

::: fw react

`className` lands on the root (the column holding the label, the shell and the two lines under it), so the `<input>` is reached through `classNames` instead. There is no `root` key; that is what `className` already is.

```tsx
<TextField
  label="Email"
  className="w-80"
  classNames={{ label: 'uppercase tracking-wide', control: 'font-mono' }}
/>
```

The slots are `label`, `shell`, `control`, `description` and `error`. `shell` is the framed box wearing the border, the fill and the focus ring; `control` is the `<input>` or `<textarea>` inside it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

`style` is laid over the text inside the field, which is React's `classNames.control`. The label, the description and the error are widgets, so they take a style of their own; the width is the parent's, or `fullWidth`.

```dart
NebaTextField(
  label: const Text('Cron'),
  style: const TextStyle(fontFamily: 'monospace', fontSize: 24),
)
```

:::

## Accessibility

::: fw react

- `label`, `description` and `error` are connected to the control with `id` and `aria-describedby`.
- With `notch` and `float` the label is still the field's `<label>`. A resting `float` label stands in for the placeholder, which is hidden until the field takes the focus.
- The focus ring belongs to the shell rather than the `<input>` inside it, so it traces the border.
- Clicking the shell's own padding puts the caret in the field.
- On iOS and iPadOS the text is at least 16px, since Safari there zooms the page in on a smaller field when it is tapped. Every other browser draws the size the field's `size` sets. `NumberField`, `Combobox`, `OtpField`, `CommandPalette` and the other text inputs in the library do the same.

:::

::: fw flutter

- The field is one node to a screen reader. A `Text` label is its name, and a `Text` description and error are read after it; an `error` also marks the field invalid.
- With `notch` and `float` the label is still the field's name. A resting `float` label stands in for the placeholder, which is hidden until the field takes the focus.
- The focus ring belongs to the shell and traces its edge. It shows whenever the field holds a caret, and on a read-only field only for keyboard focus.
- A tap on the label or on the shell's own padding puts the caret in the field.
- There are no selection handles and no copy-and-paste toolbar on a touch screen, because those come from Material or Cupertino. The pointer and the keyboard still select, and the keyboard still copies and pastes.

:::
