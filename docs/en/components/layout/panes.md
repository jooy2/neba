---
title: Panes
order: 7
flutter: true
---

# Panes

<p class="neba-lede">Divides a box into regions with a draggable bar between each pair. Use it for an editor beside a file list, a preview beside a form, or any split whose proportions the reader decides.</p>

<Demo src="panes/hero" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPanes(
  children: <NebaPane>[
    NebaPane(
      defaultSize: const NebaPaneSize.pixels(240),
      minSize: const NebaPaneSize.pixels(160),
      child: files,
    ),
    NebaPane(child: editor),
  ],
);
```

`NebaPanes` fills the space it is given, so it needs a bounded width and a bounded height: put it in a `SizedBox` with a height, an `Expanded`, or a pane of another split.

:::

## Props

### Panes

<PropsTable name="Panes" />

::: fw react

Every other `<div>` attribute passes through. The direct children have to be `Pane`s: the constraints are read off their props. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

`children` is a `List<NebaPane>`, so the type makes sure every direct child is a pane. `handleLabel` names every bar and `handleLabelBuilder` names each one, which React does with one prop that takes a string or a function. There is no `className` or `style`. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

### Pane

<PropsTable name="Pane" />

::: fw react

Every other `<div>` attribute passes through.

:::

::: fw flutter

A pane lays its `child` out at its own size and clips what runs past it, where a React pane scrolls. Put content that may be longer than the pane in a [ScrollArea](./scroll-area).

:::

## Examples

### orientation

`horizontal` lays the panes out side by side with upright bars between them; `vertical` stacks them with bars across. A bar always runs across the axis the panes run along.

<Demo src="panes/orientation">

::: fw react

<<< @/.vitepress/demos/panes/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/orientation.dart

:::

</Demo>

### defaultSize, minSize and maxSize

::: fw react

All three take a number, read as a percentage, or a CSS length: `'240px'`, `'15rem'`, `'20%'`. Panes with no `defaultSize` split whatever is left over equally. A pane's `minSize` is also its neighbour's ceiling, so a drag stops at whichever bound it reaches first. The default sizes are written into the first render, so a split rendered on the server is drawn at them before any script runs.

:::

::: fw flutter

All three take a `NebaPaneSize`: `NebaPaneSize.percent(20)` for a percentage, or `NebaPaneSize.pixels(240)` for a length in logical pixels. Panes with no `defaultSize` split whatever is left over equally. A pane's `minSize` is also its neighbour's ceiling, so a drag stops at whichever bound it reaches first. A length is turned into a share when the split is first laid out, so the first frame already draws the default sizes.

:::

`onResize` reports every pane's share in percent while the bar moves; `onResizeEnd` fires once when it is let go.

<Demo src="panes/sizing">

::: fw react

<<< @/.vitepress/demos/panes/sizing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/sizing.dart

:::

</Demo>

### Nesting

A <Fw react="Panes" flutter="NebaPanes" code /> inside a <Fw react="Pane" flutter="NebaPane" code /> is a split inside a split, which is how a three-region layout is built. Give the inner one the other `orientation`.

::: fw react

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

:::

::: fw flutter

```dart
NebaPanes(
  children: <NebaPane>[
    NebaPane(defaultSize: const NebaPaneSize.pixels(240), child: files),
    NebaPane(
      child: NebaPanes(
        orientation: NebaOrientation.vertical,
        children: <NebaPane>[
          NebaPane(defaultSize: const NebaPaneSize.percent(70), child: editor),
          NebaPane(child: terminal),
        ],
      ),
    ),
  ],
);
```

:::

### resizable

<Fw react="resizable={false}" flutter="resizable: false" code /> leaves the bar as a rule between the panes: it is still drawn, but it cannot be dragged and it is out of the tab order.

<Demo src="panes/fixed">

::: fw react

<<< @/.vitepress/demos/panes/fixed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/fixed.dart

:::

</Demo>

## Accessibility

::: fw react

- Each bar is a `separator` with `aria-valuenow` carrying the share, in percent, of the pane in front of it. It is named "Resize panes" in the `locale`, or by `handleLabel`, and its `aria-controls` names the two panes on either side.

:::

::: fw flutter

- Each bar is a slider to a screen reader, whose value is the share, in percent, of the pane in front of it; increasing or decreasing it moves the bar as far as one arrow key. It is named "Resize panes" in the `locale`, or by `handleLabel` or `handleLabelBuilder`.
- A press or a drag on a bar leaves the focus where it was, so a field in one of the panes keeps it.

:::

- A bar takes focus. ArrowLeft and ArrowRight move an upright bar the way the arrow points, under RTL too; ArrowUp and ArrowDown move one that lies across.

::: fw react

- `aria-orientation` describes the bar, not the panes: an upright bar between panes that run across is `vertical`.

:::

- A drag under RTL moves the boundary the way the pointer went.
