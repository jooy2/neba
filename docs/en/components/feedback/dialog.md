---
title: Dialog
order: 2
flutter: true
---

# Dialog

<p class="neba-lede">A modal sheet that covers the page until it is answered. Use it to confirm an action or to take input that has to interrupt the flow.</p>

<Demo src="dialog/hero" align="center" frameMinHeight="300" />

::: fw react

```tsx
import { Button, Dialog, DialogClose } from 'neba';

<Dialog
  trigger={<Button color="danger">Delete workspace</Button>}
  title="Delete this workspace?"
  description="Every project, deploy and log inside it goes with it."
  actions={<DialogClose render={<Button color="danger">Delete</Button>} />}
>
  This cannot be undone.
</Dialog>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDialog(
  triggerBuilder: (BuildContext context, VoidCallback open) {
    return NebaButton(
      onPressed: open,
      color: NebaColor.danger,
      child: const Text('Delete workspace'),
    );
  },
  title: const Text('Delete this workspace?'),
  description: const Text('Every project, deploy and log inside it goes with it.'),
  actions: <Widget>[
    NebaDialogClose(
      builder: (BuildContext context, VoidCallback close) {
        return NebaButton(onPressed: close, color: NebaColor.danger, child: const Text('Delete'));
      },
    ),
  ],
  child: const Text('This cannot be undone.'),
);
```

:::

## Props

<PropsTable name="Dialog" />

::: fw react

Native `<div>` attributes pass through to the popup. Only `color`, `title` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

The trigger is a builder, as a [Drawer](../surfaces/drawer)'s is: `triggerBuilder` is called with the callback that opens the dialog, and what it builds stays where the dialog was written. A [Popover](../surfaces/popover) takes its trigger as a widget instead, because the popup hangs off it and is placed against it; a dialog hangs off nothing, so any widget can open it, a row or a gesture as well as a Neba control.

A dialog opens into the app's root `Overlay`, which a `WidgetsApp` with a navigator already has; an app built without one wraps its home in `Overlay.wrap`. The sheet is built where the dialog was written, so it keeps the theme and the `NebaProvider` defaults from there. `initialFocus` and `finalFocus` take a `FocusNode` rather than a ref or a function, `role` is the React `role` attribute and `semanticLabel` its `aria-label`.

:::

There is no `variant` and no `elevation`: a modal always carries a level-3 shadow.

## Examples

### size and width

`size` sets the type scale and the padding along with the sheet's maximum width. When you need to break that pairing (small type on a wide sheet for a table or a diff), set <Fw react="a length in `width`" flutter="`width` in logical pixels" />.

<Demo src="dialog/sizes" frameMinHeight="340">

::: fw react

<<< @/.vitepress/demos/dialog/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/dialog/sizes.dart

:::

</Demo>

### dividers

With a long body, only the body scrolls; the heading and the actions stay put. `dividers` rules those boundaries, which is what shows the header did not scroll away.

<Demo src="dialog/scrolling" frameMinHeight="460">

::: fw react

<<< @/.vitepress/demos/dialog/scrolling.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/dialog/scrolling.dart

:::

</Demo>

### dismissible

<Fw react="`dismissible={false}`" flutter="`dismissible: false`" /> blocks both Escape and the <Fw react="click" flutter="press" /> outside. Turn it off only when `actions` holds a button that answers the dialog: otherwise there is no way out.

<Demo src="dialog/controlled" frameMinHeight="340">

::: fw react

<<< @/.vitepress/demos/dialog/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/dialog/controlled.dart

:::

</Demo>

### <Fw react="DialogClose" flutter="NebaDialogClose" />

::: fw react

Closes the dialog from a button without owning the `open` state yourself. Use `render` to put the control you want inside it.

```tsx
actions={
  <>
    <DialogClose render={<Button variant="text" color="secondary">Cancel</Button>} />
    <DialogClose render={<Button color="danger">Delete</Button>} />
  </>
}
```

:::

::: fw flutter

Closes the dialog from a button without owning the `open` state yourself. Its `builder` is handed the callback that closes the dialog it is inside, whether or not the dialog is `dismissible`.

```dart
actions: <Widget>[
  NebaDialogClose(
    builder: (BuildContext context, VoidCallback close) => NebaButton(
      onPressed: close,
      variant: NebaVariant.text,
      color: NebaColor.secondary,
      child: const Text('Cancel'),
    ),
  ),
  NebaDialogClose(
    builder: (BuildContext context, VoidCallback close) =>
        NebaButton(onPressed: close, color: NebaColor.danger, child: const Text('Delete')),
  ),
],
```

:::

::: fw react

### classNames

`className` lands on the popup: the sheet itself, which is what a caller means by "the dialog". Everything around and inside it is reached through `classNames`.

```tsx
<Dialog
  title="Delete this?"
  classNames={{ backdrop: 'backdrop-blur-none', actions: 'justify-between' }}
/>
```

The slots are `backdrop`, `viewport`, `title`, `description`, `close`, `body` and `actions`. The first two are the ones with no other way in: both render at the end of `<body>`, outside the popup, so no selector written against the sheet finds them. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

### fullScreen

`fullScreen` fills the window edge to edge with square corners, for an editor or a phone-sized screen. The sheet runs under the system's insets and what is on it is held clear of them: the status bar, a notch, the home indicator and the keyboard. A sheet that is not full screen keeps a 16-pixel margin from the window besides the insets, and shrinks above the keyboard, so its body scrolls rather than disappearing under it.

```dart
NebaDialog(fullScreen: true, title: const Text('Edit the post'), child: editor);
```

:::

## Accessibility

::: fw react

- `title` and `description` are wired into `aria-labelledby` and `aria-describedby`. The title renders as a real `<h2>`.
- The focus trap, the scroll lock, the inert page behind, and focus returning to the trigger on close are all handled.
- `showClose` is on by default. The way out of a modal should always be visible, and it is also what a touch screen reader uses to escape the popup.
- `locale` decides the ×'s accessible name; `closeLabel` writes it out instead.

:::

::: fw flutter

- The sheet is a dialog that scopes the route: a screen reader reads only the dialog, the first thing in it that takes the focus has it, Tab goes round inside it, and the focus returns to what had it before when it closes.
- `title` is a heading at level 2 and names the dialog. Flutter has no counterpart of `aria-describedby`, so `description` is read after the title, in reading order. A dialog with no title takes a `semanticLabel`.
- `dismissible: false` cancels Escape, the press outside and a screen reader's dismiss gesture. `role: SemanticsRole.alertDialog` makes it a question that has to be answered, announced with more urgency.
- `showClose` is on by default. The way out of a modal should always be visible, and it is also what a touch screen reader uses to escape the popup.
- `locale` decides the ×'s name; `closeLabel` writes it out instead.

:::
