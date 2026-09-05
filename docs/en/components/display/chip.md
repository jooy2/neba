---
title: Chip
order: 3
---

# Chip

<p class="neba-lede">A compact token holding one short value: a tag, a filter, a status. It can also be made clickable or deletable.</p>

<Demo src="chip/hero" />

```tsx
import { Chip } from 'neba';

<Chip>design-system</Chip>
<Chip color="danger" count={12}>Errors</Chip>
<Chip onDelete={remove}>typescript</Chip>;
```

## Props

<PropsTable name="Chip" />

Chip's `size` sits one step below the control heights: an `md` Chip is 26px, the same height as a `sm` [Button](../inputs/button). That separates a token placed inside content from a control the row lines up against.

## Examples

### variant and color

<Demo src="chip/variants">

<<< @/.vitepress/demos/chip/variants.tsx

</Demo>

### startIcon · endIcon · count

`startIcon` and `endIcon` are nodes placed before and after the label. `count` gets its own plate, so "Errors 12" reads as one token with a number on it rather than as two words.

<Demo src="chip/content">

<<< @/.vitepress/demos/chip/content.tsx

</Demo>

### onClick · onDelete · selected

`onClick` makes the whole chip a pressable control. `onDelete` adds a delete button after the label. `selected` marks the chip as on by deepening the surface one step rather than changing the colour family.

<Demo src="chip/interactive">

<<< @/.vitepress/demos/chip/interactive.tsx

</Demo>

### size

<Demo src="chip/sizes">

<<< @/.vitepress/demos/chip/sizes.tsx

</Demo>

## Accessibility

- The shell is always a `<span>`. `onClick` adds a `<button>` around the content; `onDelete` adds a second `<button>` beside it. Neither is nested inside the other, so both are reachable by keyboard.
- With more than one chip on screen, give the delete button a `deleteLabel` naming what is being removed: the default label leaves them indistinguishable.
- `locale` decides the delete button's accessible name; `deleteLabel` writes it out instead.
