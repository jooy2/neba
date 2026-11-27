---
title: ColorPicker
order: 9
flutter: true
---

# ColorPicker

<p class="neba-lede">A colour chosen by eye: a saturation square with a hue rail beside it, an optional opacity rail, a field for typing a value in, and a grid of ready-made swatches. It reads and writes hex, <code>rgb()</code> and <code>hsl()</code>, and adds no dependency to your bundle.</p>

<Demo src="color-picker/hero" minHeight="380" />

::: fw react

```tsx
import { ColorPicker } from 'neba';

const [color, setColor] = useState('#1a58d1');

<ColorPicker value={color} onValueChange={setColor} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

String color = '#1a58d1';

NebaColorPicker(value: color, onValueChange: (String next) => setState(() => color = next));
```

:::

## Props

<PropsTable name="ColorPicker" />

::: fw react

Every other `<div>` attribute passes through to the root, except `onChange`: the change worth listening for is `onValueChange`.

:::

::: fw flutter

The value is a `String`, and `value` left `null` means the picker keeps its own state from `defaultValue`; an empty string is a picker with nothing chosen. `label`, `description` and `error` are widgets, usually a `Text`, `format` is a `NebaColorFormat`, `locale` is a `Locale`, and `labels` is a `NebaColorPickerLabels` whose fields left `null` keep the locale's words. `semanticLabel`, `focusNode` and `autofocus` name and focus the trigger, as they do on a [Select](./select).

`name` is not there: nothing submits a Flutter form for the picker, so `required` only tells a screen reader that a colour is required. The popup is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s is.

:::

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions). Note that `color` is the family of the control's own edge and focus ring; it has nothing to do with the colour being chosen.

## Examples

### inline

By default the panel lives in a popup hanging off a trigger, which is what a form wants. `inline` draws the panel straight into the page with no trigger at all: for a settings pane, a toolbar, or anywhere the picker is the point of the screen rather than one field on it.

::: fw flutter

An inline `NebaColorPicker` is as wide as its panel, and its label, description and error wrap at that width.

:::

<Demo src="color-picker/inline">

::: fw react

<<< @/.vitepress/demos/color-picker/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/inline.dart

:::

</Demo>

### format

`format` decides the notation the value comes back in: `hex` (the default), `rgb` or `hsl`. It only affects what is written out: a `value` in any of the three is read correctly whatever `format` says.

<Demo src="color-picker/format" minHeight="440">

::: fw react

<<< @/.vitepress/demos/color-picker/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/format.dart

:::

</Demo>

### alpha

`alpha` adds an opacity rail under the hue rail and lets the value carry a fourth channel: `#rrggbbaa`, `rgba()` or `hsla()`. Without it the value is always opaque, so a caller who never asked for opacity never sees a fourth argument come out.

<Demo src="color-picker/alpha" minHeight="420">

::: fw react

<<< @/.vitepress/demos/color-picker/alpha.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/alpha.dart

:::

</Demo>

### swatches

::: fw react

`swatches` takes an array of CSS colour strings and replaces the built-in set: the place to put the handful of colours a product actually uses. `swatches={false}` draws none, and `editable={false}` drops the text field, which together leave the panel as nothing but the square and the rails.

:::

::: fw flutter

`swatches` takes a list of CSS colour strings and replaces the built-in set: the place to put the handful of colours a product actually uses. An empty list draws none, and `editable: false` drops the text field, which together leave the panel as nothing but the square and the rails.

:::

<Demo src="color-picker/swatches">

::: fw react

<<< @/.vitepress/demos/color-picker/swatches.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/swatches.dart

:::

</Demo>

### In a form

::: fw react

`label`, `description` and `error` are the same three slots every field in the library takes, and `name` submits the value with the form. A `disabled` picker submits nothing, and a `required` one that is empty holds the submit back. `clearable` offers the × that empties the control, after which the value is an empty string.

:::

::: fw flutter

`label`, `description` and `error` are the same three slots every field in the library takes. `clearable` offers the × that empties the control, after which the value is an empty string; the trigger keeps the room for it whatever it holds, so it does not widen when a colour arrives.

:::

<Demo src="color-picker/field" minHeight="460">

