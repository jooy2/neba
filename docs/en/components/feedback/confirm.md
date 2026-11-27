---
title: Confirm
order: 11
flutter: true
---

# Confirm

<p class="neba-lede">A question asked in a dialog, awaited like any other answer. The function a provider hands out resolves to what the reader pressed, so the code that asks is the code that acts.</p>

<Demo src="confirm/hero" frameMinHeight="300" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaConfirmProvider(child: app);

// anywhere under it
final NebaConfirm confirm = NebaConfirmProvider.of(context);

if (await confirm(
  const NebaConfirmOptions(title: Text('Delete the project?'), color: NebaColor.danger),
)) {
  remove();
}
```

:::

## Props

<PropsTable name="ConfirmProvider" />

### The options

<PropsTable name="ConfirmOptions" />

::: fw react

`confirm('Delete the project?')` is shorthand for `confirm({ title: 'Delete the project?' })`.

:::

::: fw flutter

`NebaConfirmProvider.of(context)` is the React package's `useConfirm()`. It returns a `NebaConfirm`, which is called like a function and is the same object for the life of the provider, so it can be fetched in `initState` or in a press handler and kept. It does not make the widget depend on the provider, so asking never builds the asker again. `maybeOf` returns `null` where there is no provider.

The question is always a `NebaConfirmOptions`: Dart has no union of a string and an object, so there is no string shorthand, and the title and the labels are widgets, usually a `Text`. The dialog opens into the root `Overlay` above the provider, and a provider with none above it brings its own, so it can wrap the navigator in `WidgetsApp.builder`.

:::

## Examples

### Return value

<Fw react="`confirm()` resolves" flutter="The future `confirm()` returns completes with" /> `true` when the reader confirms, and `false` when they cancel, press `Escape` or <Fw react="click the backdrop" flutter="press outside the sheet" />. It never <Fw react="rejects" flutter="completes with an error" />.

When the <Fw react="`ConfirmProvider` unmounts" flutter="`NebaConfirmProvider` leaves the tree" />, every question still on the sheet or waiting behind it <Fw react="resolves" flutter="is answered" /> `false`, and so does a `confirm()` called after that.

### color and destructive questions

Most confirms are about destroying something. <Fw react="`color: 'danger'`" flutter="`color: NebaColor.danger`" /> turns the confirming button and the sheet's accents over together.

::: fw react

```tsx
await confirm({
  title: 'Delete 12 files?',
  description: 'They go to the trash and are removed after 30 days.',
  confirmLabel: 'Move to trash',
  color: 'danger'
});
```

:::

::: fw flutter

```dart
await confirm(
  const NebaConfirmOptions(
    title: Text('Delete 12 files?'),
    description: Text('They go to the trash and are removed after 30 days.'),
    confirmLabel: Text('Move to trash'),
    color: NebaColor.danger,
  ),
);
```

:::

### alert

`alert` drops the cancelling button and leaves one way out, for telling rather than asking. It still <Fw react="resolves" flutter="answers" />, always `true`, even when `Escape` or the <Fw react="backdrop" flutter="press outside" /> closes the sheet, so the same `await` works either way.

::: fw react

```tsx
await confirm({ title: 'Your export is ready.', alert: true });
```

:::

::: fw flutter

```dart
await confirm(const NebaConfirmOptions(title: Text('Your export is ready.'), alert: true));
```

:::

### dismissible

`false` makes a question the reader has to answer with a button, and `Escape` and the <Fw react="backdrop" flutter="press outside" /> no longer close the sheet. Use it only where an accidental dismissal is the expensive answer.

### defaults

<Fw react="`ConfirmProvider`" flutter="`NebaConfirmProvider`" /> takes the settings every question under it shares, and each call overrides them.

::: fw react

```tsx
<ConfirmProvider defaults={{ size: 'md', locale: 'ko' }}>
```

:::

::: fw flutter

```dart
NebaConfirmProvider(
  defaults: const NebaConfirmOptions(size: NebaSize.md, locale: Locale('ko')),
  child: app,
);
```

:::

### Queued questions

Raising a second question while the first is up puts it behind the first. Nothing is answered on the reader's behalf, so while the provider is <Fw react="mounted" flutter="in the tree" /> each <Fw react="promise resolves" flutter="future completes" /> only when the reader answers its own question. <Fw flutter="A question asked while the screen is being built, from a widget's `initState`, waits for that frame to finish and then opens." />

## Accessibility

- It renders a [Dialog](./dialog), so everything that has is here: the focus held inside, the <Fw react="scroll lock, the inert page behind" flutter="page behind taking no press" />, and focus returning to whatever raised the question.
- The sheet is <Fw react="an `alertdialog`" flutter="an alert dialog, `SemanticsRole.alertDialog`" />: a question that has to be answered before anything else happens.
- The confirming button takes the focus when the sheet opens, so `Enter` answers yes and `Escape` answers no. A `danger` question opens on the cancelling button instead, so the `Enter` that asked is not followed by one that destroys.
- A question that takes over the sheet from the one before it opens as a sheet of its own, so the focus moves to its own answer and its title is announced.
- Once the last queued question is answered, the focus goes back to <Fw react="the element" flutter="what" /> held it when the first was asked.
- `title` becomes the dialog's <Fw react="accessible name and `description` its `aria-describedby`" flutter="name, and `description` is read after it" />. A question with neither is a dialog a screen reader announces as nothing: always pass at least a `title`.
