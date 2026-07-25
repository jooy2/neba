---
title: List
order: 5
---

# List

<p class="neba-lede">A stack of rows: navigation, settings, results, anything that repeats.</p>

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

## List

<PropsTable name="List" />

## ListItem

<PropsTable name="ListItem" />

## Examples

### Tiles or rules

`dividers` changes more than it sounds like. With the rules on, the lines have to reach both edges of the sheet, so the list gives up its inner padding and the rows give up their rounded corners: a row cannot be a floating tile and a ruled line at the same time.

<Demo src="list/dividers">

<<< @/.vitepress/demos/list/dividers.tsx

</Demo>

### Inside a Card

`variant="text"` is the one to reach for there. The card is already a sheet, and a second bordered rectangle inside it is a rectangle too many.

<Demo src="list/variants">

<<< @/.vitepress/demos/list/variants.tsx

</Demo>

### A row with a control on it

`action` sits outside the pressable area on purpose. A row that both navigates and holds a switch has two things to press, and one of them cannot be nested inside the other — a `<button>` inside a `<button>` is markup the browser rewrites on parse.

<Demo src="list/interactive">

<<< @/.vitepress/demos/list/interactive.tsx

</Demo>

## Two components, one axis each

`size` and `density` are properties of the stack, not of any one line in it, so they live on `List` and reach the rows through a context. Setting them per row would be two chances per row to get one wrong, and the failure is silent: a list where item four is a size bigger than the rest.

A context rather than `React.Children.map` with `cloneElement`, for the same reason [ButtonGroup](../inputs/button-group) uses one — the moment a caller `.map()`s their data or wraps a row in a [Tooltip](../feedback/tooltip), cloning stops reaching the item.

## No primitive underneath

There is no Base UI component under this, on purpose. A list is not a composite widget: it has no roving focus, no selection model, no keyboard contract of its own. Reaching for a menu or a listbox primitive to get one would hand every consumer's plain list of links the semantics of a menu, which is one of the most common ways a component library breaks a screen reader.

## Accessibility

The shell is always an `<li>`. What changes is what is inside it: a plain run of content, or — when `onClick` or `href` is given — a real `<button>` or `<a>` wrapping it.

`selected` puts `aria-current="page"` on a link and `aria-current="true"` on a button. Not `aria-pressed`, which would be a third thing: a toggle. A selected row is not a toggle.

The list says `role="list"` out loud, because Tailwind's reset takes the bullets off every `<ul>` and Safari takes the list semantics off with them.
