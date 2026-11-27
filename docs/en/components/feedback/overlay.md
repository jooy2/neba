---
title: Overlay
order: 8
flutter: true
---

# Overlay

<p class="neba-lede">A sheet over the whole page that blocks interaction. Use it while the user has to wait with nothing to answer: a save, a load, a replacement in progress.</p>

<Demo src="overlay/hero" frameMinHeight="240" />

::: fw react

```tsx
import { Overlay, ProgressCircular } from 'neba';

<Overlay open={saving} tone="blur" label="Saving">
  <ProgressCircular size="lg" />
</Overlay>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaOverlay(
  open: saving,
  tone: NebaOverlayTone.blur,
  label: 'Saving',
  child: const NebaProgressCircular(size: NebaSize.lg),
);
```

:::

## Props

<PropsTable name="Overlay" />

::: fw react

Native `<div>` attributes pass through to the sheet. Only `color` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

There is no `color`. In React it sets the colour slots whatever is on the overlay reads; a Flutter widget takes no colour from the widgets around it, so it would reach nothing, and what sits on the overlay takes its own `color`. The overlay opens into the app's root `Overlay`, which a `WidgetsApp` with a navigator already has; an app built without one wraps its home in `Overlay.wrap`. It is built where it was written, so it keeps the theme and the `NebaProvider` defaults from there, and what is on it is held clear of the system's insets and the keyboard.

:::

An Overlay has no surface, no border, no title and no actions. If there is a decision to make, use [Dialog](./dialog) instead.

## Examples

### tone

Four steps deciding how legible the page behind stays.

| tone | The page behind |
| --- | --- |
| `scrim` | Stays readable; only interaction is blocked. Same value as [Dialog](./dialog)'s backdrop, so the two never show a seam. |
| `blur` | Present as shape and colour, gone as words. For content being replaced. |
| `solid` | Hidden entirely, covered opaquely in the page surface colour. |
| `clear` | Nothing is drawn; only the pointer is blocked. |

<Demo src="overlay/tones" frameMinHeight="260">

::: fw react

<<< @/.vitepress/demos/overlay/tones.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/tones.dart

:::

</Demo>

### dismissible

Off by default, which is the other way round from [Dialog](./dialog). An Overlay is not asking for an answer, it is saying wait, so Escape and a <Fw react="click" flutter="press" /> on the scrim are both refused. Turn it on for an overlay whose job is to catch a <Fw react="click" flutter="press" /> outside something.

<Demo src="overlay/dismissible" frameMinHeight="300">

::: fw react

<<< @/.vitepress/demos/overlay/dismissible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/dismissible.dart

:::

</Demo>

### modal

<Fw react="`modal={'trap-focus'}`" flutter="`modal: NebaModal.trapFocus`" /> leaves the page <Fw react="scrollable and clickable" flutter="pressable" /> while holding focus inside the overlay. The scrim lets the pointer through as well, so the `clear` tone, whose only job is to block the pointer, blocks nothing with it.

## Accessibility

::: fw react

- Renders with `role="dialog"`, and `label` is its accessible name. `label` defaults to the locale's word for "Loading", because an overlay holding only a spinner, or a `clear` one, still has to say what it is. Pass `label` when the overlay means something else.
- The portal, the scroll lock, focus held inside, the page behind going inert, and focus returning on close are all handled.
- The entrance animates opacity only.
- `locale` decides the overlay's accessible name; `label` writes it out instead.

:::

::: fw flutter

- It is a dialog that scopes the route, and `label` is its name. `label` defaults to the locale's word for "Loading", because an overlay holding only a spinner, or a `clear` one, still has to say what it is. Pass `label` when the overlay means something else.
- The focus is held inside while it is up and goes back to what had it when it closes, and a screen reader reads only the overlay.
- The entrance animates opacity only.
- `locale` decides the overlay's name; `label` writes it out instead.

:::
