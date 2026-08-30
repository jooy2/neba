---
title: HoverCard
order: 16
---

# HoverCard

<p class="neba-lede">A card that opens when the pointer rests on something and holds a preview of what is on the other side of it — a person behind a mention, a repository behind a link, a deploy behind an id.</p>

<Demo src="hover-card/hero" />

```tsx
import { HoverCard, TextLink } from 'neba';

<HoverCard trigger={<TextLink href="/people/jooy2">@jooy2</TextLink>} title="Jooy Lee">
  Maintainer · 214 commits
</HoverCard>;
```

## Props

<PropsTable name="HoverCard" />

Every native `<div>` attribute passes through to the popup, apart from `color`, `title` and `children`, which the component owns. There is no `variant` and no `elevation`, for the reason [Popover](./popover) has neither: a surface that had to be hovered has already asserted itself, and a card that floats over the page cannot be sat flat.

It sits between the library's other two popups. A [Tooltip](../feedback/tooltip) is a label — one line, and the pointer never reaches it. A Popover was _asked for_ by a press, so it can hold a form. This one is uninvited like a tooltip and reachable like a popover: the pointer can cross into it and a link inside it can be followed.

## Examples

### trigger

The trigger is an element rather than children, and the card merges onto it — no wrapper, so the layout is unchanged and a link stays a link. Usually a [TextLink](../display/text-link) or an [Avatar](../display/avatar).

### delay · closeDelay

`delay` is how long the pointer has to rest before the card opens, and `closeDelay` how long it stays after the pointer leaves — which is what makes the gap between the trigger and the card crossable.

<Demo src="hover-card/delay">

<<< @/.vitepress/demos/hover-card/delay.tsx

</Demo>

### side · align · arrow

`side` is the edge of the trigger the card appears on, flipping when there is no room; `align` is where it sits along that edge. `arrow` draws the wedge, and is off by default because a translucent sheet's wedge cannot carry the blurred backdrop with it.

<Demo src="hover-card/placement">

<<< @/.vitepress/demos/hover-card/placement.tsx

</Demo>

### size

`size` sets the type scale, the inset and how wide the card is allowed to get. `width` overrides the last of those on its own.

<Demo src="hover-card/sizes">

<<< @/.vitepress/demos/hover-card/sizes.tsx

</Demo>

## Accessibility

- Whatever is in the card must also exist on the page the trigger leads to. A keyboard with no hover, a touchscreen with no pointer, and a screen reader all arrive by that route instead, so this can never be the only way to something.
- The card is reachable with the pointer, so a link inside it can be followed; it stays open while the pointer is in it.
- Escape closes it.
