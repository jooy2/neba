---
title: Shortcut
order: 10
---

# Shortcut

<p class="neba-lede">Renders a keyboard shortcut as key caps. Modifier keys are spelled to match the reader's platform.</p>

<Demo src="shortcut/hero" />

```tsx
import { Shortcut } from 'neba';

<Shortcut keys="Mod+K" />
<Shortcut keys="Ctrl+Alt+Delete" os="windows" />
<Shortcut keys={['Mod', '+']} />;
```

## Props

<PropsTable name="Shortcut" />

## Examples

### keys

A string is split on `+`. The array form is only needed when a key is itself a plus. Single-character tokens are capitalised to match what is printed on the cap, and an unrecognised token is drawn exactly as written.

<Demo src="shortcut/keys">

<<< @/.vitepress/demos/shortcut/keys.tsx

</Demo>

### os and `Mod`

`Mod` is the token for "the platform's primary modifier": Command (`⌘`) on macOS, Control everywhere else. Unlike the other tokens, which only change spelling, `Mod` changes which key it names.

`os` defaults to `auto`, which asks the browser for the current platform. Under server rendering the first frame uses the default spelling and switches to the platform's after hydration, so a Mac reader sees `Ctrl` briefly and then `⌘`. Name `mac`, `windows` or `linux` for documentation that describes a specific platform, or wherever that switch matters.

The same strings are what the library **binds**: `shortcut` on [CommandPalette](../inputs/command-palette) and `shortcuts` on [TextField](../inputs/text-field), [NumberField](../inputs/number-field) and [Combobox](../inputs/combobox) all read this vocabulary. So do the aliases: `Cmd`, `Command`, `Meta` and `Win` are one key, and `Esc`, `Return`, `Opt` and `Up` are spellings of `Escape`, `Enter`, `Alt` and `ArrowUp`. A key cap and the key that fires it are the same string, with one exception. Punctuation typed with Shift is written as the character it types, because Shift is not checked for it: `?` fires and `Shift+/` never does.

<Demo src="shortcut/platforms">

<<< @/.vitepress/demos/shortcut/platforms.tsx

</Demo>

### separator and variant

Omit `separator` and the platform convention is used: macOS runs the symbols together in its own modifier order, ⌃⌥⇧⌘, whatever order they were written in (`Mod+Shift+P` is `⇧⌘P`); the others join with `+`. Pass one and that character is used instead.

Key caps sit one step below the control heights, like a [Chip](./chip), and are set in a monospaced face.

<Demo src="shortcut/variants">

<<< @/.vitepress/demos/shortcut/variants.tsx

</Demo>

### In a MenuItem

[MenuItem](../inputs/menu)'s `shortcut` prop is where a Shortcut usually goes.

```tsx
<MenuItem shortcut={<Shortcut keys="Mod+E" />}>Rename</MenuItem>
```

## Accessibility

- A screen reader cannot read a symbol like `⌘` as a key name. Every key drawn as a glyph carries a visually hidden name alongside it, so the shortcut is announced as "Command K".
