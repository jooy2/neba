import * as React from 'react';
import { Separator } from '@base-ui/react/separator';
import { metaTextClasses } from '../../internal/styles';
import type { NebaAlign, NebaColor, NebaOrientation, NebaSize } from '../../types';

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
export const Divider = React.forwardRef<HTMLDivElement, DividerProps>(function Divider(
  {
    orientation = 'horizontal',
    color = 'primary',
    size = 'md',
    textAlign = 'center',
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const vertical = orientation === 'vertical';
  const hasLabel =
    children !== undefined && children !== null && children !== false && children !== '';
  const slots = { '--n-line': `var(--neba-${color}-line)` } as React.CSSProperties;

  if (!hasLabel) {
    return (
      <Separator
        ref={ref}
        orientation={orientation}
        className={[
          // The line is a single border edge; the box itself has no thickness,
          // so a divider never adds a pixel of layout beyond the rule.
          vertical ? 'w-0 self-stretch border-l' : 'h-0 w-full border-t',
          lineClasses,
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...slots, ...style }}
        {...props}
      />
    );
  }

  const [before, after] = stubClasses[orientation][textAlign];
  const edgeClasses = vertical ? 'w-0 border-l' : 'h-0 border-t';

  return (
    <Separator
      ref={ref}
      orientation={orientation}
      aria-label={typeof children === 'string' ? children : undefined}
      className={[
        'flex items-center',
        vertical ? 'w-auto flex-col self-stretch' : 'w-full',
        labelGapClasses[size],
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...slots, ...style }}
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
});
