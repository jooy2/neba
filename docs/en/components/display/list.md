---
title: List
order: 5
---

# List

<p class="neba-lede">Stacks rows of the same shape vertically. Use it for navigation, settings, search results: anything that repeats.</p>

<Demo src="list/hero" />

```tsx
import { List, ListItem } from 'neba';

<List>
  <ListItem startIcon={<GlobeIcon />} description="Deployed 4 minutes ago" onClick={open} selected>
    production
  </ListItem>
  <ListItem startIcon={<GlobeIcon />} description="Deployed 2 hours ago" onClick={open}>
    staging
  </ListItem>
</List>;
```

## Props

### List

<PropsTable name="List" />

`size` and `density` are set on `List` only. They reach every `ListItem` through a context, so there is no need to repeat them per row.

### ListItem

<PropsTable name="ListItem" />

## Examples

### dividers

`dividers` draws a rule between rows. The rules have to reach both edges of the sheet, so the list's inner padding and the rows' rounded corners go with them: rows become ruled lines rather than floating tiles.

<Demo src="list/dividers">

<<< @/.vitepress/demos/list/dividers.tsx

</Demo>

### variant

Use `variant="text"` inside a [Card](../surfaces/card). The card is already a sheet, so the borders do not double up.

<Demo src="list/variants">

<<< @/.vitepress/demos/list/variants.tsx

</Demo>

### onClick · href · action

`onClick` or `href` makes the whole row a `<button>` or an `<a>` respectively. `action` is a separate control slot **outside** that pressable area: for a row that navigates when pressed but also carries a switch of its own.

<Demo src="list/interactive">

<<< @/.vitepress/demos/list/interactive.tsx

</Demo>

## Accessibility

- `List` sets `role="list"` explicitly, because Tailwind's reset removes the bullets from `<ul>` and Safari drops the list semantics with them.
- A `ListItem` shell is always an `<li>`, with a `<button>` or an `<a>` inside it depending on `onClick` and `href`.
- `selected` puts `aria-current="page"` on a link and `aria-current="true"` on a button. Not `aria-pressed`: a selected row is not a toggle.
