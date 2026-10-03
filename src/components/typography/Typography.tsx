'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { transitionProps } from '../../internal/animate.js';
import {
  COLOR,
  FONT_SIZE,
  FONT_WEIGHT,
  LETTER_SPACING,
  LINE_HEIGHT,
  MARGIN_BOTTOM,
  MARGIN_TOP,
  overriddenBy
} from '../../internal/overrides.js';
import { clampClasses, clampSlot, cx } from '../../internal/styles.js';
import type { NebaColor, NebaTransition } from '../../types.js';

/**
 * What a piece of text *is*, which decides both its type scale and the element
 * it renders as.
 *
 * This is deliberately not called `variant`. In this library `variant` means the
 * weight of a surface — `solid` / `outline` / `text` — and a second meaning for
 * the same word is exactly what the prop conventions forbid.
 */
export type TypographyLevel =
  'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'body' | 'lead' | 'caption' | 'overline';

export type TypographyAlign = 'start' | 'center' | 'end' | 'justify';

export type TypographyWeight = 'regular' | 'medium' | 'semibold' | 'bold';

export interface TypographyProps extends Omit<
  React.ComponentPropsWithoutRef<'p'>,
  'color' | 'children'
> {
  /**
   * The type scale, and the element that carries it. `h1`–`h6` render the
   * matching heading, `lead`/`body` a `<p>`, `caption`/`overline` a `<span>`.
   * @default 'body'
   */
  level?: TypographyLevel;
  /**
   * An entrance animation, run once on mount: `transition="fade"`, or an object
   * for the details. For a trigger, a replay or anything under your own
   * control, wrap it in an `Animate*` component instead.
   */
  transition?: NebaTransition;
  /**
   * Semantic colour role. Unlike every other component this has **no default**:
   * text inherits the page's own colour unless a role is asked for, because the
   * common case for a paragraph is to look like the paragraphs around it.
   */
  color?: NebaColor;
  /** Overrides the weight the level would otherwise pick. */
  weight?: TypographyWeight;
  align?: TypographyAlign;
  /**
   * Clamps the text to this many lines with an ellipsis. `1` is a single-line
   * truncation. Omit it and the text wraps as far as it needs to.
   */
  lines?: number;
  /**
   * Adds the space below that a run of prose expects. Off by default: a library
   * component that injects margins is one a layout has to fight.
   * @default false
   */
  gutter?: boolean;
  /**
   * Renders a different element without changing the type scale — a `h2`-sized
   * line that is semantically a `<p>`, or the other way round. Base UI's own
   * escape hatch, so it behaves the same here as on Box.
   */
  render?: useRender.RenderProp;
  /**
   * A Tailwind utility here wins over the level's own size, leading, tracking,
   * weight, margins and colour, with or without a variant. Only Tailwind's
   * names are read: a class from your own stylesheet needs two classes or
   * `!important` to beat the level.
   */
  className?: string;
  children?: React.ReactNode;
}

/**
 * The scale, as the values a level writes into its `--n-type-*` slots.
 *
 * Body sits on Card's body ladder at `md` (13px/22px), so a paragraph inside a
 * card and a standalone one are the same text. The headings step up from there
 * by roughly a major third, and the leading tightens as they grow — a 30px line
 * does not want the same 1.7 ratio a 13px one does.
 *
 * The leading is that **ratio** rather than the length it works out to, which
 * is the one thing here that is not a straight reading of the design. A length
 * is a line box built for a size, and the size is the first thing a caller
 * overrides — `className="text-[2.2rem]"` on a figure left a 22px row around
 * 35px glyphs, and the only way out was a `leading-*` beside every override.
 * Each level keeps exactly the ratio it was drawn at, so nothing moves at the
 * scale's own sizes and an overridden one gets a line box in proportion. It is
 * also how Tailwind's own text scale is written.
 *
 * The levels below `h3` say `normal` rather than leaving the tracking out.
 * Below that size the scale wants the font's own spacing, and *not saying so*
 * is what let `.vp-doc h4`'s `-0.01em` through — a scale is what the component
 * states, not what is left over.
 */
