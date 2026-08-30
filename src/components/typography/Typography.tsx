'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { transitionProps } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
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
  children?: React.ReactNode;
}

/**
 * The scale.
 *
 * Body sits on Card's body ladder at `md` (13px/22px), so a paragraph inside a
 * card and a standalone one are the same text. The headings step up from there
 * by roughly a major third, and the leading tightens as they grow — a 30px line
 * does not want the same 1.7 ratio a 13px one does.
 */
const levelClasses: Record<TypographyLevel, string> = {
  h1: 'text-[1.875rem]/[2.25rem] tracking-[-0.02em]',
  h2: 'text-[1.5rem]/[1.875rem] tracking-[-0.015em]',
  h3: 'text-[1.25rem]/[1.625rem] tracking-[-0.01em]',
  h4: 'text-[1.0625rem]/[1.5rem]',
  h5: 'text-[0.9375rem]/[1.375rem]',
  h6: 'text-[0.8125rem]/[1.25rem]',
  lead: 'text-[1.0625rem]/[1.75rem]',
  body: 'text-[0.8125rem]/[1.375rem]',
  caption: 'text-[0.75rem]/[1.125rem]',
  overline: 'text-[0.6875rem]/[1rem] tracking-[0.08em] uppercase'
};

/**
 * Weight is kept out of `levelClasses` and resolved in JS so that exactly one
 * `font-*` class is ever emitted. Passing both the level's weight and an
 * override would leave two utilities of equal specificity on the element, and
 * which of them wins is decided by their order in the generated stylesheet —
 * `font-semibold` beats `font-normal` there no matter which one you asked for.
 */
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

/** How much room a level leaves under itself when `gutter` is on. */
const gutterClasses: Record<TypographyLevel, string> = {
  h1: 'mb-4',
  h2: 'mb-3.5',
  h3: 'mb-3',
  h4: 'mb-2.5',
  h5: 'mb-2',
  h6: 'mb-2',
  lead: 'mb-4',
  body: 'mb-3',
  caption: 'mb-2',
  overline: 'mb-2'
};

const weightClasses: Record<TypographyWeight, string> = {
  regular: 'font-normal',
  medium: 'font-medium',
  semibold: 'font-semibold',
  bold: 'font-bold'
};

const alignClasses: Record<TypographyAlign, string> = {
  start: 'text-start',
  center: 'text-center',
  end: 'text-end',
  justify: 'text-justify'
};

/**
 * Clamping is two different mechanisms. One line is `text-overflow: ellipsis`,
 * which keeps the text on its own baseline; more than one needs the line-clamp
 * box, which only ellipsises because WebKit says so.
 */
const clampClasses: Record<number, string> = {
  1: 'truncate',
  2: 'line-clamp-2',
  3: 'line-clamp-3',
  4: 'line-clamp-4',
  5: 'line-clamp-5',
  6: 'line-clamp-6'
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

  const classNames = cx(
    levelClasses[level],
    weightClasses[weight ?? levelWeights[level]],
    align ? alignClasses[align] : '',
    lines ? (clampClasses[lines] ?? 'line-clamp-6') : '',
    gutter ? gutterClasses[level] : '',
    color
      ? 'text-(--n-accent)'
      : mutedLevels.has(level)
        ? 'text-(--neba-muted-fg)'
        : 'text-(--neba-fg)',
    animation.className,
    className ?? ''
  );

  return useRender({
    render: render ?? React.createElement(levelElements[level]),
    ref,
    props: {
      className: classNames,
      style: (color
        ? { '--n-accent': `var(--neba-${color}-accent)`, ...animation.style, ...style }
        : { ...animation.style, ...style }) as React.CSSProperties,
      children,
      ...props
    }
  });
});
