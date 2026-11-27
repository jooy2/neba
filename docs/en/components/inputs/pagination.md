---
title: Pagination
order: 11
flutter: true
---

# Pagination

<p class="neba-lede">Moves between the pages of a paged list. Each number renders as a Button.</p>

<Demo src="pagination/hero" />

::: fw react

```tsx
import { Pagination } from 'neba';

<Pagination count={24} page={page} onPageChange={setPage} showEdges />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPagination(
  count: 24,
  page: page,
  onPageChange: (int next) => setState(() => page = next),
  showEdges: true,
);
```

:::

## Props

<PropsTable name="Pagination" />

A `count` of `1` renders nothing at all.

## Examples

### variant

`variant` is how the page buttons look when they are not the current page. The current page is always filled, whatever the variant.

The default is `text` rather than [Button](./button)'s `solid`: several filled buttons in a row leave no way to tell which page you are on.

<Demo src="pagination/variants">

::: fw react

<<< @/.vitepress/demos/pagination/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/variants.dart

:::

</Demo>

### siblingCount · boundaryCount · showEdges · showArrows

`siblingCount` is how many numbers show either side of the current page; `boundaryCount` how many always show at each end. `showEdges` adds first/last buttons and `showArrows` adds previous/next.

The number of slots in the row stays constant as the page changes. The window slides toward whichever end it is near rather than being clipped by it, so the buttons never move out from under the pointer that just pressed one. A gap of exactly one page is filled with that page rather than an ellipsis.

<Demo src="pagination/range">

::: fw react

<<< @/.vitepress/demos/pagination/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/range.dart

:::

</Demo>

### size

<Demo src="pagination/sizes">

::: fw react

<<< @/.vitepress/demos/pagination/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/sizes.dart

:::

</Demo>

### getPageHref

::: fw react

Return the address of a page and the numbers in the row become real `<a href>`. A crawler cannot press a button, so without this everything past page one of a list does not exist to a search engine. The browser's own behaviour comes back with it: open in a new tab, copy the address, see where a press goes before making it. The two arrows carry `rel="prev"` and `rel="next"`.

Pass `onPageChange` alongside it and the navigation is cancelled for the handler to answer: the shape a client-side router wants, keeping the page it already has. With no handler, the link does what a link does. A press carrying a modifier key is always left to the browser.

The page being read and an arrow at the end of the row stay links, with no `href` and with `aria-disabled`. A crawler does not follow them, and a press on one leaves the focus where it was.

<Demo src="pagination/links">

<<< @/.vitepress/demos/pagination/links.tsx

</Demo>

:::

::: fw flutter

The package opens nothing itself, so there is no `getPageHref`: a page is a press, and `onPageChange` goes to it through whatever router the app uses. There is no link for a crawler to follow, which a Flutter app does not have to serve.

:::

## Accessibility

::: fw react

- Renders a `<nav>` around a `<ul>`, with `aria-current="page"` on the current page.
- The ellipsis is punctuation rather than a control, so it is not rendered as a disabled button.
- A stepper with nowhere to go stays in the tab order with `aria-disabled`. With `getPageHref` it and the current page stay links with no `href` rather than turning into buttons. Either way, pressing Next onto the last page leaves the focus where it was.
- With `getPageHref` the numbers are links, so they appear in a screen reader's list of links and a keyboard reader can see where each one goes.
- Every accessible name is settable: `label` · `pageLabel` · `previousLabel` · `nextLabel` · `firstLabel` · `lastLabel`. With more than one pagination on a screen, use `label` to say what each one paginates.
- `locale` decides the nav name, the page buttons, the arrows and the sentence that reads out where you are. Each of them takes a string of its own.

:::

::: fw flutter

- The row is one node named "Pagination", or by `semanticLabel`, holding a button per page; the current page is selected.
- The ellipsis is punctuation rather than a control, so it is not a disabled button and a screen reader skips it.
- A stepper with nowhere to go stays in the focus order, disabled. Pressing Next onto the last page leaves the focus where it was.
- A status read politely says where the reader is, "Page 3 of 8", since the buttons alone do not say how many pages there are once an ellipsis is in the row.
- Every name is settable: `semanticLabel` · `pageLabel` · `previousLabel` · `nextLabel` · `firstLabel` · `lastLabel`. With more than one pagination on a screen, use `semanticLabel` to say what each one paginates.
- `locale` decides the row's name, the page buttons, the arrows and the sentence that reads out where you are.

:::
