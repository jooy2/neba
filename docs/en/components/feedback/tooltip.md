---
title: Tooltip
order: 4
---

# Tooltip

<p class="neba-lede">A short label that appears when the pointer rests on something. Use it to supplement a control that shows only an icon.</p>

<Demo src="tooltip/hero" align="center" />

```tsx
import { Button, Tooltip } from 'neba';

<Tooltip content="Copy the deploy URL">
  <Button variant="outline" startIcon={<LinkIcon />} />
</Tooltip>;
```

## Props

<PropsTable name="Tooltip" />

Native `<div>` attributes pass through to the popup. Only `color`, `content` and `children` are excluded, since the table above spells them differently.

The trigger merges onto `children` rather than rendering a box of its own, so the tooltip costs the layout nothing. `children` must be a single element that accepts a ref and spreads props — every Neba component does.

## Examples

### side and align

`side` is where the popup sits relative to the trigger; `align` is its alignment along that axis. The side flips automatically when there is no room at the window edge. `sideOffset` sets the gap and `arrow` draws a pointer.

<Demo src="tooltip/sides">

<<< @/.vitepress/demos/tooltip/sides.tsx

</Demo>

### delay and TooltipProvider

`delay` is how long the pointer must rest before opening; `closeDelay` is how long the tooltip stays after it leaves.

Wrapping tooltips in a `TooltipProvider` makes them share the delay: once one has opened, its neighbours open instantly, and the delay comes back after a pause. That way a row of icon buttons does not make you wait at every stop.

<Demo src="tooltip/grouped">

<<< @/.vitepress/demos/tooltip/grouped.tsx

</Demo>

## Accessibility

- The popup carries `role="tooltip"`, and the trigger gets `aria-describedby` pointing at it only while it is open.
- A tooltip is a **description**, never a name. Give an icon-only button its own `aria-label`.
- It opens on keyboard focus but not on focus that arrived from a click, and closes on Escape.
- On a touch screen it cannot be reached by pointer, and anything clickable inside it cannot be clicked. Use a popover if you need either.
