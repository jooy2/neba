---
title: Pagination
order: 11
---

# Pagination

<p class="neba-lede">A row of page numbers. Every one of them is a real Button.</p>

<Demo src="pagination/hero" />

```tsx
import { Pagination } from 'neba';

<Pagination count={24} page={page} onPageChange={setPage} showEdges />;
```

## Props

<PropsTable name="Pagination" />

## Examples

### Variants

`variant` is how the page buttons look **at rest**. The current page is always filled, because it is the one thing here that has to be legible without being read.

That is also why the default is `text` rather than the `solid` a lone Button takes: nine filled buttons in a row say that all nine are the primary action.

<Demo src="pagination/variants">

<<< @/.vitepress/demos/pagination/variants.tsx

</Demo>

### Which pages it shows

<Demo src="pagination/range">

<<< @/.vitepress/demos/pagination/range.tsx

</Demo>

### Sizes

<Demo src="pagination/sizes">

<<< @/.vitepress/demos/pagination/sizes.tsx

</Demo>

## The row keeps its length

The window slides toward whichever end it is near rather than being clipped by it. Page 1 shows `1 2 3 4 5 … 20` and page 10 shows `1 … 9 10 11 … 20` — which slots are pages and which are ellipses changes, how many there are does not.

Without that, stepping from page 1 to page 2 would relayout the row and every button would move out from under the pointer that just pressed one.

A gap of exactly one page is filled with that page rather than with an ellipsis. `1 … 3 … 9` hides a single number behind a symbol wider than the number it replaced.

## They are real Buttons

Every button in the row is a [Button](./button), and that is the point: a pagination is not a new kind of control, it is buttons in a row that happen to know about each other.

Reusing the component means the row inherits the acrylic surface, the press-instant/release-slow house signature, the focus ring, and every future change to any of them for free. It is also why a `lg` pagination lines up with a `lg` button beside it — because it _is_ one.

## One page renders nothing

A row that draws a lone disabled "1" is a control advertising that it has nothing to do.

## Accessibility

The markup is a `<nav>` around a `<ul>`, because that is what a screen reader needs to hear: a named landmark it can skip, holding a list whose length says how far the pages go, with `aria-current="page"` marking where it is.

The ellipsis is not a button, and not a disabled button. It is punctuation, not a control that happens to be unavailable.

Every accessible name is a prop — `label`, `pageLabel`, `previousLabel` and the rest. With more than one pagination on a screen, use `label` to say what each one paginates.
