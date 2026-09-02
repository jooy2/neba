/**
 * A value that changes at a breakpoint, and the machinery every component that
 * takes one shares.
 *
 * This was written inside `grid.ts`, for the grid, and it is here now for the
 * reason `media.ts` exists one level down: it is not about grids at all. A
 * span, a gutter, a content measure, a flex direction and whether an element is
 * drawn are five different questions with one answer shape, and a second copy
 * of `withBaseline` would be a second chance to disagree about what a partial
 * map means.
 *
 * The split it makes is the load-bearing part. **What a responsive value cannot
 * be is a class name.** Tailwind only ever sees class names written out
 * literally, and a per-breakpoint class map would be five complete ladders in
 * the bundle of every page that draws the component — so a prop is responsive
 * exactly when its value fits in an inline `--n-*` slot, and props whose value
 * *is* a class (`size`, `variant`, `color`, `elevation`) are deliberately not.
 * That is the same line `styleSlots()` draws for colour, drawn again here.
 *
 * The CSS half lives in `styles.css`: one cascade per slot name, each
 * breakpoint falling back through the ones below it. That is what lets a media
 * query change a value without React hearing about it — the alternative is
 * re-rendering the tree at every breakpoint to say the same thing — and it is
 * also why the list of responsive axes is kept short. A cascade is four media
 * blocks that cannot be generated, so each new one is a deliberate cost.
 */

import type * as React from 'react';
import type { NebaBreakpoint, NebaResponsive } from '../types.js';

/** Smallest first, which is also the order the media queries have to be in. */
export const breakpoints: readonly NebaBreakpoint[] = ['xs', 'sm', 'md', 'lg', 'xl'];

/** A bare value means "from `xs` up"; a map is already per-breakpoint. */
export function breakpointMap<T>(
  value: NebaResponsive<T> | undefined
): Partial<Record<NebaBreakpoint, T>> {
  if (value === undefined || value === null) return {};
  if (typeof value === 'object') return value as Partial<Record<NebaBreakpoint, T>>;

  return { xs: value };
}

/**
 * Turns a responsive value into the `--n-{name}-{breakpoint}` slots the CSS
 * reads, emitting only the breakpoints the caller actually named.
 *
 * The gaps are filled in by CSS rather than here: each breakpoint's rule falls
 * back through the ones below it, so `{ md: 6 }` needs one slot and not five.
 * That keeps the inline style on a grid item down to what was asked for.
 */
export function responsiveSlots<T>(
  name: string,
  value: NebaResponsive<T> | undefined,
  toCss: (value: T) => string
): React.CSSProperties {
  const map = breakpointMap(value);
  const slots: Record<string, string> = {};

  for (const breakpoint of breakpoints) {
    const entry = map[breakpoint];
    if (entry !== undefined) slots[`--n-${name}-${breakpoint}`] = toCss(entry);
  }

  return slots as React.CSSProperties;
}

/**
 * Fills in the `xs` entry of a partial map with the prop's own default.
 *
 * Without this, `spacing={{ md: 4 }}` would be a grid with no gutter at all
 * below 48rem — the CSS fallback rather than the documented default of 2 — and
 * a caller who narrowed one breakpoint would silently lose every other one. A
 * map says "from here up, use this instead"; it does not say "and nothing
 * below".
 */
export function withBaseline<T>(
  value: NebaResponsive<T> | undefined,
  baseline: T
): NebaResponsive<T> {
  if (value === undefined || value === null) return baseline;
  if (typeof value === 'object') {
    return { xs: baseline, ...(value as Partial<Record<NebaBreakpoint, T>>) };
  }

  return value;
}

/**
 * One responsive value laid over another, the way a more specific CSS
 * declaration is laid over a general one.
 *
 * This is what a pair like `spacing` and `columnSpacing` needs, and doing it
 * with `columnSpacing ?? spacing` is wrong in a way that only shows up once
 * either of them is a map: `spacing={2} columnSpacing={{ md: 6 }}` took the
 * override whole and left the row with no column gutter at all below 48rem,
 * because the map says nothing there and the baseline it fell back to was the
 * prop's own default rather than the `spacing` beside it.
 *
 * So the two are walked together. At each breakpoint the override wins if it
 * has said anything at or below there — and keeps winning above, because it is
 * the more specific of the two — and the base fills in until then. Only the
 * steps where the answer actually changes are emitted, so the result is still
 * one or two slots rather than five.
 */
export function overlayResponsive<T>(
  base: NebaResponsive<T>,
  override: NebaResponsive<T> | undefined
): NebaResponsive<T> {
  if (override === undefined || override === null) return base;

  const baseMap = breakpointMap(base);
  const overrideMap = breakpointMap(override);
  const merged: Partial<Record<NebaBreakpoint, T>> = {};

  let baseValue: T | undefined;
  let overrideValue: T | undefined;
  let effective: T | undefined;

  for (const breakpoint of breakpoints) {
    if (baseMap[breakpoint] !== undefined) baseValue = baseMap[breakpoint];
    if (overrideMap[breakpoint] !== undefined) overrideValue = overrideMap[breakpoint];

    const next = overrideValue !== undefined ? overrideValue : baseValue;

    if (next !== undefined && next !== effective) {
      merged[breakpoint] = next;
      effective = next;
    }
  }

  return merged;
}

/**
 * A number is pixels; a string is already a CSS length.
 *
 * Every length a caller can hand this library goes through here — a Stack's
 * overlap, a Container's measure — so that `640` and `'640px'` mean the same
 * thing everywhere rather than in the components that happened to think of it.
 */
export function lengthOf(value: number | string): string {
  return typeof value === 'number' ? `${value}px` : value;
}

/* ---------------------------------------------------------------------------
 * Being drawn at all
 *
 * The one responsive axis that is *not* a slot, and deliberately so. Whether an
 * element is drawn is a `display`, `display` has exactly two values here, and
 * Tailwind already ships both under every breakpoint — so this is ten literal
 * class names rather than a cascade and four media blocks. It is also the only
 * form that follows a consumer's own `@theme` without the library doing
 * anything: their build generates `md:hidden` from their `--breakpoint-md`.
 *
 * Written out per breakpoint because Tailwind only ever sees class names that
 * appear literally in the source — the same reason every table in
 * `internal/styles.ts` is a `Record` of complete strings.
 * ------------------------------------------------------------------------- */

/** Hidden below this breakpoint: the element exists from here up. */
export const hiddenBelowClasses: Record<NebaBreakpoint, string> = {
  xs: '',
  sm: 'max-sm:hidden',
  md: 'max-md:hidden',
  lg: 'max-lg:hidden',
  xl: 'max-xl:hidden'
};

/**
 * Hidden at this breakpoint and above: the element exists only under it.
 *
 * `xs` is `hidden` outright rather than empty — nothing is below a floor of
 * zero, so "only under `xs`" is nowhere at all.
 */
export const hiddenFromClasses: Record<NebaBreakpoint, string> = {
  xs: 'hidden',
  sm: 'sm:hidden',
  md: 'md:hidden',
  lg: 'lg:hidden',
  xl: 'xl:hidden'
};
