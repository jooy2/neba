'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses } from '../box/Box.js';
import { PageLayoutContext } from '../../internal/page-layout.js';
import {
  cx,
  hasContent,
  measureValue,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import { responsiveSlots } from '../../internal/responsive.js';
import type {
  NebaAlign,
  NebaColor,
  NebaDensity,
  NebaElevation,
  NebaMeasure,
  NebaPosition,
  NebaResponsive,
  NebaSize,
  NebaVariant
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface HeaderProps extends Omit<
  React.ComponentPropsWithoutRef<'header'>,
  'color' | 'title'
> {
  /**
   * The leading slot: the logo, the product's name, the thing that is the same
   * on every page. An [AppLogo] is what usually goes here.
   *
   * It is a slot rather than the first of `children` because the three regions
   * of a bar are laid out against each other — the middle can only be centred
   * in the bar if the two ends are measured — and a caller writing three
   * wrappers by hand is a caller whose header drifts from the next one.
   */
  brand?: React.ReactNode;
  /**
   * The trailing slot: the account menu, the theme switch, the call to action.
   * Laid out end-aligned, so a row of buttons needs no wrapper of its own.
   */
  actions?: React.ReactNode;
  /**
   * Where the middle slot sits.
   *
   * - `start` — packed against the brand, taking whatever is left. The
   *   arrangement of an application's toolbar, and the default.
   * - `center` — centred in the bar itself, not in the space left over. The two
   *   ends are given equal shares for this, so the middle stays on the bar's
   *   own midline however wide the brand is.
   * - `end` — packed against the actions.
   * @default 'start'
   */
  align?: NebaAlign;
  /**
   * How the bar sits in the page's scroll, spelled the way CSS spells it.
   * `sticky` — the default — holds it against the top of the window once the
   * page has scrolled to it, while leaving it in the flow so nothing has to be
   * padded out of its way. `fixed` takes it out of the flow entirely, which a
   * [PageLayout] answers by reserving its height. `static` lets it scroll away.
   * @default 'sticky'
   */
  position?: NebaPosition;
  /**
   * Weight of the sheet, said the way a *container* says it: the bar is never
   * dyed, because what is on it arrives with colours of its own.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /**
   * The bar's scale — its height floor, its gutter and the air around its
   * slots. As on Box, `size` here is the size of the *sheet*.
   * @default 'md'
   */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** @default 'default' */
  density?: NebaDensity;
  /**
   * Drop shadow depth. `0` (the default) is flat: a header is attached to the
   * top of the window rather than floating over the middle of it, and `divider`
   * is what separates it from the content.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Draws a hairline along the bottom edge, against the content the bar is
   * over. On by default, for BottomNavigation's reason: a bar pinned over a
   * scrolling page has content passing underneath it at every moment, and a
   * translucent sheet with nothing marking its edge reads as part of that.
   * @default true
   */
  divider?: boolean;
  /**
   * Holds the row of slots to a measure and centres it, while the sheet itself
   * still spans the window. The same ladder — and the same lengths, and the
   * same per-breakpoint map — Container's own `maxWidth` takes, so a header and
   * the Container under it line up on the same edge.
   * @default 'none'
   */
  maxWidth?: NebaResponsive<NebaMeasure>;
  /** The gutter down each side of the row. @default true */
  padded?: boolean;
  /**
   * The name the bar is announced by. Worth writing when a page has more than
   * one `<header>` in it — an article's own header and the site's — because
   * "banner" twice tells a reader which is which not at all.
   */
  label?: string;
  /**
   * Renders something other than a `<header>`. Base UI's own escape hatch, and
   * rarely what you want: the bar at the top of a page is a banner, and the tag
   * is what says so to a search engine and to a screen reader's landmark list.
   */
  render?: useRender.RenderProp;
  /** The middle slot. */
  children?: React.ReactNode;
}

/**
 * The bar's floor.
 *
 * Its own ladder rather than `controlHeightClasses`, because a header is not a
 * control: it *holds* controls, and a bar the height of the button in it is a
 * bar with no air. `md` is 56px — a 32px control with 12px above and below it,
 * which is the height a site header has had for as long as there have been
 * site headers, and the same floor BottomNavigation uses at the other end of
 * the page.
 */
const barMinHeightClasses: Record<NebaSize, string> = {
  xs: 'min-h-10',
  sm: 'min-h-12',
  md: 'min-h-14',
  lg: 'min-h-16',
  xl: 'min-h-20'
};

/** Inside one slot — between a logo and the name beside it, or between two buttons. */
const slotGapClasses: Record<NebaSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-3',
  lg: 'gap-4',
  xl: 'gap-5'
};

/**
 * Between the brand, the middle and the actions — about twice the gap *inside*
 * a slot, and a separate ladder for that reason.
 *
 * The three slots are three regions, and a region needs to read as one. With a
 * single gap doing both jobs, the first navigation link sits as far from the
 * logo as the logo sits from its own name, so the eye groups the wrong things
 * and the bar reads as one undifferentiated row.
 */
const barGapClasses: Record<NebaSize, string> = {
  xs: 'gap-3',
  sm: 'gap-4',
  md: 'gap-6',
  lg: 'gap-8',
  xl: 'gap-10'
};

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on Toolbar, Box and BottomNavigation. What carries the
 * colour family is whatever the caller put on the bar.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-press)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel)',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

