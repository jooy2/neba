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

Every other `<div>` attribute passes through to the root. The shared axes (`variant` `size` `color` `density` `orientation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### orientation and lines

`orientation` decides which way the strip runs and therefore which way it scrolls. `lines` is how many rows a horizontal zone fills before it starts a new column — two lines hold twice as much in the same width, and the strip is still one scroll.

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

`auto` — the default — draws only the button that has somewhere to go, and neither of them while everything fits. `always` draws both from the first paint and disables the one that cannot move, which is what a strip whose content arrives later wants. `none` draws neither and leaves the strip to the wheel, the arrow keys and dragging.

`snap` brings the nearest child to the leading edge whenever the scrolling stops, however it was scrolled.

<Demo src="scroll-zone/buttons" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

</Demo>

### buttonPlacement

`overlay` — the default — puts the buttons over the ends of the strip, which keeps every pixel of the box for content and lets an item pass under a button. `inline` puts them beside it: the scroller stops where the button starts, so an item is **cut off** at the button's edge rather than sliding beneath it, and the button is legible over the page rather than over whatever it landed on.

An inline button keeps its lane even while it has nowhere to go, or the strip would resize under the pointer that had just reached the end of it.

<Demo src="scroll-zone/placement" minHeight="280">

<<< @/.vitepress/demos/scroll-zone/placement.tsx

</Demo>

### Running down the page

A vertical zone needs a height to scroll inside, and it takes it from the component: the root is a flex column and the scroller fills it, so `className="h-full"` on a box with a height is all it needs.

<Demo src="scroll-zone/vertical" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/vertical.tsx

</Demo>

### drag

A finger already scrolls the strip, because the mechanism is an ordinary scroll container and touch scrolling is the browser's own — with momentum, rubber-banding and a scrollbar that no handler reproduces. `drag` adds the same gesture for a mouse or a pen, and the click that would otherwise follow a real drag is swallowed, so pulling the strip past a card never opens it.

```tsx
<ScrollZone drag={false} scrollbar>
  {items}
</ScrollZone>
```

## Accessibility

- The strip is focusable and scrolls with the arrow keys, which is the browser's own key handling on a scroll container — so it is already right under RTL.
- `label` names the region and is what a screen reader reads before its contents. Without one the strip is focusable but unnamed.
- The scroll buttons are real buttons with real names, and `previousLabel` / `nextLabel` — or `locale` — decide what those names are.
- In `hold` mode the buttons answer Enter and Space the same way they answer a press, scrolling while the key is down.
- Nothing inside the strip is hidden when it is off screen: it is genuinely reachable by scrolling, and `aria-hidden` on it would be a lie a keyboard reader would fall into.
