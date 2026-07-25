import * as React from 'react';
import { Button } from '../button/Button';
import { ChevronIcon } from '../../internal/icons';
import { controlTextClasses, gapClasses, srOnlyClasses } from '../../internal/styles';
import type { NebaElevation, NebaSize, NebaStyleProps } from '../../types';

export interface PaginationProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'onChange'> {
  /** How many pages there are. Fewer than two and the whole control renders nothing. */
  count: number;
  /** The current page, 1-based. Use with `onPageChange` for a controlled set. */
  page?: number;
  /** Which page starts current, for an uncontrolled one. @default 1 */
  defaultPage?: number;
  onPageChange?: (page: number) => void;
  /**
   * How many pages are always shown on either side of the current one.
   * @default 1
   */
  siblingCount?: number;
  /**
   * How many pages are always shown at each end, whatever the current page is.
   * `0` drops the first and last page from the row, leaving only the window.
   * @default 1
   */
  boundaryCount?: number;
  /** Shows the jump-to-first and jump-to-last steppers. @default false */
  showEdges?: boolean;
  /** Shows the previous and next steppers. @default true */
  showArrows?: boolean;
  /**
   * Drop shadow depth of the page buttons. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Unavailable. Every button in the row stops answering. */
  disabled?: boolean;
  /** Accessible name of the `<nav>`. @default 'Pagination' */
  label?: string;
  /** Accessible name of a page button. @default `Page ${page}` */
  pageLabel?: (page: number) => string;
  /** @default 'Previous page' */
  previousLabel?: string;
  /** @default 'Next page' */
  nextLabel?: string;
  /** @default 'First page' */
  firstLabel?: string;
  /** @default 'Last page' */
  lastLabel?: string;
}

/** `'…'` in two flavours, so a caller reading the range can tell them apart. */
type PaginationSlot = number | 'start-ellipsis' | 'end-ellipsis';

function range(start: number, end: number): number[] {
  return Array.from({ length: Math.max(0, end - start + 1) }, (_, index) => start + index);
}

/**
 * Which pages the row actually shows.
 *
 * The shape every pagination converges on — a fixed run at each end, a window
 * around the current page, and an ellipsis wherever those leave a gap — with one
 * detail that is easy to get wrong and matters: a gap of exactly one page is
 * filled with that page rather than with an ellipsis. `1 … 3 … 9` hides a single
 * number behind a symbol that is wider than the number it replaced.
 *
 * The row is also pinned to a constant number of slots, whatever page it is on:
 * the window slides toward whichever end it is near instead of being clipped by
 * it, so page 1 shows `1 2 3 4 5 … 20` and page 10 shows `1 … 9 10 11 … 20`.
 * Which slots are pages and which are ellipses changes; how many there are does
 * not. Without that, stepping from page 1 to page 2 would relayout the row and
 * every button would move out from under the pointer that just pressed one.
 */
function paginationRange(
  count: number,
  page: number,
  siblingCount: number,
  boundaryCount: number
): PaginationSlot[] {
  const startPages = range(1, Math.min(boundaryCount, count));
  const endPages = range(Math.max(count - boundaryCount + 1, boundaryCount + 1), count);

  const siblingsStart = Math.max(
    Math.min(page - siblingCount, count - boundaryCount - siblingCount * 2 - 1),
    boundaryCount + 2
  );
  const siblingsEnd = Math.min(
    Math.max(page + siblingCount, boundaryCount + siblingCount * 2 + 2),
    endPages.length > 0 ? endPages[0] - 2 : count - 1
  );

  return [
    ...startPages,

    // An ellipsis when more than one page is hidden, the page itself when
    // exactly one is, and nothing when none is.
    ...(siblingsStart > boundaryCount + 2
      ? (['start-ellipsis'] as PaginationSlot[])
      : boundaryCount + 1 < count - boundaryCount
        ? [boundaryCount + 1]
        : []),

    ...range(siblingsStart, siblingsEnd),

    ...(siblingsEnd < count - boundaryCount - 1
      ? (['end-ellipsis'] as PaginationSlot[])
      : count - boundaryCount > boundaryCount
        ? [count - boundaryCount]
        : []),

    ...endPages
  ];
}

/** Two chevrons, for the steppers that jump to an end rather than by one page. */
function DoubleChevronIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m7.5 4.5 3.5 3.5-3.5 3.5M3.5 4.5 7 8l-3.5 3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The ellipsis. A `<span>`, not a button and not a disabled button: it is not a
 * control that happens to be unavailable, it is punctuation.
 */
const ellipsisClasses: Record<NebaSize, string> = {
  xs: 'h-5.5 min-w-5.5',
  sm: 'h-6.5 min-w-6.5',
  md: 'h-8 min-w-8',
  lg: 'h-10 min-w-10',
  xl: 'h-12 min-w-12'
};

