---
title: Typography
order: 1
---

# Typography

<p class="neba-lede">Renders text on the library's type scale, so headings, body copy and captions all share the same size steps.</p>

<Demo src="typography/hero" />

```tsx
import { Typography } from 'neba';

<Typography level="h2">A sheet of cut acrylic</Typography>
<Typography>Every surface is the same material at a different opacity.</Typography>;
```

## Props

<PropsTable name="Typography" />

Two props differ from the rest of the library. The type scale is chosen with `level` rather than `variant`, since `variant` means the weight of a surface everywhere else. And `color` has no default: leave it unset and the text inherits the surrounding colour.

The root carries the class `neba-typography`. It is the hook a stylesheet uses to reach the text from outside React — `.neba-typography { text-wrap: balance }` — since the utilities a level resolves to are not a contract.

## Examples

### level

`level` sets both the type scale and the element rendered. `body` matches the body step of an `md` [Card](../surfaces/card), so a paragraph inside a card and one outside it are the same size. The heading steps tighten their leading as they grow.

<Demo src="typography/scale">

<<< @/.vitepress/demos/typography/scale.tsx

</Demo>

### color

<Demo src="typography/colors">

<<< @/.vitepress/demos/typography/colors.tsx

</Demo>

### lines

`lines={1}` truncates to one line with an ellipsis. `2` or more is a line clamp at that many lines.

<Demo src="typography/clamp">

<<< @/.vitepress/demos/typography/clamp.tsx

</Demo>

### render

Use `render` when the element `level` implies is not the element you need: a subheading that should stay out of the document outline, or a `<p>` that has to look like a heading.

```tsx
<Typography level="h3" render={<p />}>
  Looks like a heading, is not one
</Typography>
```

### gutter

`gutter` is off by default, so there are no vertical margins. Turn it on for a run of prose; leave it off inside a flex container that already owns its spacing.

### Overriding the size

Each level's leading is a **ratio**, not a length, so a size set through `className` keeps a line box in proportion to it:

```tsx
<Typography level="h2" className="text-[2.75rem]!">
  42
</Typography>
```

The `!` is there because a size the component wrote and a size you wrote are both one class, and which of them wins is Tailwind's ordering rather than yours — see [prop conventions](../../design/prop-conventions). Add a `leading-*` beside it when the proportion is what you want to change.
