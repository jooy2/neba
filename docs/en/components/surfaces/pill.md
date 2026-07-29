---
title: Pill
order: 6
---

# Pill

<p class="neba-lede">A lozenge that floats an in-progress status over the page. Use it for information that keeps updating — a recording timer, a build still running.</p>

<Demo src="pill/hero" />

```tsx
import { Pill } from 'neba';

<Pill startIcon={<DotIcon />} color="danger" title="Recording" />;
```

## Props

<PropsTable name="Pill" />

Every native `<div>` attribute passes through except `title`, which here is the pill's headline rather than the browser's tooltip.

The row has three parts: `startIcon` on the leading edge, `endIcon` on the trailing one, and the middle — `title`, `description` and anything in `children` — centred between them with generous padding either side.

`color` defaults to `secondary` and `elevation` to `2` — it is meant to float, so the shadow is on by default.

## Examples

### title and description

`title` is the line the pill is about and `description` is the line under it. Both are optional: a title on its own keeps the row one line tall and the shape a true stadium, and adding a description grows it into a rounded rectangle with the same corner.

<Demo src="pill/text">

<<< @/.vitepress/demos/pill/text.tsx

</Demo>

### startIcon and endIcon

The leading slot is a square box clipped to a circle, so an `<img>` fills and crops it the way an avatar should. The trailing slot sits outside the pressable area, so it can hold a readout or a control of its own.

<Demo src="pill/slots">

<<< @/.vitepress/demos/pill/slots.tsx

</Demo>

### details and expanded

`details` grows a second area beneath the pill. `expanded` makes that controlled, and `onClick` attaches the toggle. It expands by animating its height, the same way an [Accordion](./accordion) panel does.

<Demo src="pill/expandable">

<<< @/.vitepress/demos/pill/expandable.tsx

</Demo>

The details area is `inert` while closed. Focus can still enter a zero-height element, so `aria-hidden` alone would leave a keyboard user tabbing into something invisible.

### variant and size

As far as colour goes a Pill is a control rather than a container — like a [Button](../inputs/button) or a [Chip](../display/chip), the surface itself takes the colour.

<Demo src="pill/variants">

<<< @/.vitepress/demos/pill/variants.tsx

</Demo>

### position and side

The same vocabulary [Toolbar](./toolbar) uses. `fixed` pins it against the viewport and centres it horizontally with auto margins, so it stays centred under RTL.

```tsx
<Pill
  position="fixed"
  side="top"
  startIcon={<BuildIcon />}
  color="info"
  title="Building — 2 of 7"
/>
```

## When to use something else

- A token inside a run of content — a tag, a filter, a status — is a [Chip](../display/chip).
- A bar of controls along the top of a page is a [Toolbar](./toolbar).
- Something the reader has to wait on and cannot dismiss is an [Overlay](../feedback/overlay); something they can dismiss is a [Toast](../feedback/toast).
