---
title: Shortcut
order: 10
---

# Shortcut

<p class="neba-lede">A keyboard key, or a combination of them. A component whose label is harder than its box.</p>

<Demo src="shortcut/hero" />

```tsx
import { Shortcut } from 'neba';

<Shortcut keys="Mod+K" />
<Shortcut keys="Ctrl+Alt+Delete" os="windows" />
<Shortcut keys={['Mod', '+']} />;
```

## Props

<PropsTable name="Shortcut" />

## Why not `Kbd`

`<kbd>` is the name of an HTML element, not the name of an idea. Every component name in this library is a noun that says what the thing **is** — Button, Chip, Badge, Divider, Pill — and not one of them is an abbreviation. `Shortcut` is also a word the library already uses: [MenuItem](../inputs/menu)'s `shortcut` prop is the slot this was written for.

```tsx
<MenuItem shortcut={<Shortcut keys="Mod+E" />}>Rename</MenuItem>
```

## Two things that make it more than a styled `<kbd>`

Both are about the **label** rather than the box around it.

### `Mod`

A shortcut written as `Ctrl+K` is wrong for every Mac reader, and one written as `⌘K` is wrong for everybody else. So the token that means "the modifier shortcuts are built on" resolves per platform: Command on a Mac, Control everywhere else.

`os` is `auto` by default, which asks the browser. `mac`, `windows` and `linux` are for documentation that has to name a platform rather than the reader's own — a support page describing the Windows build, a table comparing the two.

`Mod` is the only token whose **meaning** changes rather than just its spelling. `Meta` is the same key only on a Mac; it is Win on Windows and Super on Linux.

<Demo src="shortcut/platforms">

<<< @/.vitepress/demos/shortcut/platforms.tsx

</Demo>

### `⌘` is not a word

A screen reader announces `⌘` as "place of interest sign", which is not a key anybody has on their keyboard. So every key drawn as a glyph carries its name beside it, in the same clipped box [Badge](./badge) uses, invisible to a sighted reader. What is announced is "Command K", which is what the shortcut is called.

## Examples

### Keys

A string is split on `+`; the array form is only needed for a shortcut whose key is itself a plus. A single-character token is capitalised — that is what is printed on the cap — and an unknown one is drawn exactly as it was written.

<Demo src="shortcut/keys">

<<< @/.vitepress/demos/shortcut/keys.tsx

</Demo>

### The separator

macOS writes a shortcut as a run of symbols: `⇧⌘P`, never `⇧+⌘+P`. The other two join theirs with a `+`. Omit `separator` and the platform's own convention is used; pass one and it is yours.

### Weight and size

A key cap sits one step down the control ladder, for the reason a [Chip](./chip) does — it is a token _inside_ a line of text, not a control the line lines up against. It is also set in a monospaced face, which is the signal that tells a cap and a chip apart at a glance.

<Demo src="shortcut/variants">

<<< @/.vitepress/demos/shortcut/variants.tsx

</Demo>

## Server rendering

`os="auto"` asks the browser, and a server has no browser. That is what `useSyncExternalStore` is for: it is the one API that hydrates with the server's answer and then re-renders with the browser's, which is exactly the sequence a Mac reader sees — `Ctrl` for one frame, then `⌘`. Reading `navigator` during render would instead be a hydration mismatch, and React throws the markup away for one of those.

If that moment matters on a given screen, name the `os`.
