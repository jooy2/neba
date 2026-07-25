---
title: Divider
order: 2
---

# Divider

<p class="neba-lede">A rule between two things. It is not a surface: no acrylic, no light, no shadow — just the hairline.</p>

<Demo src="divider/hero" />

```tsx
import { Divider } from 'neba';

<Divider />
<Divider>OR</Divider>
<Divider orientation="vertical" />;
```

## Props

<PropsTable name="Divider" />

There is no `variant` and no `elevation`. The line is drawn as a single border edge, so a divider never adds a pixel of layout beyond the rule itself — and it is literally the same declaration [Card](../surfaces/card) uses between its sections, which is why a table on a card and the card's own dividers are one family of lines.

## Examples

### Labels

`center` splits the line in half. `start` and `end` leave a short stub on the near side, so the label still reads as set _into_ the rule rather than floating above it.

<Demo src="divider/labels">

<<< @/.vitepress/demos/divider/labels.tsx

</Demo>

### Vertical

A vertical divider has no height of its own — it stretches to its flex parent, the way a rule between two toolbar groups should. A vertical label turns with the line, or the rule would grow to the width of the word and stop being a hairline.

<Demo src="divider/vertical">

<<< @/.vitepress/demos/divider/vertical.tsx

</Demo>

### Colour

Only the hairline is coloured, and only faintly.

<Demo src="divider/colors">

<<< @/.vitepress/demos/divider/colors.tsx

</Demo>

## Accessibility

`separator` is not a name-from-content role, so a visible label does not become the accessible name on its own — a screen reader would announce a bare "separator" and read the word loose. A **string** label is therefore copied into `aria-label`. Anything richer is left alone: only you know which part of it is the name.
