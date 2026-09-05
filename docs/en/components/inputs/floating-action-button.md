---
title: FloatingActionButton
order: 23
---

# FloatingActionButton

<p class="neba-lede">The one action a screen is about, as a round button floating over it: a FAB. Give it FloatingActions as children and it becomes a small set that fans out when it is pressed.</p>

<Demo src="floating-action-button/hero" minHeight="220" />

```tsx
import { FloatingActionButton } from 'neba';

<FloatingActionButton icon={<PencilIcon />} label="Compose" onClick={compose} />;
```

## Props

<PropsTable name="FloatingActionButton" />

<PropsTable name="FloatingAction" />

Every other `<div>` attribute passes through to the root and every other `<button>` attribute to each action. `onClick` belongs to the button itself.

The shared axes (`variant` `size` `color` `density` `elevation` `corner`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### Fanning out actions

Give it `FloatingAction` children and the button becomes a dial: pressing it (or resting a mouse on it) fans the actions out and swaps the glyph for a ×. Each action's name is drawn on a lozenge beside it.

`closeOnAction` decides whether the dial goes away once an action is pressed, `showLabels` whether the names are drawn, and `openOnHover` whether a resting mouse opens it.

<Demo src="floating-action-button/dial" minHeight="300">

<<< @/.vitepress/demos/floating-action-button/dial.tsx

</Demo>

### extended

`extended` writes `label` beside the glyph, which turns the disc into a stadium: the shape to use when a drawing alone does not say what the screen is for. `label` is the accessible name either way, so the word that is drawn and the word that is read can never differ.

<Demo src="floating-action-button/extended" minHeight="120">

<<< @/.vitepress/demos/floating-action-button/extended.tsx

</Demo>

### position, corner, offset

`position` defaults to `fixed`, which pins the button to a corner of the window. `absolute` pins it to a corner of the nearest positioned ancestor (a card, a map, the screen of a Mockup), and `static` puts it back in the flow.

`corner` picks one of the four corners and `offset` is the distance from both edges. Which way the actions fan out follows from `corner`, and `direction` overrides it.

<Demo src="floating-action-button/corners" minHeight="340">

<<< @/.vitepress/demos/floating-action-button/corners.tsx

</Demo>

### variant, size, color

The button itself is a [Button](./button), unchanged: the variants, the elevation ladder, the pointer light and the press behaviour are all the ones every other control has. Only `size` starts a step higher, at `lg`, because this is the one control that has to be found and hit with a thumb without being looked at. The actions are drawn a step back down.

<Demo src="floating-action-button/appearance" minHeight="260">

<<< @/.vitepress/demos/floating-action-button/appearance.tsx

</Demo>

### Controlling it

Pass `open` and the dial keeps no state of its own.

```tsx
const [open, setOpen] = useState(false);

<FloatingActionButton label="Share" open={open} onOpenChange={setOpen}>
  <FloatingAction icon={<LinkIcon />} label="Copy link" />
</FloatingActionButton>;
```

## Accessibility

- `label` is required. A button whose whole label is a drawing has no accessible name at all.
- With actions, the button carries `aria-expanded` and an `aria-controls` pointing at the set it revealed. It is not a `role="menu"`: a menu promises one tab stop for the set, arrow keys within it and typeahead, and what wants those is [Menu](./menu).
- The actions are ordinary buttons in the tab order right after the one that revealed them.
- Escape closes the dial and hands the focus back to the button. A press outside closes it too.
- The lozenge beside an action is `aria-hidden`, because the same string is already the button's accessible name and would otherwise be announced twice.