const levelScale: Record<TypographyLevel, { size: string; leading: string; tracking: string }> = {
  h1: { size: '1.875rem', leading: '1.2', tracking: '-0.02em' },
  h2: { size: '1.5rem', leading: '1.25', tracking: '-0.015em' },
  h3: { size: '1.25rem', leading: '1.3', tracking: '-0.01em' },
  h4: { size: '1.0625rem', leading: '1.41176', tracking: 'normal' },
  h5: { size: '0.9375rem', leading: '1.46667', tracking: 'normal' },
  h6: { size: '0.8125rem', leading: '1.53846', tracking: 'normal' },
  lead: { size: '1.0625rem', leading: '1.64706', tracking: 'normal' },
  body: { size: '0.8125rem', leading: '1.69231', tracking: 'normal' },
  caption: { size: '0.75rem', leading: '1.5', tracking: 'normal' },
  overline: { size: '0.6875rem', leading: '1.45455', tracking: '0.08em' }
};

/** The weight each level takes when `weight` does not say otherwise. */
const levelWeights: Record<TypographyLevel, TypographyWeight> = {
  h1: 'semibold',
  h2: 'semibold',
  h3: 'semibold',
  h4: 'semibold',
  h5: 'semibold',
  h6: 'semibold',
  lead: 'regular',
  body: 'regular',
  caption: 'regular',
  overline: 'medium'
};

/**
 * A weight as a value for the slot. Tailwind's own variable comes first, so a
 * theme that moves `--font-weight-semibold` moves this too, as the
 * `font-semibold` this used to be did.
 */
const weightValues: Record<TypographyWeight, string> = {
  regular: 'var(--font-weight-normal, 400)',
  medium: 'var(--font-weight-medium, 500)',
  semibold: 'var(--font-weight-semibold, 600)',
  bold: 'var(--font-weight-bold, 700)'
};

/** The element each level renders as when `render` is not given. */
const levelElements: Record<TypographyLevel, React.ElementType> = {
  h1: 'h1',
  h2: 'h2',
  h3: 'h3',
  h4: 'h4',
  h5: 'h5',
  h6: 'h6',
  lead: 'p',
  body: 'p',
  caption: 'span',
  overline: 'span'
};

/**
 * The two quiet levels are muted by default. Everything else takes the page's
 * own foreground — a heading that arrived pre-greyed is a heading a designer has
 * to undo.
 */
const mutedLevels = new Set<TypographyLevel>(['caption', 'overline']);

/**
 * How much room a level leaves under itself when `gutter` is on, in steps of
 * Tailwind's `--spacing`, as the `mb-*` utilities these were counted.
 *
 * Only the vertical axis is ever stated: `mx-auto` is how a caller centres a
 * measure, and that is one class they should keep.
 */
const gutterSteps: Record<TypographyLevel, number> = {
  h1: 4,
  h2: 3.5,
  h3: 3,
  h4: 2.5,
  h5: 2,
  h6: 2,
  lead: 4,
  body: 3,
  caption: 2,
  overline: 2
};

/**
 * Every property the scale states, at two strengths.
 *
 * The **guard** is written through `[&.neba-typography]`, which compiles to two
 * classes, and that is not decoration. `h1`–`h6` and `p` are the tags a host
 * stylesheet is most certain to have styled by name: `.vp-doc h2` and `.prose
 * h2` both set `font-size`, `line-height`, `letter-spacing`, `font-weight` and
 * the margins, all at one class plus one tag, which a single utility cannot
 * outrank. Measured inside VitePress's own article, every level of this scale
 * was losing its leading, `h1` and `h4` their size, the headings their
 * tracking, and `weight` was ignored outright — a `weight="regular"` heading
 * rendered at 600.
 *
 * The guard outranks a caller's one-class utility just as surely, which is what
 * the **floor** is for. A property the caller's `className` sets is stated
 * through `[:where(&)]` instead, at zero specificity — see
 * `internal/overrides.ts` for what counts as setting one. `className="mb-8"`
 * then wins, and `md:text-5xl` wins at its breakpoint with the level's own size
 * still underneath it. What a caller gives up is the guard for that one
 * property: inside `.prose`, their `mb-8` is in the article's fight, as it
 * would be on any element.
 *
 * Each pair reads a slot rather than carrying a value, so a level is data and
 * the stylesheet holds one rule per property rather than one per level.
 */
