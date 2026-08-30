---
title: Switch
order: 7
---

# Switch

<p class="neba-lede">Turns a setting on or off immediately. Use it where the change takes effect the moment it is made.</p>

<Demo src="switch/hero" />

```tsx
import { Switch } from 'neba';

<Switch label="Email alerts" defaultChecked />;
```

## Props

<PropsTable name="Switch" />

If there is a Save button underneath and the value is submitted with a form, use [Checkbox](./checkbox) instead. That is what separates the two.

## Examples

### checked and onCheckedChange

`checked` with `onCheckedChange` makes it controlled; `defaultChecked` makes it uncontrolled.

### disabled · readOnly

<Demo src="switch/states">

<<< @/.vitepress/demos/switch/states.tsx

</Demo>

### labelPlacement

`end` (the default) puts the label after the control, so it reads as a caption. `start` suits a settings list, where the labels form a left column and the switches line up on the right.

<Demo src="switch/placement">

<<< @/.vitepress/demos/switch/placement.tsx

</Demo>

### size

<Demo src="switch/sizes">

<<< @/.vitepress/demos/switch/sizes.tsx

</Demo>

### classNames

`className` lands on the field wrapper, not on the track. The track and the thumb are reached through `classNames`.

```tsx
<Switch label="Email alerts" classNames={{ control: 'w-14', thumb: 'rounded-sm' }} />
```

The slots are `label`, `control`, `thumb`, `description` and `error`. `control` is the track — the pill that fills when the switch is on — and `thumb` is the disc that travels across it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

## Accessibility

- Renders `role="switch"` with a hidden `<input>` beside it.
- The label is wired to the control, so clicking the text flips it.
- Without a `label`, give it an `aria-label`.
- The thumb's travel becomes instant under `prefers-reduced-motion`.
