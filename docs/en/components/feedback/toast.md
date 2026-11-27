---
title: Toast
order: 3
flutter: true
---

# Toast

<p class="neba-lede">A notice that appears briefly at the edge of the screen and leaves. Use it to report the result of an action without interrupting what the user is doing.</p>

<Demo src="toast/hero" align="center" minHeight="280" />

::: fw react

```tsx
import { ToastProvider, useToast } from 'neba';

// once, around the app
<ToastProvider position="bottom-end">{children}</ToastProvider>;

// anywhere under it
const toast = useToast();
toast.add({ color: 'success', title: 'Deployed', description: 'production · 4m 02s' });
```

Toasts are raised from a hook rather than rendered as a component. The appearance is decided once on `ToastProvider`; the call site passes only the content.

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

// once, around the app
NebaToastProvider(position: NebaToastPosition.bottomEnd, child: app);

// anywhere under it
NebaToastProvider.of(context).add(
  const NebaToastOptions(
    color: NebaColor.success,
    title: Text('Deployed'),
    description: Text('production · 4m 02s'),
  ),
);
```

Toasts are raised through `NebaToastProvider.of(context)` rather than built as a widget. The appearance is decided once on `NebaToastProvider`; the call site passes only the content.

:::

## Props

### <Fw react="ToastProvider" flutter="NebaToastProvider" />

<PropsTable name="ToastProvider" />

::: fw flutter

The stack is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s popup is, and over everything opened before the newest toast. A provider with no `Overlay` above it brings its own, so it can wrap the navigator in `WidgetsApp.builder` and serve every route:

```dart
WidgetsApp(
  builder: (BuildContext context, Widget? child) => NebaToastProvider(child: child!),
  // …
);
```

The stack keeps out of the safe areas and, at the bottom, from under the keyboard. Put the provider inside `NebaProvider` so the toasts take its theme.

:::

### <Fw react="useToast().add(options)" flutter="NebaToastOptions" />

<PropsTable name="useToast().add" />

::: fw react

Besides `add`, the hook returns `close(id?)`, `update(id, options)`, `promise(promise, { loading, success, error })` and `toasts`. The four methods keep the same identity for the life of the component, while the object around them changes whenever `toasts` does, so list the method rather than the object in an effect's dependencies: `[add]`, not `[toast]`.

:::

::: fw flutter

`NebaToastProvider.of(context)` returns a `NebaToastActions` with `add(options)`, `close([id])`, `update(id, options)`, `promise(future, loading:, success:, error:)` and `toasts`. It is the same object for the life of the provider, and `of` makes the widget depend on nothing, so it can be called from `initState`, from a build or from a press, and a widget that only raises toasts is never built again because one was raised. `toasts` is a `ValueListenable` of the toasts that have not closed, newest first; a widget that shows them listens to it.

:::

::: fw react

### useToastActions()

The same four methods as `useToast`, without `toasts`. `toasts` is a subscription, so a component that calls `useToast` renders again whenever a toast is added, updated or closed anywhere on the page. Give a component that only raises toasts `useToastActions` instead, which never renders it again for that.

```tsx
const { add } = useToastActions();
```

:::

## Examples

### position

::: fw react

Where the stack is pinned, given as one word combining the vertical edge (`top`/`bottom`) with [`NebaAlign`](../../design/prop-conventions).

:::

::: fw flutter

Where the stack is pinned, given as one `NebaToastPosition` that combines the vertical edge with a place along it: `topStart` to `bottomEnd`. `start` and `end` follow the reading direction.

:::

<Demo src="toast/positions" minHeight="320">

::: fw react

<<< @/.vitepress/demos/toast/positions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/positions.dart

:::

</Demo>

### timeout · actionLabel · onAction

`timeout` is how long before the toast closes itself. Give a toast the reader has to act on <Fw react="timeout: 0" flutter="timeout: Duration.zero" code /> so it does not leave on its own. `actionLabel` and `onAction` add a single button to it.

Toasts past `limit` wait out of sight, and their timers run while they wait, so a toast that waits longer than its `timeout` closes without ever having been shown. Give a toast that must be seen <Fw react="timeout: 0" flutter="timeout: Duration.zero" code />, or raise `limit`.

<Demo src="toast/action" minHeight="280">

::: fw react

<<< @/.vitepress/demos/toast/action.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/action.dart

:::

</Demo>

### update and promise

Calling `update` with the `id` that `add` returned refreshes that toast in place, for a single toast that changes state, like "uploading → uploaded". Its timer keeps running; calling `add` again with the same `id` is what starts it over.

::: fw react

```tsx
const toast = useToast();

