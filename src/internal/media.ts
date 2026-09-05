'use client';

/**
 * A media query, as something React can subscribe to.
 *
 * `useSyncExternalStore` is the right shape for one — a media query is an
 * external store with a server answer — but its `getSnapshot` is called on
 * every render, and again on every commit, of every component that asks. Built
 * the obvious way, that is a fresh `MediaQueryList` per render per component:
 * a PageLayout with a Header, a Footer, a Sidebar and a SidebarTrigger in it
 * asks the same question five times, and a page of `Animate*` wrappers asks it
 * once each.
 *
 * So the lists are made once and kept. A `MediaQueryList` is live — its
 * `matches` is the current answer, not the answer at construction — so one per
 * query string is all there ever needs to be.
 *
 * The map goes through `memoise` because the key is not the library's to
 * promise anything about: `useMediaQuery` is a public hook and takes any string
 * at all. Emptying it costs a caller nothing, since a subscription holds its
 * own list in a closure and a rebuilt one answers the same question.
 */

import * as React from 'react';
import type { NebaBreakpoint } from '../types.js';
import { memoise } from './cache.js';

const lists = new Map<string, MediaQueryList | null>();

/** The one `MediaQueryList` for a query, or `null` where there is no window. */
function listFor(query: string): MediaQueryList | null {
  return memoise(lists, query, () =>
    typeof window === 'undefined' || !window.matchMedia ? null : window.matchMedia(query)
  );
}

/** Subscribes to one query. A no-op where there is no window to ask. */
export function subscribeToQuery(query: string, onChange: () => void): () => void {
  const list = listFor(query);

  if (!list) {
    return () => {};
  }

  list.addEventListener('change', onChange);

  return () => list.removeEventListener('change', onChange);
}

/** The current answer. Reads a live object rather than building one. */
export function queryMatches(query: string): boolean {
  return listFor(query)?.matches ?? false;
}

/** A server has no window, so nothing matches. */
export function noMatchOnServer(): boolean {
  return false;
}

/**
 * The five widths, written once and read in both directions.
 *
 * They are Tailwind's defaults, which is what makes a Neba layout and a `md:`
 * utility change at the same moment — and they are here rather than in
 * `page-layout.ts`, where they used to be, because a layout asks "is the window
 * *narrower* than this" and a caller asks "is it *at least* this". Two
 * questions, one table: a second copy would be a second chance for the two to
 * disagree about what `md` is.
 *
 * This copy is the fallback rather than the source. `styles.css` publishes the
 * same four widths as `--neba-breakpoint-*`, filled in from Tailwind's own
 * theme at build time, and `readBreakpoints` below prefers those — so a
 * consumer who moves `--breakpoint-md` moves the CSS and this together instead
 * of leaving the two to disagree silently. What is written here is what a
 * server, and a page whose stylesheet has not arrived, has to answer with.
 */
export const breakpointWidths: Record<NebaBreakpoint, string> = {
  xs: '0rem',
  sm: '40rem',
  md: '48rem',
  lg: '64rem',
  xl: '80rem'
};

/**
 * The widths actually in force, read off the document once.
 *
 * Once, and lazily: `getComputedStyle` is a layout read, and the answer cannot
 * change without a new stylesheet. The first call happens when something first
 * asks a width question, which is after React has rendered and therefore after
 * the stylesheet is in the document.
 *
 * Every failure falls back to the table above rather than throwing — no window,
 * no stylesheet yet, a token a consumer's build did not emit. A wrong-by-a-
 * default breakpoint is a layout that changes at 48rem instead of 50rem; an
 * exception here would be a page that does not render.
 */
let resolved: Record<NebaBreakpoint, string> | null = null;

function readBreakpoints(): Record<NebaBreakpoint, string> {
  if (resolved) return resolved;

  if (typeof window === 'undefined' || !window.getComputedStyle) {
    return breakpointWidths;
  }

  const style = getComputedStyle(document.documentElement);
  const widths = { ...breakpointWidths };

  for (const name of ['sm', 'md', 'lg', 'xl'] as const) {
    const value = style.getPropertyValue(`--neba-breakpoint-${name}`).trim();
    if (value) widths[name] = value;
  }

  resolved = widths;

  return widths;
}

/** Narrower than this breakpoint. `xs` has nothing below it, so it is `null`. */
export function widthBelow(breakpoint: NebaBreakpoint): string | null {
  return breakpoint === 'xs' ? null : `(width < ${readBreakpoints()[breakpoint]})`;
}

/** At this breakpoint or wider — the direction a Tailwind `md:` variant means. */
export function widthAtLeast(breakpoint: NebaBreakpoint): string {
  return `(width >= ${readBreakpoints()[breakpoint]})`;
}

/**
 * One media query, as a boolean React can re-render on.
 *
 * `useSyncExternalStore` rather than state plus an effect, for the reason the
 * whole module exists: a media query *is* an external store with a server
 * answer, and reading it in an effect renders every subscriber once with the
 * wrong answer and then again with the right one. `null` is a query that is
 * always false and subscribes to nothing, which is what a breakpoint with
 * nothing below it needs.
 */
export function useMediaQuery(query: string | null): boolean {
  const subscribe = React.useCallback(
    (onChange: () => void) => (query ? subscribeToQuery(query, onChange) : () => {}),
    [query]
  );

  const snapshot = React.useCallback(() => (query ? queryMatches(query) : false), [query]);

  return React.useSyncExternalStore(subscribe, snapshot, noMatchOnServer);
}

/** The query behind every "the reader asked for less motion" decision. */
export const reducedMotionQuery = '(prefers-reduced-motion: reduce)';

const subscribeToMotion = (onChange: () => void) => subscribeToQuery(reducedMotionQuery, onChange);
const readMotion = () => queryMatches(reducedMotionQuery);

/**
 * Whether the reader has asked for less motion.
 *
 * The CSS side of this is handled in the stylesheet, where every keyframe is
 * switched off at once. This is for the motion written in JavaScript — a
 * typewriter, a headline reel, a measured marquee, a carousel that advances on
 * a timer — where there is no rule to switch off and the component has to
 * decide for itself what "still" means.
 *
 * `useSyncExternalStore` rather than state plus an effect, which is the same
 * choice Shortcut makes for the same reason: a media query is an external
 * store, and reading it in an effect means every animated element on the page
 * renders once with the wrong answer and then again with the right one. Here
 * that first render is the one that would start a typewriter a reader asked
 * not to see.
 *
 * It lives beside the query rather than in `animate.ts` so that a Carousel and
 * a ScrollZone can ask without pulling the eleven animation effects in with the
 * answer.
 */
export function usePrefersReducedMotion(): boolean {
  return React.useSyncExternalStore(subscribeToMotion, readMotion, noMatchOnServer);
}
