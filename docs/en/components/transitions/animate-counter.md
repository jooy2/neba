---
title: AnimateCounter
order: 9
flutter: true
---

# AnimateCounter

<p class="neba-lede">A number counted up to its value. The one animation in the library whose subject is the content rather than the box around it: a value being interpolated and formatted on every frame, which is not something a keyframe can do.</p>

<Demo src="animate-counter/hero" minHeight="140" />

::: fw react

```tsx
import { AnimateCounter, Statistic } from 'neba';

<Statistic label="Monthly active" value={<AnimateCounter value={128400} />} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaStatistic(
  label: Text('Monthly active'),
  value: NebaAnimateCounter(value: 128400),
);
```

:::

## Props

<PropsTable name="AnimateCounter" />

<Fw react="Every other `<span>` attribute passes through to the root." flutter="The number is set in `style` over the `DefaultTextStyle` around it." /> It has no <Fw react="`easing`" flutter="`curve`" />, `repeat` or `alternate`: a number may only ever approach its value from one side, so the curve is a fixed ease-out and there is no version of a count that loops.

It pairs with [Statistic](../charts/statistic), whose `value` takes <Fw react="a node" flutter="a widget" /> for exactly this. A dashboard that draws its numbers instantly and animates everything around them has the emphasis backwards.

## Examples

### <Fw react="format and locale" flutter="format" />

::: fw react

`Intl.NumberFormat` options, so a currency, a percentage or a compact `1.2M` is a prop rather than a `format` callback: the same prop [Statistic](../charts/statistic) and the progress indicators take. While it counts, the number keeps the decimal places of `value` or `from`, whichever has more, so a count to a whole number shows only whole numbers, and every figure is set at the same width. The box is as wide as the wider of `value` and `from` from the first frame, so the words after it stay where they are while it gains digits. A counter with no `locale` writes its number in the language of wherever it renders, so on a server-rendered page pass `locale`, or the server's `1,234.5` and the reader's `1.234,5` may disagree when the page hydrates.

:::

::: fw flutter

A function from the number to the string it is written as, because the widgets layer has no `Intl.NumberFormat`: left out, the thousands are grouped and there are at most three digits after the point, as the React package writes a number in English, and a currency, a percentage or a compact `128K` is a function of your own, as in the example. While it counts, the number handed to it keeps the decimal places of `value` or `from`, whichever has more, so a count to a whole number shows only whole numbers, and every figure is set at the same width. The box is as wide as the wider of `value` and `from` from the first frame, so the words after it stay where they are while it gains digits.

:::

<Demo src="animate-counter/formats" minHeight="240">

::: fw react

<<< @/.vitepress/demos/animate-counter/formats.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_counter/formats.dart

:::

</Demo>

### trigger

<Fw react='`trigger="visible"`' flutter="`NebaAnimateTrigger.visible`" /> is the one worth reaching for on a dashboard below the fold: a count that has already finished by the time it is scrolled to has not been seen. Before it starts, the number sits at `from` rather than at its answer. Once it has counted, a new `value` counts on from the number on screen. With <Fw react='`trigger="manual"`' flutter="`NebaAnimateTrigger.manual`" />, `play` starts the count, and a `play` that goes up counts it again from `from`: the button above the example does that.

::: fw react

```tsx
<AnimateCounter value={128400} trigger="visible" />
```

:::

::: fw flutter

```dart
const NebaAnimateCounter(value: 128400, trigger: NebaAnimateTrigger.visible);
```

:::

## Accessibility

- <Fw react="The finished number is in the document from the first frame, in a clipped box for a screen reader; what counts is a visible copy that is `aria-hidden`." flutter="A screen reader is told the finished number from the first frame, and the count is left out of the semantics tree." /> A reader who cannot see the count is told the answer rather than a hundred intermediate ones.
- <Fw react="The count is drawn rather than written into the document, so the element's text is the answer once: what a search engine reads, what a copy picks up and what `textContent` returns, on a server-rendered page and after the count alike." flutter="The answer is what a screen reader hears from the start, whatever the count on screen has reached." />
- A reduced-motion preference shows the answer straight away, including before a `trigger` has fired.
