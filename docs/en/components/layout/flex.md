---
title: Flex
order: 12
---

# Flex

<p class="neba-lede">A row, or a column, and the width at which it changes from one to the other. It draws nothing: no surface, no padding, not even a gutter unless one is asked for.</p>

<Demo src="flex/hero" />

```tsx
import { Flex } from 'neba';

<Flex direction={{ xs: 'vertical', md: 'horizontal' }} spacing={3}>
  <Card />
  <Card />
</Flex>;
```

## Props

<PropsTable name="Flex" />

Native `<div>` attributes pass through, and `render` swaps the element. The per-breakpoint maps are described in [breakpoints](../../design/breakpoints), the shared axes in [prop conventions](../../design/prop-conventions).

## Examples

### direction

`horizontal` is a row and `vertical` a column. It takes a per-breakpoint map, so a pair of controls can sit side by side once there is room and stack before there is.

<Demo src="flex/direction">

<<< @/.vitepress/demos/flex/direction.tsx

</Demo>

### spacing

`spacing` is the gutter on Tailwind's spacing scale, so `spacing={4}` is `1rem`, the same length `gap-4` is. It is the same scale a [GridContainer](./grid) uses, and it takes a per-breakpoint map. `rowSpacing` is the vertical gap and `columnSpacing` the horizontal one, whatever `direction` is; each is laid _over_ `spacing` rather than replacing it, so naming one breakpoint does not drop the gutter everywhere else.

<Demo src="flex/spacing">

<<< @/.vitepress/demos/flex/spacing.tsx

</Demo>

### justifyContent · alignItems

`justifyContent` distributes what is left over along the row, and `alignItems` decides where the children sit across it. Neither takes a per-breakpoint map.

<Demo src="flex/alignment">

<<< @/.vitepress/demos/flex/alignment.tsx

</Demo>

### wrap

Off by default, so a row stays on one line and its children shrink. Turn it on to let a row that runs out of width continue on the next line, as a run of chips does.

```tsx
<Flex wrap spacing={2}>
  {tags.map((tag) => (
    <Chip key={tag}>{tag}</Chip>
  ))}
</Flex>
```

### reverse

Runs the children the other way along whichever axis `direction` chose, at every breakpoint at once. It is a visual order only: the DOM order is still what a screen reader reads and what the tab sequence follows, so reversing a row whose order carries meaning makes the two disagree.

```tsx
<Flex direction="vertical" reverse>
  <Newest />
  <Oldest />
</Flex>
```

## Accessibility

- The box adds no role and no name. On a `<nav>` or a `<ul>`, use `render`: the tag is what carries the meaning.
- `reverse`, and `justifyContent` values that move children about, change what is seen and not what is read. Where the order matters, put the children in the order they should be read.
