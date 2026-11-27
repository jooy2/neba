---
title: Popconfirm
order: 12
flutter: true
---

# Popconfirm

<p class="neba-lede">A question asked beside the control that raised it. The small sibling of Confirm, for an act whose consequence is the row it is on rather than the page around it.</p>

<Demo src="popconfirm/hero" frameMinHeight="300" />

::: fw react

```tsx
import { IconButton, Popconfirm } from 'neba';

<Popconfirm
  title="Remove this domain?"
  description="It stops resolving immediately."
  onConfirm={() => remove(id)}
  trigger={<IconButton label="Remove" icon={<TrashIcon />} />}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPopconfirm(
  title: const Text('Remove this domain?'),
  description: const Text('It stops resolving immediately.'),
  onConfirm: () => remove(id),
  trigger: NebaIconButton(onPressed: () {}, label: 'Remove', icon: const TrashIcon()),
);
```

:::

## Props

<PropsTable name="Popconfirm" />

::: fw flutter

The trigger is a widget, as a [Popover](../surfaces/popover)'s is, rather than a builder as a [Dialog](./dialog)'s is: the bubble hangs off the trigger and is placed against it, so the trigger is a Neba control that the popconfirm hears the press of. A button that is only a trigger takes `onPressed: () {}`, as a button with none is disabled. `onConfirm` may return a `Future`; `icon: false` is `showIcon: false`, and there are no `classNames`.

:::

## Examples

### onConfirm and async work

The bubble closes when `onConfirm` **<Fw react="resolves" flutter="completes" />**, not when the button is <Fw react="clicked" flutter="pressed" />. Return a <Fw react="promise" flutter="`Future`" /> and it stays up with its confirming button busy until the work is done. A <Fw react="promise that rejects" flutter="`Future` that completes with an error" /> leaves the bubble open and the button ready again, and the error is not caught, so it reaches the <Fw react="page's own error reporting" flutter="zone it was raised in, and the app's own error reporting with it" />.

::: fw react

```tsx
<Popconfirm title="Revoke the key?" onConfirm={() => api.revoke(id)} trigger={…} />
```

:::

::: fw flutter

```dart
NebaPopconfirm(title: const Text('Revoke the key?'), onConfirm: () => api.revoke(id), trigger: …);
```

:::

### onCancel and dismissing

`onCancel` fires for the cancelling button and **not** for `Escape` or a <Fw react="click" flutter="press" /> outside.

### color and icon

`color` defaults to `danger`. <Fw react="`icon`" flutter="`showIcon`" /> draws that family's severity mark beside the question and is on by default. <Fw react="Pass a node for a mark of your own, or `false` for none." flutter="Pass a widget in `icon` for a mark of your own, drawn at the size and in the colour the `IconTheme` around it hands down, or `showIcon: false` for none." />

### side and align

`side` and `align` place the bubble against its trigger and take the same values as on [Popover](../surfaces/popover) and [Tooltip](./tooltip). `side` defaults to `top`.

## Accessibility

- It renders a [Popover](../surfaces/popover), so focus moves into the bubble and returns to the trigger when it closes.
- `Escape` and a <Fw react="click" flutter="press" /> outside dismiss without answering.
- The trigger needs its own accessible name. An icon-only trigger is an [IconButton](../inputs/icon-button) with a `label`, not a bare glyph.
- The severity mark is <Fw react="`aria-hidden`" flutter="left out of the semantics tree" />, so the title and the description have to say in words what the mark and the colour show.
