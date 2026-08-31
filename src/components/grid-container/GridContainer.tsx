'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  alignContentClasses,
  alignItemsClasses,
  columnCount,
  justifyContentClasses,
  responsiveSlots,
  spacingValue,
  withBaseline
} from '../../internal/grid.js';
import { boxPaddingClasses } from '../box/Box.js';
import { cx } from '../../internal/styles.js';
import type {
  NebaAlignItems,
  NebaDensity,
  NebaJustifyContent,
  NebaResponsive,
  NebaSize
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface GridContainerProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How many columns a row is divided into. Every `span` and every `offset`
   * inside is read against this number, so `columns={24}` makes `span={12}` a
   * half and not a full width.
   * @default 12
   */
  columns?: NebaResponsive<number>;
  /**
   * The gutter between items, on Tailwind's spacing scale — `spacing={4}` is
   * `1rem`, the same length `gap-4` is. Fractions are allowed, so `1.5` is
   * `0.375rem`.
   * @default 2
   */
  spacing?: NebaResponsive<number>;
  /** The gutter between rows only. Falls back to `spacing`. */
  rowSpacing?: NebaResponsive<number>;
  /** The gutter between columns only. Falls back to `spacing`. */
  columnSpacing?: NebaResponsive<number>;
  /** How a row distributes the space its items did not use. */
  justifyContent?: NebaJustifyContent;
  /** How items sit against each other across the row. @default 'stretch' */
  alignItems?: NebaAlignItems;
  /** Where the rows sit when the grid is shorter than the box holding it. */
  alignContent?: NebaJustifyContent;
  /**
   * Whether a row that runs out of columns continues on the next one. Turning
   * it off gives one row that overflows, which is what a horizontally
   * scrolling strip wants.
   * @default true
   */
  wrap?: boolean;
  /**
   * Inner padding, on the `size`/`density` scale. Turn it off when the grid is
   * already inside something that pads — a Container, a Card, another grid.
   * @default true
   */
  padded?: boolean;
  /**
   * The padding scale. As on Box, this is the size of the *sheet* — it never
   * touches a height or the type scale, and it has nothing to do with the
   * gutters, which are `spacing`.
   * @default 'md'
   */
  size?: NebaSize;
  /** @default 'default' */
  density?: NebaDensity;
  /**
   * Renders something other than a `<div>`: `render={<section />}`,
   * `render={<ul />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

const DEFAULT_COLUMNS = 12;

/** Two Tailwind steps, and the reason a bare `<GridContainer>` looks like one. */
const DEFAULT_SPACING = 2;

/**
 * The parent every `Grid` needs.
 *
 * It owns the three numbers an item cannot know on its own — how many columns
 * there are and how wide the two gutters are — and hands them down as inherited
 * custom properties rather than through a React context. That is not a
 * shortcut: the values are responsive, and a media query can change an
 * inherited custom property without React hearing about it, so the column count
 * an item lays itself out against is always the one that is on screen. A
 * context would have to re-render the tree at every breakpoint to say the same
 * thing.
 *
 * It deliberately does not take `variant`, `color` or `elevation`. A grid is
 * not a surface — it is the arrangement of the surfaces inside it, and the
 * moment it draws its own sheet it stops being usable as the outermost thing on
 * a page. Wrap it in a Box or a Card when the sheet is wanted.
 *
 * Nesting is a `GridContainer` inside a `Grid`, not a `Grid` that is also a
 * container: the inner grid re-declares the column count for its own subtree
 * while the item around it keeps the width the outer grid gave it.
 */
export const GridContainer = React.forwardRef<HTMLDivElement, GridContainerProps>(
  function GridContainer(rawProps, ref) {
    const {
      columns,
      spacing,
      rowSpacing,
      columnSpacing,
      justifyContent,
      alignItems,
      alignContent,
      wrap = true,
      padded = true,
      size = 'md',
      density = 'default',
      render,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density']);

    const classNames = cx(
      'neba-grid flex',
      wrap ? 'flex-wrap' : 'flex-nowrap',
      // Both gutters are read from the slots below, which is what lets a media
      // query change them without React re-rendering.
      'gap-x-(--n-gap-x) gap-y-(--n-gap-y)',
      padded ? boxPaddingClasses[density][size] : '',
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
          ...responsiveSlots('cols', withBaseline(columns, DEFAULT_COLUMNS), columnCount),
          ...responsiveSlots(
            'gap-x',
            withBaseline(columnSpacing ?? spacing, DEFAULT_SPACING),
            spacingValue
          ),
          ...responsiveSlots(
            'gap-y',
            withBaseline(rowSpacing ?? spacing, DEFAULT_SPACING),
            spacingValue
          ),
          ...style
        },
        children,
        ...props
      }
    });
  }
);
