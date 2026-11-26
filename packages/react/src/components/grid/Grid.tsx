'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  alignSelfClasses,
  offsetValue,
  spanGrow,
  spanValue,
  spanWidth
} from '../../internal/grid.js';
import { breakpointMap, responsiveSlots } from '../../internal/responsive.js';
import { cx } from '../../internal/styles.js';
import type { NebaAlignSelf, NebaBreakpoint, NebaResponsive } from '../../types.js';

/**
 * How wide a cell is: a share of the container's columns, the width of what is
 * in it, or the space the row has left.
 */
export type GridSpan = number | 'auto' | 'grow';

/**
 * The slots one `span` resolves into.
 *
 * A number is a share of the row and is arithmetic, which is what the
 * `--n-span` cascade carries. `auto` and `grow` are the contents' own width,
 * which arithmetic cannot reach — so they travel in two cascades of their own,
 * and those are emitted only for a map that actually names one. A grid of
 * numbered spans, which is nearly every grid, writes exactly the one property
 * it always wrote.
 */
function spanSlots(span: NebaResponsive<GridSpan> | undefined): React.CSSProperties {
  const map = breakpointMap(span);
  const entries = Object.entries(map) as Array<[NebaBreakpoint, GridSpan]>;
  const shares: Partial<Record<NebaBreakpoint, number>> = {};
  let keyworded = false;

  for (const [breakpoint, value] of entries) {
    if (typeof value === 'number') shares[breakpoint] = value;
    else keyworded = true;
  }

  const columns = responsiveSlots('span', shares, spanValue);

  if (!keyworded) return columns;

  return {
    ...columns,
    ...responsiveSlots('span-w', map, spanWidth),
    ...responsiveSlots('grow', map, spanGrow)
  };
}

export interface GridProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How many of the container's columns the item takes. Read against the
   * container's `columns`, so `span={6}` is a half of the default twelve and a
   * quarter of `columns={24}`.
   *
   * Responsive: `span={{ xs: 12, md: 6, lg: 4 }}` is full width on a phone,
   * half from 48rem and a third from 64rem. Every entry applies from its own
   * breakpoint up, so two of them usually describe a whole layout.
   *
   * A span wider than the row is clamped to the row rather than overflowing.
   *
   * Two widths are not a share of twelve, and both are keywords: `'auto'` is
   * as wide as the item's own contents — an icon, a chip, a button at the end
   * of a row — and `'grow'` is that plus whatever the row has left over, which
   * is how a title sits between the two. They mix with numbers in one map.
   * @default the container's full width
   */
  span?: NebaResponsive<GridSpan>;
  /**
   * Columns left empty *before* the item — space pushed in ahead of it, not an
   * absolute position in the row. First in a twelve-column row, `offset={4}`
   * with `span={4}` is the middle third; after an item that already took four
   * columns, the same offset skips four more and lands on the last third.
   *
   * Responsive in the same way `span` is.
   * @default 0
   */
  offset?: NebaResponsive<number>;
  /** Overrides the row's `alignItems` for this item alone. */
  alignSelf?: NebaAlignSelf;
  /**
   * Renders something other than a `<div>`: `render={<li />}`,
   * `render={<article />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * One cell of a `GridContainer`.
 *
 * It is a width and nothing else — no surface, no padding, no typography. What
 * goes inside brings its own, which is the whole reason a grid cell and a Box
 * are two components: wrapping something in a layout should not change how it
 * looks, and a cell that drew a sheet would make `span` a visual decision.
 *
 * The column count it divides by is inherited from the container as a custom
 * property, so a `<Grid>` with no `<GridContainer>` above it falls back to
 * twelve rather than breaking — but it will be a plain block in a plain parent,
 * which is not a layout. Always wrap.
 */
export const Grid = React.forwardRef<HTMLDivElement, GridProps>(function Grid(
  { span, offset, alignSelf, render, className, style, children, ...props },
  ref
) {
  const classNames = cx(
    'neba-grid-item',
    alignSelf ? alignSelfClasses[alignSelf] : '',
    className ?? ''
  );

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      style: {
        ...spanSlots(span),
        ...responsiveSlots('offset', offset, offsetValue),
        ...style
      },
      children,
      ...props
    }
  });
});
