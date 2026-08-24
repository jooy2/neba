---
title: WindowPane
order: 14
---

# WindowPane

<p class="neba-lede">Anything at all, drawn the way one of four operating systems draws a window. The title bar drags, the corners resize and the three buttons are real buttons, so a screenshot, a demo or a piece of a landing page can be shown as the thing it will be rather than as a picture of it.</p>

<Demo src="window-pane/hero" minHeight="340" />

```tsx
import { WindowPane } from 'neba';

<WindowPane os="macos" title="Notes" width={520} height={320}>
  <Editor />
</WindowPane>;
```

It is not a real window: there is no desktop, no z-order and nothing outside the page. What it draws is the frame, and what it holds is yours.

## Props

<PropsTable name="WindowPane" />

Every other `<div>` attribute passes through to the root, except `title` — here it is the window's name and a `ReactNode` — and `onResize`, which reports pixels rather than a DOM event. The shared axes (`size` `color` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### os

`macos` puts three coloured dots on the left and centres the title over the whole window. `windows11` puts three rectangles on the right, above rounded corners. `windows10` is the same three over square corners, a shorter bar and a rule under it. `linux` is a GNOME header bar: taller, with circular buttons and a centred title.

The buttons carry no other party's marks — a minimize is a line, a maximize is a box, a close is a cross — and none of the chrome writes a word except the title you gave it.

<Demo src="window-pane/os" minHeight="420">

<<< @/.vitepress/demos/window-pane/os.tsx

</Demo>

### controls

`true` is all three buttons, `false` is none, and an array is exactly the ones named. The order is the system's rather than the array's, so `['close', 'minimize']` still puts close last on Windows.

Each one is a controlled/uncontrolled pair: `open`, `minimized` and `maximized`, each with a `default*` and an `on*Change`. Closing an uncontrolled window renders nothing; minimizing rolls it up to its title bar, because a page has no dock to send it to; maximizing fills whatever is holding the window, which is the nearest positioned ancestor with `position="absolute"` and the viewport with `fixed`. A double click on the title bar maximizes too.

<Demo src="window-pane/controls" minHeight="400">

<<< @/.vitepress/demos/window-pane/controls.tsx

</Demo>

### draggable and resizable

`draggable` moves the window on `left` and `top` — never a transform, so no glyph is resampled for the length of the drag — and reports where it went through `onOffsetChange`. `resizable` puts a handle on all four edges and all four corners; `minWidth` and `minHeight` bound them, and `onResize` fires with the pixel size as they move.

Both need somewhere to move: give the window `position="absolute"` and a positioned ancestor, or `position="fixed"`.

<Demo src="window-pane/interactive" minHeight="400">

<<< @/.vitepress/demos/window-pane/interactive.tsx

</Demo>

### accent, transparency, active

`accent` dyes the title bar with `color`, the way Windows offers to. `transparency` is how much of the page shows through the chrome, from `0` to `1`; it applies to the title bar, the body's own fill and the border, never to the content on them, and anything above `0` also turns the acrylic on so what is behind is blurred rather than merely visible. `active={false}` is the window that is not in front: it keeps its shape and loses its emphasis, never its opacity.

<Demo src="window-pane/appearance" minHeight="420">

<<< @/.vitepress/demos/window-pane/appearance.tsx

</Demo>

## Accessibility

- The root is a `role="group"` labelled by its own title, so a screen reader reads the window's name before its contents.
- The three title bar buttons are real `<button>`s with names from `locale`, and the maximize one renames itself to "Restore" while the window is maximized.
- One resize handle — the bottom-right corner — is reachable from the keyboard and resizes with the arrow keys. The other seven are pointer affordances and are hidden from the accessibility tree; a keyboard reader has the same range through `maximize`.
- Dragging is a pointer affordance as well. A window that must be movable without one should be given its `offset` by the caller.
