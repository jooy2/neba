---
title: Chip
order: 3
flutter: true
---

# Chip

<p class="neba-lede">A compact token holding one short value: a tag, a filter, a status. It can also be made clickable or deletable.</p>

<Demo src="chip/hero" />

::: fw react

```tsx
import { Chip } from 'neba';

<Chip>design-system</Chip>
<Chip color="danger" count={12}>Errors</Chip>
<Chip onDelete={remove}>typescript</Chip>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaChip(child: Text('design-system'));
const NebaChip(color: NebaColor.danger, count: Text('12'), child: Text('Errors'));
NebaChip(onDelete: remove, child: const Text('typescript'));
```

:::

## Props

<PropsTable name="Chip" />

::: fw flutter

The label is `child`, usually a `Text`, and it is cut short with an ellipsis when the chip is given less room than it needs. `onPressed` makes the label a button and `onDelete` adds the × after it. There is no `href`, `target`, `rel` or `render`: a chip that leads somewhere calls the router from `onPressed`.

:::

Chip's `size` sits one step below the control heights: an `md` Chip is 26px, the same height as a `sm` [Button](../inputs/button). That separates a token placed inside content from a control the row lines up against.

## Examples

### variant and color

<Demo src="chip/variants">

::: fw react

<<< @/.vitepress/demos/chip/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/variants.dart

:::

</Demo>

### startIcon · endIcon · count

`startIcon` and `endIcon` are <Fw react="nodes" flutter="widgets" /> placed before and after the label<Fw flutter=", drawn at 1.2 times the label's size through the `IconTheme` the chip hands down" />. `count` gets its own plate, so "Errors 12" reads as one token with a number on it rather than as two words.

<Demo src="chip/content">

::: fw react

<<< @/.vitepress/demos/chip/content.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/content.dart

:::

</Demo>

### <Fw react="onClick · onDelete · selected" flutter="onPressed · onDelete · selected" />

<Fw react="`onClick`" flutter="`onPressed`" /> makes the whole chip a pressable control. `onDelete` adds a delete button after the label. `selected` marks the chip as on by deepening the surface one step rather than changing the colour family. A pressable chip is announced as a toggle only when `selected` is passed, `false` included; with <Fw react="`onClick`" flutter="`onPressed`" /> alone it is a plain button.

<Demo src="chip/interactive">

::: fw react

<<< @/.vitepress/demos/chip/interactive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/interactive.dart

:::

</Demo>

### href · target · rel

::: fw react

`href` makes the label a link, for a chip that leads somewhere: a tag to its page, a topic to its listing. A crawler can follow it and a reader can open it in a new tab, which a chip with `onClick` does not offer. `target` and `rel` reach the `<a>`; a `target` other than this tab adds `noopener noreferrer` to whatever `rel` says, and ends the link's accessible name with a note that it opens in a new tab, in the `locale`'s words. `onDelete` still adds its button beside the link, not inside it. A selected link chip is marked `aria-current="true"` rather than pressed, and a `disabled` one is not a link.

<Demo src="chip/links">

<<< @/.vitepress/demos/chip/links.tsx

</Demo>

:::

::: fw flutter

The Flutter package opens nothing itself, so a chip has no `href`. A chip that leads somewhere is a pressable chip whose `onPressed` calls the router, and `selected` marks the one for the page on screen.

:::

### render

::: fw react

A chip with an `href` is an `<a>`, which reloads the page. Pass a router's `Link` as `render` to move without a reload. Keep the `href` on the chip as well: it goes through to the `Link`, and so do `target`, the merged `rel` and `aria-current`. The `onDelete` button stays beside the link, and a `disabled` chip is not a link.

```tsx
<Chip href="/tags/react" render={<Link to="/tags/react" />} onDelete={remove}>
  react
</Chip>
```

:::

::: fw flutter

There is no element to swap. A chip that navigates calls the router from `onPressed`.

:::

### size

<Demo src="chip/sizes">

::: fw react

<<< @/.vitepress/demos/chip/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- The shell is always a `<span>`. `onClick` adds a `<button>` around the content and `href` an `<a>`; `onDelete` adds a second `<button>` beside it. Neither is nested inside the other, so both are reachable by keyboard.
- The delete button is named after the chip's label when the label is a string, "Remove Draft", so a row of chips is a row of buttons a screen reader can tell apart. When the label is a node, give it a `deleteLabel` naming what is being removed.

:::

::: fw flutter

- With `onPressed` the label is a button with a focus stop of its own, and `onDelete` adds a second one after it. Neither is inside the other, so a tap, Enter and Space reach each on its own.
- The × is drawn at the size of the words beside it and takes a press over the chip's whole height.
- The × is named after the chip's label when the label is a `Text`, "Remove Draft", so a row of chips is a row of buttons a screen reader can tell apart. Otherwise give it a `deleteLabel` naming what is being removed.

:::

- `locale` decides the delete button's accessible name; `deleteLabel` writes it out instead.
