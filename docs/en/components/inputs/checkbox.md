---
title: Checkbox
order: 5
---

# Checkbox

<p class="neba-lede">A single item that can be ticked. Use it for a boolean submitted with a form, or for a list where several items can be chosen at once.</p>

<Demo src="checkbox/hero" />

```tsx
import { Checkbox } from 'neba';

<Checkbox label="Remember me" defaultChecked />;
```

## Props

<PropsTable name="Checkbox" />

`label`, `description` and `error` are props rather than `children`; `children` is not accepted.

For a setting that takes effect immediately, use [Switch](./switch). A Checkbox is a value submitted alongside a Save button.

## Examples

### checked and onCheckedChange

`checked` with `onCheckedChange` makes it controlled; `defaultChecked` makes it uncontrolled.

### disabled · readOnly · error

An `error` message also turns the checkbox invalid and re-points the colour family at `danger` — the tick, the focus ring and the message all turn over together.

<Demo src="checkbox/states">

<<< @/.vitepress/demos/checkbox/states.tsx

</Demo>

### indeterminate

A third appearance for a parent checkbox whose children disagree. The value underneath is still on or off; `indeterminate` only affects what is drawn.

<Demo src="checkbox/indeterminate">

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

</Demo>

### size

<Demo src="checkbox/sizes">

<<< @/.vitepress/demos/checkbox/sizes.tsx

</Demo>

## Accessibility

- Renders `role="checkbox"` with a hidden `<input>` beside it, so giving it a `name` submits it with a form.
- The label is wired to the control, so clicking the text toggles the box.
- Without a `label`, give it an `aria-label`.
- `indeterminate` reports `aria-checked="mixed"`.
