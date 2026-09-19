'use client';

import * as React from 'react';
import { Collapsible as BaseUICollapsible } from '@base-ui/react/collapsible';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { ChevronIcon } from '../../internal/icons.js';
import { TextLink } from '../text-link/TextLink.js';
import { safeHref, safeRel } from '../../internal/link.js';
import { sourcesMessages, useMessages, type SourcesMessages } from '../../internal/i18n.js';
import {
  citationMarkClasses,
  collapsiblePanelClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaElevation,
  NebaSize,
  NebaSlots,
  NebaStyleProps,
  NebaVariant
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** One thing an answer was built out of. */
export interface SourceItem {
  /** Its name. The link text, and the heading of an [InlineCitation]'s preview. */
  title: React.ReactNode;
  /**
   * Where it points. A scheme outside `http`, `https`, `mailto` and `tel`
   * leaves the row without a link rather than writing it out, because a URL in
   * a search result was not written by the page's author.
   */
  href?: string;
  /** The line under the title — the passage that matched, the publisher, a date. */
  description?: React.ReactNode;
  /** Where it came from, set beside the title. A domain, a publication. */
  site?: React.ReactNode;
  /** A favicon or a thumbnail, in the square before the number. */
  icon?: React.ReactNode;
  /**
   * The number this source is cited by, overriding its place in the list. For a
   * list that shows only the sources actually cited, out of a longer set.
   */
  index?: number;
  /** Where the link opens. `rel` gains `noopener noreferrer` whenever it leaves the tab. */
  target?: string;
  rel?: string;
}

/** The parts a Sources draws behind its root. */
export type SourcesSlot = 'header' | 'list' | 'item';

export interface SourcesProps
  extends
    Pick<NebaStyleProps, 'size' | 'variant' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'onChange'> {
  /** The sources, in the order they are numbered. */
  items: readonly SourceItem[];
  /** The heading. Defaults to the `locale`'s word for it. */
  title?: React.ReactNode;
  /**
   * Folds the list behind the heading.
   *
   * On, because a list of sources is the longest thing in an answer and the
   * least often read: what a reader wants from it most of the time is to know
   * how many there were. Off, the heading is a plain line and the list is open.
   * @default true
   */
  collapsible?: boolean;
  /** Whether the list is showing. Pass it to drive the disclosure yourself. */
  open?: boolean;
  /** Where an uncontrolled Sources starts. @default false */
  defaultOpen?: boolean;
  /** Called when the heading opens or closes the list. */
  onOpenChange?: (open: boolean) => void;
  /**
   * Numbers the rows, so a citation in the body has something to point at.
   * @default true
   */
  numbered?: boolean;
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Which language the heading is written in, as a BCP 47 tag. */
  locale?: string;
  /** Those words, written out. Overrides the `locale`'s. */
  labels?: Partial<SourcesMessages>;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<SourcesSlot>;
}

/**
 * The same three weights said the way a container says them: the sheet is never
 * dyed. `text` is what a list under an answer wants, where the heading is a
 * line of its own and the rows are links.
 */
const variantClasses: Record<NebaVariant, string> = {
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

/** The square a favicon or a thumbnail lands in, clipped so an `<img>` fits it. */
const iconBoxClasses: Record<NebaSize, string> = {
  xs: 'size-3.5',
  sm: 'size-4',
  md: 'size-4.5',
  lg: 'size-5',
  xl: 'size-6'
};

/**
 * The list of things an answer was built out of.
 *
 * A [List](../display/list) would draw the rows. What it has no way to do is
 * the part that makes this a component: the rows are *numbered*, and the
 * numbers are what an [InlineCitation](./inline-citation) in the body points
 * at. Numbering a list by hand is numbering it twice — once here and once in
 * every sentence that cites it — and the second copy is the one that goes
 * wrong.
 */
export const Sources = React.forwardRef<HTMLDivElement, SourcesProps>(
  function Sources(rawProps, ref) {
    const {
      variant = 'text',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      items,
      title,
      collapsible = true,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      numbered = true,
      locale,
      labels,
      classNames,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const messages = useMessages(sourcesMessages, locale);
    const words = { ...messages, ...labels };

    const [openState, setOpenState] = React.useState(defaultOpen);
    const controlled = openProp !== undefined;
    const open = controlled ? openProp : openState;

    const padX = boxPaddingXClasses[density][size];
    const padY = boxPaddingYClasses[density][size];
    const heading = hasContent(title) ? title : words.title;

    const list = (
      <ol
        // Tailwind's reset takes the markers off every `<ol>`, and Safari takes
        // the list semantics off with them.
        role="list"
        className={cx(
          'm-0 flex list-none flex-col gap-2 p-0',
          padX,
          density === 'compact' ? 'pb-2' : 'pb-4',
          sheetBodyClasses[size],
          classNames?.list ?? ''
        )}
      >
        {items.map((item, at) => {
          const number = item.index ?? at + 1;
          const href = safeHref(item.href);
          const label = (
            <span className="min-w-0 font-medium">
              {item.title}
              {hasContent(item.site) ? (
                <span
                  className={cx('ms-2 font-normal text-(--neba-muted-fg)', metaTextClasses[size])}
                >
                  {item.site}
                </span>
              ) : null}
            </span>
          );

          return (
            <li
              key={`${number}-${href ?? at}`}
              className={cx('flex min-w-0 items-baseline gap-2', classNames?.item ?? '')}
            >
              {numbered ? (
                <span aria-hidden="true" className={citationMarkClasses}>
                  {number}
                </span>
              ) : null}

              {hasContent(item.icon) ? (
                <span
                  className={cx(
                    'inline-flex shrink-0 items-center justify-center self-center overflow-hidden',
                    'rounded-[0.25rem] [&_img]:size-full [&_img]:object-cover',
                    iconBoxClasses[size]
                  )}
                >
                  {item.icon}
                </span>
              ) : null}

              <span className="flex min-w-0 flex-col gap-0.5">
                {/* A real TextLink rather than an `<a>` of its own: the
                    underline's thickness, its offset and the rule that lets it
                    survive a host stylesheet are that component's, and a second
                    kind of link in one library is a library whose links do not
                    all behave the same. */}
                {href ? (
                  <TextLink
                    href={href}
                    underline="hover"
                    target={item.target}
                    rel={safeRel(item.target, item.rel)}
                    className="min-w-0"
                  >
                    {label}
                  </TextLink>
                ) : (
                  label
                )}

                {hasContent(item.description) ? (
                  <span className={cx('min-w-0 text-(--neba-muted-fg)', metaTextClasses[size])}>
                    {item.description}
                  </span>
                ) : null}
              </span>
            </li>
          );
        })}
      </ol>
    );

    const rootClasses = cx(
      'flex flex-col overflow-hidden',
      radiusClasses[size],
      variantClasses[variant],
      transitionClasses,
      iconClasses,
      className ?? ''
    );
    const rootStyle = { ...surfaceSlots(color, elevation), ...style };

    if (!collapsible) {
      return (
        <div ref={ref} className={rootClasses} style={rootStyle} {...props}>
          <div
            className={cx(
              'flex items-center font-semibold text-(--neba-fg)',
              padX,
              padY,
              gapClasses[size],
              sheetTitleClasses[size],
              classNames?.header ?? ''
            )}
          >
            {heading}
            <span className="text-(--neba-muted-fg) tabular-nums">{items.length}</span>
          </div>
          {list}
        </div>
      );
    }

    return (
      <BaseUICollapsible.Root
        ref={ref}
        open={open}
        onOpenChange={(next) => {
          if (!controlled) {
            setOpenState(next);
          }
          onOpenChange?.(next);
        }}
        className={rootClasses}
        style={rootStyle}
        {...props}
      >
        <BaseUICollapsible.Trigger
          className={cx(
            'flex w-full cursor-pointer items-center text-start font-semibold text-(--neba-fg)',
            padX,
            padY,
            gapClasses[size],
            sheetTitleClasses[size],
            transitionClasses,
            'hover:bg-(--n-soft)',
            'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
            classNames?.header ?? ''
          )}
        >
          <span className="min-w-0 truncate">{heading}</span>
          {/* The count is the whole point of the closed state: most readers
              want to know how many there were rather than which. */}
          <span className="shrink-0 font-normal text-(--neba-muted-fg) tabular-nums">
            {items.length}
          </span>

          <span
            className={[
              'ms-auto flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)',
              '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
              'data-[panel-open]:rotate-180'
            ].join(' ')}
          >
            <ChevronIcon />
          </span>
        </BaseUICollapsible.Trigger>

        <BaseUICollapsible.Panel className={collapsiblePanelClasses}>
          {list}
        </BaseUICollapsible.Panel>
      </BaseUICollapsible.Root>
    );
  }
);
