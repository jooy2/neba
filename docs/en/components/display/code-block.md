---
title: CodeBlock
order: 21
flutter: true
---

# CodeBlock

<p class="neba-lede">A viewer for one line of code or a thousand, with syntax highlighting, a copy button, line numbers and shell prompts. Every part of its chrome is a prop, so the same component is a bare snippet inside a sentence and the full transcript at the top of a README.</p>

<Demo src="code-block/hero" minHeight="260" />

::: fw react

```tsx
import { CodeBlock } from 'neba';

<CodeBlock code="npm install neba" language="bash" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCodeBlock(code: 'npm install neba', language: 'bash');
```

:::

## Props

<PropsTable name="CodeBlock" />

::: fw react

Every native `<div>` attribute passes through, apart from `color`, `title`, `prefix`, `children` and `onCopy`, which the component owns. The shared axes are described under [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

The block takes the width it is given, as a paragraph does, so it needs a parent with a bounded width. The shared axes are described under [prop conventions](../../design/prop-conventions).

:::

## Examples

### language

The name of the grammar: `ts`, `bash`, `yml`, `dockerfile`. Common spellings and file extensions are understood, so a value copied off a fenced code block works as it is: `jsx` and `mjs` mean JavaScript, `yml` means YAML, `html` and `vue` mean XML. A name nothing here knows is drawn plain rather than refused.

<Demo src="code-block/language" minHeight="320">

::: fw react

<<< @/.vitepress/demos/code-block/language.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/language.dart

:::

</Demo>

::: fw react

Thirty-four languages come with the component. Anything else is registered once, at module scope, with the definition from highlight.js:

```ts
import { registerLanguage } from 'neba';
import elixir from 'highlight.js/lib/languages/elixir';

registerLanguage('elixir', elixir);
```

:::

::: fw flutter

The Flutter package has no highlight.js. Its own lexers colour TypeScript and JavaScript with JSX, JSON, HTML and XML, CSS, Bash, PowerShell, Python, YAML, SQL, Rust and diffs, and every other name is understood, named on the bar and drawn plain. Anything else is registered once, before the blocks are built, as a function from the source to its runs:

```dart
registerNebaCodeLanguage('ini', (String source) => <NebaCodeSpan>[
  for (final String line in source.split('\n'))
    NebaCodeSpan('$line\n', line.startsWith(';') ? NebaCodeKind.comment : NebaCodeKind.plain),
]);
```

:::

### theme

Which palette the block wears, independent of the page's light and dark.

Four are the library's own: <Fw react="`dark`" flutter="`NebaCodeTheme.dark`" /> is the default, `light` is its counterpart, <Fw react="`auto` follows the nearest `.dark`, `.light` or `data-theme` root, and the system setting where there is none" flutter="`auto` follows the theme the block is in" />, and `mono` drops the hues entirely and carries the structure in weight and muting. Eight more are ports kept at their published values: <Fw react="`one-dark`, `dracula`, `monokai`, `nord`, `night-owl`, `gruvbox`, `github` and `solarized-light`" flutter="`oneDark`, `dracula`, `monokai`, `nord`, `nightOwl`, `gruvbox`, `github` and `solarizedLight`" />.

<Demo src="code-block/theme" minHeight="480">

::: fw react

<<< @/.vitepress/demos/code-block/theme.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/theme.dart

:::

</Demo>

::: fw react

A theme is a set of `--n-code-*` custom properties under a `.neba-code[data-code-theme]` selector and nothing else, so `theme` takes any string and a project can write its own:

```css
.neba-code[data-code-theme='ours'] {
  --n-code-bg: #101418;
  --n-code-fg: #d7dce2;
  --n-code-comment: #59626e;
  --n-code-keyword: #ff8ab3;
  --n-code-string: #9ad48f;
  /* number, function, type, variable, tag, attr, meta, add, del */
}
```

Fourteen slots to fill, with `.neba-code` in the selector so the theme outranks the default one whatever order the stylesheets load in. The muted text, the hairline, the hover tint and the two used by `highlightLines` are all mixed from `--n-code-bg` and `--n-code-fg`, so they follow whatever you set without being declared.

:::

::: fw flutter

A theme of your own is a `NebaCodeTheme` made from a `NebaCodePalette`, the fourteen colours a theme fills:

```dart
const NebaCodeTheme ours = NebaCodeTheme(
  NebaCodePalette(
    background: Color(0xFF101418),
    foreground: Color(0xFFD7DCE2),
    comment: Color(0xFF59626E),
    keyword: Color(0xFFFF8AB3),
    string: Color(0xFF9AD48F),
    // number, function, type, variable, tag, attribute, meta, addition, deletion
  ),
  name: 'ours',
);
```

The muted text, the hairline, the hover tint and the two used by `highlightLines` are all mixed from `background` and `foreground`, so they follow whatever you set without being declared.

:::

### highlightLines

Marks lines with a tinted row and a rule down its leading edge. <Fw react="A number is one line, a string is a list of lines and ranges (`'4'`, `'4-9'`, `'1,4-9,12'`), and an array is any mix of the two." flutter="It is a string: a line or a range, or a list of them, `'4'`, `'4-9'`, `'1,4-9,12'`." /> They are counted the way the gutter counts, so with <Fw react="`startLine={286}`" flutter="`startLine: 286`" /> the line the gutter calls 288 is <Fw react="`highlightLines={288}`" flutter="`highlightLines: '288'`" />.

The tint is mixed from the theme's own ink rather than the page's colour family, so it stays legible on all twelve palettes.

<Demo src="code-block/marks" minHeight="520">

::: fw react

<<< @/.vitepress/demos/code-block/marks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/marks.dart

:::

</Demo>

### toolbar · showLanguage · copyable · rawToggle

The bar over the code, and the three things on it. <Fw react="`toolbar={false}`" flutter="`toolbar: false`" /> removes the bar and everything on it whatever the other three say. `rawToggle` is off by default. Turned on, it adds a toggle that drops the colouring and shows the characters as they are.

<Demo src="code-block/chrome" minHeight="300">

::: fw react

<<< @/.vitepress/demos/code-block/chrome.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/chrome.dart

:::

</Demo>

### lineNumbers · startLine

Numbers down the side, starting wherever an excerpt actually starts. The gutter is sized for the last number, so it does not step as the block scrolls.

<Demo src="code-block/numbers" minHeight="220">

::: fw react

<<< @/.vitepress/demos/code-block/numbers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/numbers.dart

:::

</Demo>

### prompt

A shell symbol in front of every line that has something on it: `$`, `#`, `C:\>`, `>>>`. It is drawn but never present: <Fw react="the symbol is generated content, so a reader dragging across the block does not select it, find-in-page does not match it, and neither the copy button nor a manual copy puts it on the clipboard" flutter="the symbol sits outside the selection, so a reader dragging across the block does not select it, and neither the copy button nor a copied selection puts it on the clipboard" />.

<Demo src="code-block/prompt" minHeight="360">

::: fw react

<<< @/.vitepress/demos/code-block/prompt.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/prompt.dart

:::

</Demo>

### maxHeight · wrap

`maxHeight` is how tall the block may get before the code scrolls inside it: a number is pixels. `wrap` folds long lines instead of scrolling them sideways.

<Demo src="code-block/scroll" minHeight="320">

::: fw react

<<< @/.vitepress/demos/code-block/scroll.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/scroll.dart

:::

</Demo>

### fontFamily · fontSize · lineHeight · letterSpacing

`size` moves the type scale and the padding together, the way it does everywhere. The four overrides are for the cases it cannot reach: a licensed typeface, a fixed pixel size a screenshot has to match, looser leading for a block being read aloud from.

::: fw flutter

`fontSize` and `letterSpacing` are pixels and `lineHeight` is a multiple of the size; an `em` is written out as pixels, so `0.04em` at 15 pixels is `0.6`.

:::

<Demo src="code-block/typography" minHeight="320">

::: fw react

<<< @/.vitepress/demos/code-block/typography.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/typography.dart

:::

</Demo>

### highlight

::: fw react

`highlight={false}` draws the code with no colouring at all and fetches no grammar. With it on, the block draws plain on the first frame and colours itself when the grammar lands. A block that is off screen fetches its grammar straight away but is not coloured until it is within a screen's height of the view; copying and selecting work the same either way.

:::

::: fw flutter

`highlight: false` draws the code with no colouring at all. With it on, the block is coloured on its first frame: the lexers are part of the package, so there is nothing to fetch. Copying and selecting work the same either way.

:::

## Accessibility

::: fw react

- Code that is wider or taller than its box is a scrollable region with `tabIndex={0}` and a name, so a reader with no pointer to drag with can still scroll it. The name is the `title` when there is one, and the language otherwise. A block with nothing to scroll is neither, so a page of short snippets is not a page of landmarks and tab stops.
- Prompts and line numbers are generated content with empty alternative text, which keeps them from being read out as well as off the clipboard. A browser without the alternative-text syntax (Firefox before 128, Safari before 17.4) still reads them.
- The copy button announces the result through a polite live region.
- <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> inside the focused block selects the code and nothing else. Prompts and line numbers are left out of the selection, as they are left out of the clipboard.

:::

::: fw flutter

- Code that is wider or taller than its box is a named region in the focus order, and the arrow keys, Page Up, Page Down, Home and End scroll it. The name is `semanticLabel`, then a `title` that is a `Text`, then the language, then the word for code. A block with nothing to scroll is neither, so a page of short snippets is not a page of regions and tab stops.
- Prompts and line numbers are left out of the semantics tree, so a screen reader does not read them, and out of the selection and the clipboard.
- The copy button announces the result through a status live region.
- The code can be selected with the pointer, and <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> inside the focused block selects the code and nothing else. A touch screen shows no selection handles yet, as in the fields.

:::
