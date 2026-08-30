'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { barMinHeightClasses, BottomNavigationContext } from '../../internal/bottom-navigation.js';
import type {
  BottomNavigationLabels,
  BottomNavigationValue
} from '../../internal/bottom-navigation.js';
import { observeResize } from '../../internal/observe.js';
import { cx, surfaceClasses, surfaceSlots, transitionClasses } from '../../internal/styles.js';
import type {
  NebaDensity,
  NebaElevation,
  NebaPosition,
  NebaSize,
  NebaStyleProps,
  NebaVariant
} from '../../types.js';

/**
 * Where a floating bar sits, with one value the shared vocabulary does not have.
 *
 * `absolute` is not a second spelling of anything in `NebaPosition` — it is the
 * fourth CSS value, and it is the one that makes the bar belong to a *region*
 * rather than to the window: a bar inside a Mockup's screen, inside a card,
 * inside a preview. The same addition FloatingActionButton makes, for the same
 * reason.
 */
export type FloatingBottomNavigationPosition = NebaPosition | 'absolute';

export interface FloatingBottomNavigationProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'defaultValue' | 'onChange'> {
  /** The destination the reader is on. Use with `onValueChange` for a controlled bar. */
  value?: BottomNavigationValue | null;
  /** Which starts current, for an uncontrolled bar. */
  defaultValue?: BottomNavigationValue | null;
  onValueChange?: (value: BottomNavigationValue) => void;
  /**
   * How the bar sits in the page's scroll. `fixed` — the default — holds it
   * against the bottom of the window; `sticky` holds it against the bottom of
   * whatever is scrolling; `absolute` holds it against the bottom of the
   * nearest positioned ancestor, which is what a bar inside a screen of its own
   * wants; `static` puts it back in the flow, centred.
   * @default 'fixed'
   */
  position?: FloatingBottomNavigationPosition;
  /**
   * How far the bar floats above the bottom edge — a number in pixels or any
   * CSS length. This is the whole difference between this component and
   * [BottomNavigation]: the gap under it is what makes the page keep going
   * underneath rather than stop at a bar.
   * @default 16
   */
  offset?: number | string;
  /**
   * Which names are drawn. `selected` here, against the `all` a full-width bar
   * defaults to: this bar is only as wide as what is in it, so five drawn names
   * would stretch it across the screen and it would stop being a lozenge.
   * @default 'selected'
   */
  labels?: BottomNavigationLabels;
  /**
   * Adds `env(safe-area-inset-bottom)` to `offset`, so the bar clears a phone's
   * home indicator rather than sitting on it. Unlike on BottomNavigation this
   * moves the whole sheet: there is nothing under it to keep covered.
   * @default true
   */
  safeArea?: boolean;
  /**
   * Drop shadow depth. `2` here, against the `0` everything else defaults to
   * and against BottomNavigation's own `0`, for the reason Pill's is `2`: this
   * bar is defined by not being part of the page. A lozenge floating flat over
   * the content it is floating over reads as a mistake.
   * @default 2
   */
  elevation?: NebaElevation;
  /** Every destination stops answering. */
  disabled?: boolean;
  /** The name the bar is announced by — "Main", "Sections". */
  label?: string;
  /**
   * Renders something other than a `<nav>`. Base UI's own escape hatch, and
   * rarely what you want here: a row of destinations is navigation.
   */
  render?: useRender.RenderProp;
  /** The BottomNavigationItems. The same item both bars take. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on BottomNavigation and Toolbar. What carries the colour
 * family is the one destination that is current.
 *
 * `outline` is the default here rather than the sheet with no edge, because
 * this one is over the page rather than against its edge: the hairline is what
 * separates a floating lozenge from whatever is passing underneath it.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-press)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel-hover)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * Where a floating bar hangs.
 *
 * Centred by stretching the box across its container and letting `mx-auto`
 * shrink it back, never by translating it half its own width — the same
 * arrangement Pill uses, and for the same reason: the house rule against
 * transforming a surface holds here too, and `auto` margins stay centred under
 * RTL.
 */
const positionClasses: Record<FloatingBottomNavigationPosition, string> = {
  // `relative` belongs to this table rather than to the class list, and that is
  // not tidiness: the bar has to be positioned for the highlight to be measured
  // against it, and a `relative` written unconditionally beside an `absolute`
  // from here is two utilities of equal specificity setting the same property —
  // which of them wins is decided by their order in the generated stylesheet,
  // and the one that won took a `position="absolute"` bar out of its corner.
  // The other three are already positioned and need nothing.
  static: 'relative mx-auto w-fit',
  absolute: 'absolute inset-x-0 bottom-(--n-nav-offset) z-30 mx-auto w-fit',
  sticky: 'sticky bottom-(--n-nav-offset) z-30 mx-auto w-fit',
  fixed: 'fixed inset-x-0 bottom-(--n-nav-offset) z-40 mx-auto w-fit'
};

/**
 * The air inside the sheet, around the row.
 *
 * Tighter than the full-width bar's, and that is what the shape needs rather
 * than a different opinion about spacing: an item in this bar carries a rounded
 * fill of its own when it is current, and the gap between that fill and the
 * lozenge's own edge is this padding. Too much of it and there are two
 * concentric stadiums with a stripe of nothing between them.
 */
const rowPaddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'p-1', sm: 'p-1', md: 'p-1.5', lg: 'p-1.5', xl: 'p-2' },
  compact: { xs: 'p-0.5', sm: 'p-0.5', md: 'p-1', lg: 'p-1', xl: 'p-1' }
};

