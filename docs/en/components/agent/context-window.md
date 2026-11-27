---
title: ContextWindow
order: 5
flutter: true
---

# ContextWindow

<p class="neba-lede">How much of the context window has gone, and what went into it. A ring, the counts written compactly, the split into input, output, reasoning and cached, and what the turn cost.</p>

<Demo src="context-window/hero" />

::: fw react

```tsx
import { ContextWindow } from 'neba';

<ContextWindow
  max={200_000}
  tokens={{ input: 94_200, output: 12_400, reasoning: 8_100, cached: 61_000 }}
  cost={0.42}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaContextWindow(
  max: 200000,
  tokens: NebaContextTokens(input: 94200, output: 12400, reasoning: 8100, cached: 61000),
  cost: 0.42,
);
```

:::

## Props

<PropsTable name="ContextWindow" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` is excluded, since the table above spells it differently.

:::

::: fw flutter

`tokens` is a `NebaContextTokens`. The widgets layer has no `Intl`, so there is no `currency`: the counts are written in English unless `format` writes them, and the cost in US dollars unless `formatCost` does. `labels` is a map keyed by the React package's names for the words.

:::

A [Meter](../feedback/meter) draws the same reading as a single bar, without the split and the cost.

### ContextTokens

<PropsTable name="ContextTokens" />

## Examples

### max · used · tokens

`max` is the window; `used` is what has gone. Leave `used` out and it is `input` plus `output` plus `reasoning`, which is the usual case — a caller who has the split has the total.

`cached` is **not** in that sum. Every model that reports it means "this much of the input came out of a cache", so those tokens are already inside `input`; adding them again would report the window as fuller than it is by exactly the number the cache saved. It is still drawn as a row, because how much was free is worth knowing.

Every part of `tokens` is optional, and only the ones reported are drawn. A part that is `0` **is** reported: a cache that returned nothing is a different fact from a model that has no cache.

<Demo src="context-window/filling">

::: fw react

<<< @/.vitepress/demos/context-window/filling.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/context_window/filling.dart

:::

</Demo>

### thresholds

Where the ring changes colour, in tokens rather than as a share — so a window at four fifths is <Fw react="{ from: 0.8 * max, color: 'warning' }" flutter="NebaThreshold(from: 0.8 * max, color: NebaColor.warning)" code />. The same prop a [Meter](../feedback/meter) takes, read the same way: in the order given, and the last one the value has reached wins.

### The colours of the split

The four parts take the first four chart palette slots, in the order above, rather than colour families.

### breakdown

On. Turned off, the gauge is the ring and the counts beside it, which is what fits in a [Toolbar](../surfaces/toolbar) or at the end of a [PromptInput](./prompt-input).

<Demo src="context-window/compact">

::: fw react

<<< @/.vitepress/demos/context-window/compact.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/context_window/compact.dart

:::

</Demo>

### <Fw react="locale" flutter="format · formatCost" />

::: fw react

What decides whether 124,000 tokens read as `124K`, `12.4万` or `12.4만`, and what currency formatting the cost gets. It falls back to a provider's `locale`, so a server and a browser write the same thing.

:::

::: fw flutter

What writes 124,000 tokens as something other than `124K`, and the cost as something other than `$0.42`. The widgets layer has no `Intl` to ask, so another language's numbers and another currency are functions of the caller's; `locale` changes only the gauge's own words.

:::

<Demo src="context-window/locale">

::: fw react

<<< @/.vitepress/demos/context-window/locale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/context_window/locale.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI's Meter owns the semantics: `role="meter"` with the value and range attributes, so the reading is announced as a reading rather than as a picture. The meter is the ring, the label and the count; the split, the cost and `children` sit outside it, so the split is read as a list and a link under it is a link.
- `aria-valuetext` is the same sentence the gauge draws, rather than a percentage of a range nobody described.
- The swatches beside the split are `aria-hidden`; every row is named in words.

:::

::: fw flutter

- The ring, the label and the count are one semantics node, named by the label, whose value is the same sentence the gauge draws rather than a percentage of a range nobody described. The split, the cost and `child` sit outside it, so the split is read as a list and a link under it is a link.
- The swatches beside the split are drawn and not read; every row is named in words.

:::
