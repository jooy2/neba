---
title: Rating
order: 21
flutter: true
---

# Rating

<p class="neba-lede">A score, as a row of stars. Left choosable it is a radio group; set to <code>readOnly</code> it becomes a single picture reporting an average.</p>

<Demo src="rating/hero" />

::: fw react

```tsx
import { Rating } from 'neba';

<Rating defaultValue={4} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaRating(defaultValue: 4);
```

:::

## Props

<PropsTable name="Rating" />

::: fw react

Every other `<div>` attribute passes through to the root, except `onChange`: the change worth listening for is `onValueChange`.

:::

::: fw flutter

The rating holds its own score from `defaultValue`, or shows `value` and reports a choice through `onValueChange`.

:::

The shared axes (`size` `color`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### count, precision

`count` is how many stars there are and therefore the highest score. `precision` is the smallest step that can be chosen, and at `0.5` each star is split into two hit areas so half stars can be picked. Each half is narrower than the 24 pixels a finger needs, so keep whole stars where the Rating is pressed on a touch screen.

`precision` bounds what can be **chosen** and nothing else. A `value` of `4.3` is drawn as four stars and a third at every precision.

<Demo src="rating/precision">

::: fw react

<<< @/.vitepress/demos/rating/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/precision.dart

:::

</Demo>

### readOnly

::: fw react

`readOnly` makes it a picture rather than a control. No inputs are rendered at all and one `role="img"` carries the score as a sentence, so the stars take no tab stops. The stars keep their colour rather than draining the saturation.

:::

::: fw flutter

`readOnly` makes it a picture rather than a control: one image node carries the score as a sentence, and the stars take no focus. The stars keep their colour rather than draining the saturation.

:::

<Demo src="rating/readonly">

::: fw react

<<< @/.vitepress/demos/rating/readonly.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/readonly.dart

:::

</Demo>

### size, color

`size` takes the height of one star from the standalone-glyph ladder. `color` defaults to `warning`.

<Demo src="rating/appearance">

::: fw react

<<< @/.vitepress/demos/rating/appearance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/appearance.dart

:::

</Demo>

### icon, emptyIcon

Both glyphs can be replaced. The filled copy is laid over the empty one and clipped to a percentage of the width, so the two have to be the **same shape** for a half star to land on the outline underneath it.

<Demo src="rating/icons">

::: fw react

<<< @/.vitepress/demos/rating/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/icons.dart

:::

</Demo>

### clearable, disabled

Choosing the star that is already chosen clears the score back to `0`. <Fw react='clearable={false}' flutter='clearable: false' code /> stops that.

<Demo src="rating/states">

::: fw react

<<< @/.vitepress/demos/rating/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/states.dart

:::

</Demo>

### locale, <Fw react="label" flutter="semanticLabel" />, valueLabel

::: fw react

The only words this component invents are its accessible names, and `locale` decides their language. It takes a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`; unsupported tags fall back to English. `label` names the group and `valueLabel` writes both one star's name and the read-only sentence.

```tsx
<Rating locale="ko" />
<Rating label="How was the order?" valueLabel={(value, count) => `${value}/${count} stars`} />
```

:::

::: fw flutter

The only words this component invents are what a screen reader hears, and `locale` decides their language. `semanticLabel` names the set and `valueLabel` writes both one star's name and the read-only sentence.

```dart
const NebaRating(locale: Locale('ko'));
NebaRating(
  semanticLabel: 'How was the order?',
  valueLabel: (double value, int count) => '$value/$count stars',
);
```

:::

### In a form

::: fw react

Give it a `name` and the radios are submitted under it. `required` stops the form until a star has been chosen.

```tsx
<form>
  <Rating name="score" required />
</form>
```

:::

::: fw flutter

Flutter has no form submission, so there is no `name` and no `required`: the score is the caller's, from `value` and `onValueChange`.

:::

## Accessibility

::: fw react

- A choosable Rating is a `role="radiogroup"` built out of real `<input type="radio">`s: one tab stop for the row, arrow keys within it, `aria-checked` on the one that is taken, and a value in a form submission.
- Each star is read out as "3 out of 5".
- `readOnly` removes every input and leaves a single `role="img"`.
- On a Rating a reader sets, an empty star clears 3:1 against the page in both themes. A `readOnly` Rating draws its empty stars fainter, as the ghost of the ones beside them.
- Set `locale` so the names are read in the page's language, or write them yourself with `label` and `valueLabel`.

:::

::: fw flutter

- A choosable Rating is a named set of radios: one focus stop for the row, arrow keys within it that move and choose and wrap at the ends, and the one that is taken checked.
- Each star is read out as "3 out of 5".
- `readOnly` leaves a single image node with the score as a sentence.
- On a Rating a reader sets, an empty star clears 3:1 against the page in both themes. A `readOnly` Rating draws its empty stars fainter, as the ghost of the ones beside them.
- Set `locale` so the names are read in the app's language, or write them yourself with `semanticLabel` and `valueLabel`.

:::
