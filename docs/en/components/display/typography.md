---
title: Typography
order: 1
---

# Typography

<p class="neba-lede">The library's type scale on its own. Until now it only existed inside the components that happened to need it — a Card's title, a TextField's label.</p>

<Demo src="typography/hero" />

```tsx
import { Typography } from 'neba';

<Typography level="h2">A sheet of cut acrylic</Typography>
<Typography>Every surface is the same material at a different opacity.</Typography>;
```

## Props

<PropsTable name="Typography" />

### Two deliberate deviations

**It is `level`, not `variant`.** In this library `variant` means the weight of a _surface_ — `solid` / `outline` / `text` — and a second meaning for the same word is exactly what the [prop conventions](../../guide/prop-conventions) forbid.

**`color` has no default.** Every other component defaults to `primary`. Here that would make all body text blue: the common case for a paragraph is to look like the paragraphs around it, so an unset `color` means "inherit the page".

## Examples

### The scale

`body` sits on Card's body ladder at `md`, so a paragraph inside a card and a standalone one are the same text. The headings step up from there, and the leading tightens as they grow — a 30px line does not want the same ratio a 13px one does.

<Demo src="typography/scale">

<<< @/.vitepress/demos/typography/scale.tsx

</Demo>

### Colour

<Demo src="typography/colors">

<<< @/.vitepress/demos/typography/colors.tsx

</Demo>

### Clamping

One line is a truncation with an ellipsis; more than one is a line clamp. Both are `lines`.

<Demo src="typography/clamp">

<<< @/.vitepress/demos/typography/clamp.tsx

</Demo>

### Scale without the element

`level` sets the type scale _and_ the element, which is the common case. When they have to differ — a subheading that should not enter the document outline, or a `<p>` that has to look like an `h3` — `render` breaks the tie.

```tsx
<Typography level="h3" render={<p />}>
  Looks like a heading, is not one
</Typography>
```

## No margins by default

`gutter` is off. A library component that injects margins is one a layout has to fight; turn it on for a run of prose and leave it off inside a flex column that already owns its spacing.