/**
 * The tile that slides.
 *
 * The highlight belongs to the *bar* rather than to the item that is current,
 * which is the whole of why it can travel: an item painting its own background
 * can only switch it on and off, while one object moving between four boxes is
 * a thing with a position to animate. It is the same arrangement SegmentedButton
 * makes, for the same reason.
 *
 * Nothing is transformed — `left`, `top`, `width` and `height` are what move,
 * so the label riding over the tile is never resampled.
 */
const tileClasses: Record<NebaVariant, string> = {
  solid: `${surfaceClasses} bg-(--n-panel-hover) [box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]`,
  outline: `${surfaceClasses} bg-(--n-soft-hover) [box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]`,
  text: 'bg-(--n-soft-hover)'
};

/** Between one destination and the next. */
const rowGapClasses: Record<NebaSize, string> = {
  xs: 'gap-0.5',
  sm: 'gap-0.5',
  md: 'gap-1',
  lg: 'gap-1',
  xl: 'gap-1.5'
};

/**
 * A row of destinations floating clear of the bottom edge of the window.
 *
 * It is [BottomNavigation] lifted off the page: the same `<nav>`, the same
 * `aria-current`, the same BottomNavigationItem children, and deliberately not
 * a `role="tablist"` for the same reason — a bottom navigation changes what the
 * page is, not which panel of one is showing.
 *
 * What differs is the shape, and everything about the shape follows from
 * `offset`. Because the page keeps going underneath, the sheet is a stadium
 * rather than a bar with two corners, it is only as wide as its destinations,
 * it carries a shadow, and it names only the destination the reader is on —
 * five drawn names would stretch it back into a bar.
 *
 * The stadium is the exception the house radius rule is drawn against, exactly
 * as Pill is: a control is held short of the 50% that would make it a pill
 * because the flat run along its edge is what reads as a sheet with the corners
 * cut off. Nothing here is lying on the page.
 */
export const FloatingBottomNavigation = React.forwardRef<
  HTMLElement,
  FloatingBottomNavigationProps
