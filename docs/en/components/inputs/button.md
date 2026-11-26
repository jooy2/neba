---
title: Button
order: 1
flutter: true
---

# Button

<p class="neba-lede">A control that runs an action. Use it for anything the user deliberately triggers: submitting a form, saving, deleting.</p>

<Demo src="button/hero" />

::: fw react

```tsx
import { Button } from 'neba';

<Button onClick={save}>Save</Button>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaButton(onPressed: save, child: const Text('Save'));
```

:::

## Props

<PropsTable name="Button" />

::: fw react

Every native `<button>` attribute passes straight through. The one exception is `color`, omitted because it collides with the `color` in the table above.

:::

::: fw flutter

The label is `child`, usually a `Text`, and the action is `onPressed`. With no `onPressed` the button is disabled, as every Flutter button is. `semanticLabel` names a button that has only an icon.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

`solid` is the primary action, `outline` a secondary one, `text` a low-weight action for a list or a toolbar. Keep one `solid` per screen.

<Demo src="button/variants">

::: fw react

<<< @/.vitepress/demos/button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/variants.dart

:::

</Demo>

### color

Six role colours only; arbitrary colour values are not accepted.

<Demo src="button/colors">

::: fw react

<<< @/.vitepress/demos/button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/colors.dart

:::

</Demo>

### size

Sets the height and the type scale together: `xs` 22px · `sm` 26px · `md` 32px · `lg` 40px · `xl` 48px. `md` is the desktop default.

<Demo src="button/sizes">

::: fw react

<<< @/.vitepress/demos/button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/sizes.dart

:::

</Demo>

### density

`density` changes horizontal padding and nothing else. Two buttons of the same `size` are the same height whatever their density, so a mixed row keeps its baseline.

<Demo src="button/density">

::: fw react

<<< @/.vitepress/demos/button/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/density.dart

:::

</Demo>

### startIcon and endIcon

::: fw react

Icons are drawn at `1.2em`, so they track the label and never need a size of their own. With icons but no `children` the button goes square, and then it needs an `aria-label`: for an icon-only control, [IconButton](./icon-button) requires `label` instead.

:::

::: fw flutter

Icons are drawn at 1.2 times the label's size, through the `IconTheme` the button hands down, so they track the label and never need a size of their own. With icons but no `child` the button goes square, and then it needs a `semanticLabel`.

:::

<Demo src="button/icons">

::: fw react

<<< @/.vitepress/demos/button/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/icons.dart

:::

</Demo>

### loading · readOnly · disabled

::: fw react

| prop       | Appearance                                      | Focus | Native `disabled` |
| ---------- | ----------------------------------------------- | ----- | ----------------- |
| `loading`  | Unchanged; a spinner takes the `startIcon` slot | Kept  | No                |
| `readOnly` | Keeps its colour, goes flat, drains saturation  | Kept  | No                |
| `disabled` | Drops the colour family for neutral grey        | Lost  | Yes               |

None of the three let a click reach the parent.

:::

::: fw flutter

| Parameter                     | Appearance                                           | Focus |
| ----------------------------- | ---------------------------------------------------- | ----- |
| `loading`                     | Unchanged; a turning ring takes the `startIcon` slot | Kept  |
| `readOnly`                    | Keeps its colour, goes flat, drains saturation       | Kept  |
| `disabled`, or no `onPressed` | Drops the colour family for neutral grey             | Lost  |

None of the three calls `onPressed`.

:::

<Demo src="button/states">

::: fw react

<<< @/.vitepress/demos/button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/states.dart

:::

</Demo>

### elevation

Drop shadow depth. The default `0` means no shadow at all. Hovering adds a level and pressing removes one, so even a `0` button answers a press.

<Demo src="button/elevation">

::: fw react

<<< @/.vitepress/demos/button/elevation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/elevation.dart

:::

</Demo>

### fullWidth

Stretches to the width of the container.

<Demo src="button/full-width">

::: fw react

<<< @/.vitepress/demos/button/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/full_width.dart

:::

</Demo>

### render

::: fw react

Renders something other than a `<button>`. An action that navigates should be an `<a href>`: a crawler follows it, it appears in a screen reader's list of links, and the browser's own behaviour (open in a new tab, copy the address) keeps working. A router's `Link` goes in the same way.

The surface, the sizes and the press signature are unchanged. An `<a>` has no `disabled`, so a button that has to be unavailable stays a `<button>`.

:::

::: fw flutter

There is no element to swap. A button that navigates calls the router from `onPressed`; the surface, the sizes and the press signature are the same either way.

:::

::: fw react

<Demo src="button/render">

<<< @/.vitepress/demos/button/render.tsx

</Demo>

:::

## Accessibility

::: fw react

- Renders a native `<button>` by default. `type` passes through, so `type="submit"` works inside a form.
- Changing the element with `render` keeps that element's semantics: an `<a href>` stays a link rather than being covered by `role="button"`.
- Give icon-only buttons an `aria-label`.
- The focus ring only appears on `:focus-visible`, so a mouse click never draws one.

:::

::: fw flutter

- It is a button to a screen reader, enabled or not, and a tap, Enter and Space all press it.
- Give a button with only an icon a `semanticLabel`.
- The focus ring only appears for keyboard focus, so a tap never draws one.

:::

- `loading` and `readOnly` keep focus: dropping out of the tab order costs keyboard users their sense of the page.
- Every colour combination meets 4.5:1 for text on the fill.
