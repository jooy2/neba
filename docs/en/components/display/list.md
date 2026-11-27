---
title: List
order: 5
flutter: true
---

# List

<p class="neba-lede">Stacks rows of the same shape vertically. Use it for navigation, settings, search results: anything that repeats.</p>

<Demo src="list/hero" />

::: fw react

```tsx
import { List, ListItem } from 'neba';

<List>
  <ListItem startIcon={<GlobeIcon />} description="Deployed 4 minutes ago" onClick={open} selected>
    production
  </ListItem>
  <ListItem startIcon={<GlobeIcon />} description="Deployed 2 hours ago" onClick={open}>
    staging
  </ListItem>
</List>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaList(
  children: <Widget>[
    NebaListItem(
      startIcon: const GlobeIcon(),
      description: const Text('Deployed 4 minutes ago'),
      onPressed: open,
      selected: true,
      child: const Text('production'),
    ),
    NebaListItem(
      startIcon: const GlobeIcon(),
      description: const Text('Deployed 2 hours ago'),
      onPressed: open,
      child: const Text('staging'),
    ),
  ],
);
```

:::

## Props

### List

<PropsTable name="List" />

`size` and `density` are set on `List` only. They reach every `ListItem` through <Fw react="a context" flutter="an inherited widget" />, so there is no need to repeat them per row.

::: fw flutter

The list takes the width it is given and is as tall as its rows. There is no `render`: Flutter's semantics have one kind of list, so a list where the order is the point is the same `NebaList`.

:::

### ListItem

<PropsTable name="ListItem" />

::: fw flutter

The package opens nothing itself, so a row that leads somewhere is a callback: `onPressed` calls the router, and `href` tells a screen reader, and on the web the browser, where it goes. An `href` with no `onPressed` leaves the row as plain content that takes no focus.

:::

## Examples

### dividers

`dividers` draws a rule between rows. The rules have to reach both edges of the sheet, so the list's inner padding and the rows' rounded corners go with them: rows become ruled lines rather than floating tiles.

<Demo src="list/dividers">

::: fw react

<<< @/.vitepress/demos/list/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/dividers.dart

:::

</Demo>

### spacing

Rows touch by default, and the padding inside each one keeps their text apart. `spacing` puts a gap between them, on <Fw react="Tailwind's spacing scale: `1` is `0.25rem`" flutter="the spacing scale: `1` is 4 logical pixels" />, enough that a hovered or selected tile no longer runs into its neighbour. It is ignored with `dividers`, where the rule is what separates the rows.

<Demo src="list/spacing">

::: fw react

<<< @/.vitepress/demos/list/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/spacing.dart

:::

</Demo>

### variant

Use <Fw react="`variant=&quot;text&quot;`" flutter="`NebaVariant.text`" /> inside a [Card](../surfaces/card). The card is already a sheet, so the borders do not double up.

<Demo src="list/variants">

::: fw react

<<< @/.vitepress/demos/list/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/variants.dart

:::

</Demo>

### <Fw react="onClick" flutter="onPressed" /> · href · action

::: fw react

`onClick` or `href` makes the whole row a `<button>` or an `<a>` respectively. `action` is a separate control slot **outside** that pressable area: for a row that navigates when pressed but also carries a switch of its own.

:::

::: fw flutter

`onPressed` makes the whole row a button, and a link when it also has an `href`. `action` is a separate control slot **outside** that pressable area: for a row that navigates when pressed but also carries a switch of its own.

:::

<Demo src="list/interactive">

::: fw react

<<< @/.vitepress/demos/list/interactive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/interactive.dart

:::

</Demo>

## Accessibility

::: fw react

- `List` sets `role="list"` explicitly, because Tailwind's reset removes the bullets from `<ul>` and Safari drops the list semantics with them.
- A `ListItem` shell is always an `<li>`, with a `<button>` or an `<a>` inside it depending on `onClick` and `href`.
- `selected` puts `aria-current="page"` on a link and `aria-current="true"` on a button. Not `aria-pressed`: a selected row is not a toggle.

:::

::: fw flutter

- `NebaList` is a list in the semantics tree and each `NebaListItem` an item of it, which the web reads as `role="list"` and `role="listitem"`.
- A pressable row is a button inside its item, or a link with an `href`; `action` sits beside it in the same item. Enter presses a row, and Space presses a button row but not a link.
- `selected` marks the row selected, which the web writes as `aria-current="true"`. It is not a toggle.

:::
