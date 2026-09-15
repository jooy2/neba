---
title: HoverCard
order: 16
---

# HoverCard

<p class="neba-lede">A card that opens when the pointer rests on something and holds a preview of what is on the other side of it: a person behind a mention, a repository behind a link, a deploy behind an id.</p>

<Demo src="hover-card/hero" />

```tsx
import { HoverCard, TextLink } from 'neba';

<HoverCard trigger={<TextLink href="/people/nadiarowan">@nadiarowan</TextLink>} title="Nadia Rowan">
  Maintainer · 214 commits
</HoverCard>;
```

## Props

<PropsTable name="HoverCard" />

Every native `<div>` attribute passes through to the popup, apart from `color`, `title` and `children`, which the component owns. There is no `variant` and no `elevation`.

## Examples

### trigger

`trigger` takes one element rather than children, and the card merges onto it without a wrapper, so the layout is unchanged and a link stays a link. It is usually a [TextLink](../display/text-link) or an [Avatar](../display/avatar).

### delay · closeDelay

`delay` is how long the pointer has to rest before the card opens, and `closeDelay` is how long the card stays after the pointer leaves. `closeDelay` is what lets the pointer cross the gap between the trigger and the card.

<Demo src="hover-card/delay">

<<< @/.vitepress/demos/hover-card/delay.tsx

</Demo>

### side · align · arrow

`side` is the edge of the trigger the card appears on, flipping when there is no room; `align` is where it sits along that edge. `arrow` draws the wedge and is off by default.

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
