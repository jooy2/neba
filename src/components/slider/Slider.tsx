'use client';

import * as React from 'react';
import { Slider as BaseUISlider } from '@base-ui/react/slider';
import {
  cx,
  hasContent,
  metaTextClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import { WidthSizer } from '../../internal/sizer.js';
import type {
  NebaColor,
  NebaFieldSlot,
  NebaOrientation,
  NebaSize,
  NebaSlots
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

type BaseSliderProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUISlider.Root>,
  'className' | 'style' | 'render' | 'children' | 'orientation'
>;

/**
 * The parts a Slider draws behind its root.
 *
 * `control` is the whole strip a press lands on, which is deliberately taller
 * than the `track` drawn inside it. There is no `error`: a slider always has a
 * value in range, so there is nothing for one to say.
 */
export type SliderSlot = Exclude<NebaFieldSlot, 'error'> | 'track' | 'indicator' | 'thumb' | 'mark';

/** One labelled point on the track. */
export interface SliderMark {
  /** Where it sits, in the slider's own units. */
  value: number;
  /** What is written under it. A mark with no label is a tick on its own. */
  label?: React.ReactNode;
}

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
  /**
   * Points named along the track: `1 / 100 / 250 / 500` under a count, or
   * "realistic" and "abstract" at the two ends of a style axis.
   *
   * An array is the marks, each at its own `value`, and a mark with no `label`
   * is a tick on its own. `true` is a tick at every `step`, which is worth
   * pairing with a step you chose — the default `step={1}` over the default
   * range is a hundred of them.
   *
   * A mark is read by the eye and not by a screen reader: the value is already
   * announced by the thumb, and a second reading of the same numbers is noise.
   * @default false
   */
  marks?: boolean | readonly SliderMark[];
  /** Class names for the root: the column holding the label, the strip and the
   * line under it. The parts behind it are `classNames`. */
  className?: string;
  /**
   * Class names for the parts behind the root — the strip, the rail, the fill,
   * a thumb, a mark.
   */
  classNames?: NebaSlots<SliderSlot>;
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
 * The marks a `marks` of `true` stands for: one at every step.
 *
 * Floored at the step rather than counted up by it, so an axis whose range is
 * not a whole number of steps still lands its last mark on a real value. The
 * ceiling is what stops a `step` of `0.01` from putting ten thousand elements
 * in the document; past it the caller is asked for the list they meant.
 */
const MAX_STEP_MARKS = 100;

function stepMarks(min: number, max: number, step: number): SliderMark[] {
  const span = max - min;

  if (!(step > 0) || !(span > 0) || span / step > MAX_STEP_MARKS) return [];

  const count = Math.floor(span / step);

  // `min + index * step` rather than an accumulator: adding 0.1 to itself ten
  // times does not reach 1, and a mark that misses its own value by a
  // rounding error lands a pixel off the thumb that stops on it.
  return Array.from({ length: count + 1 }, (_, index) => ({ value: min + index * step }));
}

/**
 * Where a mark sits along the track, as a percentage of the range.
 *
 * The two insets are the ones Base UI moves its own thumb with, so a mark and
 * the thumb that reaches it are measured from the same edge — including under
 * RTL, where `inset-inline-start` flips and the arithmetic does not have to.
 */
function markPosition(mark: SliderMark, min: number, max: number, vertical: boolean) {
  const percent = ((mark.value - min) / (max - min)) * 100;

  return vertical ? { insetBlockEnd: `${percent}%` } : { insetInlineStart: `${percent}%` };
}

/**
 * A mark is centred by a flex box with no size on the axis it sits on: a child
 * wider than its container overflows it equally on both sides, which centres
 * the label on the value without a `translate` and without the sign flip one
 * would need under RTL.
 */
const markStackClasses = 'absolute flex text-(--neba-muted-fg)';
const tickClasses = 'shrink-0 rounded-full bg-(--neba-border)';

/**
 * A value chosen along a range.
 *
 * Pass an array to `value` or `defaultValue` and it becomes a range slider with
 * one thumb per entry — there is no separate `range` prop, because the shape of
 * the value already says which one this is.
 */
export const Slider = React.forwardRef<HTMLDivElement, SliderProps>(function Slider(rawProps, ref) {
  const {
    size = 'md',
    color = 'primary',
    orientation = 'horizontal',
    label,
    description,
    showValue = false,
    marks = false,
    disabled = false,
    classNames,
    min = 0,
    max = 100,
    step = 1,
    className,
    style,
    ...props
  } = useStyleDefaults(rawProps, ['size']);

  const vertical = orientation === 'vertical';

  const markList = React.useMemo(
    () => (marks === true ? stepMarks(min, max, step) : marks === false ? [] : [...marks]),
    [marks, min, max, step]
  );

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

  const control = (
    <BaseUISlider.Control
      className={cx(
        'flex touch-none select-none items-center justify-center',
        vertical
          ? `${trackBoxWidthClasses[size]} h-full flex-col`
          : `w-full ${trackBoxHeightClasses[size]}`,
        classNames?.control
      )}
    >
      <BaseUISlider.Track
        className={cx(
          railClasses,
          vertical
            ? `${verticalThicknessClasses[size]} h-full`
            : `${trackThicknessClasses[size]} w-full`,
          classNames?.track
        )}
      >
        <BaseUISlider.Indicator className={cx(indicatorClasses, classNames?.indicator)} />
        {Array.from({ length: thumbCount }, (_, index) => (
          <BaseUISlider.Thumb
            key={index}
            index={index}
            className={cx(thumbClasses, thumbSizeClasses[size], classNames?.thumb)}
          />
        ))}
      </BaseUISlider.Track>
    </BaseUISlider.Control>
  );

  const labelled = markList.some((mark) => hasContent(mark.label));

  /*
   * The marks sit beside the control rather than inside the track: a tick drawn
   * on the rail has to stay legible over both the fill and the groove, and the
   * only ways to do that are an opacity or a second colour that neither the
   * palette nor the state rules have a place for.
   *
   * The row is `aria-hidden` on purpose. The thumb already announces its value
   * and its range, and a screen reader reading the same numbers again as loose
   * text before it is noise rather than information.
   */
  const markRow =
    markList.length > 0 ? (
      <div
        aria-hidden="true"
        className={cx(
          'relative',
          metaTextClasses[size],
          vertical ? 'h-full ps-3' : labelled ? 'h-[calc(1lh+0.375rem)] w-full' : 'h-1.5 w-full'
        )}
      >
        {markList.map((mark, index) => (
          <span
            key={`${mark.value}:${index}`}
            className={cx(
              markStackClasses,
              vertical ? 'start-0 h-0 items-center gap-1.5' : 'top-0 w-0 flex-col items-center',
              classNames?.mark
            )}
            style={markPosition(mark, min, max, vertical)}
          >
            <span className={cx(tickClasses, vertical ? 'h-px w-1.5' : 'h-1.5 w-px')} />
            {hasContent(mark.label) ? (
              <span className="whitespace-nowrap">{mark.label}</span>
            ) : null}
          </span>
        ))}
        {/* Every mark is out of flow, so a vertical column would have no width
            of its own. The widest label is what it should be, which is the one
            question the sizer answers. */}
        {vertical ? (
          <WidthSizer
            samples={markList.filter((mark) => hasContent(mark.label)).map((mark) => mark.label)}
          />
        ) : null}
      </div>
    ) : null;

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
      min={min}
      max={max}
      step={step}
      {...props}
    >
      {label || showValue ? (
        <div className={`flex w-full items-baseline gap-2 ${metaTextClasses[size]}`}>
          {label ? (
            <BaseUISlider.Label
              className={cx(
                'font-medium',
                disabled ? 'text-(--neba-disabled-fg)' : 'text-(--neba-fg)',
                classNames?.label
              )}
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

      {vertical ? (
        <div className="flex h-40 items-stretch">
          {control}
          {markRow}
        </div>
      ) : (
        control
      )}
      {vertical ? null : markRow}

      {description ? (
        <div
          className={cx(metaTextClasses[size], 'text-(--neba-muted-fg)', classNames?.description)}
        >
          {description}
        </div>
      ) : null}
    </BaseUISlider.Root>
  );
});
