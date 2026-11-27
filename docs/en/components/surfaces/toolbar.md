---
title: Toolbar
order: 7
flutter: true
---

# Toolbar

<p class="neba-lede">Lays controls out in a bar. Use it for an application header, a page's action row, or the status strip under an editor.</p>

<Demo src="toolbar/hero" />

::: fw react

```tsx
import { Toolbar } from 'neba';

<Toolbar render={<header />} start={<Logo />} end={<Button>Deploy</Button>}>
  Workspace
</Toolbar>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaToolbar(
  start: const <Widget>[Logo()],
  end: <Widget>[NebaButton(onPressed: deploy, child: const Text('Deploy'))],
  children: const <Widget>[Text('Workspace')],
);
```

:::

## Props

<PropsTable name="Toolbar" />

::: fw react

Every native `<div>` attribute passes through.

There are three slots: `start` and `end` are pinned to their ends and `children` takes what is left, so no spacer element is needed to push things apart.

:::

::: fw flutter

There are three slots, each a list of widgets laid out in a row 8 pixels apart: `start` and `end` are pinned to their ends and `children` takes what is left, so no `Spacer` is needed to push things apart. A widget in the middle that should fill that width, such as a field, goes in an `Expanded`. The bar takes the width it is given.

:::

## Examples

### size and density

A Toolbar has no height of its own. It is as tall as the controls in it plus its padding, and `size` and `density` set that padding. <Fw react='density="compact"' flutter="density: NebaDensity.compact" code /> gives a dense bar without moving the type scale.

<Demo src="toolbar/density">

::: fw react

<<< @/.vitepress/demos/toolbar/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/density.dart

:::

</Demo>

### position and side

::: fw react

`position` is CSS's own three values, spelled the way CSS spells them.

- `sticky`: what an application header usually wants. It takes up its own space, so nothing underneath needs padding around it.
- `fixed`: leaves the flow, so the page needs padding of its own or the first screenful sits behind the bar.

:::

::: fw flutter

`position` takes CSS's three values, but a Flutter widget is laid out where its parent puts it, so only `fixed` moves the bar.

- `sticky`: draws the bar as it looks held against its edge. Holding it there is the scroll view's job: put it in a `PinnedHeaderSliver` in a `CustomScrollView`, or at the top or the bottom of a `Column` around an `Expanded` scroll view.
- `fixed`: leaves the flow for the nearest `Overlay`, across its width and against its edge, and takes no room where it was written. The page needs padding of its own, or the first screenful sits behind the bar.

:::

`side` is the edge the bar pins to. A pinned bar drops its radius, because a rounded corner against the edge of the screen is a gap with nothing behind it. `safeArea` adds the screen's inset on that edge to the padding, so the bar stays clear of a phone's notch and home indicator.

<Demo src="toolbar/sticky">

::: fw react

<<< @/.vitepress/demos/toolbar/sticky.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/sticky.dart

:::

</Demo>

### divider and elevation

`divider` rules under the bar to show there is content beneath. `elevation` stays `0` even when the bar is pinned, so either raise it yourself on scroll or leave it flat and turn on `divider`.

### color

`color` reaches the rule. A bar that holds other people's controls does not fill its own sheet.

## Accessibility

::: fw react

- It does not set `role="toolbar"`. That role promises one tab stop for the bar with arrow keys inside it, and claiming it without implementing it is worse for a keyboard user than not claiming it.
- For a page header, pass `render={<header />}`: a real landmark, which is what a screen reader user navigates by.
- For a group of controls navigated with the arrow keys, use [ButtonGroup](../inputs/button-group).

:::

::: fw flutter

- It adds nothing to the focus order or the semantics tree. Each control on the bar is a focus stop of its own and is heard on its own; the bar does not claim to be one stop with arrow keys inside it, which it does not implement.
- Flutter has no header landmark, so there is no counterpart to `render={<header />}`.
- For a set of toggles navigated with the arrow keys, use [ToggleGroup](../inputs/toggle-group), which is one focus stop.

:::
