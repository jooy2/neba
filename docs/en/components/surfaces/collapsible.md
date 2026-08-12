---
title: Collapsible
order: 13
---

# Collapsible

<p class="neba-lede">One section that folds, standing on its own. Pressing the header opens what is under it and pressing it again closes it. A set of these, of which only one is open, is an Accordion.</p>

<Demo src="collapsible/hero" />

```tsx
import { Collapsible } from 'neba';

<Collapsible title="Shipping and returns">
  <p>Orders placed before 2pm ship the same day.</p>
</Collapsible>;
```

## Props

<PropsTable name="Collapsible" />

Every other `<div>` attribute passes through to the root, except `onChange` — the change worth listening for is `onOpenChange`.

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### title, subtitle, startIcon, action

`title` is the heading on the header and `subtitle` is the line under it. `startIcon` goes before the title; `action` goes at the end of the header but outside the trigger — a header that both folds and holds a switch has two things to press, and one of them cannot be nested inside the other.

`indicator={false}` drops the chevron, which leaves the header reporting its state in colour alone.

<Demo src="collapsible/slots">

<<< @/.vitepress/demos/collapsible/slots.tsx

</Demo>

### trigger

`trigger` replaces the header entirely with a control of your own. The element you pass becomes the trigger: it is handed the click handler, `aria-expanded` and the `aria-controls` pointing at the panel, so there is nothing to wire up.

<Demo src="collapsible/trigger">

<<< @/.vitepress/demos/collapsible/trigger.tsx

</Demo>

### variant

The three weights say what they say on every other container. `text` draws no sheet at all, which is what a fold inside running prose — or inside a Card, which is already a sheet — usually wants.

<Demo src="collapsible/variants">

<<< @/.vitepress/demos/collapsible/variants.tsx

</Demo>

### keepMounted, hiddenUntilFound

A closed panel leaves the DOM by default. `keepMounted` keeps it there, so content that is expensive to build or that holds form state survives being folded away. `hiddenUntilFound` keeps it there as `hidden="until-found"`, which lets the browser's own page search find and open it, and overrides `keepMounted`.

<Demo src="collapsible/mounting">

<<< @/.vitepress/demos/collapsible/mounting.tsx

</Demo>

### Controlling it

Pass `open` and the Collapsible keeps no state of its own. Use it to open and close several at once, to put the open state in the URL, or to drive it from a control elsewhere on the page.

```tsx
const [open, setOpen] = useState(false);

<Collapsible title="Advanced" open={open} onOpenChange={setOpen}>
  <p>Everything else goes here.</p>
</Collapsible>;
```

## Accessibility

- The trigger is a real `<button>`, carrying `aria-expanded` and an `aria-controls` pointing at the panel it opens.
- `action` sits outside the trigger, so it is reachable and pressable on its own from a keyboard.
- A closed panel leaves the DOM, so it is in neither the tab order nor the accessibility tree. `keepMounted` does not change that.
- With `hiddenUntilFound`, the browser's own page search can find closed content and open the panel around it.
