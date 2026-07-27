---
title: IconButton
order: 14
---

# IconButton

<p class="neba-lede">A round button with a glyph in it and nothing else — and a name it will not let you forget.</p>

<Demo src="icon-button/hero" />

```tsx
import { IconButton } from 'neba';

<IconButton icon={<PlusIcon />} label="Add item" />;
```

A [Button](./button) with an icon and no children already goes square: the same height, the same width, the acrylic corners cut off it. This is the other shape — a disc.

Everything else is Button's, unchanged and on purpose: the variants, the elevation ladder, the pointer light, `loading`, `readOnly`, and the values a surrounding [ButtonGroup](./button-group) sets. Two components drawing the same surface from two copies of the same table are two components that will eventually disagree.

## Props

<PropsTable name="IconButton" />

Every native `<button>` attribute passes through.

## Examples

### Sizes

The same control heights everything else uses, so a disc drops into a row of buttons without the row losing its baseline.

<Demo src="icon-button/sizes">

<<< @/.vitepress/demos/icon-button/sizes.tsx

</Demo>

### States

<Demo src="icon-button/states">

<<< @/.vitepress/demos/icon-button/states.tsx

</Demo>

## Why `label` is required

A button whose whole label is a drawing has no accessible name at all. "An icon button with no `aria-label`" is the single most common accessibility defect a component library ships, and the only fix that survives review is to make the name impossible to leave out — so it is a required prop rather than an optional one.

```tsx
// Won't compile.
<IconButton icon={<TrashIcon />} />

// Will.
<IconButton icon={<TrashIcon />} label="Delete file" />
```

Pair it with a [Tooltip](../feedback/tooltip) when the name should also be visible to a reader who can see the glyph but cannot guess it.

## The round corner

The house radius rule holds every corner just short of the 50% that would make a control a pill, because the flat run along the top and bottom edge is what still reads as a sheet with its corners cut. A disc breaks that, deliberately.

The rule is about _labelled_ controls: the flat run is there for the line of text to sit on, and a glyph has no line of text. A circle with a single mark centred in it is a punched token rather than a moulded key, so it protects the thing the rule exists to protect by a different route. When a square icon control is what a layout wants — inside a ButtonGroup, in a dense table row — use a Button with no children and it will already be one.

## Coming from Material UI

| MUI | Neba |
| --- | --- |
| `<IconButton><Add /></IconButton>` | `icon={<Add />}`, and `label` is required |
| `size="small"` | `size="sm"` — the five-step ladder, and it is a control height |
| `edge="start"` | Not offered. Use the layout around it |
| `color="error"` | `color="danger"` |
| `disabled` | The same. `loading` and `readOnly` are also here, from Button |
