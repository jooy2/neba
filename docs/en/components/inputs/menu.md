---
title: Menu
order: 9
flutter: true
---

# Menu

<p class="neba-lede">A list of actions that appears when a trigger is pressed. It can hold nested submenus and checkable rows, and is fully operable from the keyboard.</p>

<Demo src="menu/hero" minHeight="240" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaMenu(
  trigger: NebaButton(onPressed: () {}, child: const Text('Actions')),
  children: <Widget>[
    NebaMenuItem(onPressed: rename, shortcut: const Text('⌘E'), child: const Text('Rename')),
    const NebaMenuSubmenu(
      label: Text('Move to'),
      children: <Widget>[NebaMenuItem(child: Text('Archive'))],
    ),
    const NebaMenuSeparator(),
    NebaMenuItem(onPressed: delete, color: NebaColor.danger, child: const Text('Delete')),
  ],
);
```

:::

Rows are written as <Fw react="components" flutter="widgets" /> rather than passed as an array, because each carries its own handler and icon and some of them are submenus. For a list that picks a value, use [Select](./select).

## Props

### Menu

<PropsTable name="Menu" />

::: fw flutter

`trigger` opens the menu through its own press, so it has to be a Neba control, such as a `NebaButton` or a `NebaChip` with `onPressed`. A button that is only a trigger takes `onPressed: () {}`, because a Flutter button with none is disabled. `disabled` stops the trigger opening the menu; the trigger is drawn as it is, so disable it as well.

The popup is drawn in the app's root `Overlay`. A `MaterialApp`, a `CupertinoApp` and a `WidgetsApp` with routes all have one; an app built without one wraps itself in `Overlay.wrap`.

There is no `keepMounted`: there is no document for a crawler to read, and a closed popup is out of the semantics tree either way.

:::

### MenuItem

<PropsTable name="MenuItem" />

::: fw flutter

The package opens nothing itself, so a row that leads somewhere is a callback: `onPressed` calls the router or a URL launcher, and `href` tells a screen reader, and on the web the browser, where it goes. A row with no `onPressed` still closes the menu when it is picked; `disabled` is what stops it.

:::

### MenuSubmenu

<PropsTable name="MenuSubmenu" />

### MenuGroup

<PropsTable name="MenuGroup" />

### MenuCheckboxItem

<PropsTable name="MenuCheckboxItem" />

### MenuRadioGroup

<PropsTable name="MenuRadioGroup" />

::: fw flutter

`NebaMenuRadioGroup<T>` is generic over the value, as `NebaRadioGroup` is, and its rows are `NebaMenuRadioItem<T>` of the same `T`.

:::

### MenuRadioItem

<PropsTable name="MenuRadioItem" />

### MenuSeparator

::: fw react

A rule between rows. It takes the attributes of a `<div>` and nothing else.

:::

::: fw flutter

A rule between rows, drawn across the whole popup. It takes no arguments.

:::

### ContextMenu

<PropsTable name="ContextMenu" />

## Examples

### href · startIcon · shortcut

::: fw react

`href` renders the row as a real `<a>`, so it can be opened in a new tab or have its address copied. `shortcut` takes a [Shortcut](../display/shortcut). `MenuSeparator` divides rows into groups.

:::

::: fw flutter

`href` makes the row a link to a screen reader, and `newTab` says it opens elsewhere; following it is `onPressed`'s. `shortcut` takes a `Text` or a [Shortcut](../display/shortcut). `NebaMenuSeparator` divides rows into groups.

:::

<Demo src="menu/basic" minHeight="320">

::: fw react

<<< @/.vitepress/demos/menu/basic.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/basic.dart

:::

</Demo>

### MenuSubmenu

There is no depth limit: a submenu's children are menu rows too, so one of them can be another `MenuSubmenu`. They open on hover, and moving the pointer diagonally into an open submenu does not close it.

<Demo src="menu/nested" minHeight="220">

::: fw react

<<< @/.vitepress/demos/menu/nested.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/nested.dart

:::

</Demo>

### Checkable and radio rows

A tick is for items that can be on together; a dot is for one-of-a-set. Neither closes the menu when picked. <Fw react="`closeOnClick`" flutter="`closeOnPress`" /> can be set per row.

<Demo src="menu/state" minHeight="300">

::: fw react

<<< @/.vitepress/demos/menu/state.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/state.dart

:::

</Demo>

### ContextMenu

::: fw react

A menu opened by right-click. Pass the rows as `content` and the target area as `children` — exactly one element, which the trigger merges onto rather than wrapping, so the menu adds nothing to the layout.

Anything else you pass goes to that area rather than to the popup, which `className` and `style` describe. That is what lets a `ContextMenu` sit inside another trigger: to put a [Tooltip](../feedback/tooltip) on the same element, write the tooltip around the menu rather than the other way about.

From the keyboard it opens with the context-menu key or `Shift+F10` while the area holds the focus, so an area that cannot take the focus on its own needs `tabIndex={0}`.

:::

::: fw flutter

A menu opened by a right-click, or by a long press on a touch screen, where the pointer is. Pass the rows as `content` and the area as `child`, which is laid out exactly as it would be without the menu. On the web the browser's own menu is held off while the pointer is over the area.

From the keyboard it opens with the context-menu key or `Shift+F10` while something inside the area holds the focus, so an area that cannot take the focus on its own goes inside a `Focus`.

:::

<Demo src="menu/context" minHeight="260">

::: fw react

<<< @/.vitepress/demos/menu/context.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/context.dart

:::

</Demo>

### size and density

<Demo src="menu/sizes" minHeight="200">

::: fw react

<<< @/.vitepress/demos/menu/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/sizes.dart

:::

</Demo>

### side · align · openOnHover

`side` and `align` place the popup relative to the trigger. `openOnHover` opens the menu without a click.

::: fw react

### keepMounted

A closed menu's rows are not in the DOM by default. `keepMounted` keeps the popup and its rows in the DOM while the menu is closed, hidden, and every `MenuSubmenu` inside keeps its rows too. Use it for a menu of links that a crawler which runs scripts should find. The popup is portalled, so the rows arrive once the page has hydrated, not in the server's HTML. `ContextMenu` takes the same prop.

```tsx
<Menu keepMounted trigger={<Button>Docs</Button>}>
  <MenuItem href="/guide">Guide</MenuItem>
  <MenuItem href="/changelog">Changelog</MenuItem>
