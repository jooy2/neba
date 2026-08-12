---
title: BottomNavigation
order: 22
---

# BottomNavigation

<p class="neba-lede">A bar of an app's main destinations, held against the bottom edge of the window. One glyph with a name under it is one destination, and the one the reader is on carries <code>aria-current</code>.</p>

<Demo src="bottom-navigation/hero" minHeight="200" />

```tsx
import { BottomNavigation, BottomNavigationItem } from 'neba';

<BottomNavigation label="Main" value={section} onValueChange={setSection}>
  <BottomNavigationItem value="home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
  <BottomNavigationItem value="search" icon={<SearchIcon />}>
    Search
  </BottomNavigationItem>
</BottomNavigation>;
```

## Props

<PropsTable name="BottomNavigation" />

<PropsTable name="BottomNavigationItem" />

Every other `<nav>` attribute passes through to the root and every other `<button>` attribute to each destination, except `onChange` — the change worth listening for is `onValueChange`.

The shared axes (`variant` `size` `color` `density` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### position

The default is `fixed`, against the `static` everything else in the library defaults to, and that is what this component is: it is held against the bottom edge of the window whatever the page does. The page then needs bottom padding of its own, or its last line sits behind the bar.

`sticky` keeps the bar in the flow but stops it at the bottom edge of the scrolling region. `static` is an ordinary sheet in the flow.

<Demo src="bottom-navigation/pinned" minHeight="280">

<<< @/.vitepress/demos/bottom-navigation/pinned.tsx

</Demo>

### labels

`all` draws every name. `selected` draws only the current one, and `none` draws none of them.

An undrawn name is still in the document. A button whose whole label is a glyph has no accessible name at all, so what goes is the pixels and nothing else.

<Demo src="bottom-navigation/labels" minHeight="320">

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

</Demo>

### href

A destination with an `href` is a real `<a>`. That is what makes a long press offer "open in a new tab" and what puts the address in the status bar, neither of which a `<button>` calling a router can do.

<Demo src="bottom-navigation/links" minHeight="120">

<<< @/.vitepress/demos/bottom-navigation/links.tsx

</Demo>

### variant, divider, safeArea

`variant` says what it says on every other container — the sheet is never dyed, and what carries the colour family is the one destination that is current. `divider` is the hairline along the top edge, facing the content, and it is on by default. `safeArea` adds `env(safe-area-inset-bottom)` under the row to clear a phone's home indicator, while the sheet itself still reaches the bottom of the screen.

<Demo src="bottom-navigation/appearance" minHeight="360">

<<< @/.vitepress/demos/bottom-navigation/appearance.tsx

</Demo>

### Controlling it

Pass `value` and the bar keeps no state of its own, which is the shape to use when the router already knows where the reader is.

```tsx
<BottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
</BottomNavigation>
```

## Accessibility

- The root is a `<nav>` and `label` names it. It is not a `role="tablist"`: a tab list promises one tab stop for the set and arrow keys within it, and a bottom navigation changes the page rather than which panel of one is showing.
- The current destination carries `aria-current="page"`.
- Each destination is a real `<button>`, or a real `<a>` when it is given an `href`.
- A name that `labels` keeps undrawn stays in the document, where it is the destination's accessible name.
- With `position="fixed"`, pad the bottom of the page by the bar's height, or its last line is covered.
