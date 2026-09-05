---
title: NumberField
order: 13
---

# NumberField

<p class="neba-lede">A field that only takes a number, with steppers to nudge the value, range clamping and formatted display.</p>

<Demo src="number-field/hero" />

```tsx
import { NumberField } from 'neba';

<NumberField label="Seats" defaultValue={3} min={1} max={20} />;
```

## Props

<PropsTable name="NumberField" />

Native `<div>` attributes pass through to the root. Only `color` and `defaultValue` are excluded, since the table above spells them differently.

`value` is a `number | null`, where `null` means empty. It is never a string you have to parse.

The shell is identical to [TextField](./text-field)'s, so a field of the same `size` lines up beside it.

## Examples

### steppers

`end` groups the increment and decrement buttons at the right of the field. `split` puts the minus and the plus on either side of the number, for a quantity that is nudged rather than typed. `none` drops the buttons and leaves keyboard input.

<Demo src="number-field/steppers">

<<< @/.vitepress/demos/number-field/steppers.tsx

</Demo>

### step · largeStep · smallStep

The arrow keys move by `step`, Shift by `largeStep` and Alt by `smallStep`. `snapOnStep` rounds the result to a multiple of `step`.

`allowWheelScrub` is off by default. Turning it on lets the wheel change the value, at the cost of sharing a gesture with the page's scroll.

### format and locale

`format` is `Intl.NumberFormatOptions`. The field can show `$1,240` or `7.5%` while `value` stays `1240` and `0.075`.

<Demo src="number-field/format">

<<< @/.vitepress/demos/number-field/format.tsx

</Demo>

### variant

<Demo src="number-field/variants">

<<< @/.vitepress/demos/number-field/variants.tsx

</Demo>

### size

The steppers are sized in `em`, so they track the number. The field lines up with a [Button](./button), [TextField](./text-field) or [Select](./select) of the same `size`.

<Demo src="number-field/sizes">

<<< @/.vitepress/demos/number-field/sizes.tsx

</Demo>

### disabled · readOnly · error

`readOnly` removes the steppers rather than leaving them disabled. The number stays selectable so it can be copied out.

<Demo src="number-field/states">

<<< @/.vitepress/demos/number-field/states.tsx

</Demo>

### shortcuts

`shortcuts` maps a key combination to what it does, written the way [Shortcut](../display/shortcut) draws it. `Mod` is Command on a Mac and Control everywhere else, and the modifiers are matched exactly: `Enter` and `Mod+Enter` never both fire.

```tsx
<NumberField label="Quantity" shortcuts={{ Enter: commit }} />
```

It is bound to the `<input>` rather than to the root, which is what makes it worth having here: `className` and a plain `onKeyDown` both land on the column holding the label and the two lines under it, so their `currentTarget` is not the field.

Nothing is prevented for you. A shortcut on `ArrowUp` fires _and_ the field still steps; call `preventDefault` in the handler if it should not.

### classNames

`className` lands on the root (the column holding the label, the shell and the two lines under it), so the `<input>` is reached through `classNames.control`.

```tsx
<NumberField label="Seats" classNames={{ control: 'text-right', stepper: 'rounded-none' }} />
```

The slots are `label`, `shell`, `control`, `description`, `error` and `stepper`. `stepper` is both buttons rather than one each: a pair of steppers that do not match is not a thing anyone is building. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

## Accessibility

- The visible control is a text input with `inputmode="numeric"` and an `aria-roledescription`; beside it a hidden `<input type="number">` holds `min`, `max` and `step` and handles form submission and browser validation. Keeping the two apart is what lets the visible field show `$1,240`.
- `label` becomes the accessible name; the steppers are named by `incrementLabel` and `decrementLabel`.
- The steppers stay out of the tab order, because the arrow keys on the field do the same job.
- A stepper that has reached `min` or `max` becomes `disabled`.
- `locale` names the two steppers, so a plain BCP 47 string keeps the digits and the buttons in one language.
