'use client';

import * as React from 'react';
import { chatMessages, useMessages } from '../../internal/i18n.js';
import { CheckIcon, ClockIcon, DangerIcon, LinkIcon } from '../../internal/icons.js';
import { safeRel } from '../../internal/link.js';
import {
  controlSlots,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  srOnlyClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaVariant } from '../../types.js';

/**
 * Whose message this is.
 *
 * `start` and `end` rather than `them`/`me` or `left`/`right`: a thread runs the
 * way the language does, and the same two words already mean this everywhere
 * else in the library. `start` is the default because a message from someone
 * else is the one you have no other way of knowing about.
 */
export type ChatBubbleSide = 'start' | 'end';

/**
 * How far a message has got.
 *
 * The four steps are a ladder and the fifth is not on it: `failed` is the
 * message that did not go, which is why it is the only one drawn in another
 * colour family.
 */
export type ChatBubbleStatus = 'sending' | 'sent' | 'delivered' | 'read' | 'failed';

/** What a link inside a message unfurls to. */
export interface ChatBubbleLinkPreview {
  /** Where the card goes. */
  url: string;
  /** The page's title. */
  title?: React.ReactNode;
  /** Its summary, clamped to two lines. */
  description?: React.ReactNode;
  /** The share image, drawn across the top of the card. */
  image?: string;
  /** Who published it — a domain, a site name. */
  site?: React.ReactNode;
  /** Opens the card in a new tab. @default false */
  newTab?: boolean;
}

export interface ChatBubbleProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'title'
> {
  /**
   * Whose message this is.
   * @default 'start'
   */
  side?: ChatBubbleSide;
  /** Who sent it, above the bubble. */
  name?: React.ReactNode;
  /** When it was sent, beside the name. */
  time?: React.ReactNode;
  /**
   * The sender's picture — an [Avatar](../display/avatar), at the size the
   * thread uses. Left out, the bubble takes the whole row.
   */
  avatar?: React.ReactNode;
  /**
   * How far the message has got, drawn as a mark under the bubble. Left out,
   * nothing is drawn — a received message has no delivery state worth showing.
   */
  status?: ChatBubbleStatus;
  /** Overrides the word the mark is read out as. */
  statusLabel?: string;
  /**
   * Draws the three dots instead of the message. What `children` holds is left
   * alone, so the same bubble can go back to it when the message arrives.
   * @default false
   */
  typing?: boolean;
  /**
   * A picture, a video, a map — drawn edge to edge above the text, so the
   * bubble's corners crop it.
   */
  media?: React.ReactNode;
  /** A link in the message, unfurled into a card under the text. */
  preview?: ChatBubbleLinkPreview;
  /**
   * The message's own actions — a [Menu](../inputs/menu) trigger, most of the
   * time. Sits beside the bubble and stays out of the way until the row is
   * hovered or something in it takes focus.
   */
  actions?: React.ReactNode;
  /**
   * Which language the marks are read out in — a BCP 47 tag such as `ko`,
   * `pt-BR` or `zh-Hant`. Unsupported tags fall back to English.
   */
  locale?: string;
  /**
   * Weight of the bubble's surface. `solid` is the usual way to tell your own
   * messages from everyone else's; `side` deliberately does not decide this,
   * because which end is filled is a decision about the product, not about the
   * component.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** Padding inside the bubble, and nothing else. @default 'default' */
  density?: NebaDensity;
  /** Drop shadow depth. `0` (the default) is flat. @default 0 */
  elevation?: NebaElevation;
  /** The message. */
  children?: React.ReactNode;
}

/**
 * A bubble's own padding track, tighter than the one a Box uses.
 *
 * A Box is a region of a page and a bubble is a sentence with a surface behind
 * it: 16px of padding around eight words is a card, not a message. Both axes,
 * because unlike a control a bubble has no height to fight.
 */
const bubblePaddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: {
    xs: 'px-2 py-1',
    sm: 'px-2.5 py-1.5',
    md: 'px-3 py-2',
    lg: 'px-3.5 py-2.5',
    xl: 'px-4 py-3'
  },
  compact: {
    xs: 'px-1.5 py-0.5',
    sm: 'px-2 py-1',
    md: 'px-2.5 py-1.5',
    lg: 'px-3 py-1.5',
    xl: 'px-3.5 py-2'
  }
};

