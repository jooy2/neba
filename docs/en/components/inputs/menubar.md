---
title: Menubar
order: 29
---

# Menubar

<p class="neba-lede">The strip of words at the top of an application (File, Edit, View), each of which opens a menu. Once one is open, moving along the strip walks through the others rather than closing the one you left.</p>

<Demo src="menubar/hero" />

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

## Props

<PropsTable name="Menubar" />

Every native `<div>` attribute passes through, apart from `color`.

It draws no surface of its own. A menu bar sits _on_ something (a [Toolbar](../surfaces/toolbar), a [WindowPane](../surfaces/window-pane)'s title bar, a [Header](../layout/header)), and a sheet under a strip that is already on a sheet is two sheets.

### MenubarMenu

<PropsTable name="MenubarMenu" />

The rows are the same `MenuItem`, `MenuSeparator`, `MenuGroup`, `MenuCheckboxItem`, `MenuRadioGroup` and `MenuSubmenu` a [Menu](./menu) takes, because it is the same menu. `size`, `color` and `density` belong to the bar and are not repeated here.

## Examples

### Nested and checkable rows

Everything a Menu can hold, a menu on the bar can hold: submenus, groups, checkboxes and radio rows.

### size

Its own ladder, one rung below the control heights at every step: a menu bar is a strip of words rather than a row of buttons, and it usually sits inside something that already has a height.

<Demo src="menubar/sizes">

<<< @/.vitepress/demos/menubar/sizes.tsx

</Demo>

### orientation

`vertical` stacks the words instead, and the arrow keys follow.

<Demo src="menubar/orientation">

<<< @/.vitepress/demos/menubar/orientation.tsx

</Demo>

### On a window

<Demo src="menubar/window">

<<< @/.vitepress/demos/menubar/window.tsx

</Demo>

## Accessibility

- Renders `role="menubar"` with each word a `menuitem` that owns a menu.
- The whole bar is one tab stop; the arrow keys move between the words and into the rows, and typeahead works in both.
- Give the bar an `aria-label` where a page holds more than one.
