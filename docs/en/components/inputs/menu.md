---
title: Menu
order: 9
---

# Menu

<p class="neba-lede">A list of actions that appears when a trigger is pressed. It can hold nested submenus and checkable rows, and is fully operable from the keyboard.</p>

<Demo src="menu/hero" />

```tsx
import { Button, Menu, MenuItem, MenuSeparator, MenuSubmenu } from 'neba';

<Menu trigger={<Button>Actions</Button>}>
  <MenuItem shortcut="⌘E">Rename</MenuItem>
  <MenuSubmenu label="Move to">
    <MenuItem>Archive</MenuItem>
  </MenuSubmenu>
  <MenuSeparator />
  <MenuItem color="danger">Delete</MenuItem>
</Menu>;
```

Rows are written as components rather than passed as an array, because each carries its own handler and icon and some of them are submenus. For a list that picks a value, use [Select](./select).

## Props

### Menu

<PropsTable name="Menu" />

### MenuItem

<PropsTable name="MenuItem" />

### MenuSubmenu

<PropsTable name="MenuSubmenu" />

### ContextMenu

<PropsTable name="ContextMenu" />

## Examples

### href · startIcon · shortcut

`href` renders the row as a real `<a>`, so it can be opened in a new tab or have its address copied. `shortcut` takes a [Shortcut](../display/shortcut). `MenuSeparator` divides rows into groups.

<Demo src="menu/basic">

<<< @/.vitepress/demos/menu/basic.tsx

</Demo>

### MenuSubmenu

There is no depth limit: a submenu's children are menu rows too, so one of them can be another `MenuSubmenu`. They open on hover, and moving the pointer diagonally into an open submenu does not close it.

<Demo src="menu/nested">

<<< @/.vitepress/demos/menu/nested.tsx

</Demo>

### Checkable and radio rows

A tick is for items that can be on together; a dot is for one-of-a-set. Neither closes the menu when picked. `closeOnClick` can be set per row.

<Demo src="menu/state">

<<< @/.vitepress/demos/menu/state.tsx

</Demo>

### ContextMenu

A menu opened by right-click. Pass the rows as `content` and the target area as `children`.

<Demo src="menu/context">

<<< @/.vitepress/demos/menu/context.tsx

</Demo>

### size and density

<Demo src="menu/sizes">

<<< @/.vitepress/demos/menu/sizes.tsx

</Demo>

### side · align · openOnHover

`side` and `align` place the popup relative to the trigger. `openOnHover` opens the menu without a click.

## Accessibility

- The `menu` / `menuitem` roles, roving focus with the arrow keys, Home and End, typeahead, Escape, closing on an outside click and restoring focus to the trigger are all handled.
- Give a destructive row `color="danger"`; the text, the soft background and the focus ring turn over together.
- When the label is not a string, give `label` the text typeahead should match against.
- A `disabled` row stays listed and findable by typeahead. A row that disappears reads as "there is no such thing" rather than "it is not available here".
