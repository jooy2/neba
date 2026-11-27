---
title: Anchor
order: 21
flutter: true
---

# Anchor

<p class="neba-lede">The list of headings on the page being read, with the one the reader is in marked. Real fragment links, so they jump to their headings whether or not the tracking is running.</p>

<Demo src="anchor/hero" raw />

::: fw react

```tsx
import { Anchor } from 'neba';

<Anchor
  items={[
    { href: '#install', label: 'Install' },
    { href: '#setup', label: 'Setup', depth: 1 }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaAnchor(
  items: <NebaAnchorItem>[
    NebaAnchorItem(target: installKey, label: const Text('Install')),
    NebaAnchorItem(target: setupKey, label: const Text('Setup'), depth: 1),
  ],
);
```

:::

## Props

<PropsTable name="Anchor" />

::: fw react

Every native `<nav>` attribute passes through, apart from `color` and `children`.

:::

::: fw flutter

A heading is named by the `GlobalKey` of its widget rather than by an `id`, and the list follows the scroll view those headings are in, the nearest one around the first heading that is built. A row that is pressed scrolls that view.

:::

### AnchorItem

<PropsTable name="AnchorItem" />

## Examples

### <Fw react="activeHref" flutter="activeTarget" /> and onActiveChange

Left alone, the list tracks the scroll: the marked row is the last heading whose top has passed the line, which reads correctly going up as well as down, and the last heading is marked once the scroll reaches the bottom. A page with nothing to scroll starts on the first heading. Pass <Fw react="`activeHref`" flutter="`activeTarget`" /> to decide which row is marked yourself: the tracking keeps running, so `onActiveChange` still reports the heading the reader is in, which is what <Fw react="`activeHref`" flutter="`activeTarget`" /> is usually set from.

Nothing is marked while the reader is still above the first heading.

### offset

How far below the top of the scrollport a heading counts as reached. Set it to the height of a sticky header, or the heading under the bar is never the one marked.

::: fw react

On a page that scrolls the document, a pressed row is the browser's own jump to the heading, which does not read `offset`. Give the page a `scroll-padding-top` of the same height so the heading lands below the bar too.

:::

::: fw flutter

A pressed row scrolls the heading's view so the heading lands `offset` below its top, under a bar pinned over it.

:::

### container

::: fw react

What scrolls, when it is not the document: the element a [PageLayout](../layout/page-layout) with `scroll="content"` puts the page inside, for instance.

Given one, a row scrolls that container itself rather than letting the browser jump to the fragment — which would scroll the box and then scroll the page as well so that the box is in view, and would land the heading under whatever `offset` describes. The URL's fragment is left alone; a heading inside a box the caller scrolls is somewhere in the caller's app. Without a `container` the click is the browser's, as it always was.

:::

::: fw flutter

There is no `container`: the list finds the scroll view the headings are in by their keys, and scrolls that view when a row is pressed. A heading in a lazily built list that is not built yet has no position to measure and is not marked until it is.

:::

### rail

`rail` draws a line down the leading edge and lights it beside the active row. It is on by default.

<Demo src="anchor/rail">

::: fw react

<<< @/.vitepress/demos/anchor/rail.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/anchor/rail.dart

:::

</Demo>

### size

<Demo src="anchor/sizes">

::: fw react

<<< @/.vitepress/demos/anchor/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/anchor/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a real `<nav>` of real `<a href="#…">`s. They work with JavaScript off, and they are in the link list a screen reader can pull up.
- The marked row carries `aria-current="location"`, which is the value for where the reader is within a set of links.
- The `<nav>` is named from `locale`, or from `label`.
- A heading with no `id` cannot be tracked, and its row is a link to nothing.

:::

::: fw flutter

- The list is one node named "On this page" in the `locale`'s words, or by `semanticLabel`, holding a link per row.
- The marked row is selected, which is as close as Flutter semantics comes to `aria-current="location"`.
- A heading whose key is on no widget cannot be tracked, and its row scrolls nowhere.

:::
