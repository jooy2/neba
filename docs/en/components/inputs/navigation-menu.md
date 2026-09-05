---
title: NavigationMenu
order: 30
---

# NavigationMenu

<p class="neba-lede">A site's navigation: a row of destinations, some of which open a panel of more of them. Every row is a real link, which is what puts it in the link list, on the status bar and in a crawler's index.</p>

<Demo src="navigation-menu/hero" />

```tsx
import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

<NavigationMenu aria-label="Main">
  <NavigationMenuItem label="Product">
    <NavigationMenuLink href="/analytics" title="Analytics" description="Every number." />
  </NavigationMenuItem>
  <NavigationMenuItem label="Pricing" href="/pricing" />
</NavigationMenu>;
```

## Props

<PropsTable name="NavigationMenu" />

Every native `<nav>` attribute passes through, apart from `color`.

The difference from a [Menu](./menu) is what the rows _are_. A menu holds actions, so its rows are `menuitem`s. This holds links, so it is a `<nav>` full of `<a>`s. Reach for a Menu when the row does something and for this when the row goes somewhere.

### NavigationMenuItem

<PropsTable name="NavigationMenuItem" />

### NavigationMenuLink

<PropsTable name="NavigationMenuLink" />

## Examples

### Items with and without a panel

An item with children is a trigger and a panel; an item with an `href` and nothing else is a link, and the two are announced differently.

### columns

How many columns the panel lays its links out in. One is right for a short list; a wide menu of regions or products wants two or three.

<Demo src="navigation-menu/columns">

<<< @/.vitepress/demos/navigation-menu/columns.tsx

</Demo>

### orientation

`vertical` stacks the items and opens the panels beside them: a nav rail rather than a bar.

<Demo src="navigation-menu/orientation">

<<< @/.vitepress/demos/navigation-menu/orientation.tsx

</Demo>

### In a header

<Demo src="navigation-menu/header">

<<< @/.vitepress/demos/navigation-menu/header.tsx

</Demo>

## Accessibility

- Renders a real `<nav>`; give it an `aria-label` where a page holds more than one.
- Every destination is an `<a href>`, so it can be opened in a new tab, copied, followed by a crawler and reached from a screen reader's link list.
- The row is keyboard-driven: the arrow keys move between items and into an open panel, and Escape closes it.
- A panel resizes between items rather than closing and reopening, so crossing the row reads as one surface.
