---
title: Show
order: 11
flutter: true
---

# Show

<p class="neba-lede">Its children at some widths and not at others. A floor, a ceiling, or both, on the same five-step ladder every other breakpoint in the library uses.</p>

<Demo src="show/hero" />

::: fw react

```tsx
import { Show } from 'neba';

<Show above="md">
  <Sidebar />
</Show>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaShow(above: NebaBreakpoint.md, child: sidebar);
```

:::

## Props

<PropsTable name="Show" />

::: fw react

Native `<div>` attributes pass through, and `render` swaps the element. The five breakpoints and what they are worth are described in [breakpoints](../../design/breakpoints).

:::

::: fw flutter

It draws nothing and takes no `className` or `style`. The five breakpoints are `NebaBreakpoint`, and what they are worth is described in [breakpoints](../../design/breakpoints).

:::

## Examples

### above and below

`above` is inclusive and `below` is exclusive, so the same breakpoint in both covers every width exactly once with no gap and no overlap. That pair is the common case: one arrangement for a phone, another for everything else.

<Demo src="show/pair">

::: fw react

<<< @/.vitepress/demos/show/pair.tsx

:::

</Demo>

### Bounding a range

::: fw react

Given together they are a floor and a ceiling: `above="sm" below="lg"` is drawn from 40rem up to but not including 64rem.

:::

::: fw flutter

Given together they are a floor and a ceiling: `above: NebaBreakpoint.sm, below: NebaBreakpoint.lg` is shown from 640 up to but not including 1024 logical pixels.

:::

<Demo src="show/range">

::: fw react

<<< @/.vitepress/demos/show/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/show/range.dart

:::

</Demo>

### Inside a grid or flex row

::: fw react

Without `render` the wrapper is `display: contents`, so a `Show` between a [GridContainer](./grid) and a [Grid](./grid) leaves the cell a cell, and one inside a flex row leaves its children flex items. Nothing given to it to style (padding, a background) has anywhere to land; put those on an element inside it, or name the element with `render`.

:::

::: fw flutter

A shown NebaShow builds its child where it stands, with nothing in between, so one between a [GridContainer](./grid) and a [Grid](./grid) leaves the cell a cell. While it is hidden, `NebaFlex` and `NebaGridContainer` leave it out entirely, so it takes no cell and no gap; Flutter's own `Row` and `Column` give its empty box a gap like any other child.

:::

<Demo src="show/transparent">

::: fw react

<<< @/.vitepress/demos/show/transparent.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/show/transparent.dart

:::

</Demo>

### Not rendering at all

::: fw react

The children are always rendered: what changes is `display`. That is what makes the answer right in the first frame the browser paints, and the same answer on a server.

When something must not _run_ below a width, such as a component that fetches or mounts a map, CSS cannot make that decision. `useBreakpoint` is what makes it. It answers `false` on a server and on the first client render, so what it controls arrives after hydration.

```tsx
import { useBreakpoint } from 'neba';

const wide = useBreakpoint('md');

return wide ? <Map /> : <StaticImage />;
```

:::

::: fw flutter

The width is the window's, `MediaQuery.sizeOf`, as a media query reads the viewport's; in a preview on this site the window is the preview's own frame. A hidden child is not built at all, so a widget below it that fetches or mounts a map does not run, and one that crosses the breakpoint is built afresh, its state with it.

To decide in a build method of your own, compare the same width against the ladder:

```dart
final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

return wide ? const MapView() : const StaticImage();
```

:::

### render

::: fw react

`render` names the element, which is what a `Show` inside a table or a list needs: a `<div>` is not allowed between a `<tr>` and a `<td>`. The element keeps its own box, so a `<td>` keeps its padding and border and only the hiding is added.

```tsx
<tr>
  <td>{row.name}</td>
  <Show above="lg" render={<td />}>
    {row.updatedAt}
  </Show>
</tr>
```

:::

::: fw flutter

There is no `render`. A Flutter widget has no element to name, and a shown NebaShow is its child and nothing else, so it can stand wherever its child can.

:::

## Accessibility

::: fw react

- A hidden branch is `display: none`, so it is out of the accessibility tree and out of the tab order as well as off the screen. Nothing is announced twice.
- Both halves of an `above`/`below` pair are in the DOM at every width, so anything that must not be duplicated (an `id`, a form control's `name`, a heading) has to differ between them or live outside the pair.

:::

::: fw flutter

- A hidden branch is not built, so it is out of the semantics tree and the focus order as well as off the screen. Nothing is announced twice.
- Only one half of an `above`/`below` pair is built at a time, and a half that comes back is built afresh, so what was typed into it is gone.

:::
