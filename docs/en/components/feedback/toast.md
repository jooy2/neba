---
title: Toast
order: 3
---

# Toast

<p class="neba-lede">A message that arrives on its own, over whatever is already on the page.</p>

<Demo src="toast/hero" align="center" />

```tsx
import { ToastProvider, useToast } from 'neba';

// once, around the app
<ToastProvider position="bottom-end">{children}</ToastProvider>;

// anywhere under it
const toast = useToast();
toast.add({ color: 'success', title: 'Deployed', description: 'production · 4m 02s' });
```

## ToastProvider

<PropsTable name="ToastProvider" />

## useToast().add(options)

<PropsTable name="useToast().add" />

Besides `add`, the hook returns `close(id?)`, `update(id, options)`, `promise(promise, { loading, success, error })` and `toasts`.

## Examples

### Where the stack sits

`position` is two words rather than a `side` plus an `align`, because the two are not independent: a toast stack is pinned to the top or the bottom and never to a side. The second half is [`NebaAlign`](../../guide/prop-conventions), the same word every other component uses.

<Demo src="toast/positions">

<<< @/.vitepress/demos/toast/positions.tsx

</Demo>

### Actions, and following a promise

A toast the reader has to act on should not leave before it is read, so give it `timeout: 0`. `promise` is the other half of the same idea: one toast that changes its mind rather than three stacked on each other.

<Demo src="toast/action">

<<< @/.vitepress/demos/toast/action.tsx

</Demo>

## A hook, not a component

What a caller has at the moment a toast is warranted is a click handler, not a place in the tree. A `<Toast open={…}/>` they would have to keep mounted — with a piece of state per message — is the shape this component exists to avoid.

Everything about how a toast _looks_ is decided once, on the provider: where the stack sits, how wide it is, which surface it wears, how long it lasts. The call site stays the one thing it should be — what happened.

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

Reusing an `id` updates that toast in place and restarts its timer, which is what "uploading… / uploaded" wants.

## Toast or Alert?

An [Alert](./alert) belongs to the page it is about and stays there. A toast is about something that just happened somewhere else, and it leaves. If the message is still true a minute from now, it is an Alert.

## Accessibility

Base UI owns the parts that are invisible when they work: the live region that makes a message which appeared out of nowhere reach a screen reader, timers that pause on hover and on window blur, the limit, the swipe, and F6 to move focus into the stack.

`priority: 'high'` interrupts a screen reader; the default waits for a pause. An error is worth interrupting for and a save confirmation is not.

The × is deliberately kept out of the accessibility tree until the stack is hovered or focused, so a toast is announced as one message rather than as a message and a button.
