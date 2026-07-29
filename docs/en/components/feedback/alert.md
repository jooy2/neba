---
title: Alert
order: 1
---

# Alert

<p class="neba-lede">A message about something that just happened, set into the page. Use it for notices that stay on screen — a save confirmation, a validation error, a setting that needs attention.</p>

<Demo src="alert/hero" />

```tsx
import { Alert } from 'neba';

<Alert color="success">Your changes have been saved.</Alert>
<Alert color="danger" title="Deploy failed" onClose={dismiss}>
  The build exited with code 1.
</Alert>;
```

## Props

<PropsTable name="Alert" />

`color` defaults to `info` rather than `primary`.

## Examples

### title and children

`children` alone is a one-line notice; adding `title` gives you a headline with the detail under it. It is the same component with a different number of slots filled.

<Demo src="alert/shapes">

<<< @/.vitepress/demos/alert/shapes.tsx

</Demo>

### variant

An alert is the thing being coloured, so unlike a [Box](../surfaces/box) its sheet takes the tint. Use `text` inside a form, where a second bordered rectangle among the fields is one too many.

<Demo src="alert/variants">

<<< @/.vitepress/demos/alert/variants.tsx

</Demo>

### color

`color` sets the severity, and the glyph changes with it. Three drawings cover the six families, so the kind of message carries even where the colour does not.

<Demo src="alert/colors">

<<< @/.vitepress/demos/alert/colors.tsx

</Demo>

### icon

Pass a node to replace the default glyph, or `icon={false}` to draw none.

### action and onClose

`action` is a slot outside `children`, so it stays on the first line while the message wraps beside it. Passing `onClose` is what makes the × appear.

<Demo src="alert/dismissing">

<<< @/.vitepress/demos/alert/dismissing.tsx

</Demo>

## Accessibility

- The severity picks the live region: `warning` and `danger` get `role="alert"`, which interrupts what a screen reader is saying, and the rest get `role="status"`, which waits for a pause.
- Passing `role` yourself overrides the default.
- With several alerts on screen, use `closeLabel` to name what is being dismissed.
