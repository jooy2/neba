---
title: ScrollZone
order: 9
flutter: true
---

# ScrollZone

<p class="neba-lede">A strip of anything, laid out in one direction and scrolled in it. Cards, chips, avatars or thumbnails run across the box or down it, in as many lines as you ask for, with a pair of buttons for the pointer that has no wheel and no finger.</p>

<Demo src="scroll-zone/hero" minHeight="220" />

::: fw react

```tsx
import { ScrollZone } from 'neba';

<ScrollZone label="Continue watching" spacing={3}>
  {shows.map((show) => (
    <Card key={show.name} className="w-40" title={show.name} />
  ))}
</ScrollZone>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaScrollZone(
  label: 'Continue watching',
  spacing: 3,
  children: <Widget>[
    for (final Show show in shows)
      SizedBox(width: 160, child: NebaCard(title: Text(show.name))),
  ],
);
```

:::

## Props

<PropsTable name="ScrollZone" />

::: fw react

Every other `<div>` attribute passes through to the root, and so does `ref`. `scrollerRef` and `onScroll` belong to the box inside it that scrolls.

:::

::: fw flutter

It takes no `className` or `style`. Underneath it is an ordinary Flutter scroll view, so a finger, a stylus, a trackpad and momentum are the platform's own; `controller` hands you its position and `onScroll` is called as it moves. Like any Flutter scroll view it needs a bounded size along the way it runs: a horizontal zone inside a `Row` goes in an `Expanded`. The buttons are round `NebaButton`s.

:::

The shared axes (`variant` `size` `color` `density` `orientation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### orientation and lines

`orientation` decides which way the strip runs and therefore which way it scrolls. `lines` is how many rows a horizontal zone fills before it starts a new column: two lines hold twice as much in the same width, and the strip is still one scroll.

`spacing` is the gap between children, on the same scale as [GridContainer](./grid)'s: `2` is <Fw react="`0.5rem`" flutter="8 logical pixels" />.

<Demo src="scroll-zone/lines" minHeight="220">

::: fw react

<<< @/.vitepress/demos/scroll-zone/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/lines.dart

:::

</Demo>

### mode

What a press of a button does. `item` moves to the next child along and `step` says how many at a time; `page` moves by everything currently on screen; `hold` scrolls for as long as the button is held, at `speed` pixels a second. A press too short to be a hold moves one item, so a quick tap is never a dead press.

<Demo src="scroll-zone/modes" minHeight="360">

::: fw react

<<< @/.vitepress/demos/scroll-zone/modes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/modes.dart

:::

</Demo>

### buttons

`auto` (the default) draws neither while everything fits. At an end, an overlaid button with nowhere to go is removed and an inline one stays in place, `disabled`. `always` draws both from the first <Fw react="paint" flutter="frame" />, including while everything still fits, which suits a strip whose content arrives later. `none` draws neither and leaves the strip to dragging, the arrow keys and whatever the pointer can already swipe with.

`snap` brings the nearest child to the leading edge whenever the scrolling stops, however it was scrolled.

<Demo src="scroll-zone/buttons" minHeight="260">

::: fw react

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/buttons.dart

:::

</Demo>

### buttonPlacement

`inline` (the default) puts the buttons beside the strip. The scroller stops where a button starts, so an item is **cut off** at the button's edge rather than sliding beneath it. `overlay` puts the buttons over the ends of the strip instead, which keeps every pixel of the box for content and lets an item pass under a button.

An inline button keeps its lane while it has nowhere to go, so the strip does not change width when it reaches an end.

Until the zone has measured itself, which <Fw react="on a server-rendered page is the first paint" flutter="is its first frame" />, an inline `auto` zone holds both lanes open with the buttons hidden. A strip that overflows keeps them and its buttons appear in place; a strip that fits gives them back.

<Demo src="scroll-zone/placement" minHeight="280">

::: fw react

<<< @/.vitepress/demos/scroll-zone/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/placement.dart

:::

</Demo>

### Running down the page

::: fw react

A vertical zone needs a height to scroll inside, and it takes it from the component: the root is a flex column and the scroller fills it, so `className="h-full"` on a box with a height is all it needs.

:::

::: fw flutter

A vertical zone needs a height to scroll inside. Give it one with a `SizedBox`, or put it in an `Expanded`, and the strip fills what is left between the buttons.

:::

<Demo src="scroll-zone/vertical" minHeight="260">

::: fw react

<<< @/.vitepress/demos/scroll-zone/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/vertical.dart

:::

</Demo>

### drag

::: fw react

A finger already scrolls the strip. `drag` adds the same gesture for a mouse or a pen, and the click that would otherwise follow a real drag is swallowed, so pulling the strip past a card never opens it.

```tsx
<ScrollZone drag={false} scrollbar>
  {items}
</ScrollZone>
```

:::

::: fw flutter

A finger, a stylus and a trackpad already scroll the strip. `drag` adds the same gesture for a mouse, and a press that turns into a drag never reaches the child under it, so pulling the strip past a card never opens it. A drag let go mid-flick carries on with the platform's momentum.

```dart
NebaScrollZone(drag: false, scrollbar: true, children: items);
```

:::

### wheel

`wheel` turns a mouse wheel rolled over a horizontal strip into travel along it. It is off by default, and a vertical zone ignores it.

While the pointer is over a strip that overflows, the wheel moves only the strip, even at its ends, and the page takes the wheel back once the pointer moves off. A sideways trackpad swipe is left alone, since it already scrolls the strip.

<Demo src="scroll-zone/wheel" minHeight="280">

::: fw react

<<< @/.vitepress/demos/scroll-zone/wheel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/wheel.dart

:::

</Demo>

## Accessibility

::: fw react

- While it overflows, the strip is focusable and scrolls with the arrow keys, which is the browser's own key handling on a scroll container, so it is already right under RTL. A strip whose content fits is not a tab stop.

:::

::: fw flutter

- While it overflows, the strip is focusable and scrolls with the arrow keys along it, Page Up and Page Down, Home and End, the arrows following the reading direction under RTL. A strip whose content fits is not a tab stop. Tab visits the children in the order they are in, and a child the keyboard focuses is scrolled clear of the strip's edge.

:::

- `label` names the region and is what a screen reader reads before its contents. Without one it is named with the locale's generic word, so it is never unnamed, but only `label` says what is in it.
- The scroll buttons are real buttons with real names, and `previousLabel` / `nextLabel` (or `locale`) decide what those names are.
- In `hold` mode the buttons answer Enter and Space the same way they answer a press, scrolling while the key is down.
- A button with nowhere to go <Fw react="is marked `aria-disabled` rather than `disabled`" flutter="is disabled but stays in the focus order" />, so the press that reaches the end leaves the focus on it. An overlaid one that `auto` would remove stays until the focus moves on.
- Nothing inside the strip is hidden from assistive technology when it is off screen, since it stays reachable by scrolling.
