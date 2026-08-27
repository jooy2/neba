import * as React from 'react';
import type { NebaBreakpoint, NebaSide } from '../types.js';

/**
 * The vocabulary a page's structure is written in, and the context the four
 * components that build one share.
 *
 * It lives in `internal/` for the reason `menu.ts` does rather than the reason
 * `button-group.ts` does: four components read it — PageLayout, Header, Footer
 * and Sidebar, plus SidebarTrigger, which is a fifth — and every one of them is
 * also usable on its own. Keeping the context in PageLayout's file would make a
 * Header import a layout it may never be inside.
 *
 * Nothing here draws anything. The layout is flexbox and media queries, both of
 * which CSS states better than JavaScript can; what needs a context is the
 * handful of facts a slot cannot work out from where it sits — how wide the
 * window has to be before a sidebar stops being a column, whether a drawer is
 * open, and which language the layout's own two or three words are in.
 */

/** Which end of the band a sidebar takes. Logical, so it flips under RTL. */
export type SidebarSide = 'start' | 'end';

/** The two slots a layout measures, because a sidebar has to start below them. */
export type PageLayoutSlot = 'header' | 'footer';

/**
 * How far across a header or a footer reaches.
 *
 * - `full` — the whole width, with the sidebars beginning underneath it. The
 *   arrangement of a website: one bar across the top, and the page below it.
 * - `content` — only the column between the sidebars, which run the full height
 *   of the window beside it. The arrangement of an application: the navigation
 *   is the outermost thing on the screen and the bar belongs to the view.
 *
 * There is no third value, because there is no third arrangement: what is being
 * decided is which of the two takes the corner.
 */
export type PageLayoutSpan = 'full' | 'content';

/**
 * What scrolls.
 *
 * - `page` — the document does, the way a website does. The header and the
 *   sidebars hold their place with `position: sticky`, the browser's own
 *   address bar hides on a phone, and the scroll position is restored on a
 *   back navigation. This is the default, and it is what almost every page
 *   wants.
 * - `content` — the layout takes exactly the height of the window and only the
 *   region between the header and the footer scrolls, the way an application
 *   does. Reach for it when the page is a workspace rather than a document.
 */
export type PageLayoutScroll = 'page' | 'content';

/**
 * The width below which a sidebar stops being part of the layout and becomes a
 * drawer that is opened, or `none` to keep it in the layout at every width.
 *
 * `xs` is the breakpoint whose floor is `0`, so nothing is ever below it — it
 * means the same as `none` and is accepted only because `NebaBreakpoint` has
 * five values everywhere else in the library.
 */
export type PageLayoutCollapse = NebaBreakpoint | 'none';

export interface PageLayoutContextValue {
  /**
   * Whether there is a PageLayout above at all.
   *
   * A Header, a Footer and a Sidebar all render perfectly well without one —
   * they are a bar, a bar and a panel. What they cannot do on their own is
   * agree with each other about where they sit, which is the whole of what a
   * layout adds and the reason a component has to be able to tell.
   */
  present: boolean;
  /**
   * Hands the layout the element filling one of its slots.
   *
   * The layout measures it and writes its height onto its own root as a custom
   * property, because a sidebar that holds its place has to start below a
   * header whose height only the header knows. A callback rather than a
   * `querySelector`, so a header rendered through `render={<MyBar />}` is found
   * as reliably as one that is not.
   */
  register: (slot: PageLayoutSlot, node: HTMLElement | null) => void;
  /** Where the sidebars stop being columns. */
  collapseBelow: PageLayoutCollapse;
  /** Whether each sidebar's drawer is open. Only meaningful while it is collapsed. */
  open: Record<SidebarSide, boolean>;
  setOpen: (side: SidebarSide, open: boolean) => void;
  /** How the page scrolls, which decides how a sidebar holds its place. */
  scroll: PageLayoutScroll;
  /** The language the layout's own words are in. */
  locale?: string;
}

export const PageLayoutContext = React.createContext<PageLayoutContextValue>({
  present: false,
  register: () => {},
  collapseBelow: 'none',
  open: { start: false, end: false },
  setOpen: () => {},
  scroll: 'page'
});

