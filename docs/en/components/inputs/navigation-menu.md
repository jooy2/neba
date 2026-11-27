---
title: NavigationMenu
order: 30
flutter: true
---

# NavigationMenu

<p class="neba-lede">A site's navigation: a row of destinations, some of which open a panel of more of them. Every row is a real link, which is what puts it in the link list, on the status bar and in a crawler's index.</p>

<Demo src="navigation-menu/hero" minHeight="260" />

::: fw react

```tsx
import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

<NavigationMenu aria-label="Main">
  <NavigationMenuItem label="Product">
    <NavigationMenuLink href="/analytics" title="Analytics" description="Every number." />
  </NavigationMenuItem>
  <NavigationMenuItem label="Pricing" href="/pricing" />
</NavigationMenu>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaNavigationMenu(
  semanticLabel: 'Main',
  children: <Widget>[
    NebaNavigationMenuItem(
      label: const Text('Product'),
      children: <Widget>[
        NebaNavigationMenuLink(
          href: Uri.parse('/analytics'),
          onPressed: openAnalytics,
          title: const Text('Analytics'),
          description: const Text('Every number.'),
        ),
      ],
    ),
    NebaNavigationMenuItem(
      label: const Text('Pricing'),
      href: Uri.parse('/pricing'),
      onPressed: openPricing,
    ),
  ],
);
```

:::

## Props

<PropsTable name="NavigationMenu" />

::: fw react

Every native `<nav>` attribute passes through, apart from `color`.

The difference from a [Menu](./menu) is what the rows _are_. A menu holds actions, so its rows are `menuitem`s. This holds links, so it is a `<nav>` full of `<a>`s. Reach for a Menu when the row does something and for this when the row goes somewhere.

:::

::: fw flutter

`semanticLabel` names the navigation for a screen reader, as `aria-label` does. The panel is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s is.

The difference from a [Menu](./menu) is what the rows _are_. A menu holds actions, so its rows are menu items. This holds links, so it is a navigation region of links, each heard with its `href`. Reach for a Menu when the row does something and for this when the row goes somewhere.

The package opens nothing itself, so a link is a callback: `onPressed` calls the router or a URL launcher, and `href`, a `Uri`, tells a screen reader, and on the web the browser, where it goes. `newTab` takes the place of `target` and `rel`. `delay` and `closeDelay` are `Duration`s. There is no `keepMounted`: it exists so a server render and a crawler see the links, and a closed panel is not built.

:::

### NavigationMenuItem

<PropsTable name="NavigationMenuItem" />

### NavigationMenuLink

<PropsTable name="NavigationMenuLink" />

## Examples

### Items with and without a panel

::: fw react

An item with children is a trigger and a panel; an item with an `href` and nothing else is a link, and the two are announced differently. An item cannot be both: with children, its `href` is not used, and a development build warns in the console. Put that destination in the panel as a `NavigationMenuLink`.

:::

::: fw flutter

An item with children is a trigger and a panel; an item with none is a link, with `onPressed` and `href`, and the two are announced differently. An item cannot be both: with children, its `href` and `onPressed` are not used, and a debug build says so. Put that destination in the panel as a `NebaNavigationMenuLink`.

:::

### columns

How many columns the panel lays its links out in. One is right for a short list; a wide menu of regions or products wants two or three.

<Demo src="navigation-menu/columns" minHeight="220">

::: fw react

<<< @/.vitepress/demos/navigation-menu/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/columns.dart

:::

</Demo>

### orientation

`vertical` stacks the items and opens the panels beside them: a nav rail rather than a bar.

<Demo src="navigation-menu/orientation" minHeight="180">

::: fw react

<<< @/.vitepress/demos/navigation-menu/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/orientation.dart

:::

</Demo>

### In a header

<Demo src="navigation-menu/header" minHeight="220">

::: fw react

<<< @/.vitepress/demos/navigation-menu/header.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/header.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a real `<nav>`; give it an `aria-label` where a page holds more than one.
- Every destination is an `<a href>`, so it can be opened in a new tab, copied, followed by a crawler and reached from a screen reader's link list. A panel's links are rendered, hidden, before the panel first opens, so they are in a server render too; `keepMounted={false}` on an item leaves them out until it opens.
- The row is keyboard-driven: the arrow keys move between items and into an open panel, and Escape closes it.
- A panel resizes between items rather than closing and reopening, so crossing the row reads as one surface.

:::

::: fw flutter

- The navigation is a navigation region to a screen reader; give it a `semanticLabel` where a page holds more than one.
- An item with a panel is a button that says whether it is expanded. An item without one, and every row in a panel, is a link heard with its `href`.
- Every item is a stop of its own in the focus order, and a disabled item that opens a panel keeps its place. The arrow keys along the row move between the items, passing over a disabled one and stopping at the ends, and the arrow across it (down, or towards the inline end beside a rail) opens the panel. Tab from an open item goes into its panel and out of its end to the item after it, and Shift+Tab from there comes back in; inside the panel the arrow keys walk the links, round from one end to the other. Escape closes the panel and gives the focus back to its item, and the focus leaving the navigation closes it.
- One sheet crosses the row: moving between the items changes what is on it and eases it to their size rather than closing it and opening another.

:::
