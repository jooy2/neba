'use client';

import * as React from 'react';
import { Meter as BaseUIMeter } from '@base-ui/react/meter';
import {
  barThicknessClasses,
  progressAriaText,
  progressFraction,
  progressSlots,
  thresholdColor,
  type ProgressThickness
} from '../../internal/progress.js';
import { cx, metaTextClasses, stackGapClasses } from '../../internal/styles.js';
import type { NebaColor, NebaSize, NebaThreshold } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

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
   * The language the value is written in, as a BCP 47 tag such as `de-DE`. Left
   * out, it is a provider's `locale`, and then the reader's runtime, which a
   * server and a browser do not always share.
   */
  locale?: string;
  /**
   * Where the bar changes colour, smallest `from` first. The family of the last
   * threshold the value has reached wins; below all of them `color` stands.
   */
  thresholds?: readonly NebaThreshold[];
  /** Thickness of the groove. Nothing else on a bar has a size. @default 'md' */
  size?: NebaSize;
  /**
   * The groove's thickness in pixels, when the step's own is not the one you
   * want. The same prop a [ProgressLinear](./progress-linear) takes, because
   * the two draw the same groove.
   */
  thickness?: ProgressThickness;
  /** The family the bar carries before any threshold is reached. @default 'primary' */
  color?: NebaColor;
}

/** The same groove a ProgressLinear cuts, because they are the same object. */
const trackClasses = 'relative w-full overflow-hidden rounded-full bg-(--n-soft)';

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
export const Meter = React.forwardRef<HTMLDivElement, MeterProps>(function Meter(rawProps, ref) {
  const {
    value,
    min = 0,
    max = 100,
    label,
    showValue = false,
    format,
    locale,
    thresholds,
    thickness,
    size = 'md',
    color = 'primary',
    className,
    style,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'locale']);

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
      locale={locale}
      // The reading announced is the reading drawn. Base UI's own writes the
      // share with `Intl`, which in some languages puts a space before the `%`
      // that the text beside the bar does not have.
      getAriaValueText={progressAriaText(fraction, hasFormat)}
      className={cx('flex w-full flex-col', stackGapClasses[size], className ?? '')}
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
              {/* Without `format` the reading is the share of the range as a
                  whole percent, the way the progress indicators write it; with
                  one, it is the number in the units the caller gave. */}
              {(formatted) => (hasFormat ? formatted : `${Math.round((fraction ?? 0) * 100)}%`)}
            </BaseUIMeter.Value>
          ) : null}
        </div>
      ) : null}

      <BaseUIMeter.Track
        className={`${trackClasses} ${barThicknessClasses[size]}`}
        style={thickness === undefined ? undefined : { height: `${thickness}px` }}
      >
        <BaseUIMeter.Indicator
          // An inline width, never a transform — and a transition on it so a
          // reading that changes travels there rather than jumping.
          className="absolute top-0 rounded-full bg-(--n-fill) [transition:width_var(--neba-duration-fill)_var(--neba-ease),background-color_var(--neba-duration)_var(--neba-ease)]"
        />
      </BaseUIMeter.Track>
    </BaseUIMeter.Root>
  );
});
