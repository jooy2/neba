---
title: CodeBlock
order: 21
---

# CodeBlock

<p class="neba-lede">A viewer for one line of code or a thousand, with syntax highlighting, a copy button, line numbers and shell prompts. Every part of its chrome is a prop, so the same component is a bare snippet inside a sentence and the full transcript at the top of a README.</p>

<Demo src="code-block/hero" minHeight="260" />

```tsx
import { CodeBlock } from 'neba';

<CodeBlock code="npm install neba" language="bash" />;
```

## Props

<PropsTable name="CodeBlock" />

Every native `<div>` attribute passes through, apart from `color`, `title`, `prefix`, `children` and `onCopy`, which the component owns. The shared axes are described under [prop conventions](../../design/prop-conventions).

The code is a `code` prop rather than `children` because it is a string and not markup: a template literal keeps its own indentation, and JSX would collapse it.

## Examples

### language

The name of the grammar — `ts`, `bash`, `yml`, `dockerfile`. Common spellings and file extensions are understood, so a value copied off a fenced code block works as it is: `jsx` and `mjs` mean JavaScript, `yml` means YAML, `html` and `vue` mean XML. A name nothing here knows is drawn plain rather than refused.

<Demo src="code-block/language" minHeight="320">

<<< @/.vitepress/demos/code-block/language.tsx

</Demo>

Thirty-four languages come with the component. Anything else is registered once, at module scope, with the definition from highlight.js:

```ts
import { registerLanguage } from 'neba';
import elixir from 'highlight.js/lib/languages/elixir';

registerLanguage('elixir', elixir);
```

### theme

Which palette the block wears, independent of the page's light and dark. `dark` is the default; `light` is its counterpart; `auto` follows the page; `mono` drops the hues entirely and carries the structure in weight and muting.

<Demo src="code-block/theme" minHeight="640">

<<< @/.vitepress/demos/code-block/theme.tsx

</Demo>

### toolbar · showLanguage · copyable · rawToggle

The bar over the code, and the three things on it. `toolbar={false}` removes the bar and everything on it whatever the other three say. `rawToggle` is off by default: it drops the colouring and shows the characters as they are, which is a second button on a bar that usually wants one.

<Demo src="code-block/chrome" minHeight="300">

<<< @/.vitepress/demos/code-block/chrome.tsx

</Demo>

### lineNumbers · startLine

Numbers down the side, starting wherever an excerpt actually starts. The gutter is sized for the last number, so it does not step as the block scrolls.

<Demo src="code-block/numbers" minHeight="220">

<<< @/.vitepress/demos/code-block/numbers.tsx

</Demo>

### prompt

A shell symbol in front of every line that has something on it — `$`, `#`, `C:\>`, `>>>`. It is drawn but never present: the symbol is generated content, so a reader dragging across the block does not select it, find-in-page does not match it, and neither the copy button nor a manual copy puts it on the clipboard.

<Demo src="code-block/prompt" minHeight="360">

<<< @/.vitepress/demos/code-block/prompt.tsx

</Demo>

### maxHeight · wrap

`maxHeight` is how tall the block may get before the code scrolls inside it — a number is pixels. `wrap` folds long lines instead of scrolling them sideways.

<Demo src="code-block/scroll" minHeight="320">

<<< @/.vitepress/demos/code-block/scroll.tsx

</Demo>

### fontFamily · fontSize · lineHeight · letterSpacing

`size` moves the type scale and the padding together, the way it does everywhere. The four overrides are for the cases it cannot reach: a licensed typeface, a fixed pixel size a screenshot has to match, looser leading for a block being read aloud from.

<Demo src="code-block/typography" minHeight="320">

<<< @/.vitepress/demos/code-block/typography.tsx

</Demo>

### highlight

`highlight={false}` draws the code with no colouring at all, and nothing is fetched: the grammar engine is behind a dynamic import, so a block that does not highlight costs no more than the text in it. With it on, the block draws plain on the first frame and colours itself when the grammar lands.

## Accessibility

- The code is a scrollable region with `tabIndex={0}` and a name, so a reader with no pointer to drag with can still scroll it. The name is the `title` when there is one, and the language otherwise.
- Prompts and line numbers are generated content, which keeps them out of the accessibility tree as well as off the clipboard.
- The copy button announces the result through a polite live region, because the only other signal — the button's own label changing — is not something a screen reader reading the page would hear.
- `theme` is the one colour decision in the library that does not follow the page. A block set to `dark` stays dark under a light system preference, which is deliberate; `auto` is the opt-out.
