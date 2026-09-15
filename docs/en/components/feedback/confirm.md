---
title: Confirm
order: 11
---

# Confirm

<p class="neba-lede">A question asked in a dialog, awaited like any other answer. <code>useConfirm()</code> returns a function that resolves to what the reader pressed, so the code that asks is the code that acts.</p>

<Demo src="confirm/hero" />

```tsx
import { ConfirmProvider, useConfirm } from 'neba';

<ConfirmProvider>
  <App />
</ConfirmProvider>;

// anywhere under it
const confirm = useConfirm();

if (await confirm({ title: 'Delete the project?', color: 'danger' })) {
  remove();
}
```

## Props

<PropsTable name="ConfirmProvider" />

### The options

<PropsTable name="ConfirmOptions" />

`confirm('Delete the project?')` is shorthand for `confirm({ title: 'Delete the project?' })`.

## Examples

### Return value

`confirm()` resolves `true` when the reader confirms, and `false` when they cancel, press `Escape` or click the backdrop. It never rejects.

### color and destructive questions

Most confirms are about destroying something. `color: 'danger'` turns the confirming button and the sheet's accents over together.

```tsx
await confirm({
  title: 'Delete 12 files?',
  description: 'They go to the trash and are removed after 30 days.',
  confirmLabel: 'Move to trash',
  color: 'danger'
});
```

### alert

`alert` drops the cancelling button and leaves one way out, for telling rather than asking. It still resolves, always `true`, even when `Escape` or the backdrop closes the sheet, so the same `await` works either way.

```tsx
await confirm({ title: 'Your export is ready.', alert: true });
```

### dismissible

`false` makes a question the reader has to answer with a button, and `Escape` and the backdrop no longer close the sheet. Use it only where an accidental dismissal is the expensive answer.

### defaults

`ConfirmProvider` takes the settings every question under it shares, and each call overrides them.

```tsx
<ConfirmProvider defaults={{ size: 'md', locale: 'ko' }}>
```

### Queued questions

Raising a second question while the first is up puts it behind the first. Nothing is answered on the reader's behalf, so each promise resolves only when the reader answers its own question.

## Accessibility

- It renders a [Dialog](./dialog), so everything that has is here: the focus trap, the scroll lock, the inert page behind, and focus returning to whatever raised the question.
- The sheet is a `role="alertdialog"`: a question that has to be answered before anything else happens.
- The confirming button takes the focus when the sheet opens, so `Enter` answers yes and `Escape` answers no. A `danger` question opens on the cancelling button instead, so the `Enter` that asked is not followed by one that destroys.
- Once the last queued question is answered, the focus goes back to the element that held it when the first was asked.
- `title` becomes the dialog's accessible name and `description` its `aria-describedby`. A question with neither is a dialog a screen reader announces as nothing: always pass at least a `title`.
