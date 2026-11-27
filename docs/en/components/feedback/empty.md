---
title: Empty
order: 10
flutter: true
---

# Empty

<p class="neba-lede">It fills the place content would have taken, with a glyph, a headline, a sentence and a way out. It is for the list that came back with nothing, the inbox nobody has written to, and the folder before its first file.</p>

<Demo src="empty/hero" align="center" minHeight="260" />

::: fw react

```tsx
import { Button, Empty } from 'neba';

<Empty title="No projects yet" action={<Button size="sm">Create a project</Button>}>
  Everything you deploy shows up here.
</Empty>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaEmpty(
  title: const Text('No projects yet'),
  actions: <Widget>[
    NebaButton(onPressed: create, size: NebaSize.sm, child: const Text('Create a project')),
  ],
  child: const Text('Everything you deploy shows up here.'),
);
```

:::

## Props

<PropsTable name="Empty" />

::: fw react

Native `<div>` attributes pass through, and `render` swaps the element. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

The sentence under the headline is `child`. The state takes the width it is given and centres what it holds, and in a height it is stretched to, as in a row of them, it centres that too. There is no `render`: a widget has no element to swap. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

## Examples

### title

The headline defaults to the `locale`'s way of saying that there is nothing here, so an Empty with no props at all still says something. Pass `title` for the version that names what is missing (which is nearly always worth doing), or <Fw react="`title={false}`" flutter="`showTitle: false`" /> for a state that is a glyph and a sentence with no heading over them.

<Demo src="empty/title" minHeight="200">

::: fw react

<<< @/.vitepress/demos/empty/title.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/title.dart

:::

</Demo>

### icon

::: fw react

`icon` takes any node and replaces the default tray: an icon from another set, an illustration, a brand mark. An `<svg>` is sized off the `size` ladder; anything else is left at the size it came in at. `icon={false}` drops it.

:::

::: fw flutter

`icon` takes any widget and replaces the default tray: an icon from another set, an illustration, a brand mark. A glyph that reads the `IconTheme`, as `Icon` does, is sized off the `size` ladder and drawn in the muted ink; anything else is left at the size it came in at. `showIcon: false` drops it.

:::

<Demo src="empty/icon" minHeight="200">

::: fw react

<<< @/.vitepress/demos/empty/icon.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/icon.dart

:::

</Demo>

### <Fw react="action" flutter="actions" />

::: fw react

`action` sits under the text and is where the state stops being a dead end: a button that creates the first record, a link that clears the filter that matched nothing. Pass a fragment for more than one and they lay out in a row that wraps together.

:::

::: fw flutter

`actions` sit under the text and are where the state stops being a dead end: a button that creates the first record, a link that clears the filter that matched nothing. More than one lay out in a row 8 pixels apart that wraps together.

:::

<Demo src="empty/action" minHeight="220">

::: fw react

<<< @/.vitepress/demos/empty/action.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/action.dart

:::

</Demo>

### variant

`text` is the default: an empty state is usually already inside a [Card](../surfaces/card), a [Table](../display/table) or a panel, and a second rectangle inside the first is one rectangle too many. `outline` and `solid` are for the case where nothing else marks the bounds of the region.

<Demo src="empty/variants" minHeight="200">

::: fw react

<<< @/.vitepress/demos/empty/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/variants.dart

:::

</Demo>

### size and density

`size` sets the type scale, the glyph and how much room the state takes vertically. `density` changes the padding and nothing else, which is what to reach for when the state has to fit inside a control-sized row.

<Demo src="empty/size" minHeight="360">

::: fw react

<<< @/.vitepress/demos/empty/size.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/size.dart

:::

</Demo>

### color

The sheet is never dyed: `color` reaches the hairline and the focus ring and stops there. `secondary` is the default because an empty state arriving in the accent colour is making a claim about content that does not exist. Move it when the emptiness is itself a problem.

<Demo src="empty/color" minHeight="220">

::: fw react

<<< @/.vitepress/demos/empty/color.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/color.dart

:::

</Demo>

### locale

::: fw react

`locale` is a BCP 47 tag and decides the default headline only. It is ignored once `title` is given, and an unsupported tag falls back to English.

:::

::: fw flutter

`locale` decides the default headline only, then `NebaProvider`'s, then the app's. It is ignored once `title` is given, and a language the app has not registered with `registerNebaMessages` falls back to English.

:::

<Demo src="empty/locale" minHeight="220">

::: fw react

<<< @/.vitepress/demos/empty/locale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/locale.dart

:::

</Demo>

### Inside a Table

[Table](../display/table) takes an `empty` prop for what to show instead of rows, and it renders into a cell spanning every column. That cell has padding of its own, so `density="compact"` is usually the right pairing.

<Demo src="empty/table" minHeight="260">

::: fw react

<<< @/.vitepress/demos/empty/table.tsx

:::

</Demo>

## Accessibility

::: fw react

- The root is a `role="status"` live region. A screen reader announces a live region when what is inside it changes, and an Empty that appears in place of a list arrives already holding its message, which not every screen reader announces. When a list emptying under the reader has to be heard, keep one `role="status"` element on the page from the start and write the message into it. Pass `role={undefined}` for a state that is simply part of the page when it arrives.
- The default glyph is `aria-hidden`. It names nothing the headline does not already say.
- Reach for [Skeleton](./skeleton) while content is still on its way and Empty only once it is known that none is coming. Showing neither leaves a blank rectangle where the answer should be.

:::

::: fw flutter

- The state is a live region: `SemanticsRole.status` on the web and a live region on Android and iOS. A screen reader announces a live region when what is inside it changes, and an Empty that appears in place of a list arrives already holding its message, which not every screen reader announces. Pass `role: SemanticsRole.none` for a state that is simply part of the screen when it arrives.
- The default glyph says nothing to a screen reader. It names nothing the headline does not already say.
- Reach for [Skeleton](./skeleton) while content is still on its way and Empty only once it is known that none is coming. Showing neither leaves a blank rectangle where the answer should be.

:::
