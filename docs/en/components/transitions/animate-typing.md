---
title: AnimateTyping
order: 9
flutter: true
---

# AnimateTyping

<p class="neba-lede">Text appearing one character at a time. The whole string is in the document from the first frame for a screen reader, and what animates is a copy that is hidden from one.</p>

<Demo src="animate-typing/hero" />

::: fw react

```tsx
import { AnimateTyping } from 'neba';

<AnimateTyping speed={18}>Ship the interface, not the design system.</AnimateTyping>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateTyping(text: 'Ship the interface, not the design system.', speed: 18);
```

:::

## Props

<PropsTable name="AnimateTyping" />

::: fw react

Every other `<span>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

Only text is typed. Pass a string, or strings; an element among the children contributes its text and nothing about its markup, because there is no honest way to reveal half of a link. `text` is the same thing as a prop, and wins when both are given.

:::

::: fw flutter

It takes the line as `text`, set in `style` over the `DefaultTextStyle` around it and aligned by `textAlign`. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

:::

## Examples

### speed

Characters per second. A speed rather than a duration, because a long line and a short one should be typed at the same pace rather than in the same time: though `duration` is still accepted, and means the time for the whole string.

<Demo src="animate-typing/speed">

::: fw react

<<< @/.vitepress/demos/animate-typing/speed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/speed.dart

:::

</Demo>

### repeat, hold and erase

`repeat` is how many passes it makes and `hold` is how long the finished text stays up between them. Without `erase` a repeat clears in one frame, which is right for a line being replaced; with it the text is deleted a character at a time, at `eraseSpeed`: twice `speed` by default, which is what a person actually does.

<Demo src="animate-typing/loop">

::: fw react

<<< @/.vitepress/demos/animate-typing/loop.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/loop.dart

:::

</Demo>

### delay

<Fw react="Milliseconds before it starts." flutter="How long it waits before the first character." /> A delay per line is what turns a stack of typewriters into a transcript.

<Demo src="animate-typing/terminal">

::: fw react

<<< @/.vitepress/demos/animate-typing/terminal.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/terminal.dart

:::

</Demo>

### caret

::: fw react

The block after the text, on by default. `caretChar` is what it is drawn as: `▌`, `_`, anything. A string is drawn without becoming part of the element's text; an element is rendered as given.

```tsx
<AnimateTyping caretChar="▌" caret={false}>
  No caret at all
</AnimateTyping>
```

:::

::: fw flutter

The block after the text, on by default. `caretChar` is the widget it is drawn as: a `|` in the text's own style unless it says, or a `Text('_')`, or a box of your own, as the speed example draws one.

```dart
const NebaAnimateTyping(text: 'No caret at all', caret: false);
```

:::

## Accessibility

- <Fw react="The full text is in the document from the first frame, in a clipped box, and the animated copy is `aria-hidden`." flutter="A screen reader is told the full text from the first frame, and the typed copy is left out of the semantics tree." /> A screen reader reads the line once and is not made to sit through the performance.
- <Fw react="What has been typed and the caret are drawn rather than written into the document, so the element's text is the line once, with no caret on the end." flutter="The caret is drawn and never read, so what a screen reader hears is the line with no caret on the end." />
- A reduced-motion preference shows the whole string immediately, with no typing at all.
- The caret keeps blinking after the line has been typed, for as long as it is on the page, and `paused` does not reach it. Pass <Fw react="`caret={false}`" flutter="`caret: false`" /> where the line sits beside text a reader is working through.
- The box is laid out from the whole string from the first frame, so the text around it does not reflow as the line types.
- Characters are counted as graphemes, not code points: `한` and `👩‍👩‍👧` each arrive in one step rather than in three or seven.
