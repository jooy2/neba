---
title: FloatingBottomNavigation
order: 24
---

# FloatingBottomNavigation

<p class="neba-lede">A bar of an app's main destinations, floating clear of the bottom edge rather than attached to it. It is only as wide as its destinations, it is cut as a stadium, and the page keeps going underneath it.</p>

<Demo src="floating-bottom-navigation/hero" minHeight="320" />

```tsx
import { BottomNavigationItem, FloatingBottomNavigation } from 'neba';

<FloatingBottomNavigation label="Main" value={section} onValueChange={setSection}>
  <BottomNavigationItem value="home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
  <BottomNavigationItem value="search" icon={<SearchIcon />}>
    Search
  </BottomNavigationItem>
</FloatingBottomNavigation>;
```

## Props

<PropsTable name="FloatingBottomNavigation" />

Every other `<nav>` attribute passes through to the root, except `onChange`: the change worth listening for is `onValueChange`. The shared axes (`variant` `size` `color` `density` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

Its destinations are `BottomNavigationItem`, the same item [BottomNavigation](./bottom-navigation) takes. Everything about an item (`value`, `icon`, `href`, `disabled`) is documented there.

## Examples

### offset, safeArea

`offset` is how far the bar floats above the bottom edge, as a number of pixels or any CSS length. `safeArea` adds `env(safe-area-inset-bottom)` to that gap so the bar clears a phone's home indicator, and it moves the whole sheet up rather than only the row inside it.

```tsx
<FloatingBottomNavigation offset={24} safeArea={false} />
```

### position

`fixed` (the default) holds the bar against the bottom of the window. `absolute` holds it against the bottom of the nearest positioned ancestor, which is what a bar inside a screen of its own wants, and is what the preview above uses. `sticky` holds it against the bottom of whatever is scrolling, and `static` puts it back in the flow, centred.

<Demo src="floating-bottom-navigation/pinned" minHeight="300">

<<< @/.vitepress/demos/floating-bottom-navigation/pinned.tsx

</Demo>

### labels

`selected` (the default) draws only the name of the destination the reader is on, `all` draws every name, and `none` draws none of them. Under `selected`, pressing a destination grows its name and moves its neighbours over while the highlight slides under it. An undrawn name is still in the document, where it gives the glyph beside it an accessible name.

<Demo src="floating-bottom-navigation/labels" minHeight="340">

<<< @/.vitepress/demos/floating-bottom-navigation/labels.tsx

</Demo>

### variant, color, size

`variant` never dyes the sheet, and what carries the colour family is the one destination that is current. The default is `outline`.

<Demo src="floating-bottom-navigation/appearance" minHeight="320">

<<< @/.vitepress/demos/floating-bottom-navigation/appearance.tsx

</Demo>

### Controlling it

Pass `value` and the bar keeps no state of its own, which is the shape to use when the router already knows where the reader is.

```tsx
<FloatingBottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
</FloatingBottomNavigation>
```

## Accessibility

- The root is a `<nav>` and `label` names it. It is not a `role="tablist"`, so each destination is its own tab stop and the arrow keys do not move between them.
- The current destination carries `aria-current="page"`.
- Each destination is a real `<button>`, or a real `<a>` when it is given an `href`.
- A name that `labels` keeps undrawn stays in the document as the destination's accessible name. For an item that is only a glyph, that is its whole accessible name.
- For a reader who has asked for reduced motion, the highlight and the names change to the new arrangement without travelling.
- With `position="fixed"`, pad the bottom of the page by the bar's height plus its `offset`, or its last line is covered.
