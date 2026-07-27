/**
 * The arithmetic and the vocabulary the three layout components share.
 *
 * Like `internal/styles.ts` this is the library talking to itself, and it lives
 * here rather than in either component's folder for the same reason
 * `internal/button-group.ts` does: `GridContainer` and `Grid` are one system in
 * two elements, and neither should have to import the other.
 *
 * What is *not* here is the layout itself. A column width is
 * `(100% + gap) * span / columns - gap`, it has to change at four breakpoints,
 * and it is the width of an element whose column count is declared on its
 * parent — none of which Tailwind can spell, because Tailwind only ever sees
 * class names written out literally and `columns` is a number a caller picks.
 * So the widths are real CSS in `styles.css`, driven by the `--n-*` slots this
 * file generates. That is the same split the rest of the library makes: per-
 * instance values go in inline custom properties, never in class names.
 */

import type * as React from 'react';
import type {
  NebaAlignItems,
  NebaAlignSelf,
  NebaBreakpoint,
  NebaJustifyContent,
  NebaResponsive
} from '../types';

/** Smallest first, which is also the order the media queries have to be in. */
export const breakpoints: readonly NebaBreakpoint[] = ['xs', 'sm', 'md', 'lg', 'xl'];

/**
 * One step of `spacing`, in `rem`.
 *
 * This is Tailwind's spacing scale, not Material's 8px one: `spacing={4}` is
 * `1rem`, exactly what `gap-4` and the `p-4` in Box's padding table already
 * mean. Every other number in this library is on that ladder, and a grid that
 * measured its gutters differently from the box around it would be the one
 * place a caller has to stop and convert.
 */
const SPACING_STEP = 0.25;

/** A bare value means "from `xs` up"; a map is already per-breakpoint. */
function breakpointMap<T>(
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
 * A count of columns, as a plain number for `calc()` to divide by.
 *
 * Rounded and floored at 1 because the value ends up as a divisor: a grid of
 * 2.5 columns is not a thing anyone meant, and a grid of 0 is a division by
 * zero that would take the width declaration down with it.
 */
export function columnCount(value: number): string {
  return String(Math.max(1, Math.round(value)));
}

/** A span or an offset. Same rounding; an offset of 0 is meaningful. */
export function columnUnits(value: number, min: number): string {
  return String(Math.max(min, Math.round(value)));
}

export const spanValue = (value: number) => columnUnits(value, 1);
export const offsetValue = (value: number) => columnUnits(value, 0);

/**
 * A gutter, as a length.
 *
 * Fractions are the point — `spacing={1.5}` is `0.375rem`, the same step
 * `gap-1.5` is — so the multiplication is rounded to five places rather than
 * left to print `0.30000000000000004rem` into the DOM.
 */
export function spacingValue(units: number): string {
  const rem = Math.max(0, units) * SPACING_STEP;

  return `${Number(rem.toFixed(5))}rem`;
}

/* ---------------------------------------------------------------------------
 * Alignment
 *
 * These *are* literal class names, so they stay in Tailwind. The positional
 * values are mapped onto `flex-start`/`flex-end` rather than the logical
 * `start`/`end` because a flex container is what is underneath, and the bare
 * logical keywords are the newer spelling of the two.
 * ------------------------------------------------------------------------- */

export const justifyContentClasses: Record<NebaJustifyContent, string> = {
  start: 'justify-start',
  center: 'justify-center',
  end: 'justify-end',
  'space-between': 'justify-between',
  'space-around': 'justify-around',
  'space-evenly': 'justify-evenly',
  stretch: 'justify-stretch'
};

export const alignItemsClasses: Record<NebaAlignItems, string> = {
  start: 'items-start',
  center: 'items-center',
  end: 'items-end',
  stretch: 'items-stretch',
  baseline: 'items-baseline'
};

/**
 * Where the *rows* sit when the grid is shorter than the box holding it. Only
 * ever visible on a container with a height of its own, which is why it takes
 * the full distribution vocabulary and `alignItems` does not.
 */
export const alignContentClasses: Record<NebaJustifyContent, string> = {
  start: 'content-start',
  center: 'content-center',
  end: 'content-end',
  'space-between': 'content-between',
  'space-around': 'content-around',
  'space-evenly': 'content-evenly',
  stretch: 'content-stretch'
};

export const alignSelfClasses: Record<NebaAlignSelf, string> = {
  auto: 'self-auto',
  start: 'self-start',
  center: 'self-center',
  end: 'self-end',
  stretch: 'self-stretch',
  baseline: 'self-baseline'
};
