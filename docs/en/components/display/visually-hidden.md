---
title: VisuallyHidden
order: 22
flutter: true
---

# VisuallyHidden

<p class="neba-lede">Content that is in the accessibility tree and not on the screen. For the words a control needs a name from when the thing a sighted reader sees is a glyph, a number or a colour.</p>

<Demo src="visually-hidden/hero" />

::: fw react

```tsx
import { VisuallyHidden } from 'neba';

<button type="button">
  <span aria-hidden="true">×</span>
  <VisuallyHidden>Remove</VisuallyHidden>
</button>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaButton(
  onPressed: remove,
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ExcludeSemantics(child: Text('×')),
      NebaVisuallyHidden(child: Text('Remove')),
    ],
  ),
);
```

:::

## Props

<PropsTable name="VisuallyHidden" />

::: fw react

Native `<span>` attributes pass through, and `render` swaps the element. While hidden, the content sits in a 1px clipped box, so it stays in the accessibility tree and takes no room on the page.

:::

::: fw flutter

While hidden, the `child` is laid out at its own size inside a box of none: it takes no room, paints nothing and takes no pointer, and stays in the semantics tree with its actions.

:::

## Examples

### visible

::: fw react

Takes the hiding off, so the content is drawn like anything else. A skip link sets `visible` from its own focus state, as the example below does, so it appears only while it has the focus. A `focus-visible:` class cannot take the element out of the 1px box, so it cannot do the same.

:::

::: fw flutter

Takes the hiding off, so the content is drawn like anything else. A skip link sets `visible` from its own focus state, as the example below does, so it appears only while it has the focus.

:::

<Demo src="visually-hidden/skip-link">

::: fw react

<<< @/.vitepress/demos/visually-hidden/skip-link.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/visually_hidden/skip_link.dart

:::

</Demo>

### render

::: fw react

Renders something other than a `<span>`: a `<div>` for block content, an `<a>` for a skip link, a `<caption>` for a table that is described but not titled.

```tsx
<VisuallyHidden render={<caption />}>Revenue by quarter, in millions</VisuallyHidden>
```

:::

::: fw flutter

There is no element to swap: the child is whatever widget the content is.

:::

## Accessibility

::: fw react

- The content is a normal part of the accessibility tree: it contributes to an accessible name, it is read in document order, and it can be the target of `aria-describedby`.
- Put it **inside** the control it names rather than beside it. A `<button>` takes its name from its own contents.
- Mark the glyph a sighted reader sees with `aria-hidden="true"`, as the `×` in the snippet at the top is, so it is not read out beside the hidden words.
- Do not put an interactive element in one unless `visible` can become true: a focusable control the reader cannot see is a focus that appears to go nowhere.

:::

::: fw flutter

- The child is a normal part of the semantics tree: it is read where it was written and keeps its actions.
- Put it inside the control it names, beside what a sighted reader sees, and wrap that glyph in `ExcludeSemantics` so it is not read out as well.
- Do not put a control in one unless `visible` can become true: a focus a reader cannot see seems to go nowhere.

:::
