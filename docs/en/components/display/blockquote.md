---
title: Blockquote
order: 9
flutter: true
---

# Blockquote

<p class="neba-lede">Presents a quotation set apart from your own prose. Given an attribution, it wraps the quote and its source in the correct semantic markup.</p>

<Demo src="blockquote/hero" />

::: fw react

```tsx
import { Blockquote } from 'neba';

<Blockquote>Perfection is achieved when there is nothing left to take away.</Blockquote>

<Blockquote author="Antoine de Saint-Exupéry" source="Terre des Hommes">
  Perfection is achieved when there is nothing left to take away.
</Blockquote>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaBlockquote(
  child: Text('Perfection is achieved when there is nothing left to take away.'),
);

const NebaBlockquote(
  author: Text('Antoine de Saint-Exupéry'),
  source: Text('Terre des Hommes'),
  child: Text('Perfection is achieved when there is nothing left to take away.'),
);
```

:::

## Props

<PropsTable name="Blockquote" />

::: fw react

With no attribution it renders a `<blockquote>` inside a `<div>`. Given either `author` or `source`, it wraps that in a `<figure>` and puts the attribution in a `<figcaption>`.

```html
<figure>
  <blockquote cite="…">…</blockquote>
  <figcaption>— Author <cite>Source</cite></figcaption>
</figure>
```

`author` sits outside the `<cite>`, since `<cite>` is the element for the title of a work.

:::

::: fw flutter

The quote is `child`. There is no `cite`: a Flutter widget has no attribute for a machine to read the source document's address from. A screen reader reads the quote, then the author and the source, and skips the quote mark and the em dash.

:::

## Examples

### variant

`text` is the default: a single rule in the margin, sized to sit inside running prose. `outline` and `solid` draw a sheet, for a quote that is the point of the section.

<Demo src="blockquote/variants">

::: fw react

<<< @/.vitepress/demos/blockquote/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/variants.dart

:::

</Demo>

### author and source

Pass `author` on its own, `source` on its own, or both. <Fw react="`cite` is the URL of the document the quote came from and lands on the `<blockquote>`'s `cite` attribute: it never appears on screen, only machines read it." flutter="Each takes a widget, usually a `Text`; the author is set in the text colour and the source after it in the muted one." />

<Demo src="blockquote/attribution">

::: fw react

<<< @/.vitepress/demos/blockquote/attribution.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/attribution.dart

:::

</Demo>

### color

The quote's background is never dyed. `color` applies to the margin rule and the quotation mark only.

<Demo src="blockquote/colors">

::: fw react

<<< @/.vitepress/demos/blockquote/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/colors.dart

:::

</Demo>

### icon

`icon` behaves three ways: omit it for the default quotation glyph, pass <Fw react="a node" flutter="a widget" /> to replace it, pass <Fw react="false" flutter="null" code /> to draw none.

::: fw react

```tsx
<Blockquote>Default quotation mark</Blockquote>
<Blockquote icon={<QuoteIcon />}>A glyph of your own</Blockquote>
<Blockquote icon={false}>No glyph</Blockquote>
```

:::

::: fw flutter

```dart
const NebaBlockquote(child: Text('Default quotation mark'));
const NebaBlockquote(icon: QuoteIcon(), child: Text('A glyph of your own'));
const NebaBlockquote(icon: null, child: Text('No glyph'));
```

A widget of your own is sized to a square twice the text size, and an icon in it takes its size and colour from the `IconTheme` the quote sets.

:::