/**
 * A row of page numbers.
 *
 * Every button in it is a real `Button`, which is the point: a pagination is not
 * a new kind of control, it is buttons in a row that happen to know about each
 * other. Reusing the component means the row inherits the acrylic surface, the
 * press-instant/release-slow signature, the focus ring and every future change
 * to any of them for free — and it means a `lg` pagination lines up with a `lg`
 * button beside it, because it *is* one.
 *
 * `variant` sets how the pages at rest look; the current page is always `solid`,
 * which is the one thing the row has to say without being read. That is why the
 * default here is `text` rather than the `solid` a lone Button takes — nine
 * filled buttons in a row say that all nine are the primary action.
 *
 * The markup is a `<nav>` around a `<ul>` because that is what a screen reader
 * needs to hear: a named landmark it can skip, holding a list whose length says
 * how far the pages go, with `aria-current="page"` marking where it is.
 */
export const Pagination = React.forwardRef<HTMLElement, PaginationProps>(function Pagination(
  {
    variant = 'text',
    size = 'md',
    color = 'primary',
    density = 'compact',
    elevation = 0,
    count,
    page: pageProp,
    defaultPage = 1,
    onPageChange,
    siblingCount = 1,
    boundaryCount = 1,
    showEdges = false,
    showArrows = true,
    disabled = false,
    label = 'Pagination',
    pageLabel = (value) => `Page ${value}`,
    previousLabel = 'Previous page',
    nextLabel = 'Next page',
    firstLabel = 'First page',
    lastLabel = 'Last page',
    className,
    children,
    ...props
  },
  ref
) {
  const [uncontrolled, setUncontrolled] = React.useState(defaultPage);
  const current = Math.min(Math.max(pageProp ?? uncontrolled, 1), Math.max(count, 1));

  const go = (next: number) => {
    const clamped = Math.min(Math.max(next, 1), count);
    if (clamped === current) {
      return;
    }
    if (pageProp === undefined) {
      setUncontrolled(clamped);
    }
    onPageChange?.(clamped);
  };

  // One page is not a set of pages, and no pages is not a thing to say out loud.
  // A row that renders a lone disabled "1" is a control advertising that it has
  // nothing to do.
  if (count < 2) {
    return null;
  }

  const slots = paginationRange(count, current, siblingCount, boundaryCount);
  const atStart = current <= 1;
  const atEnd = current >= count;

  /**
   * The steppers. Icon-only Buttons, so they go square and land on exactly the
   * same footprint as a single-digit page — a row whose ends are a different
   * width from its middle reads as two controls pushed together.
   *
   * The chevron is drawn pointing down and turned, which is the one allowance
   * the no-transform rule makes: a glyph has no text in it to resample.
   */
  const stepper = (
    key: string,
    accessibleName: string,
    to: number,
    inert: boolean,
    rotation: string,
    glyph: React.ReactNode
  ) => (
    <li key={key} className="flex">
      <Button
        variant={variant}
        size={size}
        color={color}
        density={density}
        elevation={elevation}
        disabled={disabled || inert}
        aria-label={accessibleName}
        startIcon={<span className={`flex items-center ${rotation}`}>{glyph}</span>}
        onClick={() => go(to)}
      />
    </li>
  );

  return (
    <nav
      ref={ref}
      aria-label={label}
      className={['flex items-center', className ?? ''].filter(Boolean).join(' ')}
      {...props}
    >
      <ul role="list" className={`m-0 flex list-none items-center p-0 ${gapClasses[size]}`}>
        {showEdges
          ? stepper(
              'first',
              firstLabel,
              1,
              atStart,
              'rotate-180 rtl:rotate-0',
              <DoubleChevronIcon />
            )
          : null}

        {showArrows
          ? stepper(
              'previous',
              previousLabel,
              current - 1,
              atStart,
              'rotate-90 rtl:-rotate-90',
              <ChevronIcon />
            )
          : null}

        {slots.map((slot, index) =>
          typeof slot === 'number' ? (
            <li key={slot} className="flex">
              <Button
                // The current page is always filled, whatever the row's resting
                // variant is: it is the one thing here that has to be legible
                // without being read.
                variant={slot === current ? 'solid' : variant}
                size={size}
                color={color}
                density={density}
                elevation={elevation}
                disabled={disabled}
                aria-label={pageLabel(slot)}
                aria-current={slot === current ? 'page' : undefined}
                className="tabular-nums"
                onClick={() => go(slot)}
              >
                {slot}
              </Button>
            </li>
          ) : (
            <li
              key={`${slot}-${index}`}
              aria-hidden="true"
              className={[
                'flex select-none items-center justify-center',
                'text-(--neba-muted-fg)',
                controlTextClasses[size],
                ellipsisClasses[size]
              ].join(' ')}
            >
              …
            </li>
          )
        )}

        {showArrows
          ? stepper(
              'next',
              nextLabel,
              current + 1,
              atEnd,
              '-rotate-90 rtl:rotate-90',
              <ChevronIcon />
            )
          : null}

        {showEdges
          ? stepper('last', lastLabel, count, atEnd, 'rtl:rotate-180', <DoubleChevronIcon />)
          : null}
      </ul>

      {/* Where the reader is, as a sentence rather than as a highlighted button.
          `aria-current` says which page is chosen; this says how many there are,
          which the list length alone does not once an ellipsis is in it. */}
      <span className={srOnlyClasses} aria-live="polite">
        {`${pageLabel(current)} of ${count}`}
      </span>

      {children}
    </nav>
  );
});
