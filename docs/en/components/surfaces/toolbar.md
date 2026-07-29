---
title: Toolbar
order: 7
---

# Toolbar

<p class="neba-lede">Lays controls out in a bar. Use it for an application header, a page's action row, or the status strip under an editor.</p>

<Demo src="toolbar/hero" />

```tsx
import { Toolbar } from 'neba';

<Toolbar render={<header />} start={<Logo />} end={<Button>Deploy</Button>}>
  Workspace
</Toolbar>;
```

## Props

<PropsTable name="Toolbar" />

Every native `<div>` attribute passes through.

There are three slots: `start` and `end` are pinned to their ends and `children` takes what is left, so no spacer element is needed to push things apart.

## Examples

### size and density

A Toolbar has no height of its own. It is as tall as the controls in it plus its padding, and `size` and `density` set that padding. `density="compact"` gives a dense bar without moving the type scale.

<Demo src="toolbar/density">

<<< @/.vitepress/demos/toolbar/density.tsx

</Demo>

### position and side

`position` is CSS's own three values, spelled the way CSS spells them.

- `sticky` — what an application header usually wants. It takes up its own space, so nothing underneath needs padding around it.
- `fixed` — leaves the flow, so the page needs padding of its own or the first screenful sits behind the bar.

`side` is the edge the bar pins to. A pinned bar drops its radius, because a rounded corner against the edge of the screen is a gap with nothing behind it.

<Demo src="toolbar/sticky">

<<< @/.vitepress/demos/toolbar/sticky.tsx

</Demo>

### divider and elevation

`divider` rules under the bar to show there is content beneath. `elevation` stays `0` even when the bar is pinned, so either raise it yourself on scroll or leave it flat and turn on `divider`.

### color

`color` reaches the rule and the focus ring. A bar that holds other people's controls does not fill its own sheet.

## Accessibility

- It does not set `role="toolbar"`. That role promises one tab stop for the bar with arrow keys inside it, and claiming it without implementing it is worse for a keyboard user than not claiming it.
- For a page header, pass `render={<header />}`: a real landmark, which is what a screen reader user navigates by.
- For a group of controls navigated with the arrow keys, use [ButtonGroup](../inputs/button-group).
