---
title: Transfer
order: 31
---

# Transfer

<p class="neba-lede">Two lists and the arrows between them: everything that could be chosen on one side, everything that has been on the other. For a choice long enough that a field full of chips stops being readable.</p>

<Demo src="transfer/hero" />

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

## Props

<PropsTable name="Transfer" />

Every native `<div>` attribute passes through, apart from `color`.

### TransferItem

<PropsTable name="TransferItem" />

Below about a dozen options a [Combobox](./combobox) with `multiple`, or a column of [Checkbox](./checkbox)es, is the smaller component. This one earns its size when the answer to "what did I actually pick" needs a list of its own.

## Examples

### value and onValueChange

The value is what is on the **right**, in the order `items` gives, so a row does not move when it is sent across and back. Ticking a row is not choosing it: ticks say which rows the next press moves, and the value says which side they are on.

### searchable

Puts a filter above each list. It hides rows; it never moves them, and a hidden row is not part of a press.

<Demo src="transfer/searchable">

<<< @/.vitepress/demos/transfer/searchable.tsx

</Demo>

### height · disabled

`height` is how tall each list is. A `disabled` item stays in its list and can never be ticked or moved; `disabled` on the whole component does the same to all of them.

<Demo src="transfer/states">

<<< @/.vitepress/demos/transfer/states.tsx

</Demo>

### locale · sourceLabel · targetLabel

The headings, the buttons and the filter come from `locale`. `sourceLabel` and `targetLabel` write the two headings out instead, which is usually what you want: "Available" and "Selected" are rarely what the two lists actually are.

## Accessibility

- Every row is a real checkbox with its label wired to it, so the whole thing is reachable with Tab and Space.
- The tick above each list is `Select all` for that list, and reports a mixed state while only some rows are ticked.
- Both buttons are named ("Move to selected" and "Move to available"), and go unavailable while there is nothing for them to move.
