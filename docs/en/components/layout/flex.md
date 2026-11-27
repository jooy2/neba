---
title: Flex
order: 12
flutter: true
---

# Flex

<p class="neba-lede">A row, or a column, and the width at which it changes from one to the other. It draws nothing: no surface, no padding, not even a gutter unless one is asked for.</p>

<Demo src="flex/hero" />

::: fw react

```tsx
import { Flex } from 'neba';

<Flex direction={{ xs: 'vertical', md: 'horizontal' }} spacing={3}>
  <Card />
  <Card />
</Flex>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaFlex(
  spacing: 2,
  alignItems: NebaAlignItems.center,
  children: <Widget>[avatar, name],
);
```

:::

## Props

<PropsTable name="Flex" />

::: fw react

Native `<div>` attributes pass through, and `render` swaps the element. The per-breakpoint maps are described in [breakpoints](../../design/breakpoints), the shared axes in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

It draws nothing and takes no `className` or `style`. A child that should take the room left over goes in an `Expanded`, as in any Flutter row. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

## Examples

### direction

`horizontal` is a row and `vertical` a column.<Fw react=" It takes a per-breakpoint map, so a pair of controls can sit side by side once there is room and stack before there is." />

<Demo src="flex/direction">

::: fw react

<<< @/.vitepress/demos/flex/direction.tsx

:::

</Demo>

### spacing

::: fw flutter

`spacing` is the gutter on the spacing scale, so `spacing: 4` is 16 logical pixels, the scale a [GridContainer](./grid) uses. `rowSpacing` is the vertical gap and `columnSpacing` the horizontal one, whatever `direction` is.

:::

::: fw react

`spacing` is the gutter on Tailwind's spacing scale, so `spacing={4}` is `1rem`, the same length `gap-4` is. It is the same scale a [GridContainer](./grid) uses, and it takes a per-breakpoint map. `rowSpacing` is the vertical gap and `columnSpacing` the horizontal one, whatever `direction` is; each is laid _over_ `spacing` rather than replacing it, so naming one breakpoint does not drop the gutter everywhere else.

:::

<Demo src="flex/spacing">

::: fw react

<<< @/.vitepress/demos/flex/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/flex/spacing.dart

:::

</Demo>

### justifyContent · alignItems

`justifyContent` distributes what is left over along the row, and `alignItems` decides where the children sit across it.<Fw react=" Neither takes a per-breakpoint map." />

<Demo src="flex/alignment">

::: fw react

<<< @/.vitepress/demos/flex/alignment.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/flex/alignment.dart

:::

</Demo>

### wrap

::: fw react

Off by default, so a row stays on one line and its children shrink. Turn it on to let a row that runs out of width continue on the next line, as a run of chips does.

```tsx
<Flex wrap spacing={2}>
  {tags.map((tag) => (
    <Chip key={tag}>{tag}</Chip>
  ))}
</Flex>
```

:::

::: fw flutter

Off by default, so a row stays on one line; a child that should give way goes in a `Flexible`. Turn it on to let a row that runs out of width continue on the next line, as a run of chips does.

```dart
NebaFlex(
  wrap: true,
  spacing: 2,
  children: <Widget>[for (final String tag in tags) Text(tag)],
);
```

:::

### reverse

::: fw react

Runs the children the other way along whichever axis `direction` chose, at every breakpoint at once. It is a visual order only: the DOM order is still what a screen reader reads and what the tab sequence follows, so reversing a row whose order carries meaning makes the two disagree.

```tsx
<Flex direction="vertical" reverse>
  <Newest />
  <Oldest />
</Flex>
```

:::

::: fw flutter

Runs the children the other way along whichever axis `direction` chose. It is a visual order only: focus traversal and semantics still follow the order of `children`, so reversing a row whose order carries meaning makes the two disagree.

```dart
NebaFlex(
  direction: NebaOrientation.vertical,
  reverse: true,
  children: <Widget>[newest, oldest],
);
```

:::

## Accessibility

::: fw react

- The box adds no role and no name. On a `<nav>` or a `<ul>`, use `render`: the tag is what carries the meaning.

:::

::: fw flutter

- It adds no semantics. Where the group means something, wrap it in a `Semantics`.

:::

- `reverse`, and `justifyContent` values that move children about, change what is seen and not what is read. Where the order matters, put the children in the order they should be read.
