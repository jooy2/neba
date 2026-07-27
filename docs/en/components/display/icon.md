---
title: Icon
order: 7
---

# Icon

<p class="neba-lede">A glyph at a known size, in a known colour. Neba ships no icon set — it gives whatever set you chose the same two axes everything else here has.</p>

<Demo src="icon/hero" />

```tsx
import { Icon } from 'neba';

<Icon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

An icon set is a decision about how an application looks, and a component library has no business making it. What is missing without one is smaller and duller: every icon arrives at whatever size its author drew it at, carrying whatever colour it was given, and both have to be undone at the call site.

**The glyph is a prop, not `children`.** That is the whole design. An icon set hands you an element you did not draw, and the two things you always want to change about it — how big it is and what colour it is — are the two things you cannot reach once it is a child of something. As a prop it is content the Icon _sizes_, rather than content the Icon merely wraps.

## Props

<PropsTable name="Icon" />

Every native `<span>` attribute passes through.

## Examples

### Sizes

Its own ladder, not the control heights: 14, 16, 20, 24 and 28px. An icon is not a control, and a `md` glyph at the 32px a `md` button is would be the size of the button it usually sits in. The steps are the sizes icon sets are actually drawn at, so a glyph lands on its own grid and never has to be resampled.

<Demo src="icon/sizes">

<<< @/.vitepress/demos/icon/sizes.tsx

</Demo>

### Colour, and inheriting it

`color` is the one colour prop in the library that does not default to `primary`. An icon is content, and the overwhelmingly common case is an icon inside something that has already decided what colour its content is — a Button's label, a muted caption, an Alert's own family. An Icon that arrived pre-dyed blue would have to be turned off again at every one of those.

<Demo src="icon/colors">

<<< @/.vitepress/demos/icon/colors.tsx

</Demo>

### Saying something, or saying nothing

Without `label` the icon is hidden from the accessibility tree entirely, and that is the right default: most icons sit next to a word that already says the same thing, and reading both out loud is worse than reading one. Pass `label` only when the glyph is carrying the meaning by itself.

```tsx
// The word next to it already says "Delete".
<Button startIcon={<Icon icon={<TrashIcon />} />}>Delete</Button>

// Nothing else says it, so the icon has to.
<Icon icon={<TrashIcon />} label="Delete" />
```

For a glyph that is the _whole_ control, reach for [IconButton](../inputs/icon-button) instead — it makes the name required rather than optional.

## Coming from Material UI

| MUI | Neba |
| --- | --- |
| `<Icon>star</Icon>` | Not offered. Neba ships no font-based icon set; pass an element |
| `<SvgIcon>…</SvgIcon>` | `icon={<svg …/>}` |
| `fontSize="small"` | `size="sm"` — the same five-step ladder as everything else |
| `color="error"` | `color="danger"`, and the default is `inherit` rather than a family |
| <code v-pre>sx={{ fontSize: 34 }}</code> | Not offered. Sizes are steps on a ladder, not arbitrary numbers |
