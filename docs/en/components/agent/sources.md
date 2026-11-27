---
title: Sources
order: 6
flutter: true
---

# Sources

<p class="neba-lede">The list of things an answer was built out of. Numbered rows, each a link with the passage that matched under it, folded behind a heading that says how many there were.</p>

<Demo src="sources/hero" />

::: fw react

```tsx
import { Sources } from 'neba';

<Sources
  items={[
    { title: 'The design language', site: 'neba.cdget.com', href: '/design/design-language' },
    { title: 'Breakpoints', site: 'neba.cdget.com', href: '/design/breakpoints' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSources(
  items: <NebaSourceItem>[
    NebaSourceItem(
      title: const Text('The design language'),
      site: const Text('neba.cdget.com'),
      onPressed: () => open('/design/design-language'),
    ),
    NebaSourceItem(
      title: const Text('Breakpoints'),
      site: const Text('neba.cdget.com'),
      onPressed: () => open('/design/breakpoints'),
    ),
  ],
);
```

:::

## Props

<PropsTable name="Sources" />

::: fw react

Native `<div>` attributes pass through to the root. `color`, `title` and `onChange` are excluded, since the table above spells them differently.

:::

::: fw flutter

Each row is a `NebaSourceItem`. `keepMounted` takes the place of `hiddenUntilFound`, and `labels` is a map keyed by the React package's names for the words.

:::

The rows are _numbered_, and the numbers are what an [InlineCitation](./inline-citation) in the body points at.

### SourceItem

<PropsTable name="SourceItem" />

## Examples

### collapsible

On. The list folds under its header, and the header shows how many sources there are whether it is open or not.

Off, the heading is a plain line and the list is open. There is no disclosure at all in that state, so nothing is pressable.

<Demo src="sources/folding">

::: fw react

<<< @/.vitepress/demos/sources/folding.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sources/folding.dart

:::

</Demo>

### <Fw react="hiddenUntilFound" flutter="keepMounted" />

::: fw react

On. A folded list stays in the DOM as `hidden="until-found"`, so its links are in a server render, and the browser's own page search can find a row and open the list around it. `hiddenUntilFound={false}` takes a folded list out of the DOM.

:::

::: fw flutter

On. A folded list keeps its rows built. `keepMounted: false` lets them go while the list is folded.

:::

### Numbering

Rows are numbered from one, in the order they were given. A source's own `index` overrides that, which is what a list showing only the sources actually cited — out of a longer set — needs.

<Fw react="numbered={false}" flutter="numbered: false" code /> drops the marks. Reach for it when nothing in the body cites anything, since a number with nothing pointing at it is a number a reader looks for a meaning in.

### Links

::: fw react

A row with an `href` is a real [TextLink](../display/text-link), so its underline and its focus ring are the ones every other link in the library draws. A row without one is plain text: a passage from a file the reader cannot open is still a source.

Any `href` whose scheme is not `http`, `https`, `mailto` or `tel` leaves the row unlinked rather than being written out, and a `target` that leaves the tab gains `rel="noopener noreferrer"`.

:::

::: fw flutter

A row with an `onPressed` is a real [TextLink](../display/text-link), so its underline and its focus ring are the ones every other link in the library draws; the package opens nothing itself, so the callback is what follows it. A row without one is plain text: a passage from a file the reader cannot open is still a source.

An `href` is what a screen reader, and on the web the browser, is told the link points at. One whose scheme is not `http`, `https`, `mailto` or `tel` leaves the row unlinked, and `newTab` tells a screen reader the link leaves the app.

:::

### variant

`text` is the default, and the list draws no sheet.

<Demo src="sources/variant">

::: fw react

<<< @/.vitepress/demos/sources/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sources/variant.dart

:::

</Demo>

## Accessibility

::: fw react

- An `<ol>` with `role="list"` spelled out, so Safari keeps the list semantics after Tailwind's reset takes the markers off.
- The number beside a row is `aria-hidden`: it is a pointer for the eye, and the row is already in a numbered list.
- The heading is a real button when the list folds, wired to the panel by Base UI.
- A folded list is in neither the tab order nor the accessibility tree. Unless `hiddenUntilFound` is off, the browser's own page search can still find a row in it and open the list.

:::

::: fw flutter

- The rows are a list and each row an item of it, to a screen reader.
- The number beside a row is drawn and not read: it is a pointer for the eye, and the row is already in a list.
- The heading is a button that is expanded or collapsed when the list folds, named by the heading and the count.
- A folded list is in neither the focus order nor the semantics tree from the moment it starts folding.

:::