const id = toast.add({
  title: 'Deleted',
  timeout: 0,
  actionLabel: 'Undo',
  onAction: () => restore(id)
});
toast.update(id, { color: 'success', title: 'Restored' });
```

:::

::: fw flutter

```dart
final NebaToastActions toast = NebaToastProvider.of(context);

late final String id;
id = toast.add(
  NebaToastOptions(
    title: const Text('Deleted'),
    timeout: Duration.zero,
    actionLabel: const Text('Undo'),
    onAction: () => restore(id),
  ),
);
toast.update(id, const NebaToastOptions(color: NebaColor.success, title: Text('Restored')));
```

:::

`promise` runs the same flow from a single <Fw react="Promise" flutter="Future" code />: pass the loading, success and error messages and one toast moves between them.

::: fw flutter

`success` and `error` are functions of the value and of the error, so a message can say what came back. The returned `Future` completes as the one passed in does, its error included.

:::

### classNames

::: fw react

A ToastProvider renders no element of its own (it wraps the app and puts a portalled stack on the page), so there is no `className` here and no `root` slot for one to land on. Every part of the stack is named instead.

```tsx
<ToastProvider classNames={{ viewport: 'p-8', toast: 'font-mono' }}>
  <App />
</ToastProvider>
```

The slots are `viewport`, `toast`, `title`, `description`, `action` and `close`. `viewport` is the strip the toasts are stacked in; `toast` is one of them, and every toast in the stack gets it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

There are no class names. The title, the description and the action's label are widgets, so each takes a style of its own; the sheet, the × and the strip are the provider's.

:::

## Accessibility

::: fw react

- Toasts are announced through a live region, so a message that appeared out of nowhere still reaches a screen reader.
- A toast leaves on its own, so a reader can miss it. A message that is still true a minute from now belongs in an [Alert](./alert), which stays on the page.
- `priority: 'high'` interrupts what a screen reader is saying; the default waits for a pause.
- Timers pause on hover and while the window is blurred. F6 moves focus into the stack.
- The close button stays out of the accessibility tree until the stack is hovered or focused, so a toast is announced as one message rather than as a message and a button.

:::

::: fw flutter

- The title and the description of each toast are a live region, and the action and the × sit outside it, so a toast is read out as one message and its buttons stay within reach. On the web a toast is `SemanticsRole.status`, which waits for a pause, and `priority: NebaToastPriority.high` makes it `SemanticsRole.alert`, which interrupts. Android and iOS have neither role: there a toast is a live region, read out when it appears, and both priorities are read the same way.
- A toast leaves on its own, so a reader can miss it. A message that is still true a minute from now belongs in an [Alert](./alert), which stays on the page.
- Timers hold while a mouse is over the stack, while the keyboard focus is in it, from a finger on it until a finger goes down elsewhere, and while the app is not the focused window.
- The stack is a region named by `label`. F6 moves the focus to the newest toast, which is a focus stop with a ring of its own, and Escape closes the toast holding the focus. The focus then goes to the next toast, or back to where F6 found it.
- The × is drawn at the size of the text beside it, and its target reaches into the padding around it to 24 pixels each way.

:::

- The provider's `locale` names the × on every toast; `closeLabel` writes it out instead.
