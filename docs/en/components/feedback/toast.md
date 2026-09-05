---
title: Toast
order: 3
---

# Toast

<p class="neba-lede">A notice that appears briefly at the edge of the screen and leaves. Use it to report the result of an action without interrupting what the user is doing.</p>

<Demo src="toast/hero" align="center" />

```tsx
import { ToastProvider, useToast } from 'neba';

// once, around the app
<ToastProvider position="bottom-end">{children}</ToastProvider>;

// anywhere under it
const toast = useToast();
toast.add({ color: 'success', title: 'Deployed', description: 'production · 4m 02s' });
```

Toasts are raised from a hook rather than rendered as a component. The appearance is decided once on `ToastProvider`; the call site passes only the content.

## Props

### ToastProvider

<PropsTable name="ToastProvider" />

### useToast().add(options)

<PropsTable name="useToast().add" />

Besides `add`, the hook returns `close(id?)`, `update(id, options)`, `promise(promise, { loading, success, error })` and `toasts`.

## Examples

### position

Where the stack is pinned, given as one word combining the vertical edge (`top`/`bottom`) with [`NebaAlign`](../../design/prop-conventions).

<Demo src="toast/positions">

<<< @/.vitepress/demos/toast/positions.tsx

</Demo>

### timeout · actionLabel · onAction

`timeout` is how long before the toast closes itself. Give a toast the reader has to act on `timeout: 0` so it does not leave on its own. `actionLabel` and `onAction` add a single button to it.

<Demo src="toast/action">

<<< @/.vitepress/demos/toast/action.tsx

</Demo>

### update and promise

Calling `update` with the `id` that `add` returned refreshes that toast in place and restarts its timer: for a single toast that changes state, like "uploading → uploaded".

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

`promise` runs the same flow from a single Promise: pass the loading, success and error messages and one toast moves between them.

### classNames

A ToastProvider renders no element of its own (it wraps the app and puts a portalled stack on the page), so there is no `className` here and no `root` slot for one to land on. Every part of the stack is named instead.

```tsx
<ToastProvider classNames={{ viewport: 'p-8', toast: 'font-mono' }}>
  <App />
</ToastProvider>
```

The slots are `viewport`, `toast`, `title`, `description`, `action` and `close`. `viewport` is the strip the toasts are stacked in; `toast` is one of them, and every toast in the stack gets it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

## Toast or Alert

An [Alert](./alert) belongs to its page and stays there. A toast reports something that just happened and leaves. If the message is still true a minute from now, use an Alert.

## Accessibility

- Toasts are announced through a live region, so a message that appeared out of nowhere still reaches a screen reader.
- `priority: 'high'` interrupts what a screen reader is saying; the default waits for a pause.
- Timers pause on hover and while the window is blurred. F6 moves focus into the stack.
- The close button stays out of the accessibility tree until the stack is hovered or focused, so a toast is announced as one message rather than as a message and a button.
- The provider's `locale` names the × on every toast; `closeLabel` writes it out instead.
