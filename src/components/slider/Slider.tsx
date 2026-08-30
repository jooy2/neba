'use client';

import * as React from 'react';
import { Slider as BaseUISlider } from '@base-ui/react/slider';
import { cx, metaTextClasses, surfaceClasses, transitionClasses } from '../../internal/styles.js';
import type { NebaColor, NebaOrientation, NebaSize } from '../../types.js';

type BaseSliderProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUISlider.Root>,
  'className' | 'style' | 'render' | 'children' | 'orientation'
>;

export interface SliderProps extends BaseSliderProps {
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /**
   * Which way the slider runs. A vertical slider has no length of its own, so
   * give it a height — the default `h-40` is a starting point, not a rule.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /** The label above the track. */
  label?: React.ReactNode;
  /** Helper text below the track. */
  description?: React.ReactNode;
  /**
   * Shows the current value beside the label. Pass a function to format it —
   * the raw numbers and Base UI's already-localised strings are both handed in.
   * @default false
   */
  showValue?:
    boolean | ((formatted: readonly string[], values: readonly number[]) => React.ReactNode);
  /** Class names for the wrapper, not for the track. */
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Track thickness and thumb diameter.
 *
 * The thumb is deliberately far bigger than the track — it is the only part of
 * the control you can actually hit, and a thumb sized to match a 6px rail is a
 * thumb nobody catches on a touchscreen.
 */
const trackThicknessClasses: Record<NebaSize, string> = {
  xs: 'h-1',
  sm: 'h-1.5',
  md: 'h-1.5',
  lg: 'h-2',
  xl: 'h-2.5'
};

const verticalThicknessClasses: Record<NebaSize, string> = {
  xs: 'w-1',
  sm: 'w-1.5',
  md: 'w-1.5',
  lg: 'w-2',
  xl: 'w-2.5'
};

const thumbSizeClasses: Record<NebaSize, string> = {
  xs: 'size-3',
  sm: 'size-3.5',
  md: 'size-4',
  lg: 'size-5',
  xl: 'size-6'
};

/**
 * The control is taller than the track it holds so that the whole strip is a
 * pointer target, not just the rail. Base UI presses the track wherever you
 * click, and a 6px hit area would make that unusable.
 */
const trackBoxHeightClasses: Record<NebaSize, string> = {
  xs: 'h-4',
  sm: 'h-4.5',
  md: 'h-5',
  lg: 'h-6',
  xl: 'h-7'
};

const trackBoxWidthClasses: Record<NebaSize, string> = {
  xs: 'w-4',
  sm: 'w-4.5',
  md: 'w-5',
  lg: 'w-6',
  xl: 'w-7'
};

/**
 * The rail is the family at its faintest, the indicator is the fill. Both are
 * pills for the same reason the Switch's track is: this is a groove something
 * travels along, not a sheet.
 */
const railClasses = 'rounded-full bg-(--n-soft)';
const indicatorClasses = `rounded-full bg-(--n-fill) ${transitionClasses}`;

/**
 * The thumb is a disc of the same acrylic every other surface is made of, and it
 * grows a ring on hover and focus rather than growing itself — the no-transform
 * rule is not relaxed just because this particular part has no label on it.
 */
const thumbClasses = [
  'rounded-full border bg-(--neba-surface)',
  surfaceClasses,
  '[border-color:var(--n-line-hover)]',
  '[box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]',
  'cursor-grab select-none active:cursor-grabbing',
  transitionClasses,
  'hover:[box-shadow:var(--neba-shadow-2),0_0_0_4px_var(--n-soft)]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
  'data-[dragging]:[box-shadow:var(--neba-shadow-1),0_0_0_6px_var(--n-soft-hover)]'
].join(' ');

const disabledSliderClasses = '[filter:saturate(0.25)] opacity-70 [&_*]:cursor-not-allowed';

/**
 * A value chosen along a range.
 *
 * Pass an array to `value` or `defaultValue` and it becomes a range slider with
 * one thumb per entry — there is no separate `range` prop, because the shape of
 * the value already says which one this is.
 */
export const Slider = React.forwardRef<HTMLDivElement, SliderProps>(function Slider(
  {
    size = 'md',
    color = 'primary',
    orientation = 'horizontal',
    label,
    description,
    showValue = false,
    disabled = false,
    className,
    style,
    ...props
  },
  ref
) {
  const vertical = orientation === 'vertical';

  const slots = {
    '--n-fill': `var(--neba-${color}-fill)`,
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
    '--n-line-hover': `var(--neba-${color}-line-hover)`,
    '--n-ring': `var(--neba-${color}-ring)`
  } as React.CSSProperties;

  // One thumb per value. The count comes off whichever of the two was given, so
  // an uncontrolled range slider works without being told it is one.
  const values = props.value ?? props.defaultValue;
  const thumbCount = Array.isArray(values) ? values.length : 1;

  return (
    <BaseUISlider.Root
      ref={ref}
      orientation={orientation}
      disabled={disabled}
      className={cx(
        'flex',
        vertical ? 'w-fit flex-col items-center gap-2' : 'w-full flex-col gap-1.5',
        disabled ? disabledSliderClasses : '',
        className ?? ''
      )}
      style={{ ...slots, ...style }}
      {...props}
    >
      {label || showValue ? (
        <div className={`flex w-full items-baseline gap-2 ${metaTextClasses[size]}`}>
          {label ? (
            <BaseUISlider.Label
              className={
                disabled ? 'font-medium text-(--neba-disabled-fg)' : 'font-medium text-(--neba-fg)'
              }
            >
              {label}
            </BaseUISlider.Label>
          ) : null}
          {showValue ? (
            <BaseUISlider.Value className="ms-auto tabular-nums text-(--neba-muted-fg)">
              {typeof showValue === 'function' ? showValue : null}
            </BaseUISlider.Value>
          ) : null}
        </div>
      ) : null}

      <BaseUISlider.Control
        className={[
          'flex touch-none select-none items-center justify-center',
          vertical
            ? `${trackBoxWidthClasses[size]} h-40 flex-col`
            : `w-full ${trackBoxHeightClasses[size]}`
        ].join(' ')}
      >
        <BaseUISlider.Track
          className={[
            railClasses,
            vertical
              ? `${verticalThicknessClasses[size]} h-full`
              : `${trackThicknessClasses[size]} w-full`
          ].join(' ')}
        >
          <BaseUISlider.Indicator className={indicatorClasses} />
          {Array.from({ length: thumbCount }, (_, index) => (
            <BaseUISlider.Thumb
              key={index}
              index={index}
              className={`${thumbClasses} ${thumbSizeClasses[size]}`}
            />
          ))}
        </BaseUISlider.Track>
      </BaseUISlider.Control>

      {description ? (
        <div className={`${metaTextClasses[size]} text-(--neba-muted-fg)`}>{description}</div>
      ) : null}
    </BaseUISlider.Root>
  );
});
