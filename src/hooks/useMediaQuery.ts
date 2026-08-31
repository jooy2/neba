'use client';

import { useMediaQuery as useSharedMediaQuery, widthAtLeast } from '../internal/media.js';
import type { NebaBreakpoint } from '../types.js';

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
