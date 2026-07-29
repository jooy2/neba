---
title: Card
order: 2
---

# Card

<p class="neba-lede">A Box with slots laid out on it for a title, a subtitle, a body and a footer. Use it for content of the same shape shown repeatedly.</p>

<Demo src="card/hero" />

```tsx
import { Card } from 'neba';

<Card title="Starter" subtitle="One project" footer={<Button>Choose</Button>}>
  Body
</Card>;
```

## Props

<PropsTable name="Card" />

Takes every [Box](./box) prop. The one exception is `padded`, omitted because a Card redistributes that padding section by section.

## Examples

### title · subtitle · headerAction · footer

The sections are props rather than sub-components, and a slot you do not pass is not rendered. `headerAction` is the control slot at the far end of the title row.

<Demo src="card/sections">

<<< @/.vitepress/demos/card/sections.tsx

</Demo>

### dividers

Separates the sections with a rule instead of space. The lines have to reach both edges of the sheet, so the padding moves from the Card onto each section.

<Demo src="card/dividers">

<<< @/.vitepress/demos/card/dividers.tsx

</Demo>

### size

Sets the sheet's radius and padding together with the type scale of the header and the body. The title sits one step above the body, the subtitle one step below it.

<Demo src="card/sizes">

<<< @/.vitepress/demos/card/sizes.tsx

</Demo>

### Holding controls

Pass a real heading as `title` to put it in the document outline — `title={<h2>…</h2>}`. It inherits the Card's type scale rather than the browser's.

<Demo src="card/form">

<<< @/.vitepress/demos/card/form.tsx

</Demo>
