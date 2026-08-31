'use client';

import * as React from 'react';
import {
  controlTextLeadingClasses,
  hasContent,
  metaTextClasses,
  toLength
} from '../../internal/styles.js';
import type { NebaDensity, NebaOrientation, NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * What a row inherits from the list around it.
 *
 * Local rather than in `internal/`, because only these two components exist and
 * a row is meaningless outside its list — unlike a Button, which is a component
 * in its own right that a ButtonGroup happens to contain.
 */
interface DataListContextValue {
  size: NebaSize;
  density: NebaDensity;
  orientation: NebaOrientation;
}

const DataListContext = React.createContext<DataListContextValue>({
  size: 'md',
  density: 'default',
  orientation: 'horizontal'
});

export interface DataListProps extends Omit<React.ComponentPropsWithoutRef<'dl'>, 'color'> {
  /**
   * Where the label sits.
   *
   * - `horizontal` — beside the value, in a column of its own. The default, and
   *   the shape a details panel takes.
   * - `vertical` — above it. For a narrow column, and for values long enough
   *   that a label beside them would leave most of the row empty.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /**
   * How wide the label column is when `horizontal`. A number of pixels or any
   * CSS length. Left out, it is as wide as the widest label — which is what
   * keeps every value in the list starting at the same place.
   */
  labelWidth?: number | string;
  /** Draws a hairline between the rows. @default false */
  dividers?: boolean;
  /** @default 'md' */
  size?: NebaSize;
  /** Changes the gaps between rows and columns, and nothing else. @default 'default' */
  density?: NebaDensity;
  /** The rows. */
  children?: React.ReactNode;
}

export interface DataListItemProps {
  /** What the value is called. */
  label: React.ReactNode;
  /** The value. A node, so a Chip, a link or a piece of code all fit. */
  children?: React.ReactNode;
}

/** Between the label and the value across the row. */
const columnGapClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'gap-x-3', sm: 'gap-x-4', md: 'gap-x-5', lg: 'gap-x-6', xl: 'gap-x-8' },
  compact: { xs: 'gap-x-2', sm: 'gap-x-2.5', md: 'gap-x-3', lg: 'gap-x-4', xl: 'gap-x-5' }
};

/** And between one row and the next. */
const rowGapClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'gap-y-2', sm: 'gap-y-2.5', md: 'gap-y-3', lg: 'gap-y-3.5', xl: 'gap-y-4' },
  compact: { xs: 'gap-y-1', sm: 'gap-y-1.5', md: 'gap-y-2', lg: 'gap-y-2', xl: 'gap-y-2.5' }
};

/**
 * The hairline between rows.
 *
 * `nth-of-type` rather than a wrapper element around each pair: a `<dl>` whose
 * rows are grid cells needs its `<dt>`s and `<dd>`s to be direct children, and
 * a `<div>` in between would take the grid with it. Counting per element type is
 * exactly what makes "every row but the first" expressible without one.
 */
const dividerClasses = [
  '[&>dt:nth-of-type(n+2)]:border-t [&>dd:nth-of-type(n+2)]:border-t',
  '[&>dt]:[border-color:var(--neba-border)] [&>dd]:[border-color:var(--neba-border)]'
].join(' ');

/** The padding the hairline needs above the row it opens. */
const dividerPadClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: {
    xs: '[&>dt:nth-of-type(n+2)]:pt-2 [&>dd:nth-of-type(n+2)]:pt-2',
    sm: '[&>dt:nth-of-type(n+2)]:pt-2.5 [&>dd:nth-of-type(n+2)]:pt-2.5',
    md: '[&>dt:nth-of-type(n+2)]:pt-3 [&>dd:nth-of-type(n+2)]:pt-3',
    lg: '[&>dt:nth-of-type(n+2)]:pt-3.5 [&>dd:nth-of-type(n+2)]:pt-3.5',
    xl: '[&>dt:nth-of-type(n+2)]:pt-4 [&>dd:nth-of-type(n+2)]:pt-4'
  },
  compact: {
    xs: '[&>dt:nth-of-type(n+2)]:pt-1 [&>dd:nth-of-type(n+2)]:pt-1',
    sm: '[&>dt:nth-of-type(n+2)]:pt-1.5 [&>dd:nth-of-type(n+2)]:pt-1.5',
    md: '[&>dt:nth-of-type(n+2)]:pt-2 [&>dd:nth-of-type(n+2)]:pt-2',
    lg: '[&>dt:nth-of-type(n+2)]:pt-2 [&>dd:nth-of-type(n+2)]:pt-2',
    xl: '[&>dt:nth-of-type(n+2)]:pt-2.5 [&>dd:nth-of-type(n+2)]:pt-2.5'
  }
};

/**
 * One pair: what it is called, and what it is.
 *
 * A fragment rather than an element, so the `<dt>` and the `<dd>` land as direct
 * children of the `<dl>` and the grid can line every label up against every
 * other. It has no `size` or `density` of its own — those belong to the list.
 */
export function DataListItem({ label, children }: DataListItemProps) {
  const { size, orientation } = React.useContext(DataListContext);

  return (
    <>
      <dt
        className={[
          'min-w-0 text-(--neba-muted-fg)',
          metaTextClasses[size],
          orientation === 'vertical' ? 'mb-0.5' : 'py-px'
        ].join(' ')}
      >
        {label}
      </dt>
      {/* A browser gives every `<dd>` a 40px inline-start margin. */}
      <dd className={`m-0 min-w-0 text-(--neba-fg) ${controlTextLeadingClasses[size]}`}>
        {hasContent(children) ? children : null}
      </dd>
    </>
  );
}

/**
 * A list of things and what they are called — a details panel, a summary of a
 * record, the metadata under a heading.
 *
 * It is a real `<dl>` with real `<dt>`/`<dd>` pairs, which is the whole reason
 * it is a component rather than a two-column [Table](./table): a table is a grid
 * of *rows*, all of the same shape, and a screen reader reads it by walking a
 * grid. This is a set of *pairs*, and each one is read as "label, value" — which
 * is what a details panel actually is.
 *
 * It draws no surface. Put it in a [Card](../surfaces/card) when one is wanted.
 */
export const DataList = React.forwardRef<HTMLDListElement, DataListProps>(
  function DataList(rawProps, ref) {
    const {
      orientation = 'horizontal',
      labelWidth,
      dividers = false,
      size = 'md',
      density = 'default',
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density']);

    const context = React.useMemo(
      () => ({ size, density, orientation }),
      [size, density, orientation]
    );

    const width = toLength(labelWidth);

    return (
      <DataListContext.Provider value={context}>
        <dl
          ref={ref}
          className={[
            // A `<dl>` arrives with the browser's own block margin.
            'm-0 min-w-0',
            orientation === 'vertical'
              ? 'flex flex-col'
              : 'grid [grid-template-columns:var(--n-label)_minmax(0,1fr)] items-baseline',
            columnGapClasses[density][size],
            rowGapClasses[density][size],
            dividers ? `${dividerClasses} ${dividerPadClasses[density][size]}` : '',
            className ?? ''
          ]
            .filter(Boolean)
            .join(' ')}
          style={
            {
              // `max-content` is what makes every value in the list start at the
              // same place without the caller having to measure the longest label.
              '--n-label': width ?? 'max-content',
              ...style
            } as React.CSSProperties
          }
          {...props}
        >
          {children}
        </dl>
      </DataListContext.Provider>
    );
  }
);
