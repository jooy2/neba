'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  alignContentClasses,
  alignItemsClasses,
  justifyContentClasses,
  spacingValue
} from '../../internal/grid.js';
import { overlayResponsive, responsiveSlots, withBaseline } from '../../internal/responsive.js';
import { cx } from '../../internal/styles.js';
import type {
  NebaAlignItems,
  NebaJustifyContent,
  NebaOrientation,
  NebaResponsive
} from '../../types.js';

export interface FlexProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * Which way the row runs, in the library's own two words rather than CSS's
   * four — `horizontal` is a row and `vertical` is a column, and `reverse`
   * turns either around.
   *
   * Responsive, and this is the prop the component exists for:
   * `direction={{ xs: 'vertical', md: 'horizontal' }}` is a stack on a phone
   * and a row from 48rem, which is most of what a responsive layout is.
   * @default 'horizontal'
   */
  direction?: NebaResponsive<NebaOrientation>;
  /**
   * Runs the children the other way along whichever axis `direction` chose —
   * `row-reverse` or `column-reverse`.
   *
   * Not responsive on purpose: it applies to every breakpoint's direction at
   * once, which is what "the same row, backwards" means. It is a visual order
   * only, so the DOM order is still what a screen reader and the tab sequence
   * follow — reverse a row whose order carries meaning and the two disagree.
   * @default false
   */
  reverse?: boolean;
  /**
   * The gutter between children, on Tailwind's spacing scale — `spacing={4}`
   * is `1rem`, the same length `gap-4` is. Fractions are allowed, so `1.5` is
   * `0.375rem`.
   *
   * The same prop, the same scale and the same slot a
   * [GridContainer](../grid) uses, so a gutter is one number across the two.
   * @default 0
   */
  spacing?: NebaResponsive<number>;
  /** The gutter between wrapped lines only. Falls back to `spacing`. */
  rowSpacing?: NebaResponsive<number>;
  /** The gutter along the row only. Falls back to `spacing`. */
  columnSpacing?: NebaResponsive<number>;
  /** How the row distributes the space its children did not use. */
  justifyContent?: NebaJustifyContent;
  /** How the children sit across the axis the row runs on. */
  alignItems?: NebaAlignItems;
  /** Where wrapped lines sit when the box is taller than they are. */
  alignContent?: NebaJustifyContent;
  /**
   * Whether a row that runs out of width continues on the next line.
   *
   * Off by default, which is the opposite of a `GridContainer` and deliberate:
   * a grid is columns and wrapping is what columns do, while a Flex is most
   * often a toolbar or a field row that should stay on one line and let its
   * children shrink.
   * @default false
   */
  wrap?: boolean;
  /** Lays the box out inline, so it sits in a line of text. @default false */
  inline?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<nav />}`,
   * `render={<ul />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/** No gutter unless one is asked for: a Flex is an arrangement, not a rhythm. */
const DEFAULT_SPACING = 0;

/** The two words the library says, as the four CSS has. */
function directionValue(reverse: boolean) {
  return (orientation: NebaOrientation) => {
    const axis = orientation === 'vertical' ? 'column' : 'row';

    return reverse ? `${axis}-reverse` : axis;
  };
}

/**
 * A row, or a column, and the width at which it changes from one to the other.
 *
 * This is the most common responsive decision there is — a pair of buttons side
 * by side on a desktop and stacked on a phone, a form's label beside its field
 * and then above it — and until now the only way to say it was a
 * [GridContainer](../grid) with a `Grid` around each child, which is two
 * components and a column count to describe a row of two things.
 *
 * `direction` is the whole point and is responsive; `spacing` is the gutter, on
 * the same scale and through the same slot a grid's is, so one number means one
 * length across both. Everything else is the flexbox vocabulary spelled the way
 * the rest of the library spells it.
 *
 * It draws nothing at all — no surface, no padding, not even a gutter unless
 * one is asked for. That is the difference between it and a `GridContainer`,
 * which pads by default because a grid is a page's own arrangement; a Flex is
 * used inside everything, and a wrapper that changed how its children looked
 * would make `direction` a visual decision. Put it in a Box or a Card when a
 * sheet is wanted.
 *
 * The direction and the gutters arrive as inherited custom properties rather
 * than through a context, for the reason `GridContainer` does the same: a media
 * query can change one without React hearing about it, so what is on screen is
 * always what the window is currently worth. A context would have to re-render
 * the tree at every breakpoint to say the same thing.
 */
export const Flex = React.forwardRef<HTMLDivElement, FlexProps>(function Flex(
  {
    direction,
    reverse = false,
    spacing,
    rowSpacing,
    columnSpacing,
    justifyContent,
    alignItems,
    alignContent,
    wrap = false,
    inline = false,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const classNames = cx(
    'neba-flex',
    inline ? 'inline-flex' : 'flex',
    // All three are read out of the slots, which is what lets a media query
    // change them without React re-rendering.
    '[flex-direction:var(--n-flex-dir)] gap-x-(--n-gap-x) gap-y-(--n-gap-y)',
    wrap ? 'flex-wrap' : 'flex-nowrap',
    justifyContent ? justifyContentClasses[justifyContent] : '',
    alignItems ? alignItemsClasses[alignItems] : '',
    alignContent ? alignContentClasses[alignContent] : '',
    className ?? ''
  );

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      style: {
        ...responsiveSlots(
          'flex-dir',
          withBaseline(direction, 'horizontal'),
          directionValue(reverse)
        ),
        // The axis-specific gutter is laid *over* `spacing` rather than
        // replacing it, so a map that names one breakpoint does not take the
        // gutter away everywhere else.
        ...responsiveSlots(
          'gap-x',
          overlayResponsive(withBaseline(spacing, DEFAULT_SPACING), columnSpacing),
          spacingValue
        ),
        ...responsiveSlots(
          'gap-y',
          overlayResponsive(withBaseline(spacing, DEFAULT_SPACING), rowSpacing),
          spacingValue
        ),
        ...style
      },
      children,
      ...props
    }
  });
});
