---
title: Slider
order: 8
flutter: true
---

# Slider

<p class="neba-lede">Picks a value by dragging along a range. Use it where the relative magnitude matters more than the exact number.</p>

<Demo src="slider/hero" />

::: fw react

```tsx
import { Slider } from 'neba';

<Slider label="Volume" defaultValue={65} showValue />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSlider(label: const Text('Volume'), defaultValue: 65, showValue: true);
```

:::

## Props

<PropsTable name="Slider" />

`onValueChange` fires throughout the drag; `onValueCommitted` fires once, when the value settles. Put the network request on the latter.

::: fw flutter

`value` is a `double`, and with `onValueChange` it makes a controlled slider; leave it out and the slider keeps its own value, starting from `defaultValue`. A range is its own constructor, `NebaSlider.range`, which takes `values`, `defaultValues`, `onValuesChange` and `onValuesCommitted` as lists, since Dart has no `number | number[]`. `label` and `description` are widgets, usually a `Text`.

`format` writes a value, for the row `showValue` draws and for what a screen reader hears, so there is no function form of `showValue` and no `locale`. `getAriaLabel` and `getAriaValueText` are `thumbSemanticLabel` and `thumbSemanticValue`, and `semanticLabel` names the thumbs of a slider with no label. There is no `name`, since a Flutter slider has no form to submit it to.

:::

When an exact number has to be typed, use [NumberField](./number-field).

## Examples

### <Fw react="A range from an array value" flutter="A range from a list of values" />

::: fw react

Pass an array of numbers as the `value` and you get that many thumbs: a range slider. There is no separate prop for it.

:::

::: fw flutter

`NebaSlider.range` takes a list of numbers as its `values` and draws that many thumbs: a range slider. With no values it starts from `min` and `max`.

:::

A press on the track moves the nearest thumb there. A thumb dragged past another pushes it along, and a key stops a thumb at its neighbour.

<Demo src="slider/range">

::: fw react

<<< @/.vitepress/demos/slider/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/range.dart

:::

</Demo>

### min · max · step

`step` is the interval the thumb settles on. `showValue` prints the current value beside the label.

::: fw flutter

The arrow keys move a focused thumb by `step`, and Shift with an arrow, Page Up and Page Down by `largeStep`. Home and End take it as far as it can go. Without a `format` a value is grouped by threes, with at most three decimals.

:::

### marks

::: fw react

`marks` names points along the track: `1 / 100 / 250 / 500` under a count, or the two ends of a style axis. Pass an array of `{ value, label? }`, and a mark with no label is a tick on its own. A label is centred on its tick, except at `min` and `max`, where it lines up inward from the tick so that it stays within the length of the track.

`marks` without a value is a tick at every `step`, which is worth pairing with a step you chose — the default `step={1}` over the default range draws a hundred and one of them, and a range of more than a hundred steps draws none at all.

:::

::: fw flutter

`marks` names points along the track: `1 / 100 / 250 / 500` under a count, or the two ends of a style axis. Pass a `NebaSliderMarks` holding a list of `NebaSliderMark(value:, label:)`, and a mark with no label is a tick on its own. A label is centred on its tick, except at `min` and `max`, where it lines up inward from the tick so that it stays within the length of the track.

`NebaSliderMarks.steps` is a tick at every `step`, which is worth pairing with a step you chose — the default `step: 1` over the default range draws a hundred and one of them, and a range of more than a hundred steps draws none at all.

:::

The row is hidden from screen readers: the thumb already announces the value and the range.

<Demo src="slider/marks">

::: fw react

<<< @/.vitepress/demos/slider/marks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/marks.dart

:::

</Demo>

### size

The thumb is drawn larger than the track: it is the part you actually hit, so it needs a real touch target.

<Demo src="slider/sizes">

::: fw react

<<< @/.vitepress/demos/slider/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/sizes.dart

:::

</Demo>

### orientation

::: fw react

A `vertical` slider has no length of its own; give it a height.

:::

::: fw flutter

A `vertical` slider runs up from `min` at the bottom. It takes the height it is given, and 160 pixels where it is given none; put it in a `SizedBox` for a length of its own.

:::

<Demo src="slider/vertical">

::: fw react

<<< @/.vitepress/demos/slider/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/vertical.dart

:::

</Demo>

::: fw react

### classNames

`className` lands on the root — the column holding the label, the strip and the line under it — and the parts inside are reached through `classNames`.

```tsx
<Slider label="Volume" classNames={{ track: 'h-1', thumb: 'rounded-sm', mark: 'font-mono' }} />
```

The slots are `label`, `control`, `track`, `indicator`, `thumb`, `description` and `mark`. `control` is the whole strip a press lands on, which is taller than the `track` drawn inside it.

:::

## Accessibility

::: fw react

- Each thumb is a real `<input type="range">`, so the arrow keys, Home/End and Page Up/Down all work as they should.
- `label` becomes each thumb's accessible name, and `description` describes it. Without a label, give the slider an `aria-label`, which also lands on the thumbs.
- A range slider's thumbs share the label. Name them apart with `getAriaLabel`, and word their values with `getAriaValueText`.
- `showValue` renders an `<output>`, which is announced as the value changes.
- Hovering and dragging draw a ring around the thumb rather than changing its size.

:::

::: fw flutter

- Each thumb is heard as a slider with its value, and takes a screen reader's increase and decrease as a step either way. The arrow keys, Home and End and Page Up and Down move it once it holds the focus.
- `label` becomes each thumb's name, and `description` is read after it. Without a label, give the slider a `semanticLabel`.
- A range slider's thumbs share the label, and each says which end of the range it is. Name them apart with `thumbSemanticLabel`, and word their values with `thumbSemanticValue`; the label is then read as text of its own.
- The row `showValue` draws is not read, since every thumb says its value.
- A press on the track leaves the focus where it was. A press on the label puts it on the thumb of a single slider.
- Hovering and dragging draw a ring around the thumb rather than changing its size.

:::
