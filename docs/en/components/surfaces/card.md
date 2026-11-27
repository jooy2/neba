---
title: Card
order: 2
flutter: true
---

# Card

<p class="neba-lede">A Box with slots laid out on it for a title, a subtitle, a body and a footer. Use it for content of the same shape shown repeatedly.</p>

<Demo src="card/hero" />

::: fw react

```tsx
import { Button, Card } from 'neba';

<Card title="Starter" subtitle="One project" footer={<Button>Choose</Button>}>
  Body
</Card>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCard(
  title: const Text('Starter'),
  subtitle: const Text('One project'),
  footer: NebaButton(onPressed: choose, child: const Text('Choose')),
  child: const Text('Body'),
);
```

:::

## Props

<PropsTable name="Card" />

Takes every [Box](./box) prop. The one exception is `padded`, omitted because a Card redistributes that padding section by section.

::: fw flutter

Every slot is a widget. `footer` is set in the body's type but is not laid out as a row: a pair of buttons goes in a `Row` or a `NebaFlex` of its own, where a `Spacer` pushes one to the end. A card takes the width it is given, so one inside a row needs a width of its own.

:::

## Examples

### title · subtitle · headerAction · footer

The sections are props rather than sub-components, and a slot you do not pass is not <Fw react="rendered" flutter="built" />. `headerAction` is the control slot at the far end of the title row.

<Demo src="card/sections">

::: fw react

<<< @/.vitepress/demos/card/sections.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/sections.dart

:::

</Demo>

### dividers

Separates the sections with a rule instead of space. The lines have to reach both edges of the sheet, so the padding moves from the Card onto each section.

<Demo src="card/dividers">

::: fw react

<<< @/.vitepress/demos/card/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/dividers.dart

:::

</Demo>

### size

Sets the sheet's radius and padding together with the type scale of the header and the body. The title sits one step above the body, the subtitle one step below it.

<Demo src="card/sizes">

::: fw react

<<< @/.vitepress/demos/card/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/sizes.dart

:::

</Demo>

### Holding controls

A Card holds a form as readily as text, with its actions in `footer`.

::: fw react

Pass a real heading as `title` to put the card in the document outline: `title={<h2>…</h2>}`. It inherits the Card's type scale rather than the browser's, even inside an article whose stylesheet styles `h2`. Classes on the heading win over that scale, `title={<h2 className="text-xl">…</h2>}`; a heading with a class is left to them, so inside such an article the article's rule applies to whatever they do not set.

:::

::: fw flutter

Wrap the `title` in `Semantics(header: true, child: …)` to put the card in the screen's outline. It keeps the title's type; a `style` on the `Text` wins over it.

:::

<Demo src="card/form">

::: fw react

<<< @/.vitepress/demos/card/form.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/form.dart

:::

</Demo>