/**
 * The corner nearest the speaker is cut short.
 *
 * This is the library's one piece of chat vocabulary, and it does the job a
 * drawn tail does elsewhere: it says which end of the row the message came
 * from, without hanging a triangle off a sheet of acrylic that is supposed to
 * have been cut with a straight edge. Written as the logical properties rather
 * than as `rounded-tl`, so a thread in Arabic squares the other corner without
 * being told.
 *
 * A flat 4px rather than a step down the radius ladder, and that is the whole
 * point of writing it out: the ladder runs 10px to 22px, so `--neba-radius-xs`
 * against `--neba-radius-md` is a four-pixel difference nobody would ever read
 * as meaning something. The cut has to be obvious at a glance in a column of
 * forty messages or it is not saying anything.
 */
const tailClasses: Record<ChatBubbleSide, string> = {
  start: '[border-start-start-radius:0.25rem]',
  end: '[border-start-end-radius:0.25rem]'
};

/**
 * Filled, hairline, tinted.
 *
 * A bubble *is* the thing being coloured — unlike a Box, which holds other
 * people's content and so keeps its sheet undyed — so `solid` floods it and the
 * text switches to `--n-on-solid`. That is what makes a column of your own
 * messages read as yours at a glance rather than one line at a time.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-(--n-soft) [box-shadow:var(--n-elev)]'
};

/**
 * The double tick, drawn here rather than in `internal/icons` because it is the
 * one glyph in the library only one component has any use for.
 *
 * Two ticks overlapping by a third of their width, which is what says "two"
 * without doubling the width of the mark — a delivered message and a sent one
 * have to be told apart at 12px, side by side, in a column.
 */
function DoubleCheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m1.5 8.5 2.75 2.75L9.5 6"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M7 10.75 8.25 12l5.25-5.25"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** One glyph per step. `read` shares the mark with `delivered` and takes the colour. */
const statusIcons: Record<ChatBubbleStatus, React.ReactNode> = {
  sending: <ClockIcon />,
  sent: <CheckIcon />,
  delivered: <DoubleCheckIcon />,
  read: <DoubleCheckIcon />,
  failed: <DangerIcon />
};

/**
 * Only two of the five carry a colour: the one that arrived and the one that
 * did not. The three in between are the ordinary course of events, and a thread
 * where every message is marked in colour is a thread where the colour has
 * stopped meaning anything.
 */
const statusToneClasses: Record<ChatBubbleStatus, string> = {
  sending: 'text-(--neba-muted-fg)',
  sent: 'text-(--neba-muted-fg)',
  delivered: 'text-(--neba-muted-fg)',
  read: 'text-(--n-accent)',
  failed: 'text-(--neba-danger-accent)'
};

/**
 * The card a link unfurls into.
 *
 * Its surface is mixed out of `currentColor` rather than out of a token,
 * because it is the one part of a bubble that has to work on both a filled
 * surface and a bare one: on `solid` the text is white and the card is a white
 * wash, on `outline` the text is the page's ink and the card is a grey one. A
 * fixed token would be invisible against one of the two.
 */
