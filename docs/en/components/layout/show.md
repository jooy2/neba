---
title: Show
order: 11
---

# Show

<p class="neba-lede">Its children at some widths and not at others. A floor, a ceiling, or both, on the same five-step ladder every other breakpoint in the library uses.</p>

<Demo src="show/hero" />

```tsx
import { Show } from 'neba';

<Show above="md">
  <Sidebar />
</Show>;
```

## Props

<PropsTable name="Show" />

Native `<div>` attributes pass through, and `render` swaps the element. The five breakpoints and what they are worth are described in [breakpoints](../../design/breakpoints).

## Examples

### above and below

`above` is inclusive and `below` is exclusive, so the same breakpoint in both covers every width exactly once with no gap and no overlap. That pair is the common case: one arrangement for a phone, another for everything else.

<Demo src="show/pair">

<<< @/.vitepress/demos/show/pair.tsx

</Demo>

### Bounding a range

Given together they are a floor and a ceiling: `above="sm" below="lg"` is drawn from 40rem up to but not including 64rem.

<Demo src="show/range">

<<< @/.vitepress/demos/show/range.tsx

</Demo>

### It adds no box

The wrapper is `display: contents`, so a `Show` between a [GridContainer](./grid) and a [Grid](./grid) leaves the cell a cell, and one inside a flex row leaves its children flex items. Nothing given to it to style — padding, a background — has anywhere to land; put those on an element inside it, or name the element with `render`.

<Demo src="show/transparent">

<<< @/.vitepress/demos/show/transparent.tsx

</Demo>

### Not rendering at all

The children are always rendered — what changes is `display`. That is what makes the answer right in the first frame the browser paints, and the same answer on a server.

When something must not _run_ below a width — a component that fetches, or mounts a map — that is a decision CSS cannot make, and `useBreakpoint` is what makes it. It answers `false` on a server and on the first client render, so what it controls arrives after hydration.

```tsx
import { useBreakpoint } from 'neba';

const wide = useBreakpoint('md');

return wide ? <Map /> : <StaticImage />;
```

### render

`render` names the element, which is what a `Show` inside a table or a list needs — a `<div>` is not allowed between a `<tr>` and a `<td>`.

```tsx
<tr>
  <td>{row.name}</td>
  <Show above="lg" render={<td />}>
    {row.updatedAt}
  </Show>
</tr>
```

## Accessibility

- A hidden branch is `display: none`, so it is out of the accessibility tree and out of the tab order as well as off the screen. Nothing is announced twice.
- Both halves of an `above`/`below` pair are in the DOM at every width, so anything that must not be duplicated — an `id`, a form control's `name`, a heading — has to differ between them or live outside the pair.
