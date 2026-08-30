'use client';

import * as React from 'react';
import { anchorMessages, useMessages } from '../../internal/i18n.js';
import {
  controlTextLeadingClasses,
  focusRingClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaDensity, NebaSize } from '../../types.js';

/** One heading in the list. */
export interface AnchorItem {
  /**
   * The fragment it points at — `#getting-started`. The `id` it names is what
   * the list watches, so a heading with no `id` cannot be tracked.
   */
  href: string;
  /** What the row says. */
  label: React.ReactNode;
  /**
   * How deep the heading sits, from `0`. Only the indent depends on it; the
   * list is flat, because a nested `<ul>` inside a table of contents is read as
   * a list inside a list and says nothing a reader needed.
   * @default 0
   */
  depth?: number;
}

export interface AnchorProps extends Omit<
  React.ComponentPropsWithoutRef<'nav'>,
  'color' | 'children' | 'onChange'
> {
  /** The headings, in the order they appear on the page. */
  items: readonly AnchorItem[];
  /**
   * Which row is marked, by its `href`. Given, the list stops tracking the
   * scroll and says what it is told.
   */
  activeHref?: string | null;
  /** Called whenever the row the reader is in changes. */
  onActiveChange?: (href: string | null) => void;
  /**
   * How far below the top of the scrollport a heading counts as reached, in
   * pixels. Set it to the height of a sticky header, or the heading under the
   * bar is never the one marked.
   * @default 0
   */
  offset?: number;
  /**
   * What scrolls, when it is not the document — the element a
   * [PageLayout](../layout/page-layout) with `scroll="content"` puts the page
   * inside, for instance.
   */
  container?: React.RefObject<HTMLElement | null>;
  /** Draws the rail down the leading edge, with the active row lit. @default true */
  rail?: boolean;
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** Tightens the rows and nothing else. @default 'default' */
  density?: NebaDensity;
  /**
   * Which language the `<nav>` is named in — a BCP 47 tag such as `ko`, `pt-BR`
   * or `zh-Hant`. Unsupported tags fall back to English.
   */
  locale?: string;
  /** The accessible name of the `<nav>`. Defaults to the `locale`'s word for it. */
  label?: string;
}

const rowPaddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'py-1', sm: 'py-1', md: 'py-1.5', lg: 'py-1.5', xl: 'py-2' },
  compact: { xs: 'py-0.5', sm: 'py-0.5', md: 'py-1', lg: 'py-1', xl: 'py-1' }
};

/** How far one level of heading is set in from the last. */
const indentSizes: Record<NebaSize, number> = {
  xs: 8,
  sm: 10,
  md: 12,
  lg: 14,
  xl: 16
};

const linkClasses = [
  'block min-w-0 truncate no-underline',
  'text-(--neba-muted-fg)',
  transitionClasses,
  focusRingClasses,
  'hover:text-(--neba-fg)',
  'aria-[current=location]:font-medium aria-[current=location]:text-(--n-accent)'
].join(' ');

/**
 * The rail's lit segment.
 *
 * A border on the row rather than a travelling marker, for the reason nothing in
 * the library slides: a segment that animated from one heading to the next would
 * be a thing moving under a reader who is already moving.
 */
const railClasses = [
  'border-s [border-color:transparent]',
  '[transition:border-color_var(--neba-duration)_var(--neba-ease)]',
  'aria-[current=location]:[border-color:var(--n-accent)]'
].join(' ');

/**
 * Which heading the reader is in.
 *
 * The last one whose top has passed the line, which is the only rule that reads
 * correctly while scrolling *up* as well as down. The bottom of the scroll is a
 * special case and has to be: the last heading on a page often has less content
 * under it than a viewport, so its top never reaches the line and it would
 * otherwise be the one section that can never be marked.
 */