const previewSurfaceClasses = [
  'block overflow-hidden rounded-(--neba-radius-sm) border no-underline',
  '[border-color:color-mix(in_oklab,currentColor_18%,transparent)]',
  '[background-color:color-mix(in_oklab,currentColor_7%,transparent)]',
  'hover:[background-color:color-mix(in_oklab,currentColor_12%,transparent)]',
  '[transition-property:background-color] [transition-duration:var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

/**
 * The affordance stays out of the way of the message until the row is reached
 * for — the same allowance `chipRemoveClasses` takes, and for the same reason:
 * this is not a control changing what it is, it is a handle that would otherwise
 * sit in the middle of a conversation being read.
 *
 * A pointer that cannot hover has nothing to reveal it, so it is simply always
 * there on touch.
 */
const actionsClasses = [
  'shrink-0 opacity-0',
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'group-hover/bubble:opacity-100 group-focus-within/bubble:opacity-100',
  '[@media(hover:none)]:opacity-100'
].join(' ');

/**
 * One message in a conversation.
 *
 * Everything around the bubble is optional and nothing about it is fixed by
 * `side`: the avatar, the sender's name, the time, the delivery mark, the media
 * above the text and the link card below it are each drawn only when they are
 * given something. What `side` decides is which way the row runs and which
 * corner of the sheet is cut short.
 *
 * `variant` is what tells your own messages from everyone else's, and it is
 * deliberately not tied to `side` — filling the right-hand column is a
 * convention, not a law, and a thread that fills neither is a perfectly good
 * thread.
 */
export const ChatBubble = React.forwardRef<HTMLDivElement, ChatBubbleProps>(function ChatBubble(
  {
    side = 'start',
    name,
    time,
    avatar,
    status,
    statusLabel,
    typing = false,
    media,
    preview,
    actions,
    locale,
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const messages = useMessages(chatMessages, locale);
  const end = side === 'end';

  const hasHeader = hasContent(name) || hasContent(time);
  const hasBody = typing || hasContent(children) || Boolean(preview);

  const bubbleClasses = [
    'flex min-w-0 flex-col overflow-hidden',
    radiusClasses[size],
    tailClasses[side],
    variantClasses[variant],
    transitionClasses
  ].join(' ');

  const statusText = status ? (statusLabel ?? messages[status]) : '';

  return (
    <div
      ref={ref}
      className={[
        'group/bubble flex w-full items-start gap-2',
        end ? 'flex-row-reverse' : '',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...controlSlots(color, elevation, variant), ...style }}
      {...props}
    >
      {hasContent(avatar) ? <div className="shrink-0">{avatar}</div> : null}

      <div
        className={[
          'flex min-w-0 max-w-[min(100%,32rem)] flex-col',
          sheetHeaderGapClasses[size],
          end ? 'items-end' : 'items-start'
        ].join(' ')}
      >
        {hasHeader ? (
          <div className={`flex items-baseline gap-2 ${metaTextClasses[size]}`}>
            {hasContent(name) ? <span className="font-semibold">{name}</span> : null}
            {hasContent(time) ? <span className="text-(--neba-muted-fg)">{time}</span> : null}
          </div>
        ) : null}

        <div className={`flex min-w-0 items-center gap-1 ${end ? 'flex-row-reverse' : ''}`}>
          <div className={bubbleClasses}>
            {/* Edge to edge: the bubble's own corners are what crop it, which is
                why the padding lives on the sections rather than on the sheet. */}
            {hasContent(media) ? (
              <div className="[&_img]:block [&_img]:w-full [&_video]:block [&_video]:w-full">
                {media}
              </div>
            ) : null}

            {hasBody ? (
              <div
                className={[
                  bubblePaddingClasses[density][size],
                  'flex min-w-0 flex-col gap-2',
                  sheetBodyClasses[size]
                ].join(' ')}
              >
                {typing ? (
                  <TypingDots label={messages.typing} />
                ) : hasContent(children) ? (
                  <div className="min-w-0 break-words whitespace-pre-line">{children}</div>
                ) : null}

                {preview ? <LinkPreview preview={preview} /> : null}
              </div>
            ) : null}
          </div>

          {hasContent(actions) ? <div className={actionsClasses}>{actions}</div> : null}
        </div>

        {status ? (
          <div
            className={[
              'flex items-center gap-1',
              metaTextClasses[size],
              statusToneClasses[status],
              '[&_svg]:size-[1.15em] [&_svg]:shrink-0'
            ].join(' ')}
          >
            {statusIcons[status]}
            {/* The mark is the whole of what is drawn; the word behind it is for
                the readers the mark says nothing to. */}
            <span className={srOnlyClasses}>{statusText}</span>
          </div>
        ) : null}
      </div>
    </div>
  );
});

/**
 * Three dots that light in sequence.
 *
 * Colour only, like every other indeterminate indicator in the library — the
 * dots never move, so a bubble that is being typed into does not bounce in a
 * thread somebody is reading. The delay is carried per dot in `--n-i`, the same
 * slot `neba-plate-wave` uses.
 */
function TypingDots({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-1 py-[0.35em]" role="status">
      {[0, 1, 2].map((index) => (
        <span
          key={index}
          aria-hidden="true"
          className="neba-typing-dot size-[0.45em] rounded-full"
          style={{ '--n-i': index } as React.CSSProperties}
        />
      ))}
      <span className={srOnlyClasses}>{label}</span>
    </div>
  );
}

/** The unfurled link: an image, who published it, a title and two lines of summary. */
function LinkPreview({ preview }: { preview: ChatBubbleLinkPreview }) {
  const { url, title, description, image, site, newTab = false } = preview;
  const target = newTab ? '_blank' : undefined;

  return (
    <a
      href={url}
      target={target}
      rel={safeRel(target, undefined)}
      className={previewSurfaceClasses}
    >
      {image ? (
        // Decorative: everything the picture is saying is written underneath it.
        <img src={image} alt="" className="block h-28 w-full object-cover" />
      ) : null}
      <div className="flex flex-col gap-0.5 p-2">
        {hasContent(site) ? (
          <span className="flex items-center gap-1 text-[0.85em] opacity-70 [&_svg]:size-[1em] [&_svg]:shrink-0">
            <LinkIcon />
            <span className="truncate">{site}</span>
          </span>
        ) : null}
        {hasContent(title) ? <span className="font-semibold">{title}</span> : null}
        {hasContent(description) ? (
          <span className="line-clamp-2 text-[0.9em] opacity-80">{description}</span>
        ) : null}
      </div>
    </a>
  );
}
