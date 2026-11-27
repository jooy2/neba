---
title: AnimateHeadline
order: 9
flutter: true
---

# AnimateHeadline

<p class="neba-lede">One line replacing the one above it, on a timer. Every line sits in the same grid cell, so the box is as tall as the longest of them from the first frame and never resizes as the reel turns.</p>

<Demo src="animate-headline/hero" />

::: fw react

```tsx
import { AnimateHeadline } from 'neba';

<AnimateHeadline interval={2000}>
  <span>faster</span>
  <span>quieter</span>
  <span>yours</span>
</AnimateHeadline>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateHeadline(
  interval: Duration(milliseconds: 2000),
  children: <Widget>[Text('faster'), Text('quieter'), Text('yours')],
);
```

:::

## Props

<PropsTable name="AnimateHeadline" />

<Fw react="Every other `<span>` attribute passes through to the root." flutter="Every one of `children` is laid out in the same place, the ones not showing kept unseen, and the box clips the line coming up and the one leaving. `rise` is in logical pixels, and one line's own height when it is left out." /> The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

## Examples

### interval and duration

`interval` is how long a line is held, counted from the moment it arrives rather than from the start of the cycle, so raising `duration`, the length of the transition itself, does not quietly eat the reading time.

<Demo src="animate-headline/breaking">

::: fw react

<<< @/.vitepress/demos/animate-headline/breaking.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_headline/breaking.dart

:::

</Demo>

### Controlled

Pass `index` and the reel stops turning on its own: it becomes a way of moving between lines that something else decides. A step in a form, a tab, a timer of your own. `onIndexChange` reports the line that has just come up.

<Demo src="animate-headline/controlled">

::: fw react

<<< @/.vitepress/demos/animate-headline/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_headline/controlled.dart

:::

</Demo>

### loop and rise

`loop` off stops the reel on the last line and leaves it there. `rise` is how far a line travels as it comes up or leaves: <Fw react="`'100%'`, the default, is one line's own height" flutter="left out, it is one line's own height" />, and a smaller value is a nudge rather than a replacement.

::: fw react

```tsx
<AnimateHeadline loop={false} rise="0.4rem">
  <span>Uploading…</span>
  <span>Processing…</span>
  <span>Done</span>
</AnimateHeadline>
```

:::

::: fw flutter

```dart
const NebaAnimateHeadline(
  loop: false,
  rise: 6,
  children: <Widget>[Text('Uploading…'), Text('Processing…'), Text('Done')],
);
```

:::

## Accessibility

- Only the line that is showing is <Fw react="on the accessibility tree; the others are `visibility: hidden`" flutter="in the semantics tree; the others are hidden" />, which keeps their space without putting them in the reading order.
- <Fw react="Every line is in the document with a space between it and the next, so the element's text reads `faster quieter yours` rather than one run-together word." flutter="A line on its way out is left out of the semantics tree as soon as the next one comes up." />
- Nothing is announced when the reel turns. This is deliberate (a live region cycling every two seconds is unusable), and it is why the component is for a set of phrases where any one of them would have done, not for content a reader has to see.
- A reduced-motion preference stops the reel turning on its own: it stays on the line it is showing. A controlled `index` still changes the line, which then arrives rather than slides.
- Otherwise it keeps changing past five seconds, so the page needs a way to stop it: put a pause button beside it and bind its state to `paused`.
