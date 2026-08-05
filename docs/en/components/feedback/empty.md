---
title: Empty
order: 10
---

# Empty

<p class="neba-lede">What stands where content would have been: a glyph, a headline, a sentence and a way out. It is for the list that came back with nothing, the inbox nobody has written to, and the folder before its first file.</p>

<Demo src="empty/hero" align="center" minHeight="260" />

```tsx
import { Button, Empty } from 'neba';

<Empty title="No projects yet" action={<Button size="sm">Create a project</Button>}>
  Everything you deploy shows up here.
</Empty>;
```

## Props

<PropsTable name="Empty" />

Native `<div>` attributes pass through, and `render` swaps the element. The shared axes are described in [prop conventions](../../design/prop-conventions).

## Examples

### title

The headline defaults to the `locale`'s way of saying that there is nothing here, so an Empty with no props at all still says something. Pass `title` for the version that names what is missing — which is nearly always worth doing — or `title={false}` for a state that is a glyph and a sentence with no heading over them.

<Demo src="empty/title" minHeight="200">

<<< @/.vitepress/demos/empty/title.tsx

</Demo>

### icon

`icon` takes any node and replaces the default tray: an icon from another set, an illustration, a brand mark. An `<svg>` is sized off the `size` ladder; anything else is left at the size it came in at. `icon={false}` drops it.

<Demo src="empty/icon" minHeight="200">

<<< @/.vitepress/demos/empty/icon.tsx

</Demo>

### action

`action` sits under the text and is where the state stops being a dead end — a button that creates the first record, a link that clears the filter that matched nothing. Pass a fragment for more than one and they lay out in a row that wraps together.

<Demo src="empty/action" minHeight="220">

<<< @/.vitepress/demos/empty/action.tsx

</Demo>

### variant

`text` is the default, and it is the default here and nowhere else: an empty state is usually already inside a [Card](../surfaces/card), a [Table](../display/table) or a panel, and a second rectangle inside the first is one rectangle too many. `outline` and `solid` are for the case where nothing else marks the bounds of the region.

<Demo src="empty/variants" minHeight="200">

<<< @/.vitepress/demos/empty/variants.tsx

</Demo>

### size and density

`size` sets the type scale, the glyph and how much room the state takes vertically. `density` changes the padding and nothing else, which is what to reach for when the state has to fit inside a control-sized row.

<Demo src="empty/size" minHeight="360">

<<< @/.vitepress/demos/empty/size.tsx

</Demo>

### color

The sheet is never dyed — `color` reaches the hairline and the focus ring and stops there. `secondary` is the default because an empty state arriving in the accent colour is making a claim about content that does not exist. Move it when the emptiness is itself a problem.

<Demo src="empty/color" minHeight="220">

<<< @/.vitepress/demos/empty/color.tsx

</Demo>

### locale

`locale` is a BCP 47 tag and decides the default headline only. It is ignored once `title` is given, and an unsupported tag falls back to English.

<Demo src="empty/locale" minHeight="220">

<<< @/.vitepress/demos/empty/locale.tsx

</Demo>

### Inside a Table

[Table](../display/table) takes an `empty` prop for what to show instead of rows, and it renders into a cell spanning every column. That cell has padding of its own, so `density="compact"` is usually the right pairing.

<Demo src="empty/table" minHeight="260">

<<< @/.vitepress/demos/empty/table.tsx

</Demo>

## Accessibility

- The root is a `role="status"` live region, so a list that empties under the reader announces itself rather than going silently blank. Pass `role={undefined}` for a state that is simply part of the page when it arrives.
- The default glyph is `aria-hidden`. It names nothing the headline does not already say.
- Reach for [Skeleton](./skeleton) while content is still on its way and Empty only once it is known that none is coming. Showing neither leaves a blank rectangle where the answer should be.
