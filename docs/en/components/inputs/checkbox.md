---
title: Checkbox
order: 5
---

# Checkbox

<p class="neba-lede">A single yes/no, or one member of a set of them. Base UI's Checkbox with an acrylic tick on top of it.</p>

<Demo src="checkbox/hero" />

```tsx
import { Checkbox } from 'neba';

<Checkbox label="Remember me" defaultChecked />;
```

## Props

<PropsTable name="Checkbox" />

`label`, `description` and `error` are props rather than children, for the same reason they are on [TextField](./text-field): the arrangement is fixed, and what a caller wants to decide is what goes in each slot. `children` is not accepted at all — anything a checkbox has to say belongs in one of the three.

## Examples

### States

<Demo src="checkbox/states">

<<< @/.vitepress/demos/checkbox/states.tsx

</Demo>

An `error` also turns the checkbox invalid, which re-points the whole colour family at `danger` — the tick, the focus ring and the message all turn over together.

### Mixed

A parent whose children disagree is neither ticked nor unticked. `indeterminate` is a third appearance, not a third value: the checkbox is still either on or off underneath.

<Demo src="checkbox/indeterminate">

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

</Demo>

### Sizes

<Demo src="checkbox/sizes">

<<< @/.vitepress/demos/checkbox/sizes.tsx

</Demo>

## Why the tick is not round

The corner radius on a checkbox is ~30% of its box, not the ~45% the control ladder uses. `--neba-radius-md` is 14px, which on an 18px box is a circle — and a checkbox that is round is a radio button. The intent is the same as everywhere else in the library: a sheet with the corners cut off, never a pill.

## Accessibility

- Renders a real `role="checkbox"` with a hidden `<input>` beside it, so it submits with a form.
- The label is wired to the control by Base UI's Field: clicking the text toggles the box.
- Without a `label`, give it an `aria-label`.
- `indeterminate` reports `aria-checked="mixed"`.
