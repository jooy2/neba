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

## Examples

### onConfirm and async work

The bubble closes when `onConfirm` **resolves**, not when the button is clicked. Return a promise and it stays up with its confirming button busy until the work is done. A promise that rejects leaves the bubble open and the button ready again, and the error is not caught, so it reaches the page's own error reporting.

```tsx
<Popconfirm title="Revoke the key?" onConfirm={() => api.revoke(id)} trigger={…} />
```

### onCancel and dismissing

`onCancel` fires for the cancelling button and **not** for `Escape` or a click outside.

### color and icon

`color` defaults to `danger`. `icon` draws that family's severity mark beside the question and is on by default. Pass a node for a mark of your own, or `false` for none.

### side and align

`side` and `align` place the bubble against its trigger and take the same values as on [Popover](../surfaces/popover) and [Tooltip](./tooltip). `side` defaults to `top`.

## Accessibility

- It renders a [Popover](../surfaces/popover), so focus moves into the bubble and returns to the trigger when it closes.
- `Escape` and a click outside dismiss without answering.
- The trigger needs its own accessible name. An icon-only trigger is an [IconButton](../inputs/icon-button) with a `label`, not a bare glyph.
- The severity mark is `aria-hidden`, so the title and the description have to say in words what the mark and the colour show.
