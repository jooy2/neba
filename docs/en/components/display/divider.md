---
title: Divider
order: 2
---

# Divider

<p class="neba-lede">A thin rule that separates content. It can carry a label to name the section it opens.</p>

<Demo src="divider/hero" />

```tsx
import { Divider } from 'neba';

<Divider />
<Divider>OR</Divider>
<Divider orientation="vertical" />;
```

## Props

<PropsTable name="Divider" />

There is no `variant` and no `elevation`. The rule is drawn as a single border edge, so it takes no layout beyond its own thickness.

## Examples

### textAlign

A label in `children` splits the rule around it. `center` halves the line; `start` and `end` leave a short stub on the near side, so the label reads as set into the rule rather than floating above it.

<Demo src="divider/labels">

<<< @/.vitepress/demos/divider/labels.tsx

</Demo>

### orientation

`vertical` has no height of its own and stretches to its flex parent — the shape to use between control groups in a toolbar. A vertical label turns with the rule.

<Demo src="divider/vertical">

<<< @/.vitepress/demos/divider/vertical.tsx

</Demo>

### color

`color` applies to the rule only, and faintly.

<Demo src="divider/colors">

<<< @/.vitepress/demos/divider/colors.tsx

</Demo>

## Accessibility

- Renders with `role="separator"`.
- `separator` does not take its accessible name from content, so a **string** label is also passed through as `aria-label`. A node is left alone, since only the caller knows which part of it is the name — set `aria-label` yourself if you need one.
