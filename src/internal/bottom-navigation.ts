import * as React from 'react';
import type { NebaDensity, NebaSize } from '../types.js';

/** A destination's value. The same restraint Tabs and SegmentedButton put on theirs. */
export type BottomNavigationValue = string | number;

/**
 * Which labels are drawn.
 *
 * - `all` — every destination is named. The only one that works for a reader
 *   who has not used the app before, and the default on the bar that spans an
 *   edge of the window.
 * - `selected` — only the destination that is current. The bar keeps its height
 *   either way, because the named one is always the tallest; what changes is
 *   how much of the row is words. The names the other items lose are still in
 *   the document for a screen reader.
 * - `none` — glyphs only, with every name read out but never drawn.
 */
export type BottomNavigationLabels = 'all' | 'selected' | 'none';

/**
 * What an item inherits from the bar around it.
 *
 * The same arrangement ButtonGroup, List, Tabs and SegmentedButton use: `size`,
 * `density` and which destination is current belong to the *set*. A bar whose
 * third item is a size out is not a bar.
 *
 * It lives in `internal/` for the reason `menu.ts` does rather than the reason
 * `button-group.ts` does: two bars provide it — BottomNavigation and
 * FloatingBottomNavigation — and one item reads it. Keeping it in either bar's
 * file would make the other one import its sibling to draw a row of buttons.
 */
export interface BottomNavigationContextValue {
  value: BottomNavigationValue | null;
  change: (value: BottomNavigationValue) => void;
  size: NebaSize;
  density: NebaDensity;
  labels: BottomNavigationLabels;
  disabled: boolean;
  /**
   * Whether the bar around the item is the floating one.
   *
   * It is the shape of the item that differs and not its behaviour: a bar
   * pinned to an edge divides its whole width between its destinations, while a
   * lozenge hovering over the page is only as wide as what is in it, so its
   * items are sized by their content and cut as stadiums rather than as sheets.
   */
  floating: boolean;
}

export const BottomNavigationContext = React.createContext<BottomNavigationContextValue>({
  value: null,
  change: () => {},
  size: 'md',
  density: 'default',
  labels: 'all',
  disabled: false,
  floating: false
});

/**
 * The row's floor, and the one number the two bars have to agree on.
 *
 * `md` is 56px, which is the height a bottom navigation has had since the first
 * one — tall enough for a glyph with a word under it and short enough that it
 * is not competing with the page it is on. A floating bar is the same object
 * lifted off the edge, so it is the same height; the ladder around it keeps the
 * same proportion to the glyph and the name it holds.
 */
export const barMinHeightClasses: Record<NebaSize, string> = {
  xs: 'min-h-10',
  sm: 'min-h-12',
  md: 'min-h-14',
  lg: 'min-h-16',
  xl: 'min-h-18'
};