>(function FloatingBottomNavigation(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 2,
    value: valueProp,
    defaultValue = null,
    onValueChange,
    position = 'fixed',
    offset = 16,
    labels = 'selected',
    safeArea = true,
    disabled = false,
    label,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const [uncontrolled, setUncontrolled] = React.useState<BottomNavigationValue | null>(
    defaultValue
  );
  const controlled = valueProp !== undefined;
  const value = controlled ? valueProp : uncontrolled;

  const change = React.useCallback(
    (next: BottomNavigationValue) => {
      if (!controlled) {
        setUncontrolled(next);
      }

      onValueChange?.(next);
    },
    [controlled, onValueChange]
  );

  const context = React.useMemo(
    () => ({ value: value ?? null, change, size, density, labels, disabled, floating: true }),
    [value, change, size, density, labels, disabled]
  );

  const rootRef = React.useRef<HTMLElement | null>(null);
  const tileRef = React.useRef<HTMLSpanElement>(null);

  const setRootRef = React.useCallback(
    (node: HTMLElement | null) => {
      rootRef.current = node;

      if (typeof ref === 'function') ref(node);
      else if (ref) ref.current = node;
    },
    [ref]
  );

  /**
   * Writes the current destination's box onto the tile as four custom
   * properties.
   *
   * Written straight to the element rather than held in state: a `setState`
   * here would re-render every destination on every resize, and nothing in the
   * tree depends on the numbers except four CSS declarations.
   *
   * `animate` is what separates the two callers. A change of destination is the
   * thing this exists to animate; a resize is the bar moving under a tile that
   * was already in the right place, and animating that is a tile that lags
   * behind the window being dragged.
   */
  const measure = React.useCallback((animate: boolean) => {
    const root = rootRef.current;
    const tile = tileRef.current;
    if (!root || !tile) {
      return;
    }

    // Found by what it *is* rather than by a ref per item: the items are the
    // caller's children, composed however they liked, and `aria-current` is the
    // one mark that is on the current one wherever it ended up.
    const current = root.querySelector<HTMLElement>('[data-nav-item][aria-current]');
    if (!current) {
      return;
    }

    // A tile that has only just mounted has nowhere to travel *from*, so its
    // first placement is instant however it was asked for.
    const instant = !animate || !tile.hasAttribute('data-ready');
    if (instant) {
      tile.removeAttribute('data-ready');
    }

    tile.style.setProperty('--n-nav-x', `${current.offsetLeft}px`);
    tile.style.setProperty('--n-nav-y', `${current.offsetTop}px`);
    tile.style.setProperty('--n-nav-w', `${current.offsetWidth}px`);
    tile.style.setProperty('--n-nav-h', `${current.offsetHeight}px`);

    if (instant) {
      // Reading a layout property commits the four writes above while the
      // duration is still 0ms, so turning the transition back on cannot animate
      // a move that has already happened.
      void tile.offsetWidth;
    }

    tile.setAttribute('data-ready', '');
  }, []);

  // Before the browser paints, or the tile is visibly at nothing for a frame.
  React.useLayoutEffect(() => {
    measure(true);
  }, [measure, value, variant, size, density, labels, children]);

  React.useEffect(() => {
    const root = rootRef.current;
    if (!root) {
      return;
    }

    return observeResize(root, () => measure(false));
  }, [measure]);

  const gap = typeof offset === 'number' ? `${offset}px` : offset;

  const classNames = cx(
    // `max-w-full` rather than a width: the lozenge is as wide as its
    // destinations until that is wider than the screen, and then it is the
    // screen. The names truncate before the sheet does.
    'flex max-w-full min-w-0 items-center rounded-full',
    barMinHeightClasses[size],
    rowPaddingClasses[density][size],
    rowGapClasses[size],
    variantClasses[variant],
    positionClasses[position],
    transitionClasses,
    className
  );

  return useRender({
    render: render ?? <nav />,
    ref: setRootRef,
    props: {
      'aria-label': label,
      className: classNames,
      style: {
        ...surfaceSlots(color, elevation),
        // The whole sheet moves up rather than only the row inside it, which is
        // the other half of what `offset` means here: there is no acrylic below
        // the bar that would be left showing as a stripe.
        '--n-nav-offset': safeArea ? `calc(${gap} + env(safe-area-inset-bottom))` : gap,
        ...style
      } as React.CSSProperties,
      children: (
        <BottomNavigationContext.Provider value={context}>
          {/* Rendered only once something is current. A bar with no destination
              taken has no tile to slide, and mounting it on the first choice is
              what makes that first choice appear in place rather than fly in
              from the leading edge. */}
          {value !== null && value !== undefined ? (
            <span
              ref={tileRef}
              aria-hidden="true"
              className={cx(
                'pointer-events-none absolute rounded-full',
                'top-(--n-nav-y) left-(--n-nav-x) h-(--n-nav-h) w-(--n-nav-w)',
                tileClasses[variant],
                '[transition-property:left,top,width,height]',
                '[transition-timing-function:var(--neba-ease)]',
                // Nothing until the first measurement has landed; the house
                // duration from then on.
                '[transition-duration:0ms] data-[ready]:[transition-duration:var(--neba-duration)]',
                'motion-reduce:[transition-duration:0ms]'
              )}
            />
          ) : null}

          {children}
        </BottomNavigationContext.Provider>
      ),
      ...props
    }
  });
});
