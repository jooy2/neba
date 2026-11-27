---
title: Menubar
order: 29
flutter: true
---

# Menubar

<p class="neba-lede">The strip of words at the top of an application (File, Edit, View), each of which opens a menu. Once one is open, moving along the strip walks through the others rather than closing the one you left.</p>

<Demo src="menubar/hero" />

::: fw react

```tsx
import { Menubar, MenubarMenu, MenuItem, MenuSeparator } from 'neba';

<Menubar>
  <MenubarMenu label="File">
    <MenuItem shortcut="⌘N">New file</MenuItem>
    <MenuSeparator />
    <MenuItem>Open…</MenuItem>
  </MenubarMenu>
</Menubar>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaMenubar(
  children: <Widget>[
    NebaMenubarMenu(
      label: const Text('File'),
      children: <Widget>[
        NebaMenuItem(onPressed: create, shortcut: const Text('⌘N'), child: const Text('New file')),
        const NebaMenuSeparator(),
        NebaMenuItem(onPressed: open, child: const Text('Open…')),
      ],
    ),
  ],
);
```

:::

## Props

<PropsTable name="Menubar" />

::: fw react

Every native `<div>` attribute passes through, apart from `color`.

:::

::: fw flutter

`semanticLabel` names the bar for a screen reader, as `aria-label` does. Each menu's popup is drawn in the app's root `Overlay`, as a [Menu](./menu)'s is.

:::

It draws no surface of its own. A menu bar sits _on_ something (a [Toolbar](../surfaces/toolbar), a [WindowPane](../surfaces/window-pane)'s title bar, a [Header](../layout/header)), and a sheet under a strip that is already on a sheet is two sheets.

### MenubarMenu

<PropsTable name="MenubarMenu" />

The rows are the same `MenuItem`, `MenuSeparator`, `MenuGroup`, `MenuCheckboxItem`, `MenuRadioGroup` and `MenuSubmenu` a [Menu](./menu) takes, because it is the same menu. `size`, `color` and `density` belong to the bar and are not repeated here.

## Examples

### Nested and checkable rows

Everything a Menu can hold, a menu on the bar can hold: submenus, groups, checkboxes and radio rows.

### size

Its own ladder, one rung below the control heights at every step: a menu bar is a strip of words rather than a row of buttons, and it usually sits inside something that already has a height.

<Demo src="menubar/sizes" minHeight="200">

::: fw react

<<< @/.vitepress/demos/menubar/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menubar/sizes.dart

:::

</Demo>

### orientation

`vertical` stacks the words instead, the arrow keys follow, and each menu opens beside the bar at its inline end rather than below the word.

<Demo src="menubar/orientation" minHeight="160">

::: fw react

<<< @/.vitepress/demos/menubar/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menubar/orientation.dart

:::

</Demo>

### On a window

<Demo src="menubar/window">

::: fw react

<<< @/.vitepress/demos/menubar/window.tsx

:::

</Demo>

## Accessibility

::: fw react

- Renders `role="menubar"` with each word a `menuitem` that owns a menu.
- The whole bar is one tab stop; the arrow keys move between the words and into the rows, and typeahead works in both.
- Give the bar an `aria-label` where a page holds more than one.

:::

::: fw flutter

- The bar is a menu bar to a screen reader, and each word a menu item that says whether its menu is expanded.
- The whole bar is one stop in the focus order, the word that last had the focus. The arrow keys along the bar move between the words and pass over a disabled one, the arrow across it opens the menu at its first row, and inside an open menu the arrows along the bar walk to the menu beside it. Typeahead works on the words and in the rows. Escape closes the menu and gives the focus back to its word; Tab closes it and moves on past the bar.
- Give the bar a `semanticLabel` where a page holds more than one.

:::
