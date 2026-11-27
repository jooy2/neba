---
title: Icon
order: 7
flutter: true
---

# Icon

<p class="neba-lede">A wrapper that gives an icon glyph the library's size and colour axes. Neba ships no icon set, so the glyph comes from whichever set you chose.</p>

<Demo src="icon/hero" />

::: fw react

```tsx
import { Icon } from 'neba';

<Icon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaIcon(
  icon: BoltGlyph(),
  size: NebaSize.lg,
  color: NebaColor.warning,
  semanticLabel: 'Fast',
);
```

:::

## Props

<PropsTable name="Icon" />

::: fw react

The glyph is passed as the `icon` prop rather than as `children`, which is what lets Icon set the size and colour of an element it did not draw: `<Icon icon={<BoltIcon />} />`.

Every native `<span>` attribute passes through.

:::

::: fw flutter

The glyph is passed as `icon` rather than as `child`, and is handed the size and the colour through `IconTheme` and `DefaultTextStyle`, so an `Icon` of an icon font, a drawing that reads `IconTheme` and a text glyph all come out right. It is laid out in a square of the size. Inside a sentence it is a `WidgetSpan` with `PlaceholderAlignment.middle`.

:::

## Examples

### size

Its own steps rather than the control heights: 14 · 16 · 20 · 24 · 28px. These are the sizes icon sets are actually drawn at, so a glyph lands on the pixel grid and is never resampled.

<Demo src="icon/sizes">

::: fw react

<<< @/.vitepress/demos/icon/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/sizes.dart

:::

</Demo>

### color

`color` defaults to <Fw react="`inherit`" flutter="the text colour around it, when it is left out" />: the one colour prop in the library that does not default to `primary`. Placed somewhere that has already decided its content colour, like a button label or inside an [Alert](../feedback/alert), the icon takes that colour. Name a role colour explicitly to override it.

<Demo src="icon/colors">

::: fw react

<<< @/.vitepress/demos/icon/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/colors.dart

:::

</Demo>

### <Fw react="label" flutter="semanticLabel" />

::: fw react

Without `label` the icon is `aria-hidden` and leaves the accessibility tree. That is the default because most icons sit beside text that already says the same thing. Pass `label` only when the glyph carries the meaning on its own.

```tsx
// The text next to it already says "Delete".
<Button startIcon={<Icon icon={<TrashIcon />} />}>Delete</Button>

// There is nothing but the glyph, so it needs a name.
<Icon icon={<TrashIcon />} label="Delete" />
```

:::

::: fw flutter

Without `semanticLabel` the icon is left out of the semantics tree. That is the default because most icons sit beside text that already says the same thing. Pass `semanticLabel` only when the glyph carries the meaning on its own; the icon is then an image by that name.

```dart
// The text next to it already says "Delete".
NebaButton(onPressed: delete, startIcon: const NebaIcon(icon: TrashGlyph()), child: const Text('Delete'));

// There is nothing but the glyph, so it needs a name.
const NebaIcon(icon: TrashGlyph(), semanticLabel: 'Delete');
```

:::

For a glyph that is the whole control, use [IconButton](../inputs/icon-button) instead: there `label` is required.
