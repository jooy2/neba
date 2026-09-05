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

Its destinations are `BottomNavigationItem`, the same item [BottomNavigation](./bottom-navigation) takes. Everything about an item (`value`, `icon`, `href`, `disabled`) is documented there.

## Props

<PropsTable name="FloatingBottomNavigation" />

Every other `<nav>` attribute passes through to the root, except `onChange`: the change worth listening for is `onValueChange`. The shared axes (`variant` `size` `color` `density` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### offset

How far the bar floats above the bottom edge, as a number of pixels or any CSS length. This is the whole difference between this component and [BottomNavigation](./bottom-navigation): because the page keeps going underneath, the sheet is a stadium rather than a bar with two corners, it carries a shadow, and it is sized by its contents.

`safeArea` adds `env(safe-area-inset-bottom)` to that gap, so the bar clears a phone's home indicator. Unlike on a full-width bar it moves the whole sheet, because there is nothing under it to keep covered.

```tsx
<FloatingBottomNavigation offset={24} safeArea={false} />
```

### position

`fixed` (the default) holds the bar against the bottom of the window. `absolute` holds it against the bottom of the nearest positioned ancestor, which is what a bar inside a screen of its own wants, and is what the preview above uses. `sticky` holds it against the bottom of whatever is scrolling, and `static` puts it back in the flow, centred.

<Demo src="floating-bottom-navigation/pinned" minHeight="300">

<<< @/.vitepress/demos/floating-bottom-navigation/pinned.tsx

</Demo>

### labels

`selected` (the default here) draws only the name of the destination the reader is on. A floating bar is as wide as what is in it, so five drawn names would stretch it across the screen and it would stop being a lozenge.

`all` draws every name and `none` draws none of them. An undrawn name is still in the document, where it is what gives the glyph beside it an accessible name.

<Demo src="floating-bottom-navigation/labels" minHeight="340">

<<< @/.vitepress/demos/floating-bottom-navigation/labels.tsx

</Demo>

### The highlight

The highlight belongs to the bar rather than to the destination that is current, which is why it can travel: it is measured off whichever item carries `aria-current` and animates its `left`, `top`, `width` and `height` to the next one. Nothing is transformed, so the name riding over it is never resampled.

A name that `labels` is not drawing is collapsed rather than clipped (the box it sits in travels between nothing and the width of the words), so pressing a destination re-shapes the bar around it instead of jumping to the new arrangement: the name grows, its neighbours move over, and the highlight slides under it on the same clock. A reader who has asked for reduced motion gets the new arrangement without the journey.

### variant, color, size

`variant` says what it says on every other container: the sheet is never dyed, and what carries the colour family is the one destination that is current. `outline` is the default here rather than the sheet with no edge: the hairline is what separates a floating lozenge from whatever is passing underneath it.

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

- The root is a `<nav>` and `label` names it. It is not a `role="tablist"`: a tab list promises one tab stop for the set and arrow keys within it, and a bottom navigation changes the page rather than which panel of one is showing.
- The current destination carries `aria-current="page"`.
- Each destination is a real `<button>`, or a real `<a>` when it is given an `href`.
- A name that `labels` keeps undrawn stays in the document, where it is the destination's accessible name: which is the whole accessible name of an item that is only a glyph.
- With `position="fixed"`, pad the bottom of the page by the bar's height plus its `offset`, or its last line is covered.
