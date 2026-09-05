---
title: Container
order: 5
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

The default is `none`: gutters with no width limit.

Given a value it takes a step of the measure ladder: `xs` 30rem, `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem. The four upper steps are the [breakpoint](../../design/breakpoints) floors, so `maxWidth="lg"` holds the content to exactly the width at which a `lg:` variant starts. `xs` is the one that is not, because a measure of zero is not a thing.

<Demo src="container/max-width">

<<< @/.vitepress/demos/container/max-width.tsx

</Demo>

### A length of your own

Anything that is not a step of the ladder is passed to `max-width` untouched, so a measure the ladder does not have needs no escape hatch. A number is pixels.

```tsx
<Container maxWidth="60ch">…</Container>
<Container maxWidth="min(90vw, 72rem)">…</Container>
<Container maxWidth={640}>…</Container>
```

### Changing at a breakpoint

`maxWidth` takes a per-breakpoint map, and every entry applies from its own breakpoint up, so two of them describe a whole page. [Header](./header) and [Footer](./footer) take the same prop in the same shape, which is how a bar and the content under it stay on one edge.

<Demo src="container/responsive">

<<< @/.vitepress/demos/container/responsive.tsx

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
