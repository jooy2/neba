---
title: ScrollZone
order: 9
---

# ScrollZone

<p class="neba-lede">A strip of anything, laid out in one direction and scrolled in it. Cards, chips, avatars or thumbnails run across the box or down it, in as many lines as you ask for, with a pair of buttons for the pointer that has no wheel and no finger.</p>

<Demo src="scroll-zone/hero" minHeight="220" />

```tsx
import { ScrollZone } from 'neba';

<ScrollZone label="Continue watching" spacing={3}>
  {shows.map((show) => (
    <Card key={show.name} className="w-40" title={show.name} />
  ))}
</ScrollZone>;
```

## Props

<PropsTable name="ScrollZone" />

Every other `<div>` attribute passes through to the root, and so does `ref`. `scrollerRef` and `onScroll` belong to the box inside it that scrolls. The shared axes (`variant` `size` `color` `density` `orientation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### orientation and lines

`orientation` decides which way the strip runs and therefore which way it scrolls. `lines` is how many rows a horizontal zone fills before it starts a new column: two lines hold twice as much in the same width, and the strip is still one scroll.

`spacing` is the gap between children, on the same scale as [GridContainer](./grid)'s: `2` is `0.5rem`.

<Demo src="scroll-zone/lines" minHeight="220">

<<< @/.vitepress/demos/scroll-zone/lines.tsx

</Demo>

### mode

What a press of a button does. `item` moves to the next child along and `step` says how many at a time; `page` moves by everything currently on screen; `hold` scrolls for as long as the button is held, at `speed` pixels a second. A press too short to be a hold moves one item, so a quick tap is never a dead press.

<Demo src="scroll-zone/modes" minHeight="360">

<<< @/.vitepress/demos/scroll-zone/modes.tsx

</Demo>

### buttons

`auto` (the default) draws neither while everything fits. At an end, an overlaid button with nowhere to go is removed and an inline one stays in place, `disabled`. `always` draws both from the first paint, including while everything still fits, which suits a strip whose content arrives later. `none` draws neither and leaves the strip to dragging, the arrow keys and whatever the pointer can already swipe with.

`snap` brings the nearest child to the leading edge whenever the scrolling stops, however it was scrolled.

<Demo src="scroll-zone/buttons" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

</Demo>

### buttonPlacement

`inline` (the default) puts the buttons beside the strip. The scroller stops where a button starts, so an item is **cut off** at the button's edge rather than sliding beneath it. `overlay` puts the buttons over the ends of the strip instead, which keeps every pixel of the box for content and lets an item pass under a button.

An inline button keeps its lane while it has nowhere to go, so the strip does not change width when it reaches an end.

<Demo src="scroll-zone/placement" minHeight="280">

<<< @/.vitepress/demos/scroll-zone/placement.tsx

</Demo>

### Running down the page

A vertical zone needs a height to scroll inside, and it takes it from the component: the root is a flex column and the scroller fills it, so `className="h-full"` on a box with a height is all it needs.

<Demo src="scroll-zone/vertical" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/vertical.tsx

</Demo>

### drag

A finger already scrolls the strip. `drag` adds the same gesture for a mouse or a pen, and the click that would otherwise follow a real drag is swallowed, so pulling the strip past a card never opens it.

```tsx
<ScrollZone drag={false} scrollbar>
  {items}
</ScrollZone>
```

### wheel

`wheel` turns a mouse wheel rolled over a horizontal strip into travel along it. It is off by default, and a vertical zone ignores it.

While the pointer is over a strip that overflows, the wheel moves only the strip, even at its ends, and the page takes the wheel back once the pointer moves off. A sideways trackpad swipe is left alone, since it already scrolls the strip.

<Demo src="scroll-zone/wheel" minHeight="280">

<<< @/.vitepress/demos/scroll-zone/wheel.tsx

</Demo>

## Accessibility

- The strip is focusable and scrolls with the arrow keys, which is the browser's own key handling on a scroll container, so it is already right under RTL.
- `label` names the region and is what a screen reader reads before its contents. Without one it is named with the locale's generic word, so it is never unnamed, but only `label` says what is in it.
- The scroll buttons are real buttons with real names, and `previousLabel` / `nextLabel` (or `locale`) decide what those names are.
- In `hold` mode the buttons answer Enter and Space the same way they answer a press, scrolling while the key is down.
- A button with nowhere to go is marked `aria-disabled` rather than `disabled`, so the press that reaches the end leaves the focus on it. An overlaid one that `auto` would remove stays until the focus moves on.
- Nothing inside the strip is hidden from assistive technology when it is off screen, since it stays reachable by scrolling.
