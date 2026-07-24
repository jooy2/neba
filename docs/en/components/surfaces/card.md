---
title: Card
order: 2
---

# Card

<p class="neba-lede">A Box with the parts a card is made of laid out on it: a title, a subtitle, a body and a footer. Every Box prop passes straight through, so a card is styled on exactly the same axes as the box it is.</p>

<Demo src="card/hero" />

```tsx
import { Card } from 'neba';

<Card title="Starter" subtitle="One project" footer={<Button>Choose</Button>}>
  Body
</Card>;
```

## Props

<PropsTable name="Card" />

Takes every [Box](./box) prop. The one exception is `padded`, which is omitted because a card redistributes that padding section by section.

## Examples

### Sections

The sections are props rather than compound sub-components. The arrangement is fixed, and what a caller wants to decide is what goes in each slot, not what order the slots come in. A slot you do not pass is not rendered.

<Demo src="card/sections">

<<< @/.vitepress/demos/card/sections.tsx

</Demo>

### Dividers

Turn `dividers` on and the sections are separated by a hairline instead of by space. The lines have to reach both edges, so the padding moves from the sheet onto each section.

<Demo src="card/dividers">

<<< @/.vitepress/demos/card/dividers.tsx

</Demo>

### Sizes

`size` sets the sheet's radius and padding together with the type scale of the header and the body. The title sits one step above the body, the subtitle one step below it.

<Demo src="card/sizes">

<<< @/.vitepress/demos/card/sizes.tsx

</Demo>

### Holding controls

A card is a box, so the controls inside it sit on glass. When the title belongs in the document outline, pass a real heading — `title={<h2>…</h2>}`. It inherits the card's type scale rather than the browser's.

<Demo src="card/form">

<<< @/.vitepress/demos/card/form.tsx

</Demo>
