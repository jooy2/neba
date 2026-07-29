---
title: Container
order: 1
---

# Container

<p class="neba-lede">Puts horizontal gutters around a page's content and centres it. Keeping content off the edge of the window is its only job.</p>

<Demo src="container/hero" />

```tsx
import { Container } from 'neba';

<Container>Content</Container>;
```

## Props

<PropsTable name="Container" />

Every native `<div>` attribute passes through.

It draws no surface, so there is no `variant`, `color` or `elevation`. Put a [Box](../surfaces/box) or a [Card](../surfaces/card) inside when a sheet is wanted.

It is often used with [Grid](./grid), but the two are separate: a Container decides how far the content sits from the edge of the window, a [GridContainer](./grid) how the content divides itself up.

## Examples

### maxWidth

The default is `none` — gutters with no width limit.

Given a value, it uses [the same steps as Grid's breakpoints](./grid#breakpoints). `lg` is 64rem, the same width Tailwind's `lg:` utilities apply at.

<Demo src="container/max-width">

<<< @/.vitepress/demos/container/max-width.tsx

</Demo>

### padded · centered · render

The three are independent. `padded={false}` keeps the centring and the width limit and drops only the gutters; `centered={false}` does the opposite. `render` changes the element, so a Container can be a page's real `<main>`.

<Demo src="container/plain">

<<< @/.vitepress/demos/container/plain.tsx

</Demo>

### size and density

These set how wide the gutters are. It uses [Box](../surfaces/box)'s steps, and touches neither a height nor the type scale.

### With a grid

The gutters and the width limit outside, the columns inside. The inner grid is `padded={false}`, because it already sits in something that pads.

```tsx
<Container maxWidth="lg">
  <GridContainer spacing={3} padded={false}>
    <Grid span={{ xs: 12, md: 8 }}>Body</Grid>
    <Grid span={{ xs: 12, md: 4 }}>Sidebar</Grid>
  </GridContainer>
</Container>
```
