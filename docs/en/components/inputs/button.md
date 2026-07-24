---
title: Button
order: 1
---

# Button

<p class="neba-lede">A control that runs an action. Base UI's Button primitive with Neba's acrylic surface on top of it.</p>

<Demo src="button/hero" />

```tsx
import { Button } from 'neba';

<Button onClick={save}>Save</Button>;
```

## Props

<PropsTable name="Button" />

Every native `<button>` attribute passes straight through. The one exception is `color`, which is omitted because it collides with the `color` in the table above.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [Prop conventions](../../guide/prop-conventions).

## Examples

### Variants

Keep one `solid` per screen. If there are two primary actions, neither of them is the primary action.

<Demo src="button/variants">

<<< @/.vitepress/demos/button/variants.tsx

</Demo>

### Colours

Six roles, and that is all. Arbitrary colour values are not accepted — a colour is a role, not a value.

<Demo src="button/colors">

<<< @/.vitepress/demos/button/colors.tsx

</Demo>

### Sizes

`md` (32px) is the desktop default. `xs` and `sm` are for toolbars and table rows; `lg` and `xl` are for the one action a screen is actually about.

<Demo src="button/sizes">

<<< @/.vitepress/demos/button/sizes.tsx

</Demo>

### Density

`density` changes horizontal padding and nothing else. Two buttons of the same `size` are the same height whatever their density, so a mixed row keeps its baseline.

<Demo src="button/density">

<<< @/.vitepress/demos/button/density.tsx

</Demo>

### Icons

Icons are drawn at `1.2em`, so they track the label and never need a size of their own. Pass no label and the button goes square — which is when it needs an `aria-label`.

<Demo src="button/icons">

<<< @/.vitepress/demos/button/icons.tsx

</Demo>

### States

<Demo src="button/states">

<<< @/.vitepress/demos/button/states.tsx

</Demo>

| State      | Appearance                                      | Focus | Native `disabled` |
| ---------- | ----------------------------------------------- | ----- | ----------------- |
| `loading`  | Unchanged; a spinner takes the `startIcon` slot | Kept  | No                |
| `readOnly` | Keeps its colour, goes flat, drains saturation  | Kept  | No                |
| `disabled` | Drops the colour family for neutral grey        | Lost  | Yes               |

None of the three let a click reach the parent.

### Elevation

The default `0` means no shadow at all — what separates the surface from the page is the acrylic edge. Hovering adds a level and pressing removes one, so a flat button answers a press without moving.

<Demo src="button/elevation">

<<< @/.vitepress/demos/button/elevation.tsx

</Demo>

### Full width

<Demo src="button/full-width">

<<< @/.vitepress/demos/button/full-width.tsx

</Demo>

## Accessibility

- Always renders a native `<button>`. `type` passes through, so `type="submit"` works inside a form.
- Give icon-only buttons an `aria-label`.
- The focus ring only appears on `:focus-visible`, so a mouse click never draws one.
- `loading` and `readOnly` keep focus: dropping out of the focus order costs keyboard users their sense of the page.
- Every colour combination meets 4.5:1 for text on the fill.
