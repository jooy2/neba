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

## Why a promise

"Are you sure?" is the most common dialog there is, and writing it by hand means a piece of state per question, a `useState` for what was being deleted when the dialog opened, and a callback that has to carry it. `onConfirm` splits one decision across two functions; awaiting it keeps the decision where it was made.

It never rejects. A question answered _no_ is an answer, not a failure, and a promise that throws for it turns every call site into a `try`.

Cancelling, `Escape` and a click on the backdrop all resolve `false` — they are the cancelling button by another route, so they answer the same way rather than leaving a promise pending forever.

## Examples

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

Drops the cancelling button, leaving one way out — for telling rather than asking. It still resolves, always `true`, so the same `await` works either way.

```tsx
await confirm({ title: 'Your export is ready.', alert: true });
```

### dismissible

`false` makes a question the reader has to answer with a button: `Escape` and the backdrop stop working. Use it where an accidental dismissal is the expensive answer, and almost nowhere else — a modal with no way out is the thing people report.

### defaults

`ConfirmProvider` takes the settings every question under it shares, and each call overrides them.

```tsx
<ConfirmProvider defaults={{ size: 'md', locale: 'ko' }}>
```

### Two at once

**Questions queue.** Raising a second one while the first is up puts it behind the first; nothing is answered on the reader's behalf.

That matters more than it looks. Resolving the older one `false` to make room would report an answer nobody gave — and at the call site, `false` reads as "they said no", so the code would take the cancelled branch for a question that was never shown.

## Accessibility

- It renders a [Dialog](./dialog), so everything that has is here: the focus trap, the scroll lock, the inert page behind, and focus returning to whatever raised the question.
- The confirming button takes the focus when the sheet opens, so `Enter` answers yes and `Escape` answers no.
- `title` becomes the dialog's accessible name and `description` its `aria-describedby`. A question with neither is a dialog a screen reader announces as nothing — always pass at least a `title`.
