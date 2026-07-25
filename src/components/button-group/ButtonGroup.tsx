import * as React from 'react';
import { ButtonGroupContext, type ButtonGroupContextValue } from '../../internal/button-group';
import type { NebaElevation, NebaOrientation, NebaStyleProps } from '../../types';

export interface ButtonGroupProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the buttons run. A vertical group is for a stacked menu of equal
   * actions; a horizontal one is the default because that is what a toolbar is.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /** Drop shadow depth, passed to every button in the group. @default 0 */
  elevation?: NebaElevation;
  /** Disables every button in the group at once. */
  disabled?: boolean;
  /** Stretches to the container and divides the width evenly between buttons. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

/**
 * The corners that face a neighbour are squared off, so the run of buttons reads
 * as one cut piece with score lines in it rather than as three separate sheets
 * that happen to be touching.
 *
 * Logical properties (`s`/`e`) rather than left/right: under RTL the first
 * button is on the right, and `rounded-l-none` would flatten the wrong side.
 */
const joinClasses: Record<NebaOrientation, string> = {
  horizontal: '[&>*:not(:first-child)]:rounded-s-none [&>*:not(:last-child)]:rounded-e-none',
  vertical: '[&>*:not(:first-child)]:rounded-t-none [&>*:not(:last-child)]:rounded-b-none'
};

/**
 * Only the hairline variant needs the overlap. Two `outline` buttons meeting
 * would otherwise show both of their borders and the seam would be twice as
 * heavy as every other edge on the page; pulling the second one back a pixel
 * makes the two share a single line.
 *
 * A `solid` group must *not* do this. Its seam is the plate edge — the white
 * inset hairline every filled surface carries — and overlapping would put one
 * button's fill over the neighbour's edge and merge the run into one blob.
 */
const overlapClasses: Record<NebaOrientation, string> = {
  horizontal: '[&>*:not(:first-child)]:-ms-px',
  vertical: '[&>*:not(:first-child)]:-mt-px'
};

const baseClasses = [
  'inline-flex align-middle',
  // Every child gets a stacking context so the hovered or focused one can come
  // forward — without it the focus ring is clipped by whichever button happens
  // to be painted after it.
  '[&>*]:relative [&>*:hover]:z-10 [&>*:focus-visible]:z-10',
  // A group is a set of equal actions, so they should be the same height even
  // when one of them has an icon and the others do not.
  '[&>*]:shrink-0'
].join(' ');

/**
 * A row of buttons that belong together.
 *
 * Two things are happening here, and only one of them is visual. The corners
 * that face a neighbour are squared off — that is the look. The other half is
 * that `variant`, `size`, `color`, `density`, `elevation` and `disabled` are set
 * once for the set rather than repeated on every button; a group where one
 * button is a size out is the failure this exists to prevent.
 *
 * The buttons stay real `<Button>`s. This is not a segmented control and it does
 * not manage selection — for one-of-a-set use a RadioGroup, which is what that
 * actually is.
 */
export const ButtonGroup = React.forwardRef<HTMLDivElement, ButtonGroupProps>(function ButtonGroup(
  {
    variant,
    size,
    color,
    density,
    elevation,
    orientation = 'horizontal',
    disabled,
    fullWidth = false,
    className,
    children,
    ...props
  },
  ref
) {
  // Every value is passed through as-is, including `undefined`. A Button reads
  // the group only as a fallback, so "not set here" keeps meaning "use the
  // Button's own default" rather than turning into one.
  const context = React.useMemo<ButtonGroupContextValue>(
    () => ({ variant, size, color, density, elevation, disabled }),
    [variant, size, color, density, elevation, disabled]
  );

  return (
    <ButtonGroupContext.Provider value={context}>
      <div
        ref={ref}
        role="group"
        className={[
          baseClasses,
          orientation === 'vertical' ? 'flex-col' : 'flex-row',
          joinClasses[orientation],
          // `variant` defaults to `solid` on a Button, so an unset group is a
          // solid group and must not overlap.
          (variant ?? 'solid') === 'outline' ? overlapClasses[orientation] : '',
          fullWidth ? 'flex w-full [&>*]:flex-1' : '',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        {...props}
      >
        {children}
      </div>
    </ButtonGroupContext.Provider>
  );
});
