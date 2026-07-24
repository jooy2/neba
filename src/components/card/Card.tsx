import * as React from 'react';
import { Box, boxPaddingXClasses, boxPaddingYClasses, type BoxProps } from '../box/Box';
import type { NebaSize } from '../../types';

export interface CardProps extends Omit<BoxProps, 'title' | 'padded'> {
  /**
   * The card's heading. A plain string is styled as the title; pass a real
   * heading element (`title={<h2>…</h2>}`) when the card needs to appear in the
   * document outline — it inherits the title's typography rather than the
   * browser's.
   */
  title?: React.ReactNode;
  /** A second line under the title, one step down the type scale and muted. */
  subtitle?: React.ReactNode;
  /**
   * Content pinned to the end of the header row — a menu button, a status chip.
   * Stays on the title's line while the title wraps beside it.
   */
  headerAction?: React.ReactNode;
  /**
   * The bottom area. Laid out as a wrapping row so a pair of buttons needs no
   * wrapper of its own; anything else can bring its own layout.
   */
  footer?: React.ReactNode;
  /**
   * Draws a hairline between the sections instead of separating them with
   * space. The lines run the full width of the sheet, so the padding moves from
   * the card onto each section.
   * @default false
   */
  dividers?: boolean;
  /** The card's body. */
  children?: React.ReactNode;
}

/**
 * The title sits one step above the body, the subtitle one step below it — the
 * same two ladders Button and TextField use, so a card's header lines up with
 * the controls that end up inside it.
 */
const titleClasses: Record<NebaSize, string> = {
  xs: 'text-[0.75rem]/[1rem]',
  sm: 'text-[0.8125rem]/[1.125rem]',
  md: 'text-[0.9375rem]/[1.25rem]',
  lg: 'text-[1.0625rem]/[1.5rem]',
  xl: 'text-[1.25rem]/[1.75rem]'
};

const subtitleClasses: Record<NebaSize, string> = {
  xs: 'text-[0.625rem]',
  sm: 'text-[0.6875rem]',
  md: 'text-[0.75rem]',
  lg: 'text-[0.8125rem]',
  xl: 'text-[0.875rem]'
};

/**
 * Body copy, on Button's type scale but with the leading opened up: a label is
 * one line and a card body is a paragraph.
 */
const bodyClasses: Record<NebaSize, string> = {
  xs: 'text-[0.6875rem]/[1rem]',
  sm: 'text-[0.75rem]/[1.125rem]',
  md: 'text-[0.8125rem]/[1.375rem]',
  lg: 'text-[0.9375rem]/[1.5rem]',
  xl: 'text-[1.0625rem]/[1.75rem]'
};

/** Title to subtitle. Tight — they are one block of text, not two sections. */
const headerGapClasses: Record<NebaSize, string> = {
  xs: 'gap-0.5',
  sm: 'gap-0.5',
  md: 'gap-1',
  lg: 'gap-1',
  xl: 'gap-1.5'
};

/** Between sections, when there are no dividers to separate them. */
const sectionGapClasses: Record<NebaSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/**
 * The internal hairline is the same `--n-line` as the card's own edge, so it
 * reads as the sheet being scored rather than as a second, unrelated rule.
 */
const dividerClasses = 'border-t [border-color:var(--n-line)]';

/** `false`, `null`, `undefined` and `''` all mean "this section is not there". */
function hasContent(node: React.ReactNode): boolean {
  return node !== undefined && node !== null && node !== false && node !== '';
}

/**
 * A Box with the parts a card is made of laid out on it: a title, a subtitle,
 * a body and a footer.
 *
 * The sections are props rather than compound sub-components — `<Card.Header>`,
 * `<Card.Title>` — for the same reason TextField takes `label` and `description`
 * as props: the arrangement is fixed, and the thing a caller wants to decide is
 * what goes in each slot, not what order the slots come in.
 *
 * Every Box prop passes straight through, so a card is styled on exactly the
 * same axes as the box it is.
 */
export const Card = React.forwardRef<HTMLDivElement, CardProps>(function Card(
  {
    size = 'md',
    density = 'default',
    title,
    subtitle,
    headerAction,
    footer,
    dividers = false,
    className,
    children,
    ...props
  },
  ref
) {
  const insetX = boxPaddingXClasses[density][size];
  const insetY = boxPaddingYClasses[density][size];
  // With dividers the lines have to reach both edges, so the sheet gives up its
  // padding and every section takes it on instead. Without them the sheet keeps
  // its vertical padding and the sections are told apart by a gap.
  const sectionClasses = dividers ? `${insetX} ${insetY}` : insetX;

  const hasHeader = hasContent(title) || hasContent(subtitle) || hasContent(headerAction);

  const header = (
    <>
      {hasContent(title) || hasContent(subtitle) ? (
        <div className={`flex min-w-0 flex-1 flex-col ${headerGapClasses[size]}`}>
          {hasContent(title) ? (
            <div className={`neba-card-title font-semibold ${titleClasses[size]}`}>{title}</div>
          ) : null}
          {hasContent(subtitle) ? (
            <div className={`text-(--neba-muted-fg) ${subtitleClasses[size]}`}>{subtitle}</div>
          ) : null}
        </div>
      ) : null}
      {hasContent(headerAction) ? <div className="ml-auto shrink-0">{headerAction}</div> : null}
    </>
  );

  const sections = [
    hasHeader ? { key: 'header', className: 'flex items-start gap-3', content: header } : null,
    hasContent(children)
      ? { key: 'content', className: bodyClasses[size], content: children }
      : null,
    hasContent(footer)
      ? {
          key: 'footer',
          className: `flex flex-wrap items-center gap-2 ${bodyClasses[size]}`,
          content: footer
        }
      : null
  ].filter((section) => section !== null);

  return (
    <Box
      ref={ref}
      size={size}
      density={density}
      padded={false}
      className={[
        'flex flex-col',
        dividers ? '' : `${insetY} ${sectionGapClasses[size]}`,
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      {...props}
    >
      {sections.map((section, index) => (
        <div
          key={section.key}
          className={[
            sectionClasses,
            section.className,
            dividers && index > 0 ? dividerClasses : ''
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {section.content}
        </div>
      ))}
    </Box>
  );
});
