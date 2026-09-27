'use client';

import * as React from 'react';
import { HoverCard } from '../hover-card/HoverCard.js';
import { TextLink } from '../text-link/TextLink.js';
import {
  fillMessage,
  linkMessages,
  sourcesMessages,
  useMessages,
  type SourcesMessages
} from '../../internal/i18n.js';
import { opensElsewhere, safeHref, safeRel } from '../../internal/link.js';
import {
  citationMarkClasses,
  cx,
  focusRingClasses,
  hasContent,
  metaTextClasses,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface InlineCitationProps extends Omit<
  React.ComponentPropsWithoutRef<'a'>,
  'color' | 'title' | 'children'
> {
  /**
   * Which source this is, and the only thing the mark itself says. It is the
   * caller's number rather than one counted here: a citation sits in a
   * paragraph, and the list it points at is somewhere else on the page.
   */
  index: number;
  /** The heading of the preview. Without it there is nothing to preview. */
  title?: React.ReactNode;
  /** The line under it — the passage that was used, the publisher, a date. */
  description?: React.ReactNode;
  /** Where it came from, set beside the title in the preview. */
  site?: React.ReactNode;
  /**
   * Where the citation points. A scheme outside `http`, `https`, `mailto` and
   * `tel` leaves the mark as plain text rather than writing the URL out. Without
   * one the mark is a `<span>`, which takes the keyboard focus only when it has
   * a preview to open.
   */
  href?: string;
  /** Where the link opens. `rel` gains `noopener noreferrer` whenever it leaves the tab. */
  target?: string;
  /**
   * Shows the preview on hover and on focus. Off, the mark is a bare link, and
   * the reader has the list at the bottom of the answer and nothing else.
   * @default true
   */
  preview?: boolean;
  /** The type scale of the preview. The mark itself is sized in `em`. @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** Which language the mark's accessible name is written in, as a BCP 47 tag. */
  locale?: string;
  /** That sentence, written out. Overrides the `locale`'s. */
  labels?: Partial<SourcesMessages>;
}

/**
 * A numbered footnote in the body of an answer, with the source behind it a
 * hover away.
 *
 * The mark is the same square a [Sources](./sources) row draws, and that is the
 * whole arrangement: a reader sees `2` in a sentence and finds `2` in the list
 * underneath. Both read one class from `internal/styles.ts`, because two
 * drawings of one number is two chances for the pair to stop matching.
 *
 * `index` is the caller's rather than counted here. A citation sits inside a
 * paragraph and the list it points at is somewhere else on the page, so there
 * is no parent that could number it — and a component that numbered itself by
 * render order would renumber the whole answer whenever a sentence moved.
 */
export const InlineCitation = React.forwardRef<HTMLElement, InlineCitationProps>(
  function InlineCitation(rawProps, ref) {
    const {
      index,
      title,
      description,
      site,
      href,
      target,
      rel,
      preview = true,
      size = 'md',
      color = 'primary',
      locale,
      labels,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'locale']);

    const messages = useMessages(sourcesMessages, locale);
    const linkWords = useMessages(linkMessages, locale);
    const words = { ...messages, ...labels };
    const name = fillMessage(words.citation, { index: String(index) });
    const address = safeHref(href);
    const previews = preview && hasContent(title);

    // Not a superscript. A `<sup>` shrinks the number a second time on top of
    // the `0.8em` the mark already is, and at that size a digit in a tinted box
    // is a smudge rather than a number a reader can act on.
    const shared = {
      className: cx(
        citationMarkClasses,
        'align-[0.15em] no-underline',
        address ? 'cursor-pointer' : 'cursor-default',
        'hover:bg-(--n-soft-hover)',
        focusRingClasses,
        transitionClasses,
        className ?? ''
      ),
      style: {
        '--n-soft': `var(--neba-${color}-soft)`,
        '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
        '--n-on-tint': `var(--neba-${color}-on-tint)`,
        '--n-ring': `var(--neba-${color}-ring)`,
        ...style
      } as React.CSSProperties
    };

    /*
     * With no address there is no link, and an `<a>` without an `href` is not
     * one: it takes no focus, and an `aria-label` on an element with no role is
     * one a screen reader may not read. So the mark is a `<span>` that says its
     * name in text, and takes the focus only when there is a preview for the
     * focus to open.
     */
    const mark = address ? (
      <a
        ref={ref as React.Ref<HTMLAnchorElement>}
        href={address}
        target={target}
        rel={safeRel(target, rel)}
        // The name is the whole of what is read, so the words that say the link
        // opens a new tab go into it rather than beside it.
        aria-label={opensElsewhere(target) ? `${name} ${linkWords.newTab}` : name}
        {...shared}
        {...props}
      >
        {index}
      </a>
    ) : (
      <span
        ref={ref as React.Ref<HTMLSpanElement>}
        tabIndex={previews ? 0 : undefined}
        {...shared}
        {...(props as React.HTMLAttributes<HTMLSpanElement>)}
      >
        <span className={srOnlyClasses}>{name}</span>
        <span aria-hidden="true">{index}</span>
      </span>
    );

    if (!previews) {
      return mark;
    }

    return (
      <HoverCard
        size={size}
        color={color}
        trigger={mark}
        title={
          address ? (
            <TextLink
              href={address}
              underline="hover"
              target={target}
              rel={safeRel(target, rel)}
              locale={locale}
            >
              {title}
            </TextLink>
          ) : (
            title
          )
        }
        description={site}
      >
        {hasContent(description) ? (
          <span className={cx('text-(--neba-muted-fg)', metaTextClasses[size])}>{description}</span>
        ) : null}
      </HoverCard>
    );
  }
);
