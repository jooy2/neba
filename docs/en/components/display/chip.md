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

`onClick` makes the whole chip a pressable control. `onDelete` adds a delete button after the label. `selected` marks the chip as on by deepening the surface one step rather than changing the colour family. A pressable chip is announced as a toggle only when `selected` is passed, `false` included; with `onClick` alone it is a plain button.

<Demo src="chip/interactive">

<<< @/.vitepress/demos/chip/interactive.tsx

</Demo>

### href · target · rel

`href` makes the label a link, for a chip that leads somewhere: a tag to its page, a topic to its listing. A crawler can follow it and a reader can open it in a new tab, which a chip with `onClick` does not offer. `target` and `rel` reach the `<a>`; a `target` other than this tab adds `noopener noreferrer` to whatever `rel` says, and ends the link's accessible name with a note that it opens in a new tab, in the `locale`'s words. `onDelete` still adds its button beside the link, not inside it. A selected link chip is marked `aria-current="true"` rather than pressed, and a `disabled` one is not a link.

<Demo src="chip/links">

<<< @/.vitepress/demos/chip/links.tsx

</Demo>

### size

<Demo src="chip/sizes">

<<< @/.vitepress/demos/chip/sizes.tsx

</Demo>

## Accessibility

- The shell is always a `<span>`. `onClick` adds a `<button>` around the content and `href` an `<a>`; `onDelete` adds a second `<button>` beside it. Neither is nested inside the other, so both are reachable by keyboard.
- The delete button is named after the chip's label when the label is a string, "Remove Draft", so a row of chips is a row of buttons a screen reader can tell apart. When the label is a node, give it a `deleteLabel` naming what is being removed.
- `locale` decides the delete button's accessible name; `deleteLabel` writes it out instead.
