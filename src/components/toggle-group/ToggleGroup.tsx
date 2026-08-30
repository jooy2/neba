'use client';

import * as React from 'react';
import { ToggleGroup as BaseUIToggleGroup } from '@base-ui/react/toggle-group';
import { ButtonGroupContext, type ButtonGroupContextValue } from '../../internal/button-group.js';
import { cx } from '../../internal/styles.js';
import type { NebaElevation, NebaOrientation, NebaStyleProps, NebaVariant } from '../../types.js';

export interface ToggleGroupProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /** Passed to every toggle in the set. @default 'outline' */
  variant?: NebaVariant;
  /**
   * Which toggles are on, by their `value`. An array in both the single and the
   * multiple case — Base UI's own shape, and the one that does not change type
   * when `multiple` is turned on.
   */
  value?: readonly string[];
  /** Which start on, for an uncontrolled set. */
  defaultValue?: readonly string[];
  onValueChange?: (value: string[]) => void;
  /**
   * Whether more than one can be on at a time. Off, turning one on turns the
   * last one off — which is a one-of-a-set, and worth a second thought: if the
   * choice is a *value* rather than a state, that is a
   * [SegmentedButton](./segmented-button) or a [RadioGroup](./radio-group).
   * @default false
   */
  multiple?: boolean;
  /**
   * Which way the toggles run.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /** Drop shadow depth, passed to every toggle in the set. @default 0 */
  elevation?: NebaElevation;
  /** Disables every toggle in the set at once. */
  disabled?: boolean;
  /** Whether the arrow keys wrap around at the ends. @default true */
  loopFocus?: boolean;
  /** Stretches to the container and divides the width evenly between toggles. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

/**
 * The corners that face a neighbour are squared off, exactly as in a
 * [ButtonGroup](./button-group) — a run of toggles is one cut piece with score
 * lines in it. Logical properties, so the first toggle is on the right under RTL
 * and the right side is the one that stays round.
 */
const joinClasses: Record<NebaOrientation, string> = {
  horizontal: '[&>*:not(:first-child)]:rounded-s-none [&>*:not(:last-child)]:rounded-e-none',
  vertical: '[&>*:not(:first-child)]:rounded-t-none [&>*:not(:last-child)]:rounded-b-none'
};

/** Two hairline edges meeting would draw a seam twice as heavy as every other. */
const overlapClasses: Record<NebaOrientation, string> = {
  horizontal: '[&>*:not(:first-child)]:-ms-px',
  vertical: '[&>*:not(:first-child)]:-mt-px'
};

const baseClasses = [
  'inline-flex align-middle',
  '[&>*]:relative [&>*:hover]:z-10 [&>*:focus-visible]:z-10',
  '[&>*]:shrink-0'
].join(' ');

/**
 * A set of toggles that share one state.
 *
 * Two things are happening, and only one of them is visual. The corners facing a
 * neighbour are squared off — that is the look. The other half is that the set
 * owns the value: the toggles report into one array, `multiple` decides whether
 * more than one of them can be on, and `variant`, `size`, `color`, `density`,
 * `elevation` and `disabled` are set once here rather than on every toggle.
 *
 * Base UI owns the roving tab index — one tab stop for the whole set, arrow keys
 * between the members — which is what makes a toolbar of eight toggles two key
 * presses deep instead of eight.
 */
export const ToggleGroup = React.forwardRef<HTMLDivElement, ToggleGroupProps>(function ToggleGroup(
  {
    variant,
    size,
    color,
    density,
    elevation,
    value,
    defaultValue,
    onValueChange,
    multiple = false,
    orientation = 'horizontal',
    disabled,
    loopFocus = true,
    fullWidth = false,
    className,
    children,
    ...props
  },
  ref
) {
  // Every value passes through as-is, `undefined` included: a Toggle reads the
  // group only as a fallback, so "not set here" keeps meaning "use the
  // Toggle's own default" rather than turning into one.
  const context = React.useMemo<ButtonGroupContextValue>(
    () => ({ variant, size, color, density, elevation, disabled }),
    [variant, size, color, density, elevation, disabled]
  );

  return (
    <ButtonGroupContext.Provider value={context}>
      <BaseUIToggleGroup
        ref={ref}
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next)}
        multiple={multiple}
        orientation={orientation}
        disabled={disabled}
        loopFocus={loopFocus}
        className={cx(
          baseClasses,
          orientation === 'vertical' ? 'flex-col' : 'flex-row',
          joinClasses[orientation],
          // A Toggle defaults to `outline`, so an unset group is a hairline
          // group and does need the overlap.
          (variant ?? 'outline') === 'outline' ? overlapClasses[orientation] : '',
          fullWidth ? 'flex w-full [&>*]:flex-1' : '',
          className ?? ''
        )}
        {...props}
      >
        {children}
      </BaseUIToggleGroup>
    </ButtonGroupContext.Provider>
  );
});
