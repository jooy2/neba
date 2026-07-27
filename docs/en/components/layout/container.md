---
title: Container
order: 1
---

# Container

<p class="neba-lede">Horizontal breathing room around whatever it wraps. Nothing to do with the grid — its one job is to keep a page's content off the edge of the window.</p>

<Demo src="container/hero" />

```tsx
import { Container } from 'neba';

<Container>Content</Container>;
```

It is often used next to [Grid](./grid), but the two are separate. A Container holds a grid as happily as it holds a single paragraph, and a [GridContainer](./grid) is complete without one. The questions are separate: how far the content sits from the edge of the window, and how the content divides itself up.

It draws no surface for the same reason. The outermost element on a page is the one thing that must not decide what the page looks like. Put a [Box](../surfaces/box) or a [Card](../surfaces/card) inside when a sheet is wanted.

## Props

<PropsTable name="Container" />

Every native `<div>` attribute passes through.

## Examples

### Measure

The default is `none` — a gutter and no width limit. A Container's job is the gutter, and a measure is a second decision that a page should have to ask for.

Given a value, it uses [the same ladder the breakpoints use](./grid#breakpoints). `lg` is 64rem, the same number a `lg:` utility changes at. That is why it is not Tailwind's named `max-w-*` scale: two ladders called `lg` on one page is how a layout drifts by a few pixels for no reason anybody can find later.

<Demo src="container/max-width">

<<< @/.vitepress/demos/container/max-width.tsx

</Demo>

### No gutter, no centring, another element

The three switches are independent. `padded={false}` keeps the centring and the measure and drops only the padding; `centered={false}` does the opposite. `render` is Base UI's render prop, so a Container can be a page's real `<main>`.

<Demo src="container/plain">

<<< @/.vitepress/demos/container/plain.tsx

</Demo>

### With a grid

The usual pairing. The gutter and the measure outside, the columns inside — and the inner grid is `padded={false}`, because it already sits in something that pads.

```tsx
<Container maxWidth="lg">
  <GridContainer spacing={3} padded={false}>
    <Grid span={{ xs: 12, md: 8 }}>Body</Grid>
    <Grid span={{ xs: 12, md: 4 }}>Sidebar</Grid>
  </GridContainer>
</Container>
```

## Coming from Material UI

| MUI | Neba |
| --- | --- |
| `maxWidth="lg"` | The same, except the default is `'none'` rather than `'lg'` |
| `disableGutters` | `padded={false}` — the name the whole library uses |
| `fixed` | Not offered. Use `maxWidth` |
| <code v-pre>sx={{ px: 3 }}</code> | `size` / `density`. Padding is a step on a ladder, not an arbitrary number |
