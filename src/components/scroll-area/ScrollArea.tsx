'use client';

import * as React from 'react';
import { ScrollArea as BaseUIScrollArea } from '@base-ui/react/scroll-area';
import { focusRingClasses, toLength } from '../../internal/styles.js';
import type { NebaColor, NebaSize } from '../../types.js';

/**
 * Which axes may scroll.
 *
 * `NebaOrientation` plus a third value rather than the type itself, because
 * "both" is meaningless everywhere that type is used today — a Divider, a
 * ButtonGroup and a Slider each run one way — and widening it there to say it
 * here would be the second spelling this library keeps out.
 */
export type ScrollAreaOrientation = 'vertical' | 'horizontal' | 'both';

export interface ScrollAreaProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** Which axes may scroll. @default 'vertical' */
  orientation?: ScrollAreaOrientation;
  /**
   * A fixed height. A vertical scroll area has to be bounded by something or
   * there is nothing to scroll; this is the shortest way to say what by.
   */
  height?: number | string;
  /** The same, as a ceiling rather than a fixed height. */
  maxHeight?: number | string;
  /** Thickness of the scrollbar and the size of its inset. @default 'md' */
  size?: NebaSize;
  /** The family the thumb carries. @default 'primary' */
  color?: NebaColor;
  /**
   * Fades the content out at each edge that has more beyond it, and only at
   * those edges — so the fade is a statement about the content rather than
   * decoration, and it disappears at the top when you are at the top.
   * @default false
   */
  fade?: boolean;
  children?: React.ReactNode;
}

/** The scrollbar's own ladder: a rail, not a control, so it is far below one. */
const railSizes: Record<NebaSize, string> = {
  xs: '0.25rem',
  sm: '0.3125rem',
  md: '0.375rem',
  lg: '0.5rem',
  xl: '0.625rem'
};

/** How far the fade reaches in from an edge that has more content behind it. */
const fadeSizes: Record<NebaSize, string> = {
  xs: '1rem',
  sm: '1.25rem',
  md: '1.5rem',
  lg: '2rem',
  xl: '2.5rem'
};

const scrollbarClasses = [
  'flex touch-none select-none rounded-full p-px',
  'bg-transparent hover:bg-(--n-soft)',
  // Opacity is the one thing a scrollbar is allowed to express a state with:
  // it is not a control changing what it is, it is an affordance staying out of
  // the way of the content until it is wanted.
  'opacity-0 transition-[opacity,background-color] duration-(--neba-duration) ease-(--neba-ease)',
  'data-[hovering]:opacity-100 data-[scrolling]:opacity-100 data-[scrolling]:duration-0'
].join(' ');

const thumbClasses = 'flex-1 rounded-full bg-(--n-thumb) hover:bg-(--n-thumb-hover)';

/**
 * A box with its own scrollbar.
 *
 * The browser's scrollbar is drawn by the operating system, which means it is
 * seventeen pixels wide on one machine, overlaid and invisible on the next, and
 * a different colour in a dark theme than the sheet it is cut into. This one is
 * an element, so it is the same everywhere and it can be made of the library's
 * own tokens.
 *
 * It is not [ScrollZone](./scroll-zone), which is a *rail* — a strip of items
 * laid out in one direction with buttons that step through them, for a row of
 * cards or a line of chips. This is the plain case: a box that is too small for
 * what is in it. Underneath, both are ordinary scroll containers, so the wheel,
 * the trackpad, the keyboard and momentum are the browser's own in both.
 */
export const ScrollArea = React.forwardRef<HTMLDivElement, ScrollAreaProps>(function ScrollArea(
  {
    orientation = 'vertical',
    height,
    maxHeight,
    size = 'md',
    color = 'primary',
    fade = false,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const vertical = orientation === 'vertical' || orientation === 'both';
  const horizontal = orientation === 'horizontal' || orientation === 'both';

  return (
    <BaseUIScrollArea.Root
      ref={ref}
      className={['relative overflow-hidden', className ?? ''].filter(Boolean).join(' ')}
      style={
        {
          '--n-soft': `var(--neba-${color}-soft)`,
          '--n-ring': `var(--neba-${color}-ring)`,
          // The thumb is the colour family at a fraction of itself rather than
          // `--neba-*-fill`: a scrollbar sits on top of content and a saturated
          // rail down the side of a paragraph reads as a second column.
          '--n-thumb': `color-mix(in oklab, var(--neba-${color}-accent) 35%, transparent)`,
          '--n-thumb-hover': `color-mix(in oklab, var(--neba-${color}-accent) 55%, transparent)`,
          '--n-rail': railSizes[size],
          '--n-fade': fadeSizes[size],
          height: toLength(height),
          maxHeight: toLength(maxHeight),
          ...style
        } as React.CSSProperties
      }
      {...props}
    >
      <BaseUIScrollArea.Viewport
        // The viewport filling its root is structure rather than styling —
        // a viewport that does not is not a scroll area — so it is written
        // inline, where nothing a caller passes can leave the box unbounded and
        // silently take the scrolling with it. Base UI supplies the
        // `overflow: scroll` beside it, also inline.
        style={{ height: '100%', width: '100%' }}
        className={[
          'overscroll-contain [outline:none]',
          focusRingClasses,
          // The fade is a mask rather than a gradient painted over the content:
          // a gradient would have to fade *to* a colour, and over a translucent
          // acrylic sheet there is no such colour. `styles.css` has the rest.
          fade ? 'neba-scroll-fade' : ''
        ]
          .filter(Boolean)
          .join(' ')}
      >
        <BaseUIScrollArea.Content className="min-w-full">{children}</BaseUIScrollArea.Content>
      </BaseUIScrollArea.Viewport>

      {vertical ? (
        <BaseUIScrollArea.Scrollbar
          orientation="vertical"
          className={`${scrollbarClasses} w-(--n-rail) [margin-block:2px]`}
        >
          <BaseUIScrollArea.Thumb className={thumbClasses} />
        </BaseUIScrollArea.Scrollbar>
      ) : null}

      {horizontal ? (
        <BaseUIScrollArea.Scrollbar
          orientation="horizontal"
          className={`${scrollbarClasses} h-(--n-rail) [margin-inline:2px]`}
        >
          <BaseUIScrollArea.Thumb className={thumbClasses} />
        </BaseUIScrollArea.Scrollbar>
      ) : null}

      {vertical && horizontal ? <BaseUIScrollArea.Corner /> : null}
    </BaseUIScrollArea.Root>
  );
});
