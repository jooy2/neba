---
title: Badge
order: 6
---

# Badge

<p class="neba-lede">A small marker overlaid on the corner of another element. Use it to report an unread count or a current status without covering what it sits on.</p>

<Demo src="badge/hero" />

```tsx
import { Badge, Button } from 'neba';

<Badge content={4} label="4 unread notifications">
  <Button startIcon={<BellIcon />} />
</Badge>

<Badge dot color="success" overlap="circle">
  <Avatar />
</Badge>;
```

## Props

<PropsTable name="Badge" />

Given `children`, the wrapping `<span>` becomes the positioning context and the marker pins to its corner. Without `children` the marker lays out inline on its own, which is what a status marker in a table cell is.

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### variant and color

`solid` is a filled marker, `outline` a border over a faint panel, `text` a tinted mark with no edge. `color` picks one of the six role colours.

<Demo src="badge/variants">

<<< @/.vitepress/demos/badge/variants.tsx

</Demo>

### content and max

`content` is what the marker says. A number past `max` (default `99`) renders as `99+`; a string is never truncated.

A `content` of `0` draws nothing by default: turn it on with `showZero`. When there is nothing to count but something to report, use `dot`; `invisible` hides the marker while keeping the layout intact.

<Demo src="badge/content">

<<< @/.vitepress/demos/badge/content.tsx

</Demo>

### placement and overlap

`placement` is the corner the marker pins to: one of four values built from `top`/`bottom` and `start`/`end`. Because it uses `start`/`end`, the corner flips automatically in RTL.

`overlap` is the shape of the element underneath. `circle` tucks the marker further in, by the amount a circle's corner sits inside its bounding box, so the marker does not float off an avatar.

<Demo src="badge/placement">

<<< @/.vitepress/demos/badge/placement.tsx

</Demo>

### size

Badge has its own size steps rather than a step off the control heights. `md` is 18px, the smallest at which a two-digit number stays legible.

<Demo src="badge/sizes">

<<< @/.vitepress/demos/badge/sizes.tsx

</Demo>

## Accessibility

- `content={3}` on its own is just "3" to a screen reader. A sentence in `label` becomes the marker's accessible name instead.

```tsx
<Badge content={3} label="3 unread notifications">
  <Button startIcon={<BellIcon />} aria-label="Notifications" />
</Badge>
```

- Under `dot` the `content` stays in the DOM, clipped rather than removed, so what the dot means is still readable.
- When the badge is `invisible` or has nothing to show, it leaves the DOM entirely, so find-on-page does not turn up text that is not on screen.