::: fw react

<<< @/.vitepress/demos/color-picker/field.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/field.dart

:::

</Demo>

### labelPlacement

`notch` puts the label on the trigger's top edge, in a gap cut out of the border, as it does on [TextField](./text-field#labelplacement). The swatch at the start of the trigger is where a `float` label would rest, so `float` draws the same as `notch`. `inline` has no trigger and ignores the prop.

<Demo src="color-picker/label-placement" minHeight="420">

::: fw react

<<< @/.vitepress/demos/color-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/label_placement.dart

:::

</Demo>

### size

`size` sets the trigger's height on the shared ladder and the panel's own width with it, so a picker lines up with the fields beside it at every step.

<Demo src="color-picker/sizes" minHeight="480">

::: fw react

<<< @/.vitepress/demos/color-picker/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/sizes.dart

:::

</Demo>

### Controlled

Pass `value` and the picker stops keeping state of its own. `open` and `onOpenChange` do the same for the popup.

::: fw react

```tsx
const [color, setColor] = useState('#1a58d1');

<ColorPicker value={color} onValueChange={setColor} />;
```

:::

::: fw flutter

```dart
NebaColorPicker(
  value: color,
  onValueChange: (String next) => setState(() => color = next),
  open: open,
  onOpenChange: (bool next) => setState(() => open = next),
);
```

:::

### The colour strings it reads

Hex in all four lengths (`#abc`, `#abcd`, `#aabbcc`, `#aabbccdd`), `rgb()`/`rgba()` and `hsl()`/`hsla()`, in both the comma and the space syntax. Named colours and `color()` are not: a picker has to be able to write back every value it can read, and there is no point on the panel that means `rebeccapurple`. A string it cannot read leaves the panel where it was.

## Accessibility

::: fw react

- The square and each rail are `role="slider"` with an accessible name and a value. On a rail, any arrow moves one step (ten with shift), `Page Up` and `Page Down` move ten, and `Home` and `End` go to the ends. On the square the left and right arrows change saturation and the up and down arrows brightness, `Page Up` and `Page Down` change brightness by ten, and `Home` and `End` take saturation to either end.
- The square reports both axes through `aria-valuetext`, since one `aria-valuenow` cannot describe a point in two dimensions.
- Every swatch is a real button named with its own colour, and the chosen one carries `aria-pressed`. Its tick is drawn in black or white depending on which can be read on that colour.
- Set `locale` so the names of the square, the rails and the field are read out in the page's own language, or write them yourself with `labels`.
- `disabled` and `readOnly` both take the panel, the rails and the swatches out of the tab order and stop them answering to the pointer and the keyboard. `disabled` takes the text field out as well; under `readOnly` it stays in the tab order, read-only, so its value can still be selected and copied.

:::

::: fw flutter

- The trigger is one node to a screen reader: a button named by a `Text` label, which says the colour as its value and is heard as collapsed or expanded. A press, Enter or Space open the panel with the focus on the square; Escape, a press outside or the focus leaving close it and give the focus back to the trigger.
- The square and each rail are sliders of their own, each a stop in the focus order with a name and a value. On a rail, any arrow moves one step (ten with shift), `Page Up` and `Page Down` move ten, and `Home` and `End` go to the ends. On the square the left and right arrows change saturation and the up and down arrows brightness, `Page Up` and `Page Down` change brightness by ten, and `Home` and `End` take saturation to either end. A screen reader's increase and decrease move a rail a step and the square's saturation a point.
- The square's value says both axes, as "Saturation 100%, brightness 90%". The hue reads as a number of degrees with the `°` sign, which a screen reader speaks in its own language, since the widgets layer has no `Intl` to write the word.
- Every swatch is a button named with its own colour, and the chosen one is heard as selected. Its tick is drawn in black or white depending on which can be read on that colour.
- Set `locale` so the names of the square, the rails and the field are read out in the app's own language, or write them yourself with `labels`.
- `disabled` and `readOnly` both take the square, the rails and the swatches out of the focus order and stop them answering to the pointer and the keyboard. `disabled` takes the text field out as well; under `readOnly` it stays in the focus order, read-only, so its value can still be selected and copied.

:::
