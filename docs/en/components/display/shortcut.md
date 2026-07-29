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

[MenuItem](../inputs/menu)'s `shortcut` prop is the slot this component was written for.

```tsx
<MenuItem shortcut={<Shortcut keys="Mod+E" />}>Rename</MenuItem>
```

## Examples

### keys

A string is split on `+`. The array form is only needed when a key is itself a plus. Single-character tokens are capitalised to match what is printed on the cap, and an unrecognised token is drawn exactly as written.

<Demo src="shortcut/keys">

<<< @/.vitepress/demos/shortcut/keys.tsx

</Demo>

### os and `Mod`

`Mod` is the token for "the platform's primary modifier": Command (`⌘`) on macOS, Control everywhere else. Unlike the other tokens, which only change spelling, `Mod` changes which key it names.

`os` defaults to `auto`, which asks the browser for the current platform. Name `mac`, `windows` or `linux` for documentation that describes a specific platform.

<Demo src="shortcut/platforms">

<<< @/.vitepress/demos/shortcut/platforms.tsx

</Demo>

### separator and variant

Omit `separator` and the platform convention is used: macOS runs the symbols together (`⇧⌘P`), the others join with `+`. Pass one and that character is used instead.

Key caps sit one step below the control heights, like a [Chip](./chip), and are set in a monospaced face.

<Demo src="shortcut/variants">

<<< @/.vitepress/demos/shortcut/variants.tsx

</Demo>

## Server rendering

`os="auto"` depends on the browser, so under SSR the first frame renders the default and switches to the real platform's spelling after hydration — a Mac reader sees `Ctrl` briefly, then `⌘`. Name the `os` on screens where that transition matters.

## Accessibility

- A screen reader cannot read a symbol like `⌘` as a key name. Every key drawn as a glyph carries a visually hidden name alongside it, so the shortcut is announced as "Command K".
