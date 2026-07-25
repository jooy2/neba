---
title: Tooltip
order: 4
---

# Tooltip

<p class="neba-lede">A short label that appears when the pointer rests on something.</p>

<Demo src="tooltip/hero" align="center" />

```tsx
import { Button, Tooltip } from 'neba';

<Tooltip content="Copy the deploy URL">
  <Button variant="outline" startIcon={<LinkIcon />} />
</Tooltip>;
```

## Props

<PropsTable name="Tooltip" />

## Examples

### Sides

The side may flip when there is no room, which is Base UI's doing and is the right behaviour — a tooltip clipped by the window edge is worse than one on the other side.

<Demo src="tooltip/sides">

<<< @/.vitepress/demos/tooltip/sides.tsx

</Demo>

### One delay for a whole toolbar

`TooltipProvider` shares the delay across a group: once any of them has opened, its neighbours open instantly, and the wait comes back after a pause. Without it, moving along a row of icon buttons means waiting out the full delay at every stop — which is what makes tooltips feel like they are fighting the pointer.

<Demo src="tooltip/grouped">

<<< @/.vitepress/demos/tooltip/grouped.tsx

</Demo>

## It wraps, it does not add

Base UI's trigger merges itself onto the child rather than rendering a box of its own, so the tooltip costs the layout nothing and the child stays whatever it was — a button, a chip, a truncated table cell. The child has to be a single element that accepts a ref and spreads props, which every Neba component does.

## Keep it short

A tooltip is not a container. It cannot be reached by a pointer on a touch screen, it disappears the moment attention moves, and anything inside it that could be clicked cannot be. Content that needs either of those is a popover's job.

That is also why the plate is filled rather than frosted. Everything else that floats in this library is translucent acrylic; a tooltip is read in the half-second it is up, over whatever happens to be behind it, and a translucent sheet is the one surface that cannot promise contrast.

## Accessibility

Base UI handles the delay and the group timeout, opening on keyboard focus but not on a focus that came from a click, closing on Escape, and keeping the plate off the edges of the window.

The part it deliberately leaves open — a popup can be many things and only the caller knows which — is wired here: the plate carries `role="tooltip"`, and the trigger gets an `aria-describedby` pointing at it while it is open, and nothing while it is closed.

A tooltip is a _description_, never a name. If a control needs a name, give it one: an icon-only button wants `aria-label`, and the tooltip beside it is the extra sentence, not the label.
