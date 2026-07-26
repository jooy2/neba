---
title: NumberField
order: 13
---

# NumberField

<p class="neba-lede">A field that only holds a number. The shell is a TextField's, to the pixel; what is added is stepping, clamping and formatting.</p>

<Demo src="number-field/hero" />

```tsx
import { NumberField } from 'neba';

<NumberField label="Seats" defaultValue={3} min={1} max={20} />;
```

## Props

<PropsTable name="NumberField" />

### Not `<input type="number">`

The native number input rounds the corners off in different places in every browser, ignores the locale, offers a wheel gesture that fights the page's scroll, and hands you a `string` that is empty when the field holds nonsense. This one keeps the pieces worth keeping and answers each of those:

- `value` is a `number | null`, and `null` means empty. It is never a string you have to parse.
- `format` is `Intl.NumberFormatOptions`, so the field shows `$1,240` or `7.5%` and still reports `1240` and `0.075`.
- The arrow keys step by `step`, Shift by `largeStep` and Alt by `smallStep`.
- The wheel does nothing unless `allowWheelScrub` says otherwise. A page that scrolls under the pointer and a field that changes under it are the same gesture, and only one of them was meant.

## Examples

### Steppers

<Demo src="number-field/steppers">

<<< @/.vitepress/demos/number-field/steppers.tsx

</Demo>

`end` is the spinner everyone has seen. `split` puts the minus and the plus on either side of the number, for a quantity that is nudged rather than typed. `none` drops the buttons and keeps everything else.

There is deliberately no stacked pair of half-height chevrons. At `xs` each arrow would be under three pixels tall, and a target that small is a target nobody hits.

### Formatting

`value` stays a plain number whatever the field is showing.

<Demo src="number-field/format">

<<< @/.vitepress/demos/number-field/format.tsx

</Demo>

### Variants

<Demo src="number-field/variants">

<<< @/.vitepress/demos/number-field/variants.tsx

</Demo>

### Sizes

The steppers are sized in `em`, so they track the number rather than carrying a ladder of their own — and the field lines up with a Button, a TextField and a Select of the same `size`.

<Demo src="number-field/sizes">

<<< @/.vitepress/demos/number-field/sizes.tsx

</Demo>

### States

Read-only takes the steppers away rather than disabling them: a button that is visible and refuses every press is worse than no button. The number stays selectable, because a read-only field is still something you copy out of.

<Demo src="number-field/states">

<<< @/.vitepress/demos/number-field/states.tsx

</Demo>

## Accessibility

- Base UI owns the parsing, the clamping, and the press-and-hold repeat on the steppers.
- What you see is a text input carrying `inputmode="numeric"` and an `aria-roledescription` of _Number field_, not `<input type="number">`. Beside it sits a hidden `<input type="number">` holding `min`, `max` and `step` — that is the one a form submits and the browser validates, and keeping the two apart is what lets the visible field show `$1,240` without the browser refusing to parse it.
- `label` becomes the accessible name; the steppers are named by `incrementLabel` and `decrementLabel` and stay out of the tab order, because the arrow keys on the field itself already do their job.
- A stepper that has run into `min` or `max` is `disabled` — it changes colour family, the way every other inert control in the library does, rather than fading.
