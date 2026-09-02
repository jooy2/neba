---
title: Flex
order: 12
---

# Flex

<p class="neba-lede">A row, or a column, and the width at which it changes from one to the other. It draws nothing — no surface, no padding, not even a gutter unless one is asked for.</p>

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

`horizontal` is a row and `vertical` a column — the library's own two words rather than CSS's four, so a Flex and a [Stack](./stack) say the same thing the same way. It is responsive, and this is the prop the component exists for: a pair of controls side by side once there is room, and stacked before there is.

<Demo src="flex/direction">

<<< @/.vitepress/demos/flex/direction.tsx

</Demo>

### spacing

The gutter, on Tailwind's spacing scale — `spacing={4}` is `1rem`, the same length `gap-4` is. The same prop and the same scale a [GridContainer](./grid) uses, so one number means one length across both, and it takes a map like everything else. `rowSpacing` and `columnSpacing` set one axis; each is laid _over_ `spacing` rather than replacing it, so naming one breakpoint does not drop the gutter everywhere else.

<Demo src="flex/spacing">

<<< @/.vitepress/demos/flex/spacing.tsx

</Demo>

### justifyContent · alignItems

The flexbox vocabulary, spelled the way the rest of the library spells it. `justifyContent` distributes what is left over along the row; `alignItems` decides where the children sit across it. Neither is responsive — they are class names, and a per-breakpoint class map would put five complete ladders in the bundle of every page that draws a Flex.

<Demo src="flex/alignment">

<<< @/.vitepress/demos/flex/alignment.tsx

</Demo>

### wrap

Off by default, which is the opposite of a [GridContainer](./grid). A grid is columns and wrapping is what columns do; a Flex is most often a toolbar or a field row that should stay on one line and let its children shrink.

```tsx
<Flex wrap spacing={2}>
  {tags.map((tag) => (
    <Chip key={tag}>{tag}</Chip>
  ))}
</Flex>
```

### Flex or Grid

A Flex sizes its children by what they are; a [Grid](./grid) sizes them against a column count. Reach for a Flex when the answer is "these things, in a line" — a toolbar, a field and its button, a card's footer. Reach for a Grid when the widths have to line up with something else on the page, which is what columns are for.

### reverse

Runs the children the other way along whichever axis `direction` chose, at every breakpoint at once. It is a visual order only: the DOM order is still what a screen reader reads and what the tab sequence follows, so reversing a row whose order carries meaning makes the two disagree.

```tsx
<Flex direction="vertical" reverse>
  <Newest />
  <Oldest />
</Flex>
```

## Accessibility

- The box adds no role and no name. On a `<nav>` or a `<ul>`, use `render` — the tag is what carries the meaning.
- `reverse`, and `justifyContent` values that move children about, change what is seen and not what is read. Where the order matters, put the children in the order they should be read.
