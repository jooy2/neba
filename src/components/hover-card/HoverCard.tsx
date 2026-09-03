'use client';

import * as React from 'react';
import { PreviewCard } from '@base-ui/react/preview-card';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  popupFadeClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { NebaAlign, NebaSide, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * The same three axes a [Popover](./popover) takes, and for the same reasons:
 * no `variant`, because a surface that had to be hovered has already asserted
 * itself, and no `elevation`, because a card floating over the page is the
 * whole idea and a prop that could sit it flat would undo it.
 */
export interface HoverCardProps
  extends
    Pick<NebaStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /**
   * What the card hangs off. Exactly one element, which must accept a ref and
   * spread props — every Neba component does.
   *
   * Usually a [TextLink](../display/text-link) or an
   * [Avatar](../display/avatar): the two things a reader wants to know more
   * about without leaving the sentence they are in.
   */
  trigger: React.ReactElement;
  /** The heading, rendered as the element that names the card. */
  title?: React.ReactNode;
  /** A line under the title. */
  description?: React.ReactNode;
  /** The body. */
  children?: React.ReactNode;
  /**
   * Which edge of the trigger it appears on. Flips when there is no room.
   * @default 'bottom'
   */
  side?: NebaSide;
  /** Where it sits along that edge. @default 'center' */
  align?: NebaAlign;
  /** Distance from the trigger, in pixels. @default 6 */
  sideOffset?: number;
  /** Shift along that edge, in pixels. @default 0 */
  alignOffset?: number;
  /**
   * Draws the wedge pointing at the trigger. Off by default, exactly as on
   * Popover: this surface is translucent over a blurred backdrop, and a wedge
   * sticking out past the card's own box cannot carry that backdrop with it.
   * @default false
   */
  arrow?: boolean;
  /** Whether the card is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * How long the pointer has to rest on the trigger before the card opens, in
   * milliseconds. The default is long enough that crossing a paragraph of links
   * does not open four of them.
   */
  delay?: number;
  /**
   * How long the card stays after the pointer has left, in milliseconds. This
   * is what makes the gap between the trigger and the card crossable.
   */
  closeDelay?: number;
  /** A hard cap on the card's width, overriding the one `size` implies. */
  width?: number | string;
}

/** One rung wider than a Popover's ladder: this one is a preview, not a note. */
const maxWidthClasses: Record<NebaSize, string> = {
  xs: 'max-w-64',
  sm: 'max-w-72',
  md: 'max-w-84',
  lg: 'max-w-md',
  xl: 'max-w-xl'
};

/** The same sheet a Popover draws, because it is the same sheet. */
const popupClasses = [
  surfaceClasses,
  'relative flex flex-col',
  'border text-(--neba-fg) bg-(--n-panel-press)',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  popupFadeClasses
].join(' ');

const arrowSizes: Record<NebaSize, number> = {
  xs: 8,
  sm: 9,
  md: 10,
  lg: 11,
  xl: 12
};

/**
 * A card that opens when the pointer rests on something, and holds a preview of
 * what is on the other side of it.
 *
 * It sits between the library's other two popups, and the distance is short in
 * both directions. A [Tooltip](../feedback/tooltip) is a label — one line, no
 * interaction, and the pointer never reaches it. A [Popover](./popover) is a
 * panel that was *asked for* by a press, so it can hold a form. This one is
 * uninvited like a tooltip and reachable like a popover: the pointer can cross
 * into it, and a link inside it can be followed.
 *
 * Because it is uninvited, it is never the only way to something. Whatever is in
 * here has to exist on the page the trigger leads to as well — a keyboard
 * without hover, a touchscreen with no pointer at all, and a screen reader all
 * arrive by that route instead.
 */
export function HoverCard(rawProps: HoverCardProps) {
  const {
    size = 'md',
    color = 'primary',
    density = 'default',
    trigger,
    title,
    description,
    children,
    side = 'bottom',
    align = 'center',
    sideOffset = 6,
    alignOffset = 0,
    arrow = false,
    open,
    defaultOpen,
    onOpenChange,
    delay,
    closeDelay,
    width,
    className,
    style,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'density']);

  const insetX = boxPaddingXClasses[density][size];
  const insetY = boxPaddingYClasses[density][size];
  const arrowSize = arrowSizes[size];

  const hasHeader = hasContent(title) || hasContent(description);
  const maxWidth = toLength(width);

  return (
    <PreviewCard.Root
      open={open}
      defaultOpen={defaultOpen}
      onOpenChange={(next) => onOpenChange?.(next)}
    >
      <PreviewCard.Trigger render={trigger} delay={delay} closeDelay={closeDelay} />

      <PreviewCard.Portal>
        {/* `neba-portal` is a hook, not a style: a portalled popup leaves the
            subtree a host may have scoped its CSS reset to. */}
        <PreviewCard.Positioner
          className="neba-portal z-50 [outline:none]"
          side={side}
          align={align}
          sideOffset={sideOffset}
          alignOffset={alignOffset}
        >
          <PreviewCard.Popup
            className={cx(
              popupClasses,
              radiusClasses[size],
              sheetBodyClasses[size],
              sheetSectionGapClasses[size],
              insetX,
              insetY,
              maxWidth === undefined ? maxWidthClasses[size] : '',
              className ?? ''
            )}
            style={{
              ...surfaceSlots(color, 3),
              ...(maxWidth === undefined ? null : { maxWidth }),
              ...style
            }}
            {...props}
          >
            {arrow ? (
              <PreviewCard.Arrow
                // Drawn pointing down once and turned to match the side Base UI
                // reports — a rotation of a glyph, which is the one allowance
                // the no-transform rule makes.
                className={[
                  'data-[side=top]:bottom-[-1px]',
                  'data-[side=bottom]:top-[-1px] data-[side=bottom]:rotate-180',
                  'data-[side=left]:right-[-1px] data-[side=left]:-rotate-90',
                  'data-[side=right]:left-[-1px] data-[side=right]:rotate-90'
                ].join(' ')}
              >
                <svg
                  width={arrowSize}
                  height={arrowSize / 2}
                  viewBox="0 0 10 5"
                  aria-hidden="true"
                  className="block"
                >
                  <path d="M0 0h10L5 5z" fill="var(--n-panel-press)" />
                  <path
                    d="M0 0 5 5 10 0"
                    fill="none"
                    stroke="var(--n-line)"
                    strokeWidth="1"
                    vectorEffect="non-scaling-stroke"
                  />
                </svg>
              </PreviewCard.Arrow>
            ) : null}

            {hasHeader ? (
              <div className={`flex min-w-0 flex-col ${sheetHeaderGapClasses[size]}`}>
                {hasContent(title) ? (
                  <div className={`m-0 font-semibold ${sheetTitleClasses[size]}`}>{title}</div>
                ) : null}
                {hasContent(description) ? (
                  <div className={`m-0 text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
                    {description}
                  </div>
                ) : null}
              </div>
            ) : null}

            {hasContent(children) ? <div className="min-w-0">{children}</div> : null}
          </PreviewCard.Popup>
        </PreviewCard.Positioner>
      </PreviewCard.Portal>
    </PreviewCard.Root>
  );
}