</Menu>
```

:::

## Accessibility

::: fw react

- The `menu` / `menuitem` roles, roving focus with the arrow keys, Home and End, typeahead, Escape, closing on an outside click and restoring focus to the trigger are all handled.
- Give a destructive row `color="danger"`; the text and the soft background under a highlighted row turn over together.
- When the label is not a string, give `label` the text typeahead should match against.
- A closed menu kept in the DOM by `keepMounted` is hidden, so its rows are out of the tab order and the accessibility tree until it opens.
- A `disabled` row stays listed and findable by typeahead. A row that disappears reads as "there is no such thing" rather than "it is not available here".

:::

::: fw flutter

- The popup is a menu to a screen reader, each row a menu item, a ticking row a checkbox item and a row of a set a radio item, with its checked state; a submenu's row says whether its submenu is expanded, and the trigger says whether the menu is. A group is named by its label.
- The arrow keys, Home and End move the highlight, letters move it to the next row that starts with them, Enter and Space pick the highlighted row, the arrow that points at a submenu opens it and the one that points back closes it. Escape closes the top popup only, a press outside closes the menu, and Tab closes it and moves on from the trigger. The focus comes back to the trigger when the menu closes, and to a submenu's row when the submenu does.
- The highlight is the focus, so the pointer and the keys light the same row, and the tint is the focus indicator: a row draws no ring.
- Give a destructive row `color: NebaColor.danger`; the text and the soft background under a highlighted row turn over together.
- When the label is not a `Text`, give `label` the text typeahead should match against.
- A `disabled` row stays listed, highlighted and findable by typeahead. A row that disappears reads as "there is no such thing" rather than "it is not available here".

:::
