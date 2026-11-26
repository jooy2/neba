---
title: Stack
order: 11
flutter: true
---

# Stack

<p class="neba-lede">Lays things over each other so a set reads as a pile rather than a row. Faces on a shared task, cards in a deck, sheets on a desk: anything where the count matters more than each item does.</p>

<Demo src="stack/hero" />

::: fw react

```tsx
import { Avatar, Stack } from 'neba';

<Stack ring>
  <Avatar name="Jane Doe" />
  <Avatar name="Kim Minji" />
</Stack>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaStack(
  ring: true,
  children: <Widget>[jane, minji],
);
```

:::

## Props

<PropsTable name="Stack" />

::: fw react

Every native `<span>` attribute passes through. It draws no surface of its own, so there is no `variant`, `color` or `elevation`.

:::

::: fw flutter

It draws no surface of its own, so there is no `variant`, `color` or `elevation`, and it takes no `className` or `style`.

:::

The box is exactly as big as the pile, so the content after a Stack is laid out against the right width. `size` is read only to pick the default `overlap`.

::: fw react

Each child is passed through untouched, so anything can be stacked, including a [Tooltip](../feedback/tooltip) around an avatar or anything produced by another component's `.map()`. `ring` is drawn on the children themselves, so it follows their shape.

:::

::: fw flutter

Each child is passed through untouched, so anything can be stacked. `ring` is drawn by the first Neba widget inside each item that draws a shape, around that shape, so a round face gets a round ring; a widget of your own draws none.

:::

See [prop conventions](../../design/prop-conventions) for the shared axes.

## Examples

### direction

`horizontal` (the default) runs the pile along the inline axis and `vertical` runs it down the page. `diagonal` flows sideways like `horizontal` and drops each item by `drop` as it goes, which is the fanned deck.

<Demo src="stack/direction" minHeight="260">

::: fw react

<<< @/.vitepress/demos/stack/direction.tsx

:::

</Demo>

### overlap and drop

`overlap` is how far each item sits under the one before it, along the axis the stack flows on<Fw react=": a CSS length, or a number of pixels" flutter=", in logical pixels" />. Left out it is a fraction of `size`. `drop` is the other axis, and only `diagonal` moves on two: it defaults to `overlap`.

### scaleStep, opacityStep and front

`scaleStep` multiplies each item against the one in front of it, so `0.94` takes six per cent off at every step and the pile recedes. `opacityStep` does the same for opacity. `front` says which end of the list is on top: `first` by default, so a pile read from its leading edge is read front to back.

<Demo src="stack/depth" minHeight="280">

::: fw react

<<< @/.vitepress/demos/stack/depth.tsx

:::

</Demo>

### max, total and overflow

`max` is how many items are drawn before the rest become one more item at the back of the pile. `total` is how many there are altogether, for a stack handed only the first few. `overflow` is handed the number that did not fit and returns what stands in for them.

::: fw react

```tsx
<Stack max={3} total={12} overflow={(hidden) => <Avatar initials={`+${hidden}`} />}>
```

:::

::: fw flutter

```dart
NebaStack(
  max: 3,
  total: 12,
  overflow: (int hidden) => Text('+$hidden'),
  children: faces,
);
```

:::

### transition and stagger

::: fw react

`transition` is the library's own entrance vocabulary, applied to each item. `stagger` adds that many milliseconds to each item's delay in turn, which is what makes a pile look dealt rather than appeared; `durationStep` does the same to the duration, and `reverse` runs the items last-to-first.

:::

::: fw flutter

`transition` is the library's own entrance vocabulary, applied to each item. `stagger` is a `Duration` added to each item's delay in turn, which is what makes a pile look dealt rather than appeared; `durationStep` does the same to the duration, and `reverse` runs the items last-to-first.

:::

<Demo src="stack/dealt" minHeight="320">

::: fw react

<<< @/.vitepress/demos/stack/dealt.tsx

:::

</Demo>

## Accessibility

::: fw react

- A Stack is a `<span>` and announces nothing. When the pile stands for a group (the people on a task, the files in a folder), give it a `role` and an accessible name, or put the count in text beside it.
- The overflow marker is drawn as an ordinary item, so whatever it renders is what a screen reader reads. `+38` on its own says very little; an `aria-label` on it says the rest.

:::

::: fw flutter

- A NebaStack adds no semantics. When the pile stands for a group (the people on a task, the files in a folder), wrap it in a `Semantics` with a label, or put the count in text beside it.
- The overflow marker is drawn as an ordinary item, so whatever it builds is what a screen reader reads. `+38` on its own says very little; a `Semantics` label on it says the rest.

:::
