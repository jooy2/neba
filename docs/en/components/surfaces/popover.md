---
title: Popover
order: 11
---

# Popover

<p class="neba-lede">A sheet that opens beside the control that opened it. Unlike a tooltip it stays up and can be reached, so what is inside can be clicked and typed into.</p>

<Demo src="popover/hero" align="center" minHeight="80" />

```tsx
import { Button, Popover } from 'neba';

<Popover trigger={<Button variant="outline">Share</Button>} title="Share this page">
  <TextField size="sm" label="Link" defaultValue="https://…" readOnly />
</Popover>;
```

## Props

<PropsTable name="Popover" />

Native `<div>` attributes pass through to the popup. Only `color`, `title` and `children` are excluded, since the table above spells them differently.

`PopoverClose` is Base UI's `Popover.Close`, re-exported. Give it a `render` prop and any element dismisses the popup it is inside: `<PopoverClose render={<Button>Apply</Button>} />`.

The shared axes are described in [prop conventions](../../design/prop-conventions).

## Examples

### side and align

`side` is which edge of the trigger the popup sits on; `align` is where it sits along that edge. The side flips automatically when the window has no room. `sideOffset` sets the gap and `alignOffset` shifts it along the edge.

<Demo src="popover/sides">

<<< @/.vitepress/demos/popover/sides.tsx

</Demo>

### A form in a popup

The popup holds focusable content, so a filter panel, a small form or a colour picker all belong here rather than in a [Dialog](../feedback/dialog) — the page behind stays readable while the form is filled in. `width` caps the popup when its content should decide the measure.

<Demo src="popover/form">

<<< @/.vitepress/demos/popover/form.tsx

</Demo>

### Controlled

Pass `open` with `onOpenChange` and the caller owns the state, so anything else on the page can open or close it. Without them the popover manages itself and `defaultOpen` sets the starting state.

<Demo src="popover/controlled">

<<< @/.vitepress/demos/popover/controlled.tsx

</Demo>

### arrow

`arrow` draws a wedge pointing at the trigger. It is off by default: this surface is translucent over a blurred backdrop, and a wedge sticking out past the popup's own box cannot carry that backdrop with it. Turn it on where the trigger is far enough away that the popup has to say what it belongs to.

```tsx
<Popover arrow trigger={<Button>Details</Button>}>
  Anchored to the button it came from.
</Popover>
```

## Accessibility

- The popup carries `role="dialog"`. `title` names it and `description` describes it, wired with `aria-labelledby` and `aria-describedby`; a popover with neither needs an `aria-label` of its own.
- Focus moves into the popup when it opens and returns to the trigger when it closes.
- Escape closes it, and so does a click outside. `dismissible={false}` cancels both — a `PopoverClose` still gets through, so it is never a trap.
- `modal` is `false` by default, so the page behind stays scrollable and usable. Use `'trap-focus'` for a popup that must be answered before anything else is touched.
- `locale` decides the ×'s accessible name; `closeLabel` writes it out instead.
