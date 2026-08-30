---
title: CommandPalette
order: 32
---

# CommandPalette

<p class="neba-lede">Everything an application can do, behind one field. The shape a keyboard-first product takes once it has more actions than a menu bar can hold: a reader types what they want instead of remembering where it was put.</p>

<Demo src="command-palette/hero" />

```tsx
import { CommandPalette } from 'neba';

<CommandPalette
  items={[
    { value: 'deploy', label: 'Deploy production', group: 'Actions', onSelect: deploy },
    { value: 'logs', label: 'Go to logs', group: 'Navigate' }
  ]}
/>;
```

## Props

<PropsTable name="CommandPalette" />

### CommandItem

<PropsTable name="CommandItem" />

It is not a [Menu](./menu) — a menu is a short list in one place and every row is visible before you look for it. It is not a [Combobox](./combobox) either: what comes back is not a value, it is something happening.

## Examples

### items · group

Commands are drawn in the order they are given, and a heading is drawn each time `group` changes — so a group's commands have to be listed together. `icon` and `shortcut` fill in the two ends of a row, and `description` a second line under the label.

<Demo src="command-palette/groups">

<<< @/.vitepress/demos/command-palette/groups.tsx

</Demo>

### keywords

Extra words the query is matched against but that are never drawn: the name somebody else's product gives the same command, an abbreviation, the word a reader would have searched for. `Roll back` found by typing `undo` is what makes a palette worth opening twice.

### shortcut

The keystroke that opens the palette, bound on the window. `Mod` is Command on a Mac and Control everywhere else — the same spelling [Shortcut](../display/shortcut) draws, read rather than written. `false` binds nothing, for an application that owns its own keyboard.

### onSelect

Each command may carry its own `onSelect`; the palette's runs after it, with the item. The palette closes either way, and the query is dropped on the way out.

### size

`size` sets the type scale, the height of the field and how wide the sheet may get. `width` and `maxHeight` override the last two on their own.

<Demo src="command-palette/sizes">

<<< @/.vitepress/demos/command-palette/sizes.tsx

</Demo>

## Accessibility

- The sheet is a modal dialog named by `label`, which has no visible title of its own. Focus moves into the field as it opens and back to wherever the reader was as it closes.
- The field is a `combobox` over a `listbox`, with the highlighted row reported through `aria-activedescendant`; the pointer and the arrow keys move the same highlight, so Enter never runs a row other than the marked one.
- Escape closes it.
- A palette is never the only way to a command. Everything in it has to be reachable some other way — a reader who does not know it exists gets no other showing.
