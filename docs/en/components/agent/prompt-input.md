---
title: PromptInput
order: 9
flutter: true
---

# PromptInput

<p class="neba-lede">Everything a prompt goes out through: the text, the attach and model controls, and one button that sends and then stops. The field grows with what is typed and then stops growing.</p>

<Demo src="prompt-input/hero" minHeight="280" />

::: fw react

```tsx
import { PromptInput } from 'neba';

<PromptInput
  label="Message"
  placeholder="Ask about the design language…"
  value={value}
  onValueChange={setValue}
  onSubmit={ask}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPromptInput(
  label: const Text('Message'),
  placeholder: 'Ask about the design language…',
  controller: controller,
  onSubmit: ask,
);
```

:::

## Props

<PropsTable name="PromptInput" />

::: fw react

Native `<textarea>` attributes pass through to the control. `color`, `size`, `value`, `defaultValue`, `onChange`, `onSubmit` and `children` are excluded, since the table above spells them differently. `className` and `style` are the root, which is a real `<form>`.

:::

::: fw flutter

The text is a `TextEditingController` or an `initialValue`, with `onChanged`, as on a [TextField](../inputs/text-field). `start` and `end` are lists of widgets, as a [Toolbar](../surfaces/toolbar)'s are. There is no `onFiles`: the widgets layer has no way to take files dropped from the operating system, so a drop target is a plugin's.

:::

A [TextField](../inputs/text-field) with `multiline` plus a [Toolbar](../surfaces/toolbar) gets the shell. What it does not get is the three things that are rewritten at every call site: a field that grows and then stops, a send button that becomes a stop button without moving, and Enter meaning _send_.

## Examples

### submitting · onStop

One button, never two. While `submitting` the send button becomes a stop button and stays pressable — what a reader reaches for to stop an answer is exactly where they last pressed to start it, and a second button appearing beside the first would move it.

Nothing sends while an answer is being written, including the key.

<Demo src="prompt-input/submitting">

::: fw react

<<< @/.vitepress/demos/prompt-input/submitting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/prompt_input/submitting.dart

:::

</Demo>

### submitKey

<Fw react="Enter" flutter="NebaPromptSubmitKey.enter" code /> sends and `Shift+Enter` breaks the line. <Fw react="Mod+Enter" flutter="NebaPromptSubmitKey.modEnter" code /> is the other way round, for a field people write paragraphs in; the combination is spelled the way [Shortcut](../display/shortcut) draws it, so the key cap beside the field and the key that fires are the same string.

**Neither fires while an input method is composing.** A Korean or Japanese reader pressing Enter to accept a candidate is finishing a word, not sending a message, and a field that read it as a send would make the language unusable.

::: fw react

**Your `onKeyDown` runs first.** Call `preventDefault` in it to keep the key from sending — a mention list or a slash-command menu open over the field takes Enter that way.

:::

::: fw flutter

**Your `shortcuts` run first.** A key bound there is taken before the field reads it — a mention list or a slash-command menu open over the field takes Enter that way.

:::

<Demo src="prompt-input/submit-key">

::: fw react

<<< @/.vitepress/demos/prompt-input/submit-key.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/prompt_input/submit_key.dart

:::

</Demo>

### minRows · maxRows

The field is `minRows` tall at its shortest and grows with the text to `maxRows`, after which it scrolls.

<Demo src="prompt-input/rows">

::: fw react

<<< @/.vitepress/demos/prompt-input/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/prompt_input/rows.dart

:::

</Demo>

### onSubmit

The field keeps its text after `onSubmit`. Clear it in the handler once the message has gone, so a message that failed to send is still there.

An empty field never sends — not by the button, which is disabled, and not by the key.

### start · end · <Fw react="children" flutter="child" />

`start` is the beginning of the toolbar under the text, where the attach button and the model [Select](../inputs/select) go. `end` is its other end, before the send button — a token count, a mode toggle. <Fw react="children" flutter="child" code /> is the strip **above** the field, for the attachments that have been added or a line saying what is being replied to.

::: fw react

### onFiles

Passing it makes the shell a drop target. It is called with the dropped files and what happens to them is the application's; the shell says it is ready for them while a drag is over it. A `disabled` or `readOnly` field takes no drop.

:::

## Accessibility

::: fw react

- The root is a real `<form>` and the button is a `type="submit"`. With `submitKey="Enter"` the field sets `enterKeyHint="send"`, so a phone's keyboard labels its Enter key as a send key.
- `label` is the field's accessible name, drawn for a screen reader and nobody else. Give it one, or an `aria-label`: a placeholder is a last resort and goes away as soon as anything is typed.
- The send button is an [IconButton](../inputs/icon-button), so its `label` is required and changes with the state — "Send" becomes "Stop".
- The focus ring belongs to the shell rather than to the `<textarea>`, so it traces the acrylic edge instead of a rectangle floating inside it.

:::

::: fw flutter

- With `NebaPromptSubmitKey.enter` the field asks a touch keyboard for a send key, which sends without taking the focus away.
- `label` is the field's name, read by a screen reader and drawn for nobody. Give it one: a placeholder is a last resort and goes away as soon as anything is typed.
- The send button is an [IconButton](../inputs/icon-button), so its `label` is required and changes with the state — "Send" becomes "Stop".
- The focus ring belongs to the shell rather than to the text, so it traces the acrylic edge instead of a rectangle floating inside it.

:::
