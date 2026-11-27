---
title: Shortcut
order: 10
flutter: true
---

# Shortcut

<p class="neba-lede">Renders a keyboard shortcut as key caps. Modifier keys are spelled to match the reader's platform.</p>

<Demo src="shortcut/hero" />

::: fw react

```tsx
import { Shortcut } from 'neba';

<Shortcut keys="Mod+K" />
<Shortcut keys="Ctrl+Alt+Delete" os="windows" />
<Shortcut keys={['Mod', '+']} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaShortcut(keys: 'Mod+K');
const NebaShortcut(keys: 'Ctrl+Alt+Delete', os: NebaShortcutOS.windows);
const NebaShortcut.split(keys: <String>['Mod', '+']);
```

:::

## Props

<PropsTable name="Shortcut" />

## Examples

### keys

A string is split on `+`. <Fw react="The array form is only needed when a key is itself a plus." flutter="`NebaShortcut.split`, which takes the keys as a list, is only needed when a key is itself a plus." /> Single-character tokens are capitalised to match what is printed on the cap, and an unrecognised token is drawn exactly as written.

<Demo src="shortcut/keys">

::: fw react

<<< @/.vitepress/demos/shortcut/keys.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/shortcut/keys.dart

:::

</Demo>

### os and `Mod`

`Mod` is the token for "the platform's primary modifier": Command (`⌘`) on macOS, Control everywhere else. Unlike the other tokens, which only change spelling, `Mod` changes which key it names.

::: fw react

`os` defaults to `auto`, which asks the browser for the current platform. A server cannot ask, so a page rendered on a server draws the Windows keys and switches to the reader's at hydration: on a Mac, `Ctrl+K` becomes `⌘K`, and because the two are not the same width, the text after the shortcut moves. To avoid that, read the platform from the request's `User-Agent` header on the server and pass it as `os`, by the rule `auto` uses: `mac` for a Mac, an iPhone or an iPad, `windows` for Windows, and `linux` for everything else. Name `mac`, `windows` or `linux` as well in documentation that describes a specific platform.

```tsx
// On the server, from the request's User-Agent header.
const os = /mac|iphone|ipad|ipod/i.test(userAgent)
  ? 'mac'
  : /win/i.test(userAgent)
    ? 'windows'
    : 'linux';

<Shortcut keys="Mod+K" os={os} />;
```

:::

::: fw flutter

`os` defaults to `NebaShortcutOS.auto`, which reads `defaultTargetPlatform`: macOS and iOS are `mac`, Windows is `windows`, and everything else `linux`. On the web that is the browser's platform. Name `mac`, `windows` or `linux` in documentation that describes a specific platform.

:::

::: fw react

The same strings are what the library **binds**: `shortcut` on [CommandPalette](../inputs/command-palette) and `shortcuts` on [TextField](../inputs/text-field), [NumberField](../inputs/number-field) and [Combobox](../inputs/combobox) all read this vocabulary. So do the aliases: `Cmd`, `Command`, `Meta` and `Win` are one key, and `Esc`, `Return`, `Opt` and `Up` are spellings of `Escape`, `Enter`, `Alt` and `ArrowUp`. A key cap and the key that fires it are the same string, with one exception. Punctuation typed with Shift is written as the character it types, because Shift is not checked for it: `?` fires and `Shift+/` never does.

:::

::: fw flutter

The aliases are the React package's: `Cmd`, `Command`, `Meta` and `Win` are one key, and `Esc`, `Return`, `Opt` and `Up` are spellings of `Escape`, `Enter`, `Alt` and `ArrowUp`. A Flutter field binds its keys with `ShortcutActivator`s rather than these strings, so a key cap and the binding it describes are written separately.

:::

<Demo src="shortcut/platforms">

::: fw react

<<< @/.vitepress/demos/shortcut/platforms.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/shortcut/platforms.dart

:::

</Demo>

### separator and variant

Omit `separator` and the platform convention is used: macOS runs the symbols together in its own modifier order, ⌃⌥⇧⌘, whatever order they were written in (`Mod+Shift+P` is `⇧⌘P`); the others join with `+`. Pass one and <Fw react="that character" flutter="that widget" /> is used instead.

Key caps sit one step below the control heights, like a [Chip](./chip), and are set in a monospaced face.

<Demo src="shortcut/variants">

::: fw react

<<< @/.vitepress/demos/shortcut/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/shortcut/variants.dart

:::

</Demo>

### In a MenuItem

::: fw react

[MenuItem](../inputs/menu)'s `shortcut` prop is where a Shortcut usually goes.

```tsx
<MenuItem shortcut={<Shortcut keys="Mod+E" />}>Rename</MenuItem>
```

:::

::: fw flutter

[MenuItem](../inputs/menu)'s `shortcut` is where a Shortcut usually goes. The row sets it at its end, after the label, and binds nothing.

```dart
NebaMenuItem(
  onPressed: rename,
  shortcut: const NebaShortcut(keys: 'Mod+E'),
  child: const Text('Rename'),
);
```

:::

## Accessibility

::: fw react

- A screen reader cannot read a symbol like `⌘` as a key name. Every key drawn as a glyph carries a visually hidden name alongside it, so the shortcut is announced as "Command K".

:::

::: fw flutter

- A screen reader cannot read a symbol like `⌘` as a key name. The shortcut is one node labelled with every key's name, so it is announced as "Command K", and the separators are left out.

:::
