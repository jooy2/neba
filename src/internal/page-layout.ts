'use client';

import * as React from 'react';
import { useLayoutEffectOnClient } from './layout-effect.js';
import { useMediaQuery, widthBelow } from './media.js';
import { hiddenBelowClasses, hiddenFromClasses } from './responsive.js';
import type { NebaBreakpoint, NebaPosition, NebaSide, NebaSize } from '../types.js';

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
 * Which bar the element being rendered right now was handed to the layout as.
 *
 * Only the `header` and the `footer` a PageLayout places are its bars. A Header
 * anywhere else in the page, such as an article's own inside `<main>`, is a
 * header of that part, and letting it register too overwrote the site header's
 * height with its own and, once it unmounted, left the layout with none.
 */
export const PageLayoutSlotContext = React.createContext<PageLayoutSlot | null>(null);

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

/** Hands a node to a ref of either kind. */
function assignRef<T>(ref: React.ForwardedRef<T>, node: T | null) {
  if (typeof ref === 'function') ref(node);
  else if (ref) ref.current = node;
}

/**
 * The ref a Header or a Footer puts on its bar: it hands the bar to the layout
 * when the bar fills that slot, and forwards it to the caller's own ref.
 *
 * Stable for as long as the slot and `position` are, which is the point of it.
 * A callback ref that changes is detached and attached again on every commit,
 * and each of those registered the bar anew — restarting both of the layout's
 * `ResizeObserver`s and writing the bar's height as `0px` and back onto the
 * layout's root, which invalidates the style of the whole page. A caller who
 * writes `ref={(node) => …}` inline hands the bar a new ref on every render, so
 * every render of a page with a Header in it did all of that. `position` is
 * kept in the dependencies on purpose: a bar switched to `fixed` has the same
 * height and fires no resize, and the room reserved for it is what changed.
 *
 * The caller's ref is therefore read from a ref of its own rather than closed
 * over. When it changes, the old one is handed `null` and the new one the bar,
 * which is what React does for a ref that changes, one phase later.
 */
