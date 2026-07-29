---
title: Button
order: 1
---

# Button

<p class="neba-lede">A control that runs an action. Use it for anything the user deliberately triggers — submitting a form, saving, deleting.</p>

<Demo src="button/hero" />

```tsx
import { Button } from 'neba';

<Button onClick={save}>Save</Button>;
```

## Props

<PropsTable name="Button" />

Every native `<button>` attribute passes straight through. The one exception is `color`, omitted because it collides with the `color` in the table above.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

`solid` is the primary action, `outline` a secondary one, `text` a low-weight action for a list or a toolbar. Keep one `solid` per screen.

<Demo src="button/variants">

<<< @/.vitepress/demos/button/variants.tsx

</Demo>

### color

Six role colours only; arbitrary colour values are not accepted.

<Demo src="button/colors">

<<< @/.vitepress/demos/button/colors.tsx

</Demo>

### size

Sets the height and the type scale together: `xs` 22px · `sm` 26px · `md` 32px · `lg` 40px · `xl` 48px. `md` is the desktop default.

<Demo src="button/sizes">

<<< @/.vitepress/demos/button/sizes.tsx

</Demo>

### density

`density` changes horizontal padding and nothing else. Two buttons of the same `size` are the same height whatever their density, so a mixed row keeps its baseline.

<Demo src="button/density">

<<< @/.vitepress/demos/button/density.tsx

</Demo>

### startIcon and endIcon

Icons are drawn at `1.2em`, so they track the label and never need a size of their own. With icons but no `children` the button goes square, and then it needs an `aria-label` — for an icon-only control, [IconButton](./icon-button) requires `label` instead.

<Demo src="button/icons">

<<< @/.vitepress/demos/button/icons.tsx

</Demo>

### loading · readOnly · disabled

| prop       | Appearance                                      | Focus | Native `disabled` |
| ---------- | ----------------------------------------------- | ----- | ----------------- |
| `loading`  | Unchanged; a spinner takes the `startIcon` slot | Kept  | No                |
| `readOnly` | Keeps its colour, goes flat, drains saturation  | Kept  | No                |
| `disabled` | Drops the colour family for neutral grey        | Lost  | Yes               |

None of the three let a click reach the parent.

<Demo src="button/states">

<<< @/.vitepress/demos/button/states.tsx

</Demo>

### elevation

Drop shadow depth. The default `0` means no shadow at all. Hovering adds a level and pressing removes one, so even a `0` button answers a press.

<Demo src="button/elevation">

<<< @/.vitepress/demos/button/elevation.tsx

</Demo>

### fullWidth

Stretches to the width of the container.

<Demo src="button/full-width">

<<< @/.vitepress/demos/button/full-width.tsx

</Demo>

## Accessibility

- Always renders a native `<button>`. `type` passes through, so `type="submit"` works inside a form.
- Give icon-only buttons an `aria-label`.
- The focus ring only appears on `:focus-visible`, so a mouse click never draws one.
- `loading` and `readOnly` keep focus: dropping out of the tab order costs keyboard users their sense of the page.
- Every colour combination meets 4.5:1 for text on the fill.
