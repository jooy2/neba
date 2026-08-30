'use client';

import * as React from 'react';
import { Avatar, type AvatarShape } from '../avatar/Avatar.js';
import { AvatarGroupContext, type AvatarGroupContextValue } from '../../internal/avatar-group.js';
import type { NebaColor, NebaElevation, NebaSize, NebaVariant } from '../../types.js';

export interface AvatarGroupProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * How many avatars are drawn before the rest become a count. Left out, every
   * one of them is drawn.
   */
  max?: number;
  /**
   * How many there are altogether, when the group was handed only the first
   * few. Without it the count is worked out from the children, which is right
   * only when all of them were passed.
   */
  total?: number;
  /**
   * How far each avatar sits under the one before it — a CSS length, or a
   * number of pixels. Left out it is a fraction of `size`, which keeps the
   * overlap looking the same at every step.
   */
  overlap?: number | string;
  /** Passed to every avatar in the group. @default 'md' */
  size?: NebaSize;
  /** Passed to every avatar in the group. @default 'circle' */
  shape?: AvatarShape;
  /** Passed to every avatar in the group. @default 'text' */
  variant?: NebaVariant;
  /** Passed to every avatar in the group. @default 'primary' */
  color?: NebaColor;
  /** Passed to every avatar in the group. @default 0 */
  elevation?: NebaElevation;
  /** The avatars. */
  children?: React.ReactNode;
}

/**
 * How far one avatar sits under the last, per step.
 *
 * Roughly a third of the box at every size: enough that the stack reads as a
 * stack, and not so much that a face is hidden behind the next one.
 */
const overlapSizes: Record<NebaSize, string> = {
  xs: '0.375rem',
  sm: '0.5rem',
  md: '0.625rem',
  lg: '0.75rem',
  xl: '0.875rem'
};

/**
 * The ring between two overlapping avatars.
 *
 * The one place the library draws a hard outline in the page's own surface
 * colour rather than an acrylic edge, and it is not decoration: two circles of
 * similar tone laid over each other have no edge between them at all, and the
 * stack reads as one smeared shape. The ring is what puts the near one in front.
 */
const ringClasses = '[&>*]:ring-2 [&>*]:ring-(--neba-surface)';

/**
 * A stack of avatars, overlapping, with the ones that did not fit as a count.
 *
 * `size`, `shape`, `variant`, `color` and `elevation` are set once here rather
 * than on every avatar — a stack whose fourth face is a size out is not a stack
 * — and an avatar's own prop still wins, which is what lets one of them be
 * marked out from the rest.
 *
 * The order is the DOM order, and the first avatar is on top: a stack read
 * left to right is read front to back, so the one the group is *about* comes
 * first rather than last.
 */
export const AvatarGroup = React.forwardRef<HTMLDivElement, AvatarGroupProps>(function AvatarGroup(
  {
    max,
    total,
    overlap,
    size = 'md',
    shape = 'circle',
    variant = 'text',
    color = 'primary',
    elevation = 0,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const context = React.useMemo<AvatarGroupContextValue>(
    () => ({ size, shape, variant, color, elevation }),
    [size, shape, variant, color, elevation]
  );

  const items = React.Children.toArray(children);
  const shown = max === undefined ? items : items.slice(0, Math.max(0, max));
  const counted = total ?? items.length;
  const hidden = Math.max(0, counted - shown.length);

  return (
    <AvatarGroupContext.Provider value={context}>
      <div
        ref={ref}
        className={[
          // `isolate` so the ring of the first avatar is painted against the
          // page rather than against whatever is behind the group.
          'isolate inline-flex items-center',
          '[&>*:not(:first-child)]:[margin-inline-start:calc(var(--n-overlap)*-1)]',
          ringClasses,
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={
          {
            '--n-overlap':
              overlap === undefined
                ? overlapSizes[size]
                : typeof overlap === 'number'
                  ? `${overlap}px`
                  : overlap,
            ...style
          } as React.CSSProperties
        }
        {...props}
      >
        {shown}
        {hidden > 0 ? <Avatar initials={`+${hidden}`} /> : null}
      </div>
    </AvatarGroupContext.Provider>
  );
});
