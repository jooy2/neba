---
title: Alert
order: 1
flutter: true
---

# Alert

<p class="neba-lede">A message about something that just happened, set into the page. Use it for notices that stay on screen: a save confirmation, a validation error, a setting that needs attention.</p>

<Demo src="alert/hero" />

::: fw react

```tsx
import { Alert } from 'neba';

<Alert color="success">Your changes have been saved.</Alert>
<Alert color="danger" title="Deploy failed" onClose={dismiss}>
  The build exited with code 1.
</Alert>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAlert(color: NebaColor.success, child: Text('Your changes have been saved.'));
NebaAlert(
  color: NebaColor.danger,
  title: const Text('Deploy failed'),
  onClose: dismiss,
  child: const Text('The build exited with code 1.'),
);
```

:::

## Props

<PropsTable name="Alert" />

`color` defaults to `info` rather than `primary`.

::: fw flutter

The message is `child` and the heading `title`, each usually a `Text`. `showIcon: false` draws no glyph where React writes `icon={false}`, and `role` takes a `SemanticsRole`. An alert takes the width it is given, so one in a `Row` needs an `Expanded` or a width of its own.

:::

## Examples

### <Fw react="title and children" flutter="title and child" />

<Fw react="`children`" flutter="`child`" /> alone is a one-line notice; adding `title` gives you a headline with the detail under it. It is the same component with a different number of slots filled.

<Demo src="alert/shapes">

::: fw react

<<< @/.vitepress/demos/alert/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/shapes.dart

:::

</Demo>

### variant

An alert is the thing being coloured, so unlike a [Box](../surfaces/box) its sheet takes the tint. Use `text` inside a form, where a second bordered rectangle among the fields is one too many.

<Demo src="alert/variants">

::: fw react

<<< @/.vitepress/demos/alert/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/variants.dart

:::

</Demo>

### color

`color` sets the severity, and the glyph changes with it. Four drawings cover the six families, so the kind of message carries even where the colour does not.

<Demo src="alert/colors">

::: fw react

<<< @/.vitepress/demos/alert/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/colors.dart

:::

</Demo>

### <Fw react="icon" flutter="icon · showIcon" />

::: fw react

Pass a node to replace the default glyph, or `icon={false}` to draw none.

An `<svg>` anywhere in an alert is sized to `1.2em` of the text around it, so an icon from any set arrives at the right size without being told one. Anything that is not an `<svg>` — an `<img>`, a sprite, a glyph in a font — carries its own size.

:::

::: fw flutter

Pass a widget as `icon` to replace the default glyph, or `showIcon: false` to draw none.

The alert hands an `IconTheme` down at 1.2 times the size of the text, so an `Icon` arrives at the right size without being told one, and the glyph is centred on the first line of the message. Anything that is not an `Icon` carries its own size.

:::

### action and onClose

`action` is a slot outside <Fw react="`children`" flutter="`child`" />, so it stays on the first line while the message wraps beside it. Passing `onClose` is what makes the × appear.

<Demo src="alert/dismissing">

::: fw react

<<< @/.vitepress/demos/alert/dismissing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/dismissing.dart

:::

</Demo>

## Accessibility

::: fw react

- The severity picks the live region: `warning` and `danger` get `role="alert"`, which interrupts what a screen reader is saying, and the rest get `role="status"`, which waits for a pause. The role is on the title and the message, so the action and the dismiss button are not read out with them.
- A screen reader announces a live region when what is inside it changes, and an Alert that mounts already holding its message is not announced by every one. For a message that has to be heard, keep the Alert mounted and change what it says, or write the message into a live region that is already on the page.
- Passing `role` yourself overrides the default, and it goes on the same element.

:::

::: fw flutter

- The severity picks the live region the title and the message are in, and the action and the dismiss button are outside it, so they are not read out with the message. On the web, `warning` and `danger` are `SemanticsRole.alert`, which interrupts what a screen reader is saying, and the rest are `SemanticsRole.status`, which waits for a pause.
- Android and iOS have no `alert` or `status` role. There the title and the message are a live region, read out when the alert appears and whenever they change, and the two severities are read the same way.
- Passing `role` overrides the default. `SemanticsRole.none` takes the message out of every live region.
- The × is drawn at the size of the text beside it, and its target reaches into the padding around it to 24 pixels each way.

:::

- With several alerts on screen, use `closeLabel` to name what is being dismissed.
- `locale` decides the dismiss button's accessible name; `closeLabel` writes it out instead.
