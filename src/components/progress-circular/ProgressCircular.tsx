'use client';

import * as React from 'react';
import { Progress } from '@base-ui/react/progress';
import {
  progressAriaText,
  progressFraction,
  progressSlots,
  progressText,
  ringDiameters,
  ringStrokes,
  type ProgressSharedProps
} from '../../internal/progress.js';
import { cx, gapClasses, metaTextClasses } from '../../internal/styles.js';
import type { NebaColor, NebaSize } from '../../types.js';

export interface ProgressCircularProps extends ProgressSharedProps {
  /** Diameter of the ring. Sits just under the control ladder at every step. */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
}

/**
 * A ring that fills, and the one to reach for when there is no room for a bar —
 * inside a button, at the end of a table row, next to a field.
 *
 * The value and the label sit *beside* the ring rather than inside it. A number
 * in the middle of a dial is the picture everyone has of this component, and it
 * only works at two of the five sizes: at `xs` the ring is fourteen pixels
 * across and there is nowhere for "40%" to go. Beside it, every size reads.
 */
export const ProgressCircular = React.forwardRef<HTMLDivElement, ProgressCircularProps>(
  function ProgressCircular(
    {
      size = 'md',
      color = 'primary',
      value = null,
      min = 0,
      max = 100,
      label,
      showValue = false,
      format,
      className,
      style,
      ...props
    },
    ref
  ) {
    const fraction = progressFraction(value, min, max);
    const indeterminate = fraction === null;
    const hasFormat = format !== undefined;

    const diameter = ringDiameters[size];
    const stroke = ringStrokes[size];
    const centre = diameter / 2;
    // The stroke straddles the path, so the radius has to come in by half of it
    // or the ring is clipped by its own viewBox.
    const radius = centre - stroke / 2;
    const circumference = 2 * Math.PI * radius;

    // Indeterminate draws a fixed quarter-arc and turns; determinate holds still
    // and lets the gap close. Both are one dash pattern on one circle.
    const dashArray = indeterminate
      ? `${circumference * 0.28} ${circumference}`
      : `${circumference}`;
    const dashOffset = indeterminate ? 0 : circumference * (1 - fraction);

    return (
      <Progress.Root
        ref={ref}
        value={value ?? null}
        min={min}
        max={max}
        format={format}
        getAriaValueText={progressAriaText(fraction, hasFormat)}
        className={cx(
          'inline-flex items-center',
          gapClasses[size],
          metaTextClasses[size],
          className ?? ''
        )}
        style={{ ...progressSlots(color), ...style }}
        {...props}
      >
        <svg
          // The rotation is on the whole `<svg>`, not on a group inside it:
          // `transform-origin: center` resolves against an element's border box,
          // which an SVG child does not have one of unless `transform-box` is
          // set as well. One element, one rule, no surprises across browsers.
          className={indeterminate ? 'neba-ring-spin shrink-0' : 'shrink-0'}
          width={diameter}
          height={diameter}
          viewBox={`0 0 ${diameter} ${diameter}`}
          fill="none"
          aria-hidden="true"
        >
          <circle cx={centre} cy={centre} r={radius} stroke="var(--n-soft)" strokeWidth={stroke} />
          <circle
            cx={centre}
            cy={centre}
            r={radius}
            stroke="var(--n-accent)"
            strokeWidth={stroke}
            strokeLinecap="round"
            strokeDasharray={dashArray}
            strokeDashoffset={dashOffset}
            // An SVG geometry attribute rather than a CSS transform: this is
            // where the arc starts, not something the ring does when its state
            // changes. Without it a determinate ring would fill from 3 o'clock.
            transform={`rotate(-90 ${centre} ${centre})`}
            className="[transition:stroke-dashoffset_var(--neba-duration-fill)_var(--neba-ease)]"
          />
        </svg>

        {label ? (
          <Progress.Label className="min-w-0 truncate text-(--neba-fg)">{label}</Progress.Label>
        ) : null}
        {showValue ? (
          <Progress.Value className="shrink-0 tabular-nums text-(--neba-muted-fg)">
            {(formatted) => progressText(fraction, formatted, hasFormat)}
          </Progress.Value>
        ) : null}
      </Progress.Root>
    );
  }
);
