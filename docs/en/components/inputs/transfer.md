---
title: Transfer
order: 31
flutter: true
---

# Transfer

<p class="neba-lede">Two lists and the arrows between them: everything that could be chosen on one side, everything that has been on the other. For a choice long enough that a field full of chips stops being readable.</p>

<Demo src="transfer/hero" />

::: fw react

```tsx
import { Transfer } from 'neba';

<Transfer
  items={[
    { value: 'status', label: 'Status' },
    { value: 'commit', label: 'Commit' }
  ]}
  value={shown}
  onValueChange={setShown}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTransfer<String>(
  items: const <NebaTransferItem<String>>[
    NebaTransferItem<String>(value: 'status', label: Text('Status')),
    NebaTransferItem<String>(value: 'commit', label: Text('Commit')),
  ],
  value: shown,
  onValueChange: (List<String> next) => setState(() => shown = next),
);
```

:::

## Props

<PropsTable name="Transfer" />

::: fw react

Every native `<div>` attribute passes through, apart from `color`.

:::

::: fw flutter

`NebaTransfer` is generic over the type of its items' values, and `sourceLabel`, `targetLabel` and each item's `label` are widgets, usually a `Text`. `value` left `null` means the transfer keeps its own state from `defaultValue`. It fills the width it is given, a list on each side of the arrows. `name` is not there: nothing submits a Flutter form for the transfer.

:::

### TransferItem

<PropsTable name="TransferItem" />

Below about a dozen options a [Combobox](./combobox) with `multiple`, or a column of [Checkbox](./checkbox)es, is the smaller component. This one earns its size when the answer to "what did I actually pick" needs a list of its own.

## Examples

### value and onValueChange

The value is what is on the **right**, in the order `items` gives, so a row does not move when it is sent across and back. Ticking a row is not choosing it: ticks say which rows the next press moves, and the value says which side they are on.

### searchable

Puts a filter above each list. It hides rows; it never moves them, and a hidden row is not part of a press.

<Demo src="transfer/searchable">

::: fw react

<<< @/.vitepress/demos/transfer/searchable.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/transfer/searchable.dart

:::

</Demo>

### height · disabled

`height` is how tall each list is. A `disabled` item stays in its list and can never be ticked or moved; `disabled` on the whole component does the same to all of them.

<Demo src="transfer/states">

::: fw react

<<< @/.vitepress/demos/transfer/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/transfer/states.dart

:::

</Demo>

::: fw react

### name

With a `name`, each value on the right is submitted with the form under that name, in the order of `value`. `FormData.getAll(name)` reads them all, and a [Form](./form)'s `onSubmit` is handed them as an array. Nothing is submitted while nothing is chosen, or while the Transfer is `disabled`.

```tsx
<Form onSubmit={save}>
  <Transfer items={columns} name="columns" defaultValue={['status', 'commit']} />
  <Button type="submit">Save</Button>
</Form>
```

:::

### locale · sourceLabel · targetLabel

The headings, the buttons and the filter come from `locale`. `sourceLabel` and `targetLabel` write the two headings out instead, which is usually what you want: "Available" and "Selected" are rarely what the two lists actually are.

## Accessibility

- Every row is a real checkbox with its label wired to it, so the whole thing is reachable with Tab and Space.
- The tick above each list is `Select all` for that list, and reports a mixed state while only some rows are ticked.
- Both buttons are named ("Move to selected" and "Move to available"), and go unavailable while there is nothing for them to move.
- After a move a polite status says how many rows moved and to which list ("2 moved to Selected"), in the `locale`'s words.

::: fw flutter

- Each list is heard as a group named by its heading, so the two select-all ticks and the two filters are heard with the list each belongs to.

:::
