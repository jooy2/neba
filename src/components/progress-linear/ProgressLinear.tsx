import * as React from 'react';
import { Progress } from '@base-ui/react/progress';
import {
  barThicknessClasses,
  progressAriaText,
  progressFraction,
  progressSlots,
  progressText,
  type ProgressSharedProps
} from '../../internal/progress.js';
import { metaTextClasses, stackGapClasses } from '../../internal/styles.js';
import type { NebaColor, NebaSize } from '../../types.js';

export interface ProgressLinearProps extends ProgressSharedProps {
  /** Thickness of the groove. Nothing else on a bar has a size. */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
}

/**
 * The groove and the segment in it are both fully rounded, which is the one
 * place the library's rule about pills does not apply: at four pixels tall
 * there is no flat run left to preserve, and a square-ended bar reads as a
 * rendering bug rather than as a cut edge.
 */
const trackClasses = 'relative w-full overflow-hidden rounded-full bg-(--n-soft)';

/**
 * A bar that fills. The workhorse: it is the only one of the three that can
 * show *how much* is left at a glance, because length is the one quantity a
 * reader can compare without counting.
 *
 * Base UI's Progress owns the semantics — `role="progressbar"`, the value and
 * range attributes, `aria-valuetext`, and dropping the value entirely when the
 * bar is indeterminate — and it also computes the fill width, so the determinate
 * case here is a class list and nothing else.
 */
export const ProgressLinear = React.forwardRef<HTMLDivElement, ProgressLinearProps>(
  function ProgressLinear(
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

    return (
      <Progress.Root
        ref={ref}
        value={value ?? null}
        min={min}
        max={max}
        format={format}
        getAriaValueText={progressAriaText(fraction, hasFormat)}
        className={['flex w-full flex-col', stackGapClasses[size], className ?? '']
          .filter(Boolean)
          .join(' ')}
        style={{ ...progressSlots(color), ...style }}
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
              <Progress.Label className="min-w-0 truncate text-(--neba-fg)">{label}</Progress.Label>
            ) : null}
            {showValue ? (
              <Progress.Value className="shrink-0 tabular-nums text-(--neba-muted-fg)">
                {(formatted) => progressText(fraction, formatted, hasFormat)}
              </Progress.Value>
            ) : null}
          </div>
        ) : null}

        <Progress.Track className={`${trackClasses} ${barThicknessClasses[size]}`}>
          <Progress.Indicator
            className={[
              'absolute rounded-full bg-(--n-fill)',
              // `neba-sweep` supplies the position, the width and the animation;
              // when the value is known Base UI supplies the width instead and
              // this transition is what makes it move rather than jump. Both
              // change an inline size, never a transform.
              indeterminate
                ? 'neba-sweep'
                : 'top-0 [transition:width_var(--neba-duration-fill)_var(--neba-ease)]'
            ].join(' ')}
          />
        </Progress.Track>
      </Progress.Root>
    );
  }
);
