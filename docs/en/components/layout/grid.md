---
title: Grid
order: 2
---

# Grid

<p class="neba-lede">A responsive layout on twelve columns. Every grid is wrapped in a <code>GridContainer</code>, and each cell is a <code>Grid</code>.</p>

<Demo src="grid/hero" />

```tsx
import { Grid, GridContainer } from 'neba';

<GridContainer spacing={3}>
  <Grid span={{ xs: 12, md: 8 }}>Body</Grid>
  <Grid span={{ xs: 12, md: 4 }}>Sidebar</Grid>
</GridContainer>;
```

The two are separate components because they know different things. How many columns there are and how wide the two gutters are is not something a cell can know on its own, and `GridContainer` is what knows all three. `Grid` inherits them and works out its own width.

It inherits them as **inherited custom properties** rather than through a React context. The values are responsive, and a media query can change an inherited custom property without React hearing about it — so the column count a cell lays itself out against is always the one that is on screen. A context would have to re-render the tree at every breakpoint to say the same thing.

`GridContainer` takes no `variant`, no `color` and no `elevation`. A grid is not a surface; it is the arrangement of the surfaces inside it, and the moment it draws its own sheet it stops being usable as the outermost thing on a page. Wrap it in a [Box](../surfaces/box) or a [Card](../surfaces/card) when the sheet is wanted.

## Props

### GridContainer

<PropsTable name="GridContainer" />

### Grid

<PropsTable name="Grid" />

Both pass every native `<div>` attribute straight through.

## Examples

### Spans

`span` is read against the container's column count. On the default twelve, `span={6}` is a half; with `columns={24}` the same `6` is a quarter.

The width is exactly `(100% + gutter) × span / columns − gutter`. Exact rather than approximate matters: the `+ gutter` pays back the one an item does not have on its trailing edge, so twelve `span={1}` cells and one `span={12}` end on the same pixel.

<Demo src="grid/spans">

<<< @/.vitepress/demos/grid/spans.tsx

</Demo>

### Breakpoints

Give `span` a map and it uses a different value per width. Every entry applies **from its own breakpoint up** — it is a floor, not a band — which is what makes two of them enough to describe a whole layout.

The widths are Tailwind's own defaults: `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem. `xs` is 0, the value with no media query around it. That is why a Neba grid and a `md:` utility change at the same moment.

`columns`, `spacing`, `rowSpacing`, `columnSpacing` and `offset` are all responsive in the same way.

<Demo src="grid/responsive">

<<< @/.vitepress/demos/grid/responsive.tsx

</Demo>

### Gutters

`spacing` is on **Tailwind's spacing scale**. `spacing={4}` is `1rem`, which is exactly what `gap-4` — and Box's `p-4` — already mean. It is not Material's 8px scale: every other number in this library is on that ladder, and a grid that measured its gutters differently from the box around it would be the one place a caller has to stop and convert.

Fractions are allowed: `spacing={1.5}` is `0.375rem`, the step `gap-1.5` is.

`rowSpacing` and `columnSpacing` each override one axis.

<Demo src="grid/spacing">

<<< @/.vitepress/demos/grid/spacing.tsx

</Demo>

### Column count

Twelve is a convention, not a rule. Twelve does not divide by five, and twenty-four does things twelve cannot.

`columns` lives on the container, and every `span` and `offset` beneath it is read against that number. A span wider than the row is clamped to the row rather than overflowing — `span={99}` fills a row, which is what whoever wrote it meant.

<Demo src="grid/columns">

<<< @/.vitepress/demos/grid/columns.tsx

</Demo>

### Offset

`offset` is empty columns pushed in **ahead of** the item — space that goes in front of it, not an absolute position counted from the start of the row. For the first item in a row the two are the same thing; after something that already took columns, the offset pushes on from there.

<Demo src="grid/offset">

<<< @/.vitepress/demos/grid/offset.tsx

</Demo>

### Alignment

`justifyContent`, `alignItems`, `alignContent`, and `alignSelf` on the item, are **props of their own**. No `sx`, no `className` — how a row distributes its leftover space is a layout decision rather than a styling escape hatch, and a prop is typed, autocompleted and documented.

The values are `start` / `center` / `end`, not `left` / `right`, for the reason everywhere else in the library says so: these flip under RTL. The distribution values keep their CSS spelling — `space-between` already has a name, and it does not need a second one.

<Demo src="grid/alignment">

<<< @/.vitepress/demos/grid/alignment.tsx

</Demo>

### Padding

`padded` defaults to `true`. `spacing` (**between** items) and `padded` (**around** the grid) are different things, and the second should be turned off when the grid already sits inside something that pads — a Container, a Card, another grid.

`size` and `density` set how much. It is Box's ladder, and it touches neither a height nor the type scale.

<Demo src="grid/padding">

<<< @/.vitepress/demos/grid/padding.tsx

</Demo>

### Nesting

A grid inside a grid is a `GridContainer` inside a `Grid`, never a `Grid` that is also a container. The inner grid re-divides the width its cell was given, so `span={6}` in there is half of a half.

<Demo src="grid/nested">

<<< @/.vitepress/demos/grid/nested.tsx

</Demo>

## Coming from Material UI

| MUI | Neba | Why |
| --- | --- | --- |
| `<Grid container>` | `<GridContainer>` | A container and a cell share none of their props. One component with a `container` boolean leaves half of them silently ignored, and only the docs say when |
| `<Grid size={6}>` | `<Grid span={6}>` | `size` means `xs`…`xl` everywhere in this library. A name cannot carry a second meaning, so this takes the word CSS uses |
| <code v-pre>size={{ xs: 12, md: 6 }}</code> | <code v-pre>span={{ xs: 12, md: 6 }}</code> | The map means the same thing |
| `spacing={2}` = 16px | `spacing={2}` = 8px | Tailwind's scale. Double an MUI value for the same length |
| `offset={4}` | `offset={4}` | The same |
| `columns={24}` | `columns={24}` | The same |
| <code v-pre>sx={{ justifyContent: 'center' }}</code> | `justifyContent="center"` | A prop |
| `direction="column"` | Not offered | A vertical grid is a stack of `span={12}`. Taking `direction` would create a state in which `span` means a height rather than a width |
| `size="auto"` / `size="grow"` | Not offered | Neither is a value that can be switched on per breakpoint, so they would work only half the time inside a responsive map. Left out rather than shipped half-working |
