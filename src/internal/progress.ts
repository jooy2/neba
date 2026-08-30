/**
 * What the three progress indicators share.
 *
 * `ProgressLinear`, `ProgressCircular` and `ProgressBox` are three different
 * shapes answering one question — how far along is this, and is it moving at
 * all — so the parts that are *not* the shape belong here: the colour slots,
 * the size ladders, and the arithmetic that turns `value`/`min`/`max` into a
 * fraction.
 *
 * The shapes themselves are all that is left in each component, which is the
 * point: they are the only thing that genuinely differs.
 *
 * `Meter` reads three of these too — the colour slots, the bar's thickness and
 * the fraction — because it is the same groove with different semantics, and a
 * meter whose `md` were a pixel off the progress bar's would be visible the
 * first time a page carried both.
 */

import type * as React from 'react';
import type { NebaColor, NebaSize } from '../types.js';

/**
 * The props all three indicators take.
 *
 * Declared once and extended rather than copied three times, because the whole
 * claim being made is that these are the same component in three shapes: a
 * `value` of `null` has to mean the same thing on a bar, a ring and a row of
 * plates, or the trio is three components that happen to share a prefix.
 */
export interface ProgressSharedProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /**
   * How far along, between `min` and `max`.
   *
   * `null` — the default — is the indeterminate case: something is happening
   * and nobody knows how much of it is left. That is the default on purpose. An
   * indicator that has not been told a value should say so rather than draw an
   * empty bar, which is a claim that no progress has been made.
   * @default null
   */
  value?: number | null;
  /** @default 0 */
  min?: number;
  /** @default 100 */
  max?: number;
  /** A name for what is loading. Read out with the value by a screen reader. */
  label?: React.ReactNode;
  /**
   * Shows the value as text beside the shape. Percentage of the range unless
   * `format` says otherwise.
   * @default false
   */
  showValue?: boolean;
  /**
   * How to format the value when it is shown — `Intl.NumberFormat` options, so
   * bytes and currencies work as well as plain numbers. Without it the value is
   * a percentage of `min`…`max`, which is the only formatting that holds for a
   * range nobody described.
   */
  format?: Intl.NumberFormatOptions;
}

/**
 * The slots a progress indicator reads.
 *
 * A progress bar *is* the thing being coloured — unlike a Box, which holds
 * other people's content — so the fill is the family's own. There is no
 * elevation ladder here on purpose: an indicator is drawn into the surface it
 * sits on, the way a groove is cut into a sheet, and a groove does not float.
 */
export function progressSlots(color: NebaColor): React.CSSProperties {
  return {
    '--n-fill': `var(--neba-${color}-fill)`,
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
    '--n-soft-press': `var(--neba-${color}-soft-press)`,
    '--n-line': `var(--neba-${color}-line)`
  } as React.CSSProperties;
}

/**
 * How thick the linear track is.
 *
 * Its own ladder rather than a fraction of `controlHeightClasses`: a bar is not
 * a control you can put a label inside, and at `md` it wants to be the weight of
 * a rule between two paragraphs, not a third of a button.
 */
export const barThicknessClasses: Record<NebaSize, string> = {
  xs: 'h-0.5',
  sm: 'h-[3px]',
  md: 'h-1',
  lg: 'h-1.5',
  xl: 'h-2'
};

/**
 * The diameter of the ring, in pixels.
 *
 * Numbers rather than classes because the same value has to reach the SVG's
 * `viewBox` arithmetic, and a ring is one of the few things in the library that
 * cannot be described by a Tailwind class alone.
 *
 * They land just under the control ladder at every step — a `md` ring is 20px
 * inside a 32px control — so a spinner dropped into a button, a field or a
 * table row never makes the row taller than it already was.
 */
export const ringDiameters: Record<NebaSize, number> = {
  xs: 14,
  sm: 16,
  md: 20,
  lg: 26,
  xl: 32
};

/** The ring's stroke, thickening with the ring so the hole stays in proportion. */
export const ringStrokes: Record<NebaSize, number> = {
  xs: 1.5,
  sm: 1.75,
  md: 2,
  lg: 2.5,
  xl: 3
};

/** One plate of a `ProgressBox`, on the tick ladder — an indicator, not a control. */
export const plateSizeClasses: Record<NebaSize, string> = {
  xs: 'size-2',
  sm: 'size-2.5',
  md: 'size-3',
  lg: 'size-4',
  xl: 'size-5'
};

/** The corner cut off a plate: the same ~30% the tick boxes use. */
export const plateRadiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-[0.1875rem]',
  sm: 'rounded-[0.25rem]',
  md: 'rounded-[0.28125rem]',
  lg: 'rounded-[0.375rem]',
  xl: 'rounded-[0.4375rem]'
};

/** Between the plates. Tight — they are one object, not a row of squares. */
export const plateGapClasses: Record<NebaSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1',
  md: 'gap-1.5',
  lg: 'gap-1.5',
  xl: 'gap-2'
};

/**
 * `value` as a fraction of the range, or `null` when there is nothing to say.
 *
 * `null` is the indeterminate case and it is the default: a component that has
 * not been told how far along it is should say so, not draw an empty bar that
 * looks like zero progress.
 *
 * The clamp is not defensive programming for its own sake — `value` usually
 * arrives from a division somewhere, and a bar that renders 140% wide because
 * one request finished twice is a worse bug than a bar that sits full.
 */
export function progressFraction(
  value: number | null | undefined,
  min: number,
  max: number
): number | null {
  if (value === null || value === undefined || Number.isNaN(value)) {
    return null;
  }

  if (max <= min) {
    return null;
  }

  return Math.min(1, Math.max(0, (value - min) / (max - min)));
}

/**
 * What the value reads as, both on screen and to a screen reader.
 *
 * Base UI's own default is `${value}%`, which is right only when the range
 * happens to be 0–100 — "3%" for step 3 of 4 is worse than saying nothing. So
 * the percentage is computed from the fraction, and a caller who passed
 * `format` gets Base UI's formatted string instead, because at that point they
 * have said what the number means.
 */
export function progressText(
  fraction: number | null,
  formatted: string | null,
  hasFormat: boolean
): string | null {
  if (fraction === null) {
    return null;
  }

  return hasFormat ? formatted : `${Math.round(fraction * 100)}%`;
}

/**
 * The same string, shaped for Base UI's `getAriaValueText`.
 *
 * `undefined` when there is no value, which hands the indeterminate case back
 * to Base UI — it already announces "indeterminate progress", and re-inventing
 * that here would be one more English string the library has to own.
 */
export function progressAriaText(
  fraction: number | null,
  hasFormat: boolean
): ((formatted: string | null) => string) | undefined {
  if (fraction === null) {
    return undefined;
  }

  return (formatted) => progressText(fraction, formatted, hasFormat) ?? '';
}
