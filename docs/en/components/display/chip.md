---
title: Chip
order: 3
---

# Chip

<p class="neba-lede">A compact token: a tag, a filter, a status, an entity plucked out of a list.</p>

<Demo src="chip/hero" />

```tsx
import { Chip } from 'neba';

<Chip>design-system</Chip>
<Chip color="danger" count={12}>Errors</Chip>
<Chip onDelete={remove}>typescript</Chip>;
```

## Props

<PropsTable name="Chip" />

## Examples

### Variants and colours

<Demo src="chip/variants">

<<< @/.vitepress/demos/chip/variants.tsx

</Demo>

### Icons and counts

A `count` gets its own small plate, so "Errors 12" reads as one token with a number on it rather than as two words. On a filled chip the plate is a hole punched in the fill; on a tinted or bare one it is the accent showing through.

<Demo src="chip/content">

<<< @/.vitepress/demos/chip/content.tsx

</Demo>

### Clickable and deletable

`selected` deepens the surface one step rather than changing the colour family — a filter that is on is still the same filter.

<Demo src="chip/interactive">

<<< @/.vitepress/demos/chip/interactive.tsx

</Demo>

### Sizes

<Demo src="chip/sizes">

<<< @/.vitepress/demos/chip/sizes.tsx

</Demo>

## A chip is one step down the ladder

A `md` chip is a `sm` control — 26px, not 32px. That is the whole visual difference between a Chip and a Button, and it is deliberate: a chip is a token _inside_ a row of content, not a control the row lines up against. At full control height an outline chip and an outline button are the same object, and a screen full of them says nothing about which one can be pressed.

Every other library reaches for a pill radius to make that distinction, which this one cannot — the flat run along a sheet's top and bottom edge is the point of the whole [design language](../../guide/design-language).

## Accessibility

The shell is always a `<span>`. What changes is what is inside it: a plain run of content, or — when `onClick` is given — a real `<button>` wrapping that content, plus a second button for `onDelete`.

Both are reachable by keyboard and neither is nested inside the other. An inert `<span>` carrying a click handler is the most common way a component library loses its keyboard users; a `<button>` inside a `<button>` is the most common way it invents markup the browser silently rewrites. This shape avoids both.

Give the delete button a `deleteLabel` naming what is being removed when there is more than one chip on screen.
