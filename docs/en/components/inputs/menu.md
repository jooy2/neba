---
title: Menu
order: 9
---

# Menu

<p class="neba-lede">A list of actions that appears when something is pressed. It nests, it holds state, and it can be driven end to end from the keyboard.</p>

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

### Groups, links and icons

Passing `href` turns the row into a real `<a>`. That is not a detail: a menu of links that are not links cannot be opened in a new tab, cannot have its address copied, and tells a screen reader the wrong thing about every row in it.

<Demo src="menu/basic">

<<< @/.vitepress/demos/menu/basic.tsx

</Demo>

### Nested menus

There is no depth limit. A submenu's children are just menu rows, and one of them can be another `MenuSubmenu`. Base UI opens them on hover with a safe triangle, so reaching diagonally into an open submenu does not close it.

<Demo src="menu/nested">

<<< @/.vitepress/demos/menu/nested.tsx

</Demo>

### Rows that hold state

A tick says "and", a dot says "instead of" — the same distinction Checkbox and Radio make everywhere else in the library. Neither closes the menu when it is picked: a list of things to tick is a list you tick more than one of.

<Demo src="menu/state">

<<< @/.vitepress/demos/menu/state.tsx

</Demo>

### Context menus

<Demo src="menu/context">

<<< @/.vitepress/demos/menu/context.tsx

</Demo>

### Sizes

<Demo src="menu/sizes">

<<< @/.vitepress/demos/menu/sizes.tsx

</Demo>

## The rows are code, not data

[Select](./select) takes an `items` array. A menu does not. That is the opposite choice, and it is deliberate.

A select's options are values from a list the caller already has. A menu's rows are **code** — each one a different handler, a different icon, sometimes a submenu. Data would mean an `items` type with a variant for every shape a row can take, which is a component tree spelled as a discriminated union.

## The popup is the Select popup

To the pixel. A select _is_ a menu that remembers what you picked, and two floating lists of rows that do not match are two lists the eye has to learn separately.

The rows' padding is the one thing that differs. A List row spans a sheet that something else decided the width of; a menu row is inside a popup that is exactly as wide as its longest label. At `md`, Box's `px-4` would add 32px to a menu that says "Cut", which is how a five-item menu ends up the width of a dialog.

## What Base UI owns

Everything that makes a menu a menu rather than a floating list of divs: roving focus with the arrow keys, Home and End, typeahead, Escape, closing on an outside click, restoring focus to the trigger, submenus opening on hover with the safe triangle, and the `menu` / `menuitem` roles that make any of it mean something to a screen reader.

What is here is the surface, the ladders and the row layout.

## Accessibility

- Give the row that deletes `color="danger"`. The whole colour family re-points, so the text, the soft background and the focus ring turn over together.
- When the label is not a plain string, give `label` the text typeahead should match against.
- A `disabled` row stays listed and stays findable by typeahead. Not disappearing is the point — a row that is gone says "there is no such thing" rather than "it is not available here".
