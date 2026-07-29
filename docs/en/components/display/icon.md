---
title: Icon
order: 7
---

# Icon

<p class="neba-lede">A wrapper that gives an icon glyph the library's size and colour axes. Neba ships no icon set, so the glyph comes from whichever set you chose.</p>

<Demo src="icon/hero" />

```tsx
import { Icon } from 'neba';

<Icon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

## Props

<PropsTable name="Icon" />

The glyph is passed as the `icon` prop rather than as `children`, which is what lets Icon set the size and colour of an element it did not draw: `<Icon icon={<BoltIcon />} />`.

Every native `<span>` attribute passes through.

## Examples

### size

Its own steps rather than the control heights: 14 · 16 · 20 · 24 · 28px. These are the sizes icon sets are actually drawn at, so a glyph lands on the pixel grid and is never resampled.

<Demo src="icon/sizes">

<<< @/.vitepress/demos/icon/sizes.tsx

</Demo>

### color

`color` defaults to `inherit` — the one colour prop in the library that does not default to `primary`. Placed somewhere that has already decided its content colour, like a button label or inside an [Alert](../feedback/alert), the icon takes that colour. Name a role colour explicitly to override it.

<Demo src="icon/colors">

<<< @/.vitepress/demos/icon/colors.tsx

</Demo>

### label

Without `label` the icon is `aria-hidden` and leaves the accessibility tree. That is the default because most icons sit beside text that already says the same thing. Pass `label` only when the glyph carries the meaning on its own.

```tsx
// The text next to it already says "Delete".
<Button startIcon={<Icon icon={<TrashIcon />} />}>Delete</Button>

// There is nothing but the glyph, so it needs a name.
<Icon icon={<TrashIcon />} label="Delete" />
```

For a glyph that is the whole control, use [IconButton](../inputs/icon-button) instead — there `label` is required.
