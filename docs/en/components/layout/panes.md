---
title: Panes
order: 7
---

# Panes

<p class="neba-lede">Divides a box into regions with a draggable bar between each pair. Use it for an editor beside a file list, a preview beside a form, or any split whose proportions the reader decides.</p>

<Demo src="panes/hero" />

```tsx
import { Pane, Panes } from 'neba';

<Panes>
  <Pane defaultSize="240px" minSize="160px">
    Files
  </Pane>
  <Pane>Editor</Pane>
</Panes>;
```

`Panes` fills the box it is in, so give that box a height.

## Props

### Panes

<PropsTable name="Panes" />

Every other `<div>` attribute passes through. The direct children have to be `Pane`s: the constraints are read off their props. The shared axes are in [prop conventions](../../design/prop-conventions).

### Pane

<PropsTable name="Pane" />

Every other `<div>` attribute passes through.

## Examples

### orientation

`horizontal` lays the panes out side by side with upright bars between them; `vertical` stacks them with bars across. A bar always runs across the axis the panes run along.

<Demo src="panes/orientation">

<<< @/.vitepress/demos/panes/orientation.tsx

</Demo>

### defaultSize, minSize and maxSize

All three take a number, read as a percentage, or a CSS length: `'240px'`, `'15rem'`, `'20%'`. Panes with no `defaultSize` split whatever is left over equally. A pane's `minSize` is also its neighbour's ceiling, so a drag stops at whichever bound it reaches first.

`onResize` reports every pane's share in percent while the bar moves; `onResizeEnd` fires once when it is let go.

<Demo src="panes/sizing">

<<< @/.vitepress/demos/panes/sizing.tsx

</Demo>

### Nesting

A `Panes` inside a `Pane` is a split inside a split, which is how a three-region layout is built. Give the inner one the other `orientation`.

```tsx
<Panes>
  <Pane defaultSize="240px">Files</Pane>
  <Pane>
    <Panes orientation="vertical">
      <Pane defaultSize={70}>Editor</Pane>
      <Pane>Terminal</Pane>
    </Panes>
  </Pane>
</Panes>
```

### resizable

`resizable={false}` leaves the bar as a rule between the panes: it is still drawn, but it cannot be dragged and it is out of the tab order.

<Demo src="panes/fixed">

<<< @/.vitepress/demos/panes/fixed.tsx

</Demo>

## Accessibility

- Each bar is a `separator` with `aria-valuenow` carrying the share, in percent, of the pane in front of it.
- A bar takes focus. ArrowLeft and ArrowRight move a upright bar; ArrowUp and ArrowDown move one that lies across.
- `aria-orientation` describes the bar, not the panes: an upright bar between panes that run across is `vertical`.
- A drag under RTL moves the boundary the way the pointer went.
