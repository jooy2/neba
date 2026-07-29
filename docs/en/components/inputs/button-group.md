---
title: ButtonGroup
order: 2
---

# ButtonGroup

<p class="neba-lede">Joins several Buttons into one set. The corners that face a neighbour are squared off, and shared props are set once on the group.</p>

<Demo src="button-group/hero" />

```tsx
import { Button, ButtonGroup } from 'neba';

<ButtonGroup variant="outline">
  <Button>Day</Button>
  <Button>Week</Button>
  <Button>Month</Button>
</ButtonGroup>;
```

## Props

<PropsTable name="ButtonGroup" />

Every native `<div>` attribute passes straight through, minus `color`.

## Examples

### Shared props

`variant` · `size` · `color` · `density` · `elevation` · `disabled` set on the group reach every child [Button](./button). A value set on a button overrides the group's, so one `danger` button can sit in a row of secondary actions.

<Demo src="button-group/shared">

<<< @/.vitepress/demos/button-group/shared.tsx

</Demo>

### orientation

`vertical` stacks the buttons and squares off the top and bottom corners instead.

<Demo src="button-group/orientation">

<<< @/.vitepress/demos/button-group/orientation.tsx

</Demo>

### fullWidth

Stretches the group to the container width, with the buttons sharing the space equally.

<Demo src="button-group/full-width">

<<< @/.vitepress/demos/button-group/full-width.tsx

</Demo>

## Accessibility

- Renders `role="group"`. Give it an `aria-label` when the button labels alone do not say what the set is for.
- It does not manage selection. For one-of-a-set, use [SegmentedButton](./segmented-button) or [RadioGroup](./radio-group).
- The hovered or focused button is raised above its neighbours so its focus ring is never clipped.
