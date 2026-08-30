'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses } from '../box/Box.js';
import { transitionProps } from '../../internal/animate.js';
import { emptyMessages, useMessages } from '../../internal/i18n.js';
import {
  cx,
  hasContent,
  iconClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaDensity,
  NebaElevation,
  NebaSize,
  NebaStyleProps,
  NebaTransition
} from '../../types.js';

export interface EmptyProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title'> {
  /**
   * The headline. Defaults to the `locale`'s way of saying that there is
   * nothing here; pass `false` for a state that is a glyph and a sentence with
   * no heading over them.
   */
  title?: React.ReactNode | false;
  /**
   * The glyph above the headline. Defaults to the empty tray; pass `false` to
   * drop it, or a node — an illustration, a brand mark, an icon from any set —
   * to replace it. An `svg` is sized off the `size` ladder; anything else is
   * left at whatever size it came in at.
   */
  icon?: React.ReactNode | false;
  /**
   * What to do about it, under the text: a "Create the first one" button, a
   * "Clear filters" link. Several of them sit in a row and wrap together.
   */
  action?: React.ReactNode;
  /**
   * Which language the default headline is written in — a BCP 47 tag. Ignored
   * once `title` is given, and unsupported tags fall back to English.
   * @default 'en'
   */
  locale?: string;
  /**
   * Drop shadow depth. `0` (the default) is flat, and it is almost always
   * right: an empty state is a hole in a surface that already exists rather
   * than a sheet of its own.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * An entrance animation, run once on mount: `transition="fade"` for a list
   * that has just come back with nothing. For a trigger or a replay, wrap it in
   * an `Animate*` component instead.
   */
  transition?: NebaTransition;
  /** Renders something other than a `<div>`: `render={<td colSpan={5} />}`. */
  render?: useRender.RenderProp;
  /** The sentence under the headline: why it is empty, or what to do next. */
  children?: React.ReactNode;
}

/**
 * The room the state takes, and its own ladder rather than Box's.
 *
 * A Box is padded so its content does not touch the edge; an empty state is
 * padded so the emptiness reads as *deliberate*. Given a Box's `p-4` a `md`
 * one comes out the height of three lines of text, which looks like a
 * paragraph that failed to load rather than an answer to a question.
 *
 * The horizontal track is Box's, unchanged: sideways there is nothing to say,
 * and a state set into a card should have the card's own gutters.
 */
const emptyPaddingYClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'py-5', sm: 'py-6', md: 'py-8', lg: 'py-10', xl: 'py-12' },
  compact: { xs: 'py-3', sm: 'py-3.5', md: 'py-4', lg: 'py-5', xl: 'py-6' }
};

/**
 * The glyph's scale, as a font size the shared `iconClasses` then reads.
 *
 * An `em` rather than a box, for the reason Alert's glyph is one: whatever the
 * caller hands over is measured against the type around it, so an icon from
 * another set lands at the same weight as ours. It is a long way above the
 * 1.2em an icon rides a label at, because this one is not riding anything —
 * it is the first thing in an otherwise empty rectangle.
 */
const glyphScaleClasses: Record<NebaSize, string> = {
  xs: 'text-[1.25rem]',
  sm: 'text-[1.5rem]',
  md: 'text-[1.75rem]',
  lg: 'text-[2.125rem]',
  xl: 'text-[2.5rem]'
};

/**
 * The three weights, said the way a *container* says them, exactly as on Box:
 * the sheet is never dyed, because `action` is somebody else's button and it
 * arrived with its own colours.
 *
 * `text` is the default here and nowhere else. An empty state is nearly always
 * already inside something — a Card's body, a Table below its header, a panel
 * — and a second rectangle drawn inside the first is one rectangle too many.
 * The other two are for the case where it is not: a region of a page that has
 * nothing else to mark its bounds.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * The tray with nothing in it.
 *
 * Drawn here rather than in `internal/icons.tsx` because one component draws
 * it, and drawn as a tray rather than as a folder, a magnifying glass or a
 * document because those three each name a *reason* — nothing filed, nothing
 * found, nothing written — and this glyph has to sit over all of them.
 *
 * The lip is a separate stroke, so what the drawing shows is a container with
 * an opening and no contents rather than a solid block.
 */
function TrayIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M1.75 9.75h3l.9 1.6h4.7l.9-1.6h3"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="m1.75 9.75 2.1-6a1.5 1.5 0 0 1 1.42-1h5.46a1.5 1.5 0 0 1 1.42 1l2.1 6v2a1.5 1.5 0 0 1-1.5 1.5h-9.5a1.5 1.5 0 0 1-1.5-1.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * What stands where content would have been: a glyph, a headline, a sentence
 * and a way out.
 *
 * It is the other half of [Skeleton](../feedback/skeleton). A skeleton is the
 * shape of something on its way; this is the shape of something that is not
 * coming — a search with no matches, an inbox nobody has written to, a folder
 * before the first file. The two are never both right at once, and a list that
 * shows neither has a blank rectangle where its answer should be.
 *
 * The headline is the only text in the library a component invents at full
 * size, and it is defaulted rather than required for one reason: the version
 * that says nothing useful is the version that gets shipped. `Nothing here` in
 * the reader's language is a floor, and every slot above it — the glyph, the
 * sentence, the action — is there to be filled with what is actually missing.
 *
 * `surfaceSlots` is the undyed slot set, so `color` reaches the hairline and
 * the ring and stops there. An empty state that arrives in the accent colour is
 * making a claim about content that does not exist; the family is worth
 * changing only when the emptiness is itself a problem (`color="danger"` on a
 * region that failed to load).
 */
export const Empty = React.forwardRef<HTMLDivElement, EmptyProps>(function Empty(
  {
    variant = 'text',
    size = 'md',
    color = 'secondary',
    density = 'default',
    elevation = 0,
    title,
    icon,
    action,
    locale,
    transition,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const messages = useMessages(emptyMessages, locale);
  const heading = title === undefined ? messages.title : title;
  const glyph = icon === undefined ? <TrayIcon /> : icon;
  const animation = transitionProps(transition);
  const titled = hasContent(heading);

  const classNames = cx(
    'flex w-full flex-col items-center justify-center text-center',
    boxPaddingXClasses[density][size],
    emptyPaddingYClasses[density][size],
    radiusClasses[size],
    sheetSectionGapClasses[size],
    transitionClasses,
    variantClasses[variant],
    animation.className,
    className ?? ''
  );

  return useRender({
    render,
    ref,
    props: {
      // A list that empties under the reader has to say so, and it has no other
      // way to: nothing was removed from the page, something was added to it.
      // Announced rather than interrupting, because "no results" is the answer
      // to a question that was just asked. `role={undefined}` turns it off for
      // a state that is simply part of the page on arrival.
      role: 'status',
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...animation.style, ...style },
      children: (
        <>
          {hasContent(glyph) ? (
            <span
              className={`flex items-center text-(--neba-muted-fg) ${glyphScaleClasses[size]} ${iconClasses}`}
            >
              {glyph}
            </span>
          ) : null}

          {titled || hasContent(children) ? (
            // `max-w-prose` and nothing narrower: an empty state is centred, and
            // a centred sentence running the full width of a page is a sentence
            // whose second line starts somewhere the eye has to hunt for.
            <div
              className={`flex max-w-prose flex-col items-center ${sheetHeaderGapClasses[size]}`}
            >
              {titled ? (
                <div className={`neba-title font-semibold ${sheetTitleClasses[size]}`}>
                  {heading}
                </div>
              ) : null}
              {hasContent(children) ? (
                // The detail is supporting text under a headline, so it takes
                // the muted ink — the same step a field's description takes.
                // Without a headline it *is* the state, and stays reading text.
                <div
                  className={`${sheetBodyClasses[size]} ${titled ? 'text-(--neba-muted-fg)' : ''}`}
                >
                  {children}
                </div>
              ) : null}
            </div>
          ) : null}

          {hasContent(action) ? (
            <div className="flex flex-wrap items-center justify-center gap-2">{action}</div>
          ) : null}
        </>
      ),
      ...props
    }
  });
});
