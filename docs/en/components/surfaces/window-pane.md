---
title: WindowPane
order: 14
---

# WindowPane

<p class="neba-lede">Anything at all, drawn the way one of eight operating systems draws a window. The title bar drags, the corners resize and the three buttons are real buttons, so a screenshot, a demo or a piece of a landing page can be shown as the thing it will be rather than as a picture of it.</p>

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

Every other `<div>` attribute passes through to the root, except `title` (here it is the window's name and a `ReactNode`), and `onResize`, which reports pixels rather than a DOM event. The shared axes (`size` `color` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### os

`os` takes eight systems, and a version is its own entry wherever the title bar is what changed.

| `os` | What it draws |
| --- | --- |
| `macos` | Three coloured dots on the left, the title centred over the whole window, one flat sheet |
| `macosx` | Aqua: a short striped bar, glossy lights, a bold embossed title, square bottom corners |
| `windows11` | Three rectangles hard against a rounded top-right corner, bar and body one Mica sheet |
| `windows10` | The same three over square corners, a shorter bar, and a rule under it |
| `windows8` | Flat and square, no rule, and a band of colour around the whole window |
| `windows7` | Aero: a sheet of glass with the content sunk into it, the page blurred through the band as well as the caption, a glowing title and a wider close |
| `windowsxp` | Luna: the glossy blue caption curve, a band of the same blue down the sides and along the bottom, coloured button plates |
| `linux` | A GNOME header bar: taller, with circular buttons and a centred title |

The older systems paint their own chrome rather than the page's, so Luna stays blue and Aqua stays grey on a page switched to dark.

XP and Aero are the two with a **band** rather than a hairline, so the content is sunk into the system's own material down both sides and along the bottom. `accent` dyes the band with the caption, so a window in your own colour is framed in it too.

A minimize button is drawn as a line, a maximize button as a box and a close button as a cross, and the chrome writes no text except `title`.

<Demo src="window-pane/os" minHeight="760">

<<< @/.vitepress/demos/window-pane/os.tsx

</Demo>

### controls

`true` is all three buttons, `false` is none, and an array is exactly the ones named. The order is the system's rather than the array's, so `['close', 'minimize']` still puts close last on Windows.

Each one is a controlled/uncontrolled pair: `open`, `minimized` and `maximized`, each with a `default*` and an `on*Change`. Closing an uncontrolled window renders nothing, and minimizing rolls it up to its title bar. Maximizing fills whatever is holding the window, which is the nearest positioned ancestor with `position="absolute"` and the viewport with `fixed`. A double click on the title bar maximizes too.

<Demo src="window-pane/controls" minHeight="400">

<<< @/.vitepress/demos/window-pane/controls.tsx

</Demo>

### draggable and resizable

`draggable` lets the title bar move the window, and `onOffsetChange` reports where it went. `resizable` puts a handle on all four edges and all four corners; `minWidth` and `minHeight` bound them, and `onResize` fires with the pixel size as they move.

Both work in the flow, where the offset moves the window from the place the layout gave it. To move it against a box of your own, give it `position="absolute"` and a positioned ancestor, or `position="fixed"` for the viewport. A fixed or absolute window is held so that its title bar stays inside that box, and a `width` or `height` passed after a resize replaces the size the resize gave it.

<Demo src="window-pane/interactive" minHeight="400">

<<< @/.vitepress/demos/window-pane/interactive.tsx

</Demo>

### Which window is in front

Left out, `active` looks after itself. A window is in front until another WindowPane on the page is pressed or takes the focus, and a press on the page around the windows changes nothing.

Being in front is drawn the way each system draws it, such as coloured traffic lights against grey ones on macOS, an accent title bar and border on Windows 10, and a tinted header bar on GNOME. On every system the window in front also has one step more shadow than the windows behind it. Pass `active` to drive this yourself when you keep your own z-order.

### accent, transparency, active

`accent` dyes the title bar with `color`, and on `windows10` it dyes the window's border too. `transparency` is how much of the page shows through the chrome, from `0` to `1`. It applies to the title bar, the body's own fill and the border and never to the content on them, and anything above `0` also blurs what is behind the window. `active={false}` pins the window behind whatever else is on the page.

<Demo src="window-pane/appearance" minHeight="420">

<<< @/.vitepress/demos/window-pane/appearance.tsx

</Demo>

## Accessibility

- The root is a `role="group"` labelled by its own title, so a screen reader reads the window's name before its contents.
- The three title bar buttons are real `<button>`s with names from `locale`, and the maximize one renames itself to "Restore" while the window is maximized. On macOS the glyph inside each dot shows under the pointer, while one of them has the keyboard focus, and always on a screen that cannot hover, so the three are never told apart by colour alone.
- One resize handle (the bottom-right corner) is reachable from the keyboard and resizes with the arrow keys, which its description says. The other seven are pointer affordances and are hidden from the accessibility tree; a keyboard reader has the same range through `maximize`.
- Dragging is a pointer affordance as well. A window that must be movable without one should be given its `offset` by the caller.
- A minimized window keeps its body in the document, `inert` and clipped, so its content is out of the tab order and the accessibility tree.
- Maximizing, restoring and minimizing animate the window's position and size, and a closed window fades out while it is already `inert`. All of them are instant for a reader who has asked for reduced motion.
