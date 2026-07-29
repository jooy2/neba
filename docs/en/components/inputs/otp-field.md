---
title: OtpField
order: 20
---

# OtpField

<p class="neba-lede">A row of one-character slots for a short code typed in from somewhere else. Use it for a PIN, a texted verification code, or an invite key.</p>

<Demo src="otp-field/hero" />

```tsx
import { OtpField } from 'neba';

<OtpField label="Verification code" length={6} groupSize={3} onComplete={(code) => verify(code)} />;
```

## Props

<PropsTable name="OtpField" />

Every other `<div>` attribute passes through to the row of slots. `color`, `size` and `onChange` are excluded: the first two are Neba props, and the value is reported by `onValueChange`. The shared axes are in [prop conventions](../../design/prop-conventions).

## Examples

### charset

`charset` decides what may be typed. Characters outside it are dropped rather than shown, and `onValueInvalid` reports the text they came in on. `numeric` also puts a number pad in front of a phone; `any` accepts whatever the keyboard produces.

<Demo src="otp-field/charsets">

<<< @/.vitepress/demos/otp-field/charsets.tsx

</Demo>

### length and groupSize

`length` is how many characters the code has, clamped to 2–12. `groupSize` splits the row every N slots with a `separator`, which is an en dash unless something else is passed.

<Demo src="otp-field/lengths">

<<< @/.vitepress/demos/otp-field/lengths.tsx

</Demo>

### mask, error, readOnly and disabled

`mask` hides the characters. `error` shows a message and re-points the colour family at `danger`, and `invalid` does the same without a message. `readOnly` keeps the code selectable; `disabled` stops every slot answering.

<Demo src="otp-field/states">

<<< @/.vitepress/demos/otp-field/states.tsx

</Demo>

### size

<Demo src="otp-field/sizes">

<<< @/.vitepress/demos/otp-field/sizes.tsx

</Demo>

### In a form

`name` puts the whole value on the form under that name. `autoSubmit` submits the owning form the moment the code is complete, which is the shape a one-field verification screen wants.

```tsx
<form action={verify}>
  <OtpField name="code" length={6} required autoSubmit />
</form>
```

## Accessibility

- Typing moves to the next slot, Backspace steps back over the previous character, and the arrow keys walk the row.
- Pasting a code spreads it across the slots from wherever the caret is, however it was pasted.
- Clicking lands on the first empty slot rather than on the one under the pointer, so a half-typed code cannot be edited into a gap.
- A clipped input carries the whole value for the form and for a phone's autofill; `autocomplete="one-time-code"` is on it already.
- `label`, `description` and `error` are wired to the slots, so all three are announced with the field.
