---
title: FloatingBottomNavigation
order: 24
flutter: true
---

# FloatingBottomNavigation

<p class="neba-lede">A bar of an app's main destinations, floating clear of the bottom edge rather than attached to it. It is only as wide as its destinations, it is cut as a stadium, and the page keeps going underneath it.</p>

<Demo src="floating-bottom-navigation/hero" minHeight="320" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

Stack(
  children: <Widget>[
    page,
    NebaFloatingBottomNavigation<String>(
      label: 'Main',
      value: section,
      onValueChange: (String next) => setState(() => section = next),
      children: const <NebaBottomNavigationItem<String>>[
        NebaBottomNavigationItem<String>(value: 'home', icon: homeIcon, child: Text('Home')),
        NebaBottomNavigationItem<String>(value: 'search', icon: searchIcon, child: Text('Search')),
      ],
    ),
  ],
);
```

:::

## Props

<PropsTable name="FloatingBottomNavigation" />

::: fw react

Every other `<nav>` attribute passes through to the root, except `onChange`: the change worth listening for is `onValueChange`. The shared axes (`variant` `size` `color` `density` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

The destinations are `children`, a list of `NebaBottomNavigationItem`, and the bar is generic over the type of their `value`; left `null`, `value` lets the bar keep its own state from `defaultValue`. `position` takes the type a [FloatingActionButton](./floating-action-button) takes, under a name of its own. The shared axes (`variant` `size` `color` `density` `elevation` `position`) are defined in [prop conventions](../../design/prop-conventions).

:::

Its destinations are <Fw react="`BottomNavigationItem`" flutter="`NebaBottomNavigationItem`" />, the same item [BottomNavigation](./bottom-navigation) takes. Everything about an item (`value`, `icon`, `href`, `disabled`) is documented there.

## Examples

### offset, safeArea

::: fw react

`offset` is how far the bar floats above the bottom edge, as a number of pixels or any CSS length. `safeArea` adds `env(safe-area-inset-bottom)` to that gap so the bar clears a phone's home indicator, and it moves the whole sheet up rather than only the row inside it.

```tsx
<FloatingBottomNavigation offset={24} safeArea={false} />
```

:::

::: fw flutter

`offset` is how far the bar floats above the bottom edge, in logical pixels. On a `fixed` or `sticky` bar, `safeArea` adds the bottom system inset to that gap so the bar clears a phone's home indicator, and it moves the whole sheet up rather than only the row inside it. An `absolute` bar belongs to a region that is not against the edge of the screen, and adds none, as a FloatingActionButton does.

```dart
NebaFloatingBottomNavigation<String>(offset: 24, safeArea: false, children: destinations);
```

:::

### position

::: fw react

`fixed` (the default) holds the bar against the bottom of the window. `absolute` holds it against the bottom of the nearest positioned ancestor, which is what a bar inside a screen of its own wants, and is what the preview above uses. `sticky` holds it against the bottom of whatever is scrolling, and `static` puts it back in the flow, centred.

:::

::: fw flutter

Flutter has no positioning against the window, so a bar that floats takes the whole of the space it is laid out in and floats at the bottom of it, centred, as a [FloatingActionButton](./floating-action-button) sits in its corner. Put it in a `Stack` over the screen or the region it belongs to, and give what scrolls underneath room at its end, so its last row can come out from under the bar; a press beside the bar goes through to what is underneath. `fixed`, the default, `sticky` and `absolute` float the same way and differ only in `safeArea`. `static` puts the bar back in the flow, centred.

:::

<Demo src="floating-bottom-navigation/pinned" minHeight="300">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/pinned.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/pinned.dart

:::

</Demo>

### labels

`selected` (the default) draws only the name of the destination the reader is on, `all` draws every name, and `none` draws none of them. Under `selected`, pressing a destination grows its name and moves its neighbours over while the highlight slides under it. An undrawn name is still <Fw react="in the document" flutter="heard" />, where it gives the glyph beside it <Fw react="an accessible name" flutter="a name" />.

<Demo src="floating-bottom-navigation/labels" minHeight="340">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/labels.dart

:::

</Demo>

### variant, color, size

`variant` never dyes the sheet, and what carries the colour family is the one destination that is current. The default is `outline`.

<Demo src="floating-bottom-navigation/appearance" minHeight="320">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/appearance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/appearance.dart

:::

</Demo>

### Controlling it

Pass `value` and the bar keeps no state of its own, which is the shape to use when the router already knows where the reader is.

::: fw react

```tsx
<FloatingBottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
</FloatingBottomNavigation>
```

:::

::: fw flutter

```dart
NebaFloatingBottomNavigation<String>(
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

- The root is a `<nav>` and `label` names it. It is not a `role="tablist"`, so each destination is its own tab stop and the arrow keys do not move between them.
- The current destination carries `aria-current="page"`.
- Each destination is a real `<button>`, or a real `<a>` when it is given an `href`.
- A name that `labels` keeps undrawn stays in the document as the destination's accessible name. For an item that is only a glyph, that is its whole accessible name.
- For a reader who has asked for reduced motion, the highlight and the names change to the new arrangement without travelling.
- With `position="fixed"`, pad the bottom of the page by the bar's height plus its `offset`, or its last line is covered.

:::

::: fw flutter

- A screen reader hears a navigation region named by `label`. It is not a tab bar, so each destination is a stop of its own in the focus order and the arrow keys do not move between them. Give every bar a `label` when a screen holds more than one: Flutter's semantics check fails on a second navigation region with no name.
- The current destination is heard as selected.
- Each destination is a button, or a link when it is given an `href`.
- A name that `labels` keeps undrawn is still the destination's name. For an item that is only a glyph, that is its whole name.
- For a reader who has asked for reduced motion, the highlight and the names change to the new arrangement without travelling.
- Pad the end of what scrolls under the bar by the bar's height plus its `offset`, or its last line is covered.

:::
