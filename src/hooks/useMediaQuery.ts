'use client';

import { useMediaQuery as useSharedMediaQuery, widthAtLeast } from '../internal/media.js';
import { valueAt } from '../internal/responsive.js';
import type { NebaBreakpoint, NebaResponsive } from '../types.js';

/**
 * One media query, as a boolean this component re-renders on.
 *
 * The same store the library's own layout runs on, which is the reason it is
 * offered rather than left to be written again: a `MediaQueryList` is live, so
 * there is exactly one per query string for the whole page no matter how many
 * components ask. Written the obvious way — `window.matchMedia` inside a
 * `getSnapshot` — every subscriber builds a fresh one on every render *and*
 * every commit, and a PageLayout with a Header, a Footer and two Sidebars in it
 * asks the same question five times per render.
 *
 * It answers `false` on a server, where there is no window and no honest answer.
 * A layout that must not flash is a layout stated in CSS; this is for the
 * decisions CSS cannot make — which component to render at all.
 */
export function useMediaQuery(query: string): boolean {
  return useSharedMediaQuery(query);
}

/**
 * The same question in the units the rest of the library uses: is the window at
 * least this wide?
 *
 * `useBreakpoint('md')` is `md:` in a class name, in JavaScript — the widths are
 * one table, so a component that branches here and a utility that branches in
 * CSS change at the same pixel. `xs` is `0rem` and therefore always true, which
 * is the value with no media query around it.
 */
export function useBreakpoint(breakpoint: NebaBreakpoint): boolean {
  return useSharedMediaQuery(widthAtLeast(breakpoint));
}

/**
 * Which breakpoint the window is currently in — the widest whose floor it has
 * reached.
 *
 * Four subscriptions and not five: `xs` is a floor of zero, so it is where the
 * window is when none of the others match, and there is no query to ask. They
 * are four separate calls rather than a loop because they are hooks; the count
 * is fixed, which is what makes that legal, and each one costs nothing extra —
 * a `MediaQueryList` is shared per query string for the whole page.
 *
 * `xs` on a server, which is the same answer the stylesheet gives before any
 * media query has had a chance to apply.
 */
export function useCurrentBreakpoint(): NebaBreakpoint {
  const sm = useSharedMediaQuery(widthAtLeast('sm'));
  const md = useSharedMediaQuery(widthAtLeast('md'));
  const lg = useSharedMediaQuery(widthAtLeast('lg'));
  const xl = useSharedMediaQuery(widthAtLeast('xl'));

  if (xl) return 'xl';
  if (lg) return 'lg';
  if (md) return 'md';
  if (sm) return 'sm';

  return 'xs';
}

/**
 * A responsive prop's own shape, resolved in JavaScript.
 *
 * `useBreakpointValue({ xs: 1, md: 3 })` is `1` under 48rem and `3` from there
 * up, reading the map exactly as the CSS cascade behind `span` and `spacing`
 * reads it: every entry is a floor, so the nearest one at or below the current
 * width wins. That sameness is the point — a component's responsive props and
 * the numbers a caller works out for themselves should not need two mental
 * models, or two ideas of what `{ md: 6 }` says about a phone.
 *
 * A bare value is returned unchanged, and `undefined` means the map has not
 * said anything yet at this width: `{ lg: 4 }` on a phone is the caller
 * declining to have an opinion there, not a failure. Pair it with `??` for a
 * default.
 *
 * It re-renders on a resize, which the CSS form does not — so reach for it when
 * the value is one JavaScript has to see (how many items to fetch, what to pass
 * a chart), and leave layout to the props that resolve in the stylesheet.
 */
export function useBreakpointValue<T>(value: NebaResponsive<T> | undefined): T | undefined {
  return valueAt(value, useCurrentBreakpoint());
}
