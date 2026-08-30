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
 * query string is all there ever needs to be, and the map is bounded by the
 * handful of queries the library actually writes.
 */

import * as React from 'react';

const lists = new Map<string, MediaQueryList | null>();

/** The one `MediaQueryList` for a query, or `null` where there is no window. */
function listFor(query: string): MediaQueryList | null {
  if (lists.has(query)) {
    return lists.get(query) ?? null;
  }

  const list =
    typeof window === 'undefined' || !window.matchMedia ? null : window.matchMedia(query);

  lists.set(query, list);

  return list;
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
