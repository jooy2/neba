---
title: Popconfirm
order: 12
---

# Popconfirm

<p class="neba-lede">A question asked beside the control that raised it. The small sibling of Confirm, for an act whose consequence is the row it is on rather than the page around it.</p>

<Demo src="popconfirm/hero" />

```tsx
import { IconButton, Popconfirm } from 'neba';

<Popconfirm
  title="Remove this domain?"
  description="It stops resolving immediately."
  onConfirm={() => remove(id)}
  trigger={<IconButton label="Remove" icon={<TrashIcon />} />}
/>;
```

## Props

<PropsTable name="Popconfirm" />

### Which one to use

The difference from [Confirm](./confirm) is **reach**, not danger and not size.

|                                                  | Use                  |
| ------------------------------------------------ | -------------------- |
| The consequence is this row, this file, this tag | Popconfirm           |
| The consequence reaches past what is on screen   | [Confirm](./confirm) |

A Popconfirm stays anchored to what raised it, so the reader can still see the thing they are about to delete — and losing that is most of what makes a modal feel heavy for a small act. A Confirm takes the page away, which is right when what is about to happen is bigger than the page.

## Examples

### onConfirm and async work

The bubble closes when `onConfirm` **settles**, not when the button is clicked. Return a promise and it stays up with its confirming button busy until the work is done.

```tsx
<Popconfirm title="Revoke the key?" onConfirm={() => api.revoke(id)} trigger={…} />
```

A question that vanished before its answer landed is a question the reader has no way to know was heard.

### onCancel and dismissing

`onCancel` fires for the cancelling button and **not** for `Escape` or a click outside. Walking away from a question is not the same act as answering no, and a caller that undoes something in `onCancel` should not undo it every time somebody presses `Escape`.

### color and icon

`color` defaults to `danger`, because that is what a Popconfirm is usually for, and `icon` draws that family's severity mark beside the question.

The mark is on by default and it is not decoration: a question that says "this is destructive" only in red says it only to some readers, so the shape carries the meaning too. Pass a node for one of your own, or `false` for none.

### side and align

Where the bubble sits against its trigger, from the same vocabulary as [Popover](../surfaces/popover) and [Tooltip](./tooltip). `top` by default — a question about a row is easier to read above it than over the rows below.

## Accessibility

- It renders a [Popover](../surfaces/popover), so focus moves into the bubble and returns to the trigger when it closes.
- `Escape` and a click outside dismiss without answering.
- The trigger needs its own accessible name. An icon-only trigger is an [IconButton](../inputs/icon-button) with a `label`, not a bare glyph.
- The severity mark is `aria-hidden`: it repeats what the words already say, and the colour family it comes from is not information a screen reader can use.