export function useBarRef(
  slot: PageLayoutSlot,
  ref: React.ForwardedRef<HTMLElement>,
  position: NebaPosition
): (node: HTMLElement | null) => void {
  const { register } = React.useContext(PageLayoutContext);
  // Only the one the layout was handed is its bar.
  const slotted = React.useContext(PageLayoutSlotContext) === slot;
  const nodeRef = React.useRef<HTMLElement | null>(null);
  const forwardedRef = React.useRef(ref);

  useLayoutEffectOnClient(() => {
    const previous = forwardedRef.current;

    if (previous === ref) return;

    forwardedRef.current = ref;
    assignRef(previous, null);
    assignRef(ref, nodeRef.current);
  }, [ref]);

  return React.useCallback(
    (node: HTMLElement | null) => {
      nodeRef.current = node;

      if (slotted) register(slot, node);

      assignRef(forwardedRef.current, node);
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps -- `position` re-attaches the ref on purpose
    [register, slot, slotted, position]
  );
}

/**
 * A Header's floor at each size, in steps of Tailwind's spacing scale.
 *
 * The same numbers as Header's `barMinHeightClasses`, which have to stay
 * literal class names for Tailwind to find them, so the two are kept in step by
 * hand and `Header.test.tsx` holds them there. They are here because the layout
 * needs them as a length, for the reason `headerFloor` gives.
 */
export const headerFloorSteps: Record<NebaSize, number> = {
  xs: 10,
  sm: 12,
  md: 14,
  lg: 16,
  xl: 20
};

/** The props of a header element that decide how much a `fixed` one takes. */
interface HeaderFloorProps {
  position?: NebaPosition;
  size?: NebaSize;
  divider?: boolean;
}

/**
 * How much a `fixed` header takes off the top of the page before anybody has
 * measured it, or `undefined` when the header is not one.
 *
 * The measured height reaches the page from an effect, which on a page the
 * server rendered is after the first paint, so everything under a fixed header
 * would be drawn behind it and then drop by its height. A Header's height is
 * its floor unless what is in it is taller, and the floor follows from three of
 * its props — so the layout reads them off the element it was handed, as a
 * Panes reads its panes' sizes, and reserves that much from the first render.
 * The measurement then only corrects a bar that came out taller.
 *
 * A header wrapped in a component of the caller's own has props this cannot
 * read, and has its room reserved only once it has been measured.
 */
export function headerFloor(
  header: React.ReactNode,
  providedSize: NebaSize | undefined
): string | undefined {
  if (!React.isValidElement<HeaderFloorProps>(header) || header.props.position !== 'fixed') {
    return undefined;
  }

  const steps = headerFloorSteps[header.props.size ?? providedSize ?? 'md'] ?? headerFloorSteps.md;

  // The hairline is a border on the bar itself, so it is part of its height.
  return header.props.divider === false
    ? `calc(var(--spacing) * ${steps})`
    : `calc(var(--spacing) * ${steps} + 1px)`;
}

/**
 * The five widths as Tailwind variants, for the parts of this that are
 * decided in CSS rather than in JavaScript.
 *
 * The tables themselves are `internal/responsive.ts`', because `Show` asks the
 * identical question and two spellings of "hidden below `md`" would be two
 * chances to disagree. What is added here is only the sixth key: `none` is a
 * layout that never collapses, which is not a breakpoint and has no place in a
 * table the rest of the library reads.
 *
 * `collapsedOnlyClasses` hides something at and above the breakpoint, which is
 * what a sidebar's own trigger wants: the hamburger exists exactly while the
 * sidebar does not. `expandedOnlyClasses` hides it below, which is what the
 * sidebar's column wants for the one paint between the server's HTML arriving
 * and JavaScript finding out how wide the window is — without it a phone draws
 * the sidebar full width and then throws it away.
 */
export const collapsedOnlyClasses: Record<PageLayoutCollapse, string> = {
  none: 'hidden',
  ...hiddenFromClasses
};

export const expandedOnlyClasses: Record<PageLayoutCollapse, string> = {
  none: '',
  ...hiddenBelowClasses
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
  return useMediaQuery(breakpoint === 'none' ? null : widthBelow(breakpoint));
}

/**
 * The drawer a collapsed Sidebar becomes, fetched only once one has collapsed.
 *
 * A Drawer is a Base UI dialog, and that dialog was two thirds of what a page
 * shell weighed — carried by every page with a sidebar, on a desktop where the
 * sidebar never stops being a column as much as on a phone. A sidebar is a
 * drawer only once a `matchMedia` in the browser says so, which never happens
 * on a server, so nothing is lost by fetching it then: the Sidebar asks as soon
 * as it collapses, which on a phone is straight after hydration, and a
 * SidebarTrigger asks when a pointer, the focus or a finger first reaches it.
 * `React.lazy` is handed the same promise and waits only for what is left of it.
 * A request that fails is forgotten, so the next one tries again.
 *
 * Here rather than in Sidebar's file because SidebarTrigger asks too, and a
 * trigger importing the sidebar would carry it. An object rather than a
 * function so a test can spy on it.
 */
const requestDrawer = () =>
  import('../components/drawer/Drawer.js').then((module) => ({ default: module.Drawer }));

let drawerRequest: ReturnType<typeof requestDrawer> | undefined;

export const drawerChunk = {
  load() {
    drawerRequest ??= requestDrawer().catch((error: unknown) => {
      drawerRequest = undefined;

      throw error;
    });

    return drawerRequest;
  }
};

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
 * of this to disagree with. It is a style read, so the caller asks once per
 * collapse and once each time the drawer opens or closes, rather than on every
 * render.
 */
export function drawerSide(side: SidebarSide): NebaSide {
  const rtl =
    typeof document !== 'undefined' &&
    getComputedStyle(document.documentElement).direction === 'rtl';

  if (side === 'start') return rtl ? 'right' : 'left';

  return rtl ? 'left' : 'right';
}
