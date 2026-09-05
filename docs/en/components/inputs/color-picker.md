---
title: ColorPicker
order: 9
---

# ColorPicker

<p class="neba-lede">A colour chosen by eye: a saturation square with a hue rail beside it, an optional opacity rail, a field for typing a value in, and a grid of ready-made swatches. It reads and writes hex, <code>rgb()</code> and <code>hsl()</code>, and adds no dependency to your bundle.</p>

<Demo src="color-picker/hero" />

```tsx
import { ColorPicker } from 'neba';

const [color, setColor] = useState('#1a58d1');

<ColorPicker value={color} onValueChange={setColor} />;
```

## Props

<PropsTable name="ColorPicker" />

Every other `<div>` attribute passes through to the root, except `onChange` — the change worth listening for is `onValueChange`.

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions). Note that `color` is the family of the control's own edge and focus ring; it has nothing to do with the colour being chosen.

## Examples

### inline

By default the panel lives in a popup hanging off a trigger, which is what a form wants. `inline` draws the panel straight into the page with no trigger at all — for a settings pane, a toolbar, or anywhere the picker is the point of the screen rather than one field on it.

<Demo src="color-picker/inline">

<<< @/.vitepress/demos/color-picker/inline.tsx

</Demo>

### format

`format` decides the notation the value comes back in: `hex` (the default), `rgb` or `hsl`. It only affects what is written out — a `value` in any of the three is read correctly whatever `format` says.

<Demo src="color-picker/format">

<<< @/.vitepress/demos/color-picker/format.tsx

</Demo>

### alpha

`alpha` adds an opacity rail under the hue rail and lets the value carry a fourth channel: `#rrggbbaa`, `rgba()` or `hsla()`. Without it the value is always opaque, so a caller who never asked for opacity never sees a fourth argument come out.

<Demo src="color-picker/alpha">

<<< @/.vitepress/demos/color-picker/alpha.tsx

</Demo>

### swatches

`swatches` takes an array of CSS colour strings and replaces the built-in set — the place to put the handful of colours a product actually uses. `swatches={false}` draws none, and `editable={false}` drops the text field, which together leave the panel as nothing but the square and the rails.

<Demo src="color-picker/swatches">

<<< @/.vitepress/demos/color-picker/swatches.tsx

</Demo>

### In a form

`label`, `description` and `error` are the same three slots every field in the library takes, and `name` submits the value with the form. `clearable` offers the × that empties the control, after which the value is an empty string.

<Demo src="color-picker/field">

<<< @/.vitepress/demos/color-picker/field.tsx

</Demo>

### size

`size` sets the trigger's height on the shared ladder and the panel's own width with it, so a picker lines up with the fields beside it at every step.

<Demo src="color-picker/sizes">

<<< @/.vitepress/demos/color-picker/sizes.tsx

</Demo>

### Controlled

Pass `value` and the picker stops keeping state of its own. `open` and `onOpenChange` do the same for the popup.

```tsx
const [color, setColor] = useState('#1a58d1');

<ColorPicker value={color} onValueChange={setColor} />;
```

### The colour strings it reads

Hex in all four lengths (`#abc`, `#abcd`, `#aabbcc`, `#aabbccdd`), `rgb()`/`rgba()` and `hsl()`/`hsla()`, in both the comma and the space syntax. Named colours and `color()` are not: a picker has to be able to write back every value it can read, and there is no point on the panel that means `rebeccapurple`. A string it cannot read leaves the panel where it was.

## Accessibility

- The square and each rail are `role="slider"` with an accessible name, a value and arrow-key support. Arrows move by one step; hold shift for ten.
- The square reports both axes through `aria-valuetext`, since one `aria-valuenow` cannot describe a point in two dimensions.
- Every swatch is a real button named with its own colour, and the chosen one carries `aria-pressed`. Its tick is drawn in black or white depending on which can be read on that colour.
- Set `locale` so the names of the square, the rails and the field are read out in the page's own language, or write them yourself with `labels`.
- `disabled` and `readOnly` both take the panel out of the tab order and stop it answering to the pointer and the keyboard.
