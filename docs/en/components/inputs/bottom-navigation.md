---
title: BottomNavigation
order: 22
flutter: true
---

# BottomNavigation

<p class="neba-lede">A bar of an app's main destinations, held against the bottom edge of the window. One glyph with a name under it is one destination, and the one the reader is on is marked as the current page.</p>

<Demo src="bottom-navigation/hero" minHeight="200" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaBottomNavigation<String>(
  label: 'Main',
  value: section,
  onValueChange: (String next) => setState(() => section = next),
  children: const <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(value: 'home', icon: homeIcon, child: Text('Home')),
    NebaBottomNavigationItem<String>(value: 'search', icon: searchIcon, child: Text('Search')),
  ],
);
```

:::

## Props

<PropsTable name="BottomNavigation" />

<PropsTable name="BottomNavigationItem" />

::: fw react

Every other `<nav>` attribute passes through to the root and every other `<button>` attribute to each destination, except `onChange`: the change worth listening for is `onValueChange`.

:::

::: fw flutter

The destinations are `children`, a list of `NebaBottomNavigationItem`, and the bar is generic over the type of their `value`. `value` with `onValueChange` makes it controlled; left `null`, the bar keeps its own state from `defaultValue`. There is no `render`, because a Flutter bar has no element to swap.

:::

The shared axes (`variant` `size` `color` `density` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### position

::: fw react

The default is `fixed`, against the `static` everything else in the library defaults to, and that is what this component is: it is held against the bottom edge of the window whatever the page does. The page then needs bottom padding of its own, or its last line sits behind the bar.

`sticky` keeps the bar in the flow but stops it at the bottom edge of the scrolling region. `static` is an ordinary sheet in the flow.

:::

::: fw flutter

The default is `fixed`, against the `static` everything else in the library defaults to. Flutter has no fixed positioning against the window, so `position` says how the bar is drawn and its parent says where it goes. `fixed` and `sticky` draw a square sheet with only the hairline facing the content, and keep the destinations clear of the system insets; `static` draws a sheet with corners for the middle of a page. Put the bar at the bottom of the screen's `Column`, under the part that scrolls, or hand it to a [PageLayout](../layout/page-layout) as its `footer`, which holds a bar that is not `static` at the bottom of the page.

:::

<Demo src="bottom-navigation/pinned" minHeight="280">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/pinned.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/pinned.dart

:::

</Demo>

### labels

`all` draws every name. `selected` draws only the current one, and `none` draws none of them. With `selected` every item keeps the line a name takes, so the glyphs stay where they are as the selection moves.

::: fw react

An undrawn name is still in the document. A button whose whole label is a glyph has no accessible name at all, so what goes is the pixels and nothing else.

:::

::: fw flutter

An undrawn name is still heard. A destination whose whole label is a glyph has no name at all, so what goes is the pixels and nothing else: a screen reader reads the words of the `Text` that is the item's `child`, and a `child` that is not a `Text` needs a `semanticLabel`.

:::

<Demo src="bottom-navigation/labels" minHeight="320">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/labels.dart

:::

</Demo>

### href

::: fw react

A destination with an `href` is a real `<a>`. That is what makes a long press offer "open in a new tab" and what puts the address in the status bar, neither of which a `<button>` calling a router can do.

:::

::: fw flutter

The package opens nothing itself, so a destination that leads somewhere is a callback: the bar's `onValueChange` or the item's `onPressed` calls the router, and `href` makes the item a link and tells a screen reader, and on the web the browser, where it goes. `newTab` says the link leaves the app, and a screen reader hears "(opens in a new tab)" after the name; there is no `target` and no `rel`.

:::

<Demo src="bottom-navigation/links" minHeight="120">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/links.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/links.dart

:::

</Demo>

### variant, divider, safeArea

`variant` says what it says on every other container: the sheet is never dyed, and what carries the colour family is the one destination that is current. `divider` is the hairline along the top edge, facing the content, and it is on by default. `safeArea` <Fw react="adds `env(safe-area-inset-bottom)` under the row to clear a phone's home indicator" flutter="keeps the row clear of the system insets on the bottom and the two sides, where a phone's home indicator and notch are" />, while the sheet itself still reaches the edge of the screen.

<Demo src="bottom-navigation/appearance" minHeight="360">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/appearance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/appearance.dart

:::

</Demo>

### Controlling it

Pass `value` and the bar keeps no state of its own, which is the shape to use when the router already knows where the reader is.

::: fw react

```tsx
<BottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
</BottomNavigation>
```

:::

::: fw flutter

```dart
NebaBottomNavigation<String>(
  value: location,
  onValueChange: navigate,
  children: const <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(value: '/home', icon: homeIcon, child: Text('Home')),
  ],
);
```

:::

## Accessibility

::: fw react

- The root is a `<nav>` and `label` names it. It is not a `role="tablist"`: a tab list promises one tab stop for the set and arrow keys within it, and a bottom navigation changes the page rather than which panel of one is showing.
- The current destination carries `aria-current="page"`.
- Each destination is a real `<button>`, or a real `<a>` when it is given an `href`.
- A name that `labels` keeps undrawn stays in the document, where it is the destination's accessible name.
- With `position="fixed"`, pad the bottom of the page by the bar's height, or its last line is covered.

:::

::: fw flutter

- A screen reader hears a navigation region named by `label`. It is not a tab bar: a tab bar promises one stop in the focus order for the set and arrow keys within it, and a bottom navigation changes the screen rather than which panel of one is showing. Each destination is a stop of its own.
- Give every bar a `label` when a screen holds more than one: Flutter's semantics check fails on a second navigation region with no name.
- The current destination is heard as selected.
- Each destination is a button, or a link when it is given an `href`. Enter presses either, and Space presses a button but not a link.
- A name that `labels` keeps undrawn is still the destination's name.

:::
