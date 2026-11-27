---
title: AnimateScramble
order: 9
flutter: true
---

# AnimateScramble

<p class="neba-lede">Text arriving through noise, one character at a time. AnimateTyping's sibling: a typewriter reveals a string from an empty line, this one resolves it out of a line that was already the right length.</p>

<Demo src="animate-scramble/hero" minHeight="120" />

::: fw react

```tsx
import { AnimateScramble } from 'neba';

<AnimateScramble text="RESOLVING SIGNAL" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateScramble(text: 'RESOLVING SIGNAL');
```

:::

## Props

<PropsTable name="AnimateScramble" />

::: fw react

Every other `<span>` attribute passes through to the root. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

It takes the line as `text`, set in `style` over the `DefaultTextStyle` around it and aligned by `textAlign`; there is no `locale`, since the line is cut into characters the same way on every platform. The settings shared by every `Animate*` are defined in [prop conventions](../../design/prop-conventions).

:::

The box is laid out from the final text, so it holds its size while the noise settles. Nothing around it reflows, and a heading does not push the page down as it lands. Each word's noise is drawn over the word it settles into, so the line breaks where the finished line breaks. In a proportional font a word's noise can be wider than the word for a moment, and is cut off at the word's end rather than moving anything.

Whitespace is never scrambled. A space that flickered into a letter and back would read as the words having moved, which is the one thing this effect exists to avoid.

## Examples

### speed, duration and tick

`speed` is how many characters settle per second; `duration` is the whole run and wins when it is given, so the per-character delay falls out of it rather than being asked for twice. `tick` is how often an unsettled character is redrawn: below about 30 milliseconds it stops reading as characters at all.

<Demo src="animate-scramble/pool" minHeight="240">

::: fw react

<<< @/.vitepress/demos/animate-scramble/pool.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_scramble/pool.dart

:::

</Demo>

### characters

The pool an unsettled character is drawn from. Keep the glyphs one height: a pool with tall and short characters in it makes the line jump as it settles.

## Accessibility

- <Fw react="The finished string is in the document from the first frame, in a clipped box for a screen reader; the noise is a visible copy that is `aria-hidden`." flutter="A screen reader is told the finished string from the first frame, and the noise is left out of the semantics tree." />
- <Fw react="The noise is drawn rather than written into the document, so the element's text is the finished string once, with none of the noise in it." flutter="The noise is drawn and never read, so what a screen reader hears is the finished string once, with none of the noise in it." />
- A reduced-motion preference shows the text straight away, including before a `trigger` has fired.
- Do not scramble something a reader has to act on quickly. It is legible only at the end.
