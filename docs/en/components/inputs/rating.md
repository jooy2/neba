---
title: Rating
order: 21
---

# Rating

<p class="neba-lede">A score, as a row of stars. Left choosable it is a radio group; set to <code>readOnly</code> it becomes a single picture reporting an average.</p>

<Demo src="rating/hero" />

```tsx
import { Rating } from 'neba';

<Rating defaultValue={4} />;
```

## Props

<PropsTable name="Rating" />

Every other `<div>` attribute passes through to the root, except `onChange`: the change worth listening for is `onValueChange`.

The shared axes (`size` `color`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### count, precision

`count` is how many stars there are and therefore the highest score. `precision` is the smallest step that can be chosen: at `0.5` each star is split into two hit areas and half stars can be picked.

`precision` bounds what can be **chosen** and nothing else. A `value` of `4.3` is drawn as four stars and a third at every precision: an average is not a choice, and rounding it to the nearest half would be reporting a different number from the one it was handed.

<Demo src="rating/precision">

<<< @/.vitepress/demos/rating/precision.tsx

</Demo>

### readOnly

`readOnly` is a picture rather than a control. No inputs are rendered at all and one `role="img"` carries the score as a sentence, so a star display never leaves twenty tab stops on a page that was reporting a number.

It is also the one `readOnly` in the library that does not drain the saturation: this is not a control being held still, it is the value itself, and a row of grey stars would say the score was unavailable.

<Demo src="rating/readonly">

<<< @/.vitepress/demos/rating/readonly.tsx

</Demo>

### size, color

`size` takes the height of one star from the standalone-glyph ladder. `color` is the one place in the library where the default is `warning`: the amber a star is expected to be.

<Demo src="rating/appearance">

<<< @/.vitepress/demos/rating/appearance.tsx

</Demo>

### icon, emptyIcon

Both glyphs can be replaced. The filled copy is laid over the empty one and clipped to a percentage of the width, so the two have to be the **same shape** for a half star to land on the outline underneath it.

<Demo src="rating/icons">

<<< @/.vitepress/demos/rating/icons.tsx

</Demo>

### clearable, disabled

Choosing the star that is already chosen clears the score back to `0`. `clearable={false}` stops that.

<Demo src="rating/states">

<<< @/.vitepress/demos/rating/states.tsx

</Demo>

### locale, label, valueLabel

The only words this component invents are its accessible names, and `locale` decides their language. It takes a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`; unsupported tags fall back to English. `label` names the group and `valueLabel` writes both one star's name and the read-only sentence.

```tsx
<Rating locale="ko" />
<Rating label="How was the order?" valueLabel={(value, count) => `${value}/${count} stars`} />
```

### In a form

Give it a `name` and the radios are submitted under it. `required` stops the form until a star has been chosen.

```tsx
<form>
  <Rating name="score" required />
</form>
```

## Accessibility

- A choosable Rating is a `role="radiogroup"` built out of real `<input type="radio">`s: one tab stop for the row, arrow keys within it, `aria-checked` on the one that is taken, and a value in a form submission.
- Each star is read out as "3 out of 5" rather than as "3 stars", because a count of stars is a plural in most languages and a fraction in none of them.
- `readOnly` removes every input and leaves a single `role="img"`.
- Set `locale` so the names are read in the page's language, or write them yourself with `label` and `valueLabel`.
