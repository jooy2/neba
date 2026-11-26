'use client';

import * as React from 'react';
import { Separator } from '@base-ui/react/separator';
import { cx, metaTextClasses, toLength } from '../../internal/styles.js';
import type { NebaAlign, NebaColor, NebaOrientation, NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** Where the label sits along a labelled divider. Ignored without a label. */
export type DividerTextAlign = NebaAlign;

export interface DividerProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /**
   * Which way the line runs. A vertical divider has no height of its own — it
   * stretches to its flex parent, the way a rule between two toolbar groups
   * should.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /**
   * Semantic colour role. Only the hairline is coloured, and only faintly: this
   * is the same `--n-line` a Card scores its sections with, so a standalone
   * divider and a card's internal one are the same line.
   * @default 'primary'
   */
  color?: NebaColor;
  /** Type scale of the label. Nothing else on a divider has a size. */
  size?: NebaSize;
  /**
   * How far the rule runs — the width of a horizontal divider, the height of a
   * vertical one. A number is pixels; a string is any CSS length, so `'50%'`
   * and `'12rem'` both work.
   *
   * `length` rather than `width`, because a divider is the one component whose
   * long axis turns with `orientation`: a `width` that meant height half the
   * time would be a worse name than a longer one.
   *
   * Left out, a horizontal divider is the full width of its container and a
   * vertical one stretches to the height of the flex row it is in — which is
   * what a rule between two things should do by default.
   */
  length?: number | string;
  /**
   * How thick the rule is. A number is pixels; a string is any CSS length.
   * @default 1
   */
  thickness?: number | string;
  /** A label set into the line — "OR" between two sign-in options. */
  children?: React.ReactNode;
  /**
   * Where the label sits. `center` splits the line in half; `start` and `end`
   * leave a short stub on the near side so the label still reads as set *into*
   * the rule rather than floating above it.
   * @default 'center'
   */
  textAlign?: DividerTextAlign;
}

/**
 * The hairline itself. A border rather than a filled 1px box, so it lands on
 * the device pixel grid the same way every other edge in the library does — and
 * so it is literally the same declaration Card uses between its sections.
 *
 * Its thickness is read from a slot rather than from a `border-2`-style utility
 * because a labelled divider draws the rule three times — the root and the two
 * stubs either side of the label — and one custom property set on the root is
 * what keeps all three the same without threading a value through each.
 */
const lineClasses = '[border-color:var(--n-line)]';

/**
 * How the line is split around an off-centre label: `[before, after]`. The short
 * side is a fixed stub rather than a small flex ratio, so the label sits the
 * same distance from the edge whatever the divider's width turns out to be.
 */
const stubClasses: Record<NebaOrientation, Record<DividerTextAlign, [string, string]>> = {
  horizontal: {
    start: ['w-4 shrink-0', 'flex-1'],
    center: ['flex-1', 'flex-1'],
    end: ['flex-1', 'w-4 shrink-0']
  },
  vertical: {
    start: ['h-4 shrink-0', 'flex-1'],
    center: ['flex-1', 'flex-1'],
    end: ['flex-1', 'h-4 shrink-0']
  }
};

/** Space between the label and the line on either side of it. */
const labelGapClasses: Record<NebaSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/**
 * A rule between two things.
 *
 * With no children it is Base UI's `Separator` and nothing else — a real
 * `role="separator"` with the right `aria-orientation`. With children the line
 * breaks around the label.
 *
 * `separator` is not a name-from-content role, so the visible label does *not*
 * become the accessible name on its own: a screen reader would announce a bare
 * "separator" and the word "OR" would be read as loose text somewhere nearby.
 * A string label is therefore copied into `aria-label`. Anything richer is left
 * alone — only the caller knows which part of it is the name.
 *
 * There is no `variant` and no `elevation`: a divider is not a surface. It has
 * no acrylic, catches no light and casts no shadow.
 */
export const Divider = React.forwardRef<HTMLDivElement, DividerProps>(
  function Divider(rawProps, ref) {
    const {
      orientation = 'horizontal',
      color = 'primary',
      size = 'md',
      length,
      thickness,
      textAlign = 'center',
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size']);

    const vertical = orientation === 'vertical';
    const hasLabel =
      children !== undefined && children !== null && children !== false && children !== '';

    const slots = {
      '--n-line': `var(--neba-${color}-line)`,
      '--n-rule': toLength(thickness) ?? '1px'
    } as React.CSSProperties;

    // The long axis, and only when it was asked for: left alone, a horizontal
    // divider is `w-full` and a vertical one stretches to its flex row, which are
    // the two things a rule between two things should already do.
    const span = toLength(length);
    const sizing = span === undefined ? null : vertical ? { height: span } : { width: span };

    const rootStyle = { ...slots, ...sizing, ...style };

    if (!hasLabel) {
      return (
        <Separator
          ref={ref}
          orientation={orientation}
          className={cx(
            // The line is a single border edge; the box itself has no thickness,
            // so a divider never adds a pixel of layout beyond the rule.
            vertical
              ? `w-0 border-l [border-left-width:var(--n-rule)] ${span === undefined ? 'self-stretch' : ''}`
              : 'h-0 w-full border-t [border-top-width:var(--n-rule)]',
            lineClasses,
            className ?? ''
          )}
          style={rootStyle}
          {...props}
        />
      );
    }

    const [before, after] = stubClasses[orientation][textAlign];
    const edgeClasses = vertical
      ? 'w-0 border-l [border-left-width:var(--n-rule)]'
      : 'h-0 border-t [border-top-width:var(--n-rule)]';

    return (
      <Separator
        ref={ref}
        orientation={orientation}
        aria-label={typeof children === 'string' ? children : undefined}
        className={cx(
          'flex items-center',
          vertical ? `w-auto flex-col ${span === undefined ? 'self-stretch' : ''}` : 'w-full',
          labelGapClasses[size],
          className ?? ''
        )}
        style={rootStyle}
        {...props}
      >
        <span aria-hidden="true" className={`${edgeClasses} ${before} ${lineClasses}`} />
        <span
          className={[
            'shrink-0 whitespace-nowrap text-(--neba-muted-fg)',
            metaTextClasses[size],
            // A vertical rule's label has to turn with it, or the line grows to
            // the width of the word and stops being a hairline.
            vertical ? '[writing-mode:vertical-rl]' : ''
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {children}
        </span>
        <span aria-hidden="true" className={`${edgeClasses} ${after} ${lineClasses}`} />
      </Separator>
    );
  }
);