/**
 * Which end of the band the sidebar being rendered right now takes.
 *
 * A second, one-value context rather than a field on the one above, because it
 * is the one fact that differs *between* two sidebars in the same layout: the
 * layout wraps each slot in its own provider, and a Sidebar handed to the
 * trailing slot needs no `side` prop of its own to know where it is. `null` is
 * "nobody said", which a standalone sidebar reads as `start`.
 */
export const SidebarSideContext = React.createContext<SidebarSide | null>(null);

/**
 * The media query each breakpoint's floor makes, written the way `styles.css`
 * writes the grid's.
 *
 * `xs` has no query because its floor is zero: there is no width below it, so
 * a sidebar that collapses there never collapses.
 */
const collapseQueries: Record<NebaBreakpoint, string | null> = {
  xs: null,
  sm: '(width < 40rem)',
  md: '(width < 48rem)',
  lg: '(width < 64rem)',
  xl: '(width < 80rem)'
};

/**
 * The same five widths as Tailwind variants, for the parts of this that are
 * decided in CSS rather than in JavaScript.
 *
 * Written out per breakpoint because Tailwind only ever sees class names that
 * appear literally in the source — the same reason every table in
 * `internal/styles.ts` is a `Record` of complete strings.
 *
 * `belowClasses` hides something at and above the breakpoint, which is what a
 * sidebar's own trigger wants: the hamburger exists exactly while the sidebar
 * does not. `aboveClasses` hides it below, which is what the sidebar's column
 * wants for the one paint between the server's HTML arriving and JavaScript
 * finding out how wide the window is — without it a phone draws the sidebar
 * full width and then throws it away.
 */
export const collapsedOnlyClasses: Record<PageLayoutCollapse, string> = {
  none: 'hidden',
  xs: 'hidden',
  sm: 'sm:hidden',
  md: 'md:hidden',
  lg: 'lg:hidden',
  xl: 'xl:hidden'
};

export const expandedOnlyClasses: Record<PageLayoutCollapse, string> = {
  none: '',
  xs: '',
  sm: 'max-sm:hidden',
  md: 'max-md:hidden',
  lg: 'max-lg:hidden',
  xl: 'max-xl:hidden'
};

/**
 * Whether the window is currently narrower than the breakpoint a sidebar
 * collapses at.
 *
 * `useSyncExternalStore` rather than an effect and a `useState`, for the one
 * reason that matters here: it has a server snapshot, and the server's answer
 * has to be "not collapsed". A sidebar that is collapsed is a Drawer, a Drawer
 * is a portal, and a portal rendered into `document.body` on the server is not
 * a thing — so the markup that ships is the column, and the CSS above is what
 * keeps that column off a narrow screen until this hook can say otherwise.
 */
export function useCollapsed(breakpoint: PageLayoutCollapse): boolean {
  const query = breakpoint === 'none' ? null : collapseQueries[breakpoint];

  const subscribe = React.useCallback(
    (onChange: () => void) => {
      if (!query || typeof window === 'undefined' || !window.matchMedia) {
        return () => {};
      }

      const list = window.matchMedia(query);
      list.addEventListener('change', onChange);

      return () => list.removeEventListener('change', onChange);
    },
    [query]
  );

  const snapshot = React.useCallback(() => {
    if (!query || typeof window === 'undefined' || !window.matchMedia) {
      return false;
    }

    return window.matchMedia(query).matches;
  }, [query]);

  return React.useSyncExternalStore(subscribe, snapshot, () => false);
}

/**
 * `start` and `end` as the two sides a Drawer speaks.
 *
 * A sidebar says which end of the band it takes, because that is a layout
 * question and a layout flips under RTL on its own. A drawer is attached to an
 * edge of the *window*, which `NebaSide` names physically for the same reason a
 * tooltip above a button is above it in every writing direction — so the two
 * have to be translated, and the document's own direction is what translates
 * them.
 *
 * Read during render rather than in an effect, which is safe here for a
 * narrower reason than it looks: the only caller is a sidebar that has already
 * collapsed, and collapsing is a client-side answer. There is no server render
 * of this to disagree with.
 */
export function drawerSide(side: SidebarSide): NebaSide {
  const rtl =
    typeof document !== 'undefined' &&
    getComputedStyle(document.documentElement).direction === 'rtl';

  if (side === 'start') return rtl ? 'right' : 'left';

  return rtl ? 'left' : 'right';
}
