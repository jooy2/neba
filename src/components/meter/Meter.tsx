'use client';

import * as React from 'react';
import { Meter as BaseUIMeter } from '@base-ui/react/meter';
import { barThicknessClasses, progressFraction, progressSlots } from '../../internal/progress.js';
import { metaTextClasses, stackGapClasses } from '../../internal/styles.js';
import type { NebaColor, NebaSize } from '../../types.js';

/**
 * A point on the scale, and the colour family the bar takes once the value has
 * reached it.
 *
 * This is the one component in the library where the semantic colour is allowed
 * to be *computed*, and it is the reason the prop exists: a meter's whole job is
 * that where the value sits is what it means — 40% of a disk is fine, 95% is a
 * page. Left to the caller, that would be a ternary at every call site, and the
 * fourth one would disagree with the first three about where amber starts.
 */
export interface MeterThreshold {
  /** The value from which this family applies, in the meter's own units. */
  from: number;
  /** What the bar turns at and above that point. */
  color: NebaColor;
}

export interface MeterProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /**
   * How much there is. Required, and that is the whole difference from a
   * [ProgressLinear](./progress-linear): a meter reports a quantity that is
   * already known, so there is no indeterminate case to have a default for.
   */
  value: number;
  /** @default 0 */
  min?: number;
  /** @default 100 */
  max?: number;
  /** A name for what is being measured. Read out with the value. */
  label?: React.ReactNode;
  /**
   * Shows the value as text beside the bar. A percentage of the range unless
   * `format` says otherwise.
   * @default false
   */
  showValue?: boolean;
  /**
   * How to write the value — `Intl.NumberFormat` options, so bytes, currencies
   * and plain counts all work. A meter usually has real units, which is when
   * this matters more than it does on a progress bar.
   */
  format?: Intl.NumberFormatOptions;
  /**
   * Where the bar changes colour, smallest `from` first. The family of the last
   * threshold the value has reached wins; below all of them `color` stands.
   */
  thresholds?: readonly MeterThreshold[];
  /** Thickness of the groove. Nothing else on a bar has a size. @default 'md' */
  size?: NebaSize;
  /** The family the bar carries before any threshold is reached. @default 'primary' */
  color?: NebaColor;
}

/** The same groove a ProgressLinear cuts, because they are the same object. */
const trackClasses = 'relative w-full overflow-hidden rounded-full bg-(--n-soft)';

/**
 * Which family the value has earned.
 *
 * Written as a scan rather than a sort so the array is read in the order it was
 * given: thresholds are meant to be listed in ascending order, and silently
 * reordering them would hide the one call site that did not.
 */
function thresholdColor(
  value: number,
  color: NebaColor,
  thresholds: readonly MeterThreshold[] | undefined
): NebaColor {
  if (!thresholds || thresholds.length === 0) return color;

  let current = color;

  for (const threshold of thresholds) {
    if (value >= threshold.from) current = threshold.color;
  }

  return current;
}

/**
 * How much of something there is, on a scale that is known in advance — disk
 * used, seats taken, quota spent, a password's strength.
 *
 * It looks exactly like a [ProgressLinear](./progress-linear) and is not one.
 * A progress bar is about *time*: something is happening and this is how far it
 * has got, so it may have no value at all and it is expected to move on its own.
 * A meter is about *quantity*: the number is already known, it does not move
 * unless the thing it measures does, and it is meaningful to say the reading is
 * bad — which is what `thresholds` is for.
 *
 * Base UI's Meter owns the semantics: `role="meter"`, the value and range
 * attributes, and formatting the number for `aria-valuetext`.
 */
export const Meter = React.forwardRef<HTMLDivElement, MeterProps>(function Meter(
  {
    value,
    min = 0,
    max = 100,
    label,
    showValue = false,
    format,
    thresholds,
    size = 'md',
    color = 'primary',
    className,
    style,
    ...props
  },
  ref
) {
  const fraction = progressFraction(value, min, max);
  const family = thresholdColor(value, color, thresholds);
  const hasFormat = format !== undefined;

  return (
    <BaseUIMeter.Root
      ref={ref}
      value={value}
      min={min}
      max={max}
      format={format}
      className={['flex w-full flex-col', stackGapClasses[size], className ?? '']
        .filter(Boolean)
        .join(' ')}
      style={{ ...progressSlots(family), ...style }}
      {...props}
    >
      {label || showValue ? (
        <div
          className={[
            'flex items-baseline gap-2',
            label ? 'justify-between' : 'justify-end',
            metaTextClasses[size]
          ].join(' ')}
        >
          {label ? (
            <BaseUIMeter.Label className="min-w-0 truncate text-(--neba-fg)">
              {label}
            </BaseUIMeter.Label>
          ) : null}
          {showValue ? (
            <BaseUIMeter.Value className="shrink-0 tabular-nums text-(--neba-muted-fg)">
              {/* Base UI's own default is the raw number, which is only right
                  once somebody has said what the units are. Without `format`
                  the honest reading is a share of the range. */}
              {(formatted) => (hasFormat ? formatted : `${Math.round((fraction ?? 0) * 100)}%`)}
            </BaseUIMeter.Value>
          ) : null}
        </div>
      ) : null}

      <BaseUIMeter.Track className={`${trackClasses} ${barThicknessClasses[size]}`}>
        <BaseUIMeter.Indicator
          // An inline width, never a transform — and a transition on it so a
          // reading that changes travels there rather than jumping.
          className="absolute top-0 rounded-full bg-(--n-fill) [transition:width_var(--neba-duration-fill)_var(--neba-ease),background-color_var(--neba-duration)_var(--neba-ease)]"
        />
      </BaseUIMeter.Track>
    </BaseUIMeter.Root>
  );
});
