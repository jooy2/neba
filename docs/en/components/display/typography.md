---
title: Typography
order: 1
flutter: true
---

# Typography

<p class="neba-lede">Renders text on the library's type scale, so headings, body copy and captions all share the same size steps.</p>

<Demo src="typography/hero" />

::: fw react

```tsx
import { Typography } from 'neba';

<Typography level="h2">A sheet of cut acrylic</Typography>
<Typography>Every surface is the same material at a different opacity.</Typography>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaTypography('A sheet of cut acrylic', level: NebaTypographyLevel.h2);
const NebaTypography('Every surface is the same material at a different opacity.');
```

:::

## Props

<PropsTable name="Typography" />

Two props differ from the rest of the library. The type scale is chosen with `level` rather than `variant`, since `variant` means the weight of a surface everywhere else. And `color` has no default: leave it unset and the text inherits the surrounding colour.

::: fw react

The root carries the class `neba-typography`. It is the hook a stylesheet uses to reach the text from outside React — `.neba-typography { text-wrap: balance }` — since the utilities a level resolves to are not a contract.

:::

::: fw flutter

The text is the first argument, as on a `Text`, and `NebaTypography.rich` takes an `InlineSpan` for text in more than one style. `align` is a `TextAlign` and `weight` a `FontWeight`.

:::

## Examples

### level

`level` sets both the type scale and <Fw react="the element rendered" flutter="the heading level a screen reader hears" />. `body` matches the body step of an `md` [Card](../surfaces/card), so a paragraph inside a card and one outside it are the same size. The heading steps tighten their leading as they grow.

<Demo src="typography/scale">

::: fw react

<<< @/.vitepress/demos/typography/scale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/scale.dart

:::

</Demo>

### color

<Demo src="typography/colors">

::: fw react

<<< @/.vitepress/demos/typography/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/colors.dart

:::

</Demo>

### lines

<Fw react="lines={1}" flutter="lines: 1" code /> truncates to one line with an ellipsis. `2` or more is a line clamp at that many lines.

<Demo src="typography/clamp">

::: fw react

<<< @/.vitepress/demos/typography/clamp.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/clamp.dart

:::

</Demo>

### render

::: fw react

Use `render` when the element `level` implies is not the element you need: a subheading that should stay out of the document outline, or a `<p>` that has to look like a heading.

```tsx
<Typography level="h3" render={<p />}>
  Looks like a heading, is not one
</Typography>
```

:::

::: fw flutter

There is no element to swap. `headingLevel` changes what a screen reader hears and leaves the scale alone: `0` takes a heading out of the outline, and `1` to `6` makes any level a heading at that depth.

```dart
const NebaTypography(
  'Looks like a heading, is not one',
  level: NebaTypographyLevel.h3,
  headingLevel: 0,
);
```

:::

### gutter

`gutter` is off by default, so there are no vertical margins. Turn it on for a run of prose; leave it off inside a flex container that already owns its spacing.

### Overriding with <Fw react="className" flutter="style" code />

::: fw react

A Tailwind utility in `className` wins over the level's own size, leading, tracking, weight, margins and colour, with or without a variant:

```tsx
<Typography level="h2" className="mb-8 text-[2.75rem] font-black">
  42
</Typography>
```

Each level's leading is a **ratio**, not a length, so a size set this way keeps a line box in proportion to it. Add a `leading-*` beside it when the proportion is what you want to change.

A class behind a variant sits on top of the level rather than replacing it: `md:text-5xl` changes the size from `md` up, and below that the level's own size still applies.

The level writes its scale at two-class strength, because `.prose h2` and VitePress's `.vp-doc h2` set `font-size`, `line-height`, `letter-spacing`, `font-weight` and the margins on the tag, at a specificity a single utility cannot reach. For each property your `className` sets, the level steps down to zero specificity instead, so inside such an article that one property is between your class and the article's rule. Only Tailwind's utility names are read: a class from your own stylesheet still needs two classes or `!important` to beat the level. A `!` utility, such as `mb-8!`, works as it always did.

:::

::: fw flutter

`style` is laid over the level's own, as a `Text`'s style is laid over the text around it:

```dart
const NebaTypography(
  '42',
  level: NebaTypographyLevel.h2,
  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900),
);
```

Each level's leading is a **ratio** and its tracking a fraction of the size, so a size set this way keeps both in proportion to it. Set `height` beside it when the proportion is what you want to change.

:::
