---
title: ContextWindow
order: 5
---

# ContextWindow

<p class="neba-lede">How much of the context window has gone, and what went into it. A ring, the counts written compactly, the split into input, output, reasoning and cached, and what the turn cost.</p>

<Demo src="context-window/hero" />

```tsx
import { ContextWindow } from 'neba';

<ContextWindow
  max={200_000}
  tokens={{ input: 94_200, output: 12_400, reasoning: 8_100, cached: 61_000 }}
  cost={0.42}
/>;
```

## Props

<PropsTable name="ContextWindow" />

Native `<div>` attributes pass through to the root. Only `color` is excluded, since the table above spells it differently.

A [Meter](../feedback/meter) draws the same reading as a bar and would do most of this. What it cannot do is the part that makes this a component: token counts are five and six digits long and have to be written compactly in the reader's own language, the four-way split only means anything with the parts next to each other, and the money underneath is a third unit again.

### ContextTokens

<PropsTable name="ContextTokens" />

## Examples

### max · used · tokens

`max` is the window; `used` is what has gone. Leave `used` out and it is the sum of `tokens`, which is the usual case — a caller who has the split has the total.

Every part of `tokens` is optional, and only the ones reported are drawn. A part that is `0` **is** reported: a cache that returned nothing is a different fact from a model that has no cache.

<Demo src="context-window/filling">

<<< @/.vitepress/demos/context-window/filling.tsx

</Demo>

### thresholds

Where the ring changes colour, in tokens rather than as a share — so a window at four fifths is `{ from: 0.8 * max, color: 'warning' }`. The same prop a [Meter](../feedback/meter) takes, read the same way: in the order given, and the last one the value has reached wins.

### The colours of the split

The four parts take the first four chart palette slots rather than four colour families, because input and output are _entities_: nothing about either means success or danger. The slots are handed out in the fixed order above, which is what keeps the adjacent pairs the ones that were checked for colour-vision separation.

### breakdown

On. Turned off, the gauge is the ring and the counts beside it, which is what fits in a [Toolbar](../surfaces/toolbar) or at the end of a [PromptInput](./prompt-input).

<Demo src="context-window/compact">

<<< @/.vitepress/demos/context-window/compact.tsx

</Demo>

### locale

What decides whether 124,000 tokens read as `124K`, `12.4万` or `12.4만`, and what currency formatting the cost gets. It falls back to a provider's `locale`, so a server and a browser write the same thing.

<Demo src="context-window/locale">

<<< @/.vitepress/demos/context-window/locale.tsx

</Demo>

## Accessibility

- Base UI's Meter owns the semantics: `role="meter"` with the value and range attributes, so the reading is announced as a reading rather than as a picture.
- `aria-valuetext` is the same sentence the gauge draws, rather than a percentage of a range nobody described.
- The swatches beside the split are `aria-hidden`; every row is named in words.
