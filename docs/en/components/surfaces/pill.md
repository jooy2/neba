---
title: Pill
order: 6
---

# Pill

<p class="neba-lede">A floating lozenge holding a small amount of live information — a recording timer, a boarding gate, a build that is still running.</p>

<Demo src="pill/hero" />

```tsx
import { Pill } from 'neba';

<Pill startIcon={<DotIcon />} color="danger">
  Recording
</Pill>;
```

Three slots: a leading glyph, a middle, a trailing one. Give it `onClick` and the middle becomes a real button; give it `details` and it grows downward into a second half.

## Props

<PropsTable name="Pill" />

Every native `<div>` attribute passes through.

## Examples

### Compact and expanded

The pair is the whole idea being borrowed. The pill grows into its second half by animating a measured height — exactly as an [Accordion](./accordion) panel does, and for the same reason: nothing is transformed, so no text is ever resampled on the way.

<Demo src="pill/expandable">

<<< @/.vitepress/demos/pill/expandable.tsx

</Demo>

The details area is `inert` while it is closed, not merely `aria-hidden`. A zero-height box is one its content is still perfectly focusable inside, and `aria-hidden` alone would leave a keyboard reader tabbing into something their screen reader has been told does not exist.

### Weights and scales

A Pill is a _control_ as far as colour goes, not a container: its surface is the thing being coloured, exactly as on a [Button](../inputs/button) or a [Chip](../display/chip). `color` defaults to `secondary` here rather than `primary`, because the object this shape is borrowed from is very nearly neutral black.

<Demo src="pill/variants">

<<< @/.vitepress/demos/pill/variants.tsx

</Demo>

### Pinned

`position` and `side` are the same vocabulary [Toolbar](./toolbar) uses. `fixed` pins it against the viewport and centres it horizontally, which is the arrangement this shape exists for — and it is centred with auto margins rather than by translating it half its own width, so it stays centred under RTL.

```tsx
<Pill position="fixed" side="top" startIcon={<BuildIcon />} color="info">
  Building — 2 of 7
</Pill>
```

## The round shape

Every other control in the library is held just short of the 50% radius that would make it a pill, because the flat run along its top and bottom edge is what still reads as a sheet with the corners cut off it. This is the exception the rule is drawn against, and it works for the same reason the rule does: a Pill is not a sheet lying on the page. It is an object hovering over one, and an object hovering over the page should not look like it was cut from the same material.

`elevation` defaults to `2` here for that reason, against the `0` everything else defaults to. It is not an inconsistency — a lozenge floating flat on the content it is floating over reads as a mistake.

## When to reach for something else

- A token _inside_ a run of content — a tag, a filter, a status — is a [Chip](../display/chip).
- A bar of controls along the top of a page is a [Toolbar](./toolbar).
- Something the page is waiting on, that the reader cannot dismiss, is an [Overlay](../feedback/overlay); something they can, a [Toast](../feedback/toast).