const scaleClasses: ReadonlyArray<readonly [number, string, string]> = [
  [
    FONT_SIZE,
    '[&.neba-typography]:text-(length:--n-type-size)',
    '[:where(&)]:text-(length:--n-type-size)'
  ],
  [
    LINE_HEIGHT,
    '[&.neba-typography]:leading-(--n-type-leading)',
    '[:where(&)]:leading-(--n-type-leading)'
  ],
  [
    LETTER_SPACING,
    '[&.neba-typography]:tracking-(--n-type-tracking)',
    '[:where(&)]:tracking-(--n-type-tracking)'
  ],
  [
    FONT_WEIGHT,
    '[&.neba-typography]:font-(weight:--n-type-weight)',
    '[:where(&)]:font-(weight:--n-type-weight)'
  ],
  // Stated with `gutter` off as well, at `0`: "off by default" has to mean *no*
  // margin below, and not whatever the article gives a paragraph.
  [MARGIN_BOTTOM, '[&.neba-typography]:mb-(--n-type-gutter)', '[:where(&)]:mb-(--n-type-gutter)']
];

const alignClasses: Record<TypographyAlign, string> = {
  start: 'text-start',
  center: 'text-center',
  end: 'text-end',
  justify: 'text-justify'
};

/**
 * Text at one of the library's sizes.
 *
 * The type scale is the one thing in a design system that everything else is
 * measured against, and until now it only existed inside the components that
 * happened to need it — a Card's title, a TextField's label. This is that ladder
 * on its own, so a page can use it without wrapping its prose in a card.
 *
 * `level` sets the scale *and* the element, which is the common case. When they
 * have to differ — a subheading that should not enter the document outline, a
 * `<p>` that has to look like an `h3` — `render` breaks the tie.
 */
export const Typography = React.forwardRef<HTMLElement, TypographyProps>(function Typography(
  {
    level = 'body',
    color,
    weight,
    align,
    lines,
    gutter = false,
    transition,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const animation = transitionProps(transition);
  const overridden = React.useMemo(() => overriddenBy(className), [className]);
  const scale = levelScale[level];
  const muted = mutedLevels.has(level);

  const classNames = cx(
    // A hook *and* the second half of every guard below: the one component in
    // the library whose whole output is text is also the one a host stylesheet
    // most wants to reach, and a utility string is not a contract. Same
    // arrangement as `neba-link`, and the class has to stay first — every
    // `[&.neba-typography]:` utility on the element is matching it.
    'neba-typography',
    ...scaleClasses.map(([property, guard, floor]) => (overridden & property ? floor : guard)),
    // With `gutter` on, the top margin is left to the page, as it always was.
    gutter ? '' : overridden & MARGIN_TOP ? '[:where(&)]:mt-0' : '[&.neba-typography]:mt-0',
    level === 'overline' ? 'uppercase' : '',
    align ? alignClasses[align] : '',
    // `caption` and `overline` are spans, and a span has no line of its own to
    // align or to leave room under — both props did nothing on them. Not under a
    // clamp of two lines or more, which is a box of its own already, and whose
    // `display` a `block` beside it would win or lose by stylesheet order.
    levelElements[level] === 'span' && (align || gutter) && !(lines !== undefined && lines > 1)
      ? 'block'
      : '',
    lines ? clampClasses(lines) : '',
    // `.prose h1`–`h4` write `color` on a heading, so the ink is guarded too.
    // With no `color`, every level but the two quiet ones states no ink and
    // inherits: pinned to the page foreground, a Typography inside a solid
    // Alert drew dark text on the dark fill, and a host's own heading colour
    // never reached it.
    color
      ? overridden & COLOR
        ? '[:where(&)]:text-(--n-accent)'
        : '[&.neba-typography]:text-(--n-accent)'
      : muted
        ? overridden & COLOR
          ? '[:where(&)]:text-(--neba-muted-fg)'
          : '[&.neba-typography]:text-(--neba-muted-fg)'
        : '',
    animation.className,
    className ?? ''
  );

  return useRender({
    render: render ?? React.createElement(levelElements[level]),
    ref,
    props: {
      className: classNames,
      style: {
        '--n-type-size': scale.size,
        '--n-type-leading': scale.leading,
        '--n-type-tracking': scale.tracking,
        '--n-type-weight': weightValues[weight ?? levelWeights[level]],
        '--n-type-gutter': gutter ? `calc(var(--spacing, 0.25rem) * ${gutterSteps[level]})` : '0',
        ...(color ? { '--n-accent': `var(--neba-${color}-accent)` } : null),
        ...clampSlot(lines),
        ...animation.style,
        ...style
      } as React.CSSProperties,
      children,
      ...props
    }
  });
});
