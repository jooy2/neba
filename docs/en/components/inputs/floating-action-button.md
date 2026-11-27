---
title: FloatingActionButton
order: 23
flutter: true
---

# FloatingActionButton

<p class="neba-lede">The one action a screen is about, as a round button floating over it: a FAB. Give it FloatingActions as children and it becomes a small set that fans out when it is pressed.</p>

<Demo src="floating-action-button/hero" minHeight="220" />

::: fw react

```tsx
import { FloatingActionButton } from 'neba';

<FloatingActionButton icon={<PencilIcon />} label="Compose" onClick={compose} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

Stack(
  children: <Widget>[
    page,
    NebaFloatingActionButton(icon: pencilIcon, label: 'Compose', onPressed: compose),
  ],
);
```

:::

## Props

<PropsTable name="FloatingActionButton" />

<PropsTable name="FloatingAction" />

::: fw react

Every other `<div>` attribute passes through to the root and every other `<button>` attribute to each action. `onClick`, `className` and `style` belong to the button itself, and the button keeps its round radius under a `style` of its own. The box pinned to the corner takes its classes through `classNames.frame`.

:::

::: fw flutter

The actions are `children`, a list of `NebaFloatingAction`. With no `onPressed` and no actions the button is disabled, as every Flutter button is; with actions, the press opens the dial and `onPressed` is optional. There is no `classNames`, because a Flutter button has no classes to take.

:::

The shared axes (`variant` `size` `color` `density` `elevation` `corner`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### Fanning out actions

Give it <Fw react="`FloatingAction` children" flutter="`NebaFloatingAction`s as `children`" /> and the button becomes a dial: pressing it (or resting a mouse on it) fans the actions out and swaps the glyph for a ×. Each action's name is drawn on a lozenge beside it.

`closeOnAction` decides whether the dial goes away once an action is pressed, `showLabels` whether the names are drawn, and `openOnHover` whether a resting mouse opens it.

<Demo src="floating-action-button/dial" minHeight="300">

::: fw react

<<< @/.vitepress/demos/floating-action-button/dial.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/dial.dart

:::

</Demo>

### extended

`extended` writes `label` beside the glyph, which turns the disc into a stadium: the shape to use when a drawing alone does not say what the screen is for. `label` is the accessible name either way, so the word that is drawn and the word that is read can never differ.

<Demo src="floating-action-button/extended" minHeight="120">

::: fw react

<<< @/.vitepress/demos/floating-action-button/extended.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/extended.dart

:::

</Demo>

### position, corner, offset

::: fw react

`position` defaults to `fixed`, which pins the button to a corner of the window. `absolute` pins it to a corner of the nearest positioned ancestor (a card, a map, the screen of a Mockup), and `static` puts it back in the flow.

:::

::: fw flutter

Flutter has no positioning against the window. A screen there is a `Stack`, and a Material `Scaffold` lays its own floating button over its body in one, so with any `position` but `static` the button takes the whole of the space it is laid out in and sits in a corner of it. Put it in a `Stack` over the screen or the region it belongs to; a press beside it goes through to what is underneath. It is not put in the overlay, where it would stay on screen over the next route and over a dialog the screen opened.

`fixed`, the default, and `sticky` keep clear of the system insets on the two edges of the corner, where a phone's home indicator and, held sideways, its notch are. `absolute` is for a region that is not against the edge of the screen (a card, a map, a preview) and adds none. `static` is the button alone, for a row or a toolbar, and for a slot that places it itself, such as a `Scaffold`'s `floatingActionButton`.

:::

`corner` picks one of the four corners and `offset` is the distance from both edges. Which way the actions fan out follows from `corner`, and `direction` overrides it.

<Demo src="floating-action-button/corners" minHeight="340">

::: fw react

<<< @/.vitepress/demos/floating-action-button/corners.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/corners.dart

:::

</Demo>

### variant, size, color

The button itself is a [Button](./button), unchanged: the variants, the elevation ladder, the pointer light and the press behaviour are all the ones every other control has. Only `size` starts a step higher, at `lg`, because this is the one control that has to be found and hit with a thumb without being looked at. The actions are drawn a step back down.

<Demo src="floating-action-button/appearance" minHeight="260">

::: fw react

<<< @/.vitepress/demos/floating-action-button/appearance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/appearance.dart

:::

</Demo>

### Controlling it

Pass `open` and the dial keeps no state of its own.

::: fw react

```tsx
const [open, setOpen] = useState(false);

<FloatingActionButton label="Share" open={open} onOpenChange={setOpen}>
  <FloatingAction icon={<LinkIcon />} label="Copy link" />
</FloatingActionButton>;
```

:::

::: fw flutter

```dart
NebaFloatingActionButton(
  label: 'Share',
  open: open,
  onOpenChange: (bool next) => setState(() => open = next),
  children: const <NebaFloatingAction>[
    NebaFloatingAction(icon: linkIcon, label: 'Copy link'),
  ],
);
```

:::

## Accessibility

::: fw react

- `label` is required. A button whose whole label is a drawing has no accessible name at all.
- With actions, the button carries `aria-expanded` and an `aria-controls` pointing at the set it revealed. It is not a `role="menu"`: a menu promises one tab stop for the set, arrow keys within it and typeahead, and what wants those is [Menu](./menu).
- The actions are ordinary buttons in the tab order right after the one that revealed them.
- Escape closes the dial and hands the focus back to the button. A press outside closes it too.
- The lozenge beside an action is `aria-hidden`, because the same string is already the button's accessible name and would otherwise be announced twice.

:::

::: fw flutter

- `label` is required. A button whose whole label is a drawing has no name at all.
- With actions, a screen reader hears whether the button is expanded. It is not a menu: a menu promises one stop for the set, arrow keys within it and typeahead, and what wants those is [Menu](./menu).
- The actions are ordinary buttons in the focus order right after the one that revealed them, whichever way the dial fans.
- Escape closes the dial wherever the focus is, and hands the focus back to the button when it was on the button or an action. A press outside closes it too, and so does an action, which gives the focus back to the button when the action held it.
- The lozenge beside an action is not heard, because the same words are already the action's name and would otherwise be announced twice.

:::
