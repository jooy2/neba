---
title: Pagination
order: 11
---

# Pagination

<p class="neba-lede">Moves between the pages of a paged list. Each number renders as a Button.</p>

<Demo src="pagination/hero" />

```tsx
import { Pagination } from 'neba';

<Pagination count={24} page={page} onPageChange={setPage} showEdges />;
```

## Props

<PropsTable name="Pagination" />

A `count` of `1` renders nothing at all.

## Examples

### variant

`variant` is how the page buttons look when they are not the current page. The current page is always filled, whatever the variant.

The default is `text` rather than [Button](./button)'s `solid`: several filled buttons in a row leave no way to tell which page you are on.

<Demo src="pagination/variants">

<<< @/.vitepress/demos/pagination/variants.tsx

</Demo>

### siblingCount · boundaryCount · showEdges · showArrows

`siblingCount` is how many numbers show either side of the current page; `boundaryCount` how many always show at each end. `showEdges` adds first/last buttons and `showArrows` adds previous/next.

The number of slots in the row stays constant as the page changes. The window slides toward whichever end it is near rather than being clipped by it, so the buttons never move out from under the pointer that just pressed one. A gap of exactly one page is filled with that page rather than an ellipsis.

<Demo src="pagination/range">

<<< @/.vitepress/demos/pagination/range.tsx

</Demo>

### size

<Demo src="pagination/sizes">

<<< @/.vitepress/demos/pagination/sizes.tsx

</Demo>

### getPageHref

Return the address of a page and the numbers in the row become real `<a href>`. A crawler cannot press a button, so without this everything past page one of a list does not exist to a search engine. The browser's own behaviour comes back with it: open in a new tab, copy the address, see where a press goes before making it. The two arrows carry `rel="prev"` and `rel="next"`.

Pass `onPageChange` alongside it and the navigation is cancelled for the handler to answer — the shape a client-side router wants, keeping the page it already has. With no handler, the link does what a link does. A press carrying a modifier key is always left to the browser.

The page being read and an arrow at the end of the row stay `<button>`. An `<a>` cannot be `disabled`, so one left as a link is one a keyboard still lands on and a crawler still follows.

<Demo src="pagination/links">

<<< @/.vitepress/demos/pagination/links.tsx

</Demo>

## Accessibility

- Renders a `<nav>` around a `<ul>`, with `aria-current="page"` on the current page.
- The ellipsis is punctuation rather than a control, so it is not rendered as a disabled button.
- With `getPageHref` the numbers are links, so they appear in a screen reader's list of links and a keyboard reader can see where each one goes.
- Every accessible name is settable: `label` · `pageLabel` · `previousLabel` · `nextLabel` · `firstLabel` · `lastLabel`. With more than one pagination on a screen, use `label` to say what each one paginates.
- `locale` decides the nav name, the page buttons, the arrows and the sentence that reads out where you are. Each of them takes a string of its own.
