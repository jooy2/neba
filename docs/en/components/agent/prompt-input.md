---
title: PromptInput
order: 9
---

# PromptInput

<p class="neba-lede">Everything a prompt goes out through: the text, the attach and model controls, and one button that sends and then stops. The field grows with what is typed and then stops growing.</p>

<Demo src="prompt-input/hero" />

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

## Props

<PropsTable name="PromptInput" />

Native `<textarea>` attributes pass through to the control. `color`, `size`, `value`, `defaultValue`, `onChange`, `onSubmit` and `children` are excluded, since the table above spells them differently. `className` and `style` are the root, which is a real `<form>`.

A [TextField](../inputs/text-field) with `multiline` plus a [Toolbar](../surfaces/toolbar) gets the shell. What it does not get is the three things that are rewritten at every call site: a field that grows and then stops, a send button that becomes a stop button without moving, and Enter meaning _send_.

## Examples

### submitting · onStop

One button, never two. While `submitting` the send button becomes a stop button and stays pressable — what a reader reaches for to stop an answer is exactly where they last pressed to start it, and a second button appearing beside the first would move it.

Nothing sends while an answer is being written, including the key.

<Demo src="prompt-input/submitting">

<<< @/.vitepress/demos/prompt-input/submitting.tsx

</Demo>

### submitKey

`Enter` sends and `Shift+Enter` breaks the line. `Mod+Enter` is the other way round, for a field people write paragraphs in; the combination is spelled the way [Shortcut](../display/shortcut) draws it, so the key cap beside the field and the key that fires are the same string.

**Neither fires while an input method is composing.** A Korean or Japanese reader pressing Enter to accept a candidate is finishing a word, not sending a message, and a field that read it as a send would make the language unusable.

<Demo src="prompt-input/submit-key">

<<< @/.vitepress/demos/prompt-input/submit-key.tsx

</Demo>

### minRows · maxRows

The field is `minRows` tall at its shortest and grows with the text to `maxRows`, after which it scrolls. A prompt field that grows without a ceiling pushes the conversation it belongs to off the screen.

The height is measured rather than declared, because the one-line CSS version of this — `field-sizing: content` — is years past the browsers the library still supports.

<Demo src="prompt-input/rows">

<<< @/.vitepress/demos/prompt-input/rows.tsx

</Demo>

### onSubmit does not clear the field

What happens to what was typed is the application's. A message that failed to send should still be there, so clearing the field is a line in the caller's own handler.

An empty field never sends — not by the button, which is disabled, and not by the key.

### start · end · children

`start` is the beginning of the toolbar under the text, where the attach button and the model [Select](../inputs/select) go. `end` is its other end, before the send button — a token count, a mode toggle. `children` is the strip **above** the field, for the attachments that have been added or a line saying what is being replied to.

### onFiles

Passing it makes the shell a drop target. It is called with the dropped files and what happens to them is the application's; the shell says it is ready for them while a drag is over it.

## Accessibility

- The root is a real `<form>`, so a phone's keyboard offers its own send key and the button is a `type="submit"` rather than a click handler pretending to be one.
- `label` is the field's accessible name, drawn for a screen reader and nobody else. Give it one, or an `aria-label`: a placeholder is a last resort and goes away as soon as anything is typed.
- The send button is an [IconButton](../inputs/icon-button), so its `label` is required and changes with the state — "Send" becomes "Stop".
- The focus ring belongs to the shell rather than to the `<textarea>`, so it traces the acrylic edge instead of a rectangle floating inside it.
