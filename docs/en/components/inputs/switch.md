---
title: Switch
order: 7
---

# Switch

<p class="neba-lede">An immediate on/off. The difference from a Checkbox is not visual, it is temporal.</p>

<Demo src="switch/hero" />

```tsx
import { Switch } from 'neba';

<Switch label="Email alerts" defaultChecked />;
```

## Props

<PropsTable name="Switch" />

## Switch or checkbox?

A checkbox is a value that gets submitted with a form. A switch takes effect the moment it moves. If there is a Save button underneath it, it should have been a checkbox.

## Examples

### States

<Demo src="switch/states">

<<< @/.vitepress/demos/switch/states.tsx

</Demo>

### Label placement

`end` reads as a caption for the control. `start` is for a settings list, where the labels form a column and every switch lines up on the right.

<Demo src="switch/placement">

<<< @/.vitepress/demos/switch/placement.tsx

</Demo>

### Sizes

<Demo src="switch/sizes">

<<< @/.vitepress/demos/switch/sizes.tsx

</Demo>

## The two rules it bends

**It is a pill.** Everywhere else the radius stops short of 50%, because the flat run along the top and bottom edge is what reads as a sheet with its corners cut off. A switch is not a sheet — it is a track something runs along, and a track with corners is a track the thumb would have to climb out of.

**Something moves.** This is the only component in the library where anything travels, and it travels on `left`, not on a `transform`. The no-transform rule exists because scaling a control resamples its label; the thumb carries no text, and its movement _is_ the control. Under `prefers-reduced-motion` the travel drops to 0ms with everything else.

## Accessibility

- Renders a real `role="switch"` with a hidden `<input>` beside it.
- The label is wired to the control by Base UI's Field: clicking the text flips it.
- Without a `label`, give it an `aria-label`.
