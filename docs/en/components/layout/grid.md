---
title: Grid
order: 2
---

# Grid

<p class="neba-lede">A responsive layout on twelve columns. <code>GridContainer</code> sets the column count and the gutters; <code>Grid</code> says how many columns a cell takes.</p>

<Demo src="grid/hero" />

```tsx
import { Grid, GridContainer } from 'neba';

<GridContainer spacing={3}>
  <Grid span={{ xs: 12, md: 8 }}>Body</Grid>
  <Grid span={{ xs: 12, md: 4 }}>Sidebar</Grid>
</GridContainer>;
```

`GridContainer` draws no surface, so it has no `variant`, `color` or `elevation`. Wrap it in a [Box](../surfaces/box) or a [Card](../surfaces/card) when the sheet is wanted.

## Props

### GridContainer

<PropsTable name="GridContainer" />

### Grid

<PropsTable name="Grid" />

Both pass every native `<div>` attribute straight through.

## Examples

### span

`span` is read against the container's column count. On the default twelve, `span={6}` is a half; with `columns={24}` the same `6` is a quarter.

The width is `(100% + gutter) × span / columns − gutter`, so twelve `span={1}` cells and one `span={12}` end on exactly the same pixel.

<Demo src="grid/spans">

<<< @/.vitepress/demos/grid/spans.tsx

</Demo>

### breakpoints

Give `span` an object and it uses a different value per width. Every entry applies **from its own breakpoint up** — it is a floor, not a band — which is what makes two of them enough to describe a whole layout.

The widths are Tailwind's own defaults: `sm` 40rem · `md` 48rem · `lg` 64rem · `xl` 80rem. `xs` is 0, the value with no media query around it, so a grid and a `md:` utility change at the same moment.

`columns` · `spacing` · `rowSpacing` · `columnSpacing` · `offset` all take responsive values the same way.

<Demo src="grid/responsive">

<<< @/.vitepress/demos/grid/responsive.tsx

</Demo>

### spacing · rowSpacing · columnSpacing

`spacing` is on **Tailwind's spacing scale**. `spacing={4}` is `1rem`, the same length as `gap-4` or Box's `p-4`. Fractions are allowed, so `spacing={1.5}` is `0.375rem`.

`rowSpacing` and `columnSpacing` each override one axis.

<Demo src="grid/spacing">

<<< @/.vitepress/demos/grid/spacing.tsx

</Demo>

### columns

The column count. Twelve is the default, but it does not divide by five, so values like `24` are useful. Every `span` and `offset` beneath the container is read against this number. A span wider than the row is clamped to the row rather than overflowing.

<Demo src="grid/columns">

<<< @/.vitepress/demos/grid/columns.tsx

</Demo>

### offset

Empty columns pushed in **ahead of** the item — space inserted in front of it rather than an absolute position counted from the start of the row. After an item that already took columns, the offset pushes on from there.

<Demo src="grid/offset">

<<< @/.vitepress/demos/grid/offset.tsx

</Demo>

### justifyContent · alignItems · alignContent · alignSelf

Alignment is set through props rather than a `className`. The first three live on `GridContainer`, `alignSelf` on `Grid`.

The values are `start` / `center` / `end`, which flip under RTL. Distribution values like `space-between` keep their CSS spelling.

<Demo src="grid/alignment">

<<< @/.vitepress/demos/grid/alignment.tsx

</Demo>

### padded

`spacing` is the space **between** items; `padded` is the padding **around** the grid. It defaults to `true`, so turn it off inside a [Container](./container), a [Card](../surfaces/card) or another grid.

`size` and `density` set how much.

<Demo src="grid/padding">

<<< @/.vitepress/demos/grid/padding.tsx

</Demo>

### Nesting

A grid inside a grid is a `GridContainer` inside a `Grid`. The inner grid re-divides the width its cell was given, so `span={6}` in there is half of a half.

<Demo src="grid/nested">

<<< @/.vitepress/demos/grid/nested.tsx

</Demo>
