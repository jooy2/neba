import * as React from 'react';
import type { NebaColor, NebaDensity, NebaSize } from '../types';

/**
 * What a menu item inherits from the menu around it.
 *
 * The same arrangement `ButtonGroup` uses, and for the same reason: `size`,
 * `color` and `density` are properties of the *menu*, not of any one row in it,
 * and passing them per item would be three chances per row to get one wrong —
 * with a silent failure, a menu where the fourth item is a size bigger.
 *
 * It lives in `internal/` rather than in `Menu.tsx` because a submenu is a menu
 * inside a menu and a context menu is the same rows hung off a right-click, so
 * three components read this and none of them should have to import the others.
 */
export interface MenuContextValue {
  size: NebaSize;
  color: NebaColor;
  density: NebaDensity;
}

export const MenuContext = React.createContext<MenuContextValue>({
  size: 'md',
  color: 'primary',
  density: 'default'
});