function activeAt(
  items: readonly AnchorItem[],
  offset: number,
  container: HTMLElement | null
): string | null {
  const top = container ? container.getBoundingClientRect().top : 0;
  const line = top + offset + 1;

  let current: string | null = null;

  for (const item of items) {
    const target = document.getElementById(item.href.replace(/^#/, ''));

    if (!target) continue;
    if (target.getBoundingClientRect().top <= line) current = item.href;
  }

  const atEnd = container
    ? container.scrollTop + container.clientHeight >= container.scrollHeight - 2
    : window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2;

  if (atEnd && items.length > 0) return items[items.length - 1].href;

  return current;
}

/**
 * The list of headings on the page being read, with the one the reader is in
 * marked.
 *
 * It is a real `<nav>` of real `<a href="#…">`s, which is what makes it work
 * before any of this runs: the links jump to their headings with JavaScript
 * turned off, and they are in the link list a screen reader can pull up. The
 * tracking is the part that is added on top, not the part that is load-bearing.
 *
 * The headings are given as `items` rather than scraped out of the document.
 * Anything that produces this list — an MDX pipeline, a CMS, a route's own
 * frontmatter — already knows the ids, and a component that went looking for
 * them would be guessing at which `<h2>`s were content and which were chrome.
 */
export const Anchor = React.forwardRef<HTMLElement, AnchorProps>(function Anchor(
  {
    items,
    activeHref,
    onActiveChange,
    offset = 0,
    container,
    rail = true,
    size = 'md',
    color = 'primary',
    density = 'default',
    locale,
    label,
    className,
    style,
    ...props
  },
  ref
) {
  const messages = useMessages(anchorMessages, locale);
  const [tracked, setTracked] = React.useState<string | null>(null);

  const controlled = activeHref !== undefined;
  const active = controlled ? activeHref : tracked;

  const onActiveChangeRef = React.useRef(onActiveChange);
  onActiveChangeRef.current = onActiveChange;

  // `items` is almost always an array literal, so it is a new value on every
  // render and depending on it directly would tear the listeners down and put
  // them back sixty times a second. What the effect actually reads is the list
  // of ids, which is a string.
  const itemsRef = React.useRef(items);
  itemsRef.current = items;
  const keys = items.map((item) => item.href).join('\u0000');

  React.useEffect(() => {
    if (controlled) return undefined;

    const scroller: HTMLElement | Window = container?.current ?? window;
    let frame = 0;
    let last: string | null = null;

    const read = () => {
      frame = 0;
      const next = activeAt(itemsRef.current, offset, container?.current ?? null);

      if (next === last) return;
      last = next;
      setTracked(next);
      onActiveChangeRef.current?.(next);
    };

    // Coalesced to one read per frame: this fires at scroll rate, and every one
    // of them measures.
    const schedule = () => {
      if (frame === 0) frame = requestAnimationFrame(read);
    };

    read();
    scroller.addEventListener('scroll', schedule, { passive: true });
    window.addEventListener('resize', schedule, { passive: true });

    return () => {
      if (frame !== 0) cancelAnimationFrame(frame);
      scroller.removeEventListener('scroll', schedule);
      window.removeEventListener('resize', schedule);
    };
  }, [keys, offset, container, controlled]);

  return (
    <nav
      ref={ref}
      aria-label={label ?? messages.label}
      className={['min-w-0', className ?? ''].filter(Boolean).join(' ')}
      style={
        {
          '--n-accent': `var(--neba-${color}-accent)`,
          '--n-ring': `var(--neba-${color}-ring)`,
          ...style
        } as React.CSSProperties
      }
      {...props}
    >
      <ul
        className={[
          'm-0 flex list-none flex-col p-0',
          rail ? 'border-s [border-color:var(--neba-border)]' : ''
        ]
          .filter(Boolean)
          .join(' ')}
      >
        {items.map((item) => (
          <li key={item.href} className={rail ? '[margin-inline-start:-1px]' : ''}>
            <a
              href={item.href}
              // `location` rather than `true`: this is where the reader is
              // within a set of links, which is the one thing that value means
              // and exactly what a table of contents is reporting.
              aria-current={active === item.href ? 'location' : undefined}
              className={[
                linkClasses,
                controlTextLeadingClasses[size],
                rowPaddingClasses[density][size],
                rail ? `${railClasses} ps-3` : ''
              ]
                .filter(Boolean)
                .join(' ')}
              style={{
                marginInlineStart: item.depth ? item.depth * indentSizes[size] : undefined
              }}
            >
              {item.label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
});