const positionClasses: Record<NebaPosition, string> = {
  static: '',
  // `top-0` and nothing else: a header is what everything *else* starts below,
  // so it is the one thing in the layout with nothing above it to clear.
  sticky: 'sticky top-0 z-30',
  fixed: 'fixed inset-x-0 top-0 z-40'
};

/**
 * How the three slots divide the bar.
 *
 * `center` is the one that needs explaining. Centring the middle in the space
 * *left over* puts it wherever the brand happens to end, so a logo that grows
 * by one character moves the navigation — which is exactly what a reader
 * notices between two pages of the same site. Giving both ends `flex-1`
 * instead makes them equal by construction, and equal ends put the middle on
 * the bar's own midline whatever is in them.
 */
const endClasses: Record<NebaAlign, string> = {
  start: 'shrink-0',
  center: 'flex-1 basis-0',
  end: 'shrink-0'
};

const middleClasses: Record<NebaAlign, string> = {
  start: 'flex min-w-0 flex-1 items-center justify-start',
  center: 'flex min-w-0 shrink items-center justify-center',
  end: 'flex min-w-0 flex-1 items-center justify-end'
};

/**
 * The bar across the top of a page.
 *
 * A real `<header>`, which is the whole reason it is a component rather than a
 * row of divs: at the top level of a document that tag is the `banner`
 * landmark, and it is what a screen reader's landmark list, a reader mode and a
 * search engine's understanding of the page are all built out of.
 *
 * Its three slots are props rather than compound sub-components, for Card's and
 * Dialog's reason: the arrangement is fixed — brand, middle, actions — and what
 * a caller wants to decide is what goes in each. That the middle can be centred
 * on the bar's own midline is only possible because the ends are the
 * component's to measure.
 *
 * Inside a [PageLayout] it also registers itself, so a sidebar that holds its
 * place knows how far down the window to start. Outside one it is simply a bar,
 * and everything above still works.
 */
export const Header = React.forwardRef<HTMLElement, HeaderProps>(function Header(rawProps, ref) {
  const {
    brand,
    actions,
    align = 'start',
    position = 'sticky',
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    divider = true,
    maxWidth,
    padded = true,
    label,
    render,
    className,
    style,
    children,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

  const layout = React.useContext(PageLayoutContext);
  const { register } = layout;

  const setRef = React.useCallback(
    (node: HTMLElement | null) => {
      register('header', node);

      if (typeof ref === 'function') ref(node);
      else if (ref) ref.current = node;
    },
    [register, ref]
  );

  const classNames = cx(
    'w-full min-w-0',
    variantClasses[variant],
    divider ? 'border-b [border-color:var(--n-line)]' : '',
    positionClasses[position],
    transitionClasses,
    className
  );

  return useRender({
    render: render ?? <header />,
    ref: setRef,
    props: {
      'aria-label': label,
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      children: (
        <div
          className={cx(
            'flex w-full items-center',
            barMinHeightClasses[size],
            barGapClasses[size],
            padded ? boxPaddingXClasses[density][size] : '',
            // `mx-auto` unconditionally: with no measure there is nothing left
            // over to centre in, so it costs nothing to say it once.
            'neba-measure mx-auto max-w-(--n-max-w)'
          )}
          style={responsiveSlots('max-w', maxWidth, measureValue)}
        >
          {hasContent(brand) ? (
            <div
              className={cx('flex min-w-0 items-center', endClasses[align], slotGapClasses[size])}
            >
              {brand}
            </div>
          ) : align === 'center' ? (
            // An empty leading end still takes its half, or the middle would be
            // centred on the space left over rather than on the bar.
            <div aria-hidden="true" className={endClasses[align]} />
          ) : null}

          {hasContent(children) ? (
            <div className={cx(middleClasses[align], slotGapClasses[size])}>{children}</div>
          ) : null}

          {hasContent(actions) ? (
            <div
              className={cx(
                'flex min-w-0 items-center justify-end',
                endClasses[align],
                slotGapClasses[size]
              )}
            >
              {actions}
            </div>
          ) : align === 'center' ? (
            <div aria-hidden="true" className={endClasses[align]} />
          ) : null}
        </div>
      ),
      ...props
    }
  });
});
