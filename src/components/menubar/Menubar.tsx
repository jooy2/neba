'use client';

import * as React from 'react';
import { Menubar as BaseUIMenubar } from '@base-ui/react/menubar';
import { Menu } from '../menu/Menu.js';
import { MenuContext } from '../../internal/menu.js';
import {
  controlTextClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  radiusClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaOrientation, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface MenubarProps
  extends
    Pick<NebaStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the bar runs. `vertical` is the shape a side rail of menus takes;
   * the arrow keys follow it either way.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /**
   * Whether an open menu takes the page away. On — the default, and Base UI's —
   * an open menu is what the pointer is talking to.
   * @default true
   */
  modal?: boolean;
  /** Whether the arrow keys wrap around at the ends of the bar. @default true */
  loopFocus?: boolean;
  /** Disables every menu on the bar at once. */
  disabled?: boolean;
  /** The menus. */
  children?: React.ReactNode;
}

export interface MenubarMenuProps {
  /** The word on the bar. */
  label: React.ReactNode;
  /** Content before the label. Sized in `em`, so it tracks it. */
  startIcon?: React.ReactNode;
  /** Unavailable. The word stays on the bar and opens nothing. */
  disabled?: boolean;
  /** The rows, written exactly as they are inside a [Menu](./menu). */
  children?: React.ReactNode;
}

/**
 * A menu bar's own row height, one rung below the control ladder at every step.
 *
 * A menu bar is not a row of buttons — it is a strip of words, and the strip is
 * usually inside something that already has a height of its own: a Toolbar, a
 * WindowPane's title bar, an application header. Sized as controls, `File Edit
 * View` would be three buttons in a row and would make the bar taller than the
 * thing it is drawn on.
 */
const triggerHeights: Record<NebaSize, string> = {
  xs: 'h-4.5',
  sm: 'h-5.5',
  md: 'h-6.5',
  lg: 'h-8',
  xl: 'h-10'
};

const triggerClasses = [
  'inline-flex shrink-0 cursor-pointer select-none items-center justify-center',
  'whitespace-nowrap font-medium leading-none',
  'text-(--neba-fg) bg-transparent',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  iconClasses,
  'hover:bg-(--n-soft)',
  // A menu bar is the one place where "this one is open" has to be legible from
  // across the bar, and it is still colour and nothing else: the word does not
  // move and the strip does not change height.
  'data-[popup-open]:bg-(--n-soft-hover) data-[popup-open]:text-(--n-accent)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
  'disabled:cursor-not-allowed disabled:text-(--neba-disabled-fg) disabled:hover:bg-transparent'
].join(' ');

/**
 * One menu on the bar: the word, and the rows behind it.
 *
 * It has no `size`, `color` or `density` of its own — all three belong to the
 * bar, which is the only place they can be set once and hold for every menu on
 * it. The rows inside are the same `MenuItem`, `MenuSeparator`, `MenuGroup` and
 * `MenuSubmenu` a [Menu](./menu) takes, because it is the same menu.
 */
export function MenubarMenu({ label, startIcon, disabled = false, children }: MenubarMenuProps) {
  const { size, color, density } = React.useContext(MenuContext);

  return (
    <Menu
      size={size}
      color={color}
      density={density}
      disabled={disabled}
      // The whole reason a menu bar is not a row of separate menus: once one of
      // them is open, crossing the bar walks through the others rather than
      // closing the one you left.
      openOnHover
      sideOffset={4}
      trigger={
        <button
          type="button"
          disabled={disabled}
          className={[
            triggerClasses,
            triggerHeights[size],
            controlTextClasses[size],
            gapClasses[size],
            paddingXClasses[density === 'default' ? 'compact' : density][size],
            radiusClasses[size]
          ].join(' ')}
        >
          {hasContent(startIcon) ? startIcon : null}
          {label}
        </button>
      }
    >
      {children}
    </Menu>
  );
}

/**
 * The strip of words at the top of an application — File, Edit, View — each of
 * which opens a menu.
 *
 * What makes it a bar rather than a row of separate menus is what happens once
 * one is open: moving along the strip walks through the others instead of
 * closing the one you left, and the arrow keys move between the menus as well as
 * inside them. Base UI owns all of that, along with the `menubar` role.
 *
 * It draws no surface of its own. A menu bar sits *on* something — a
 * [Toolbar](../surfaces/toolbar), a [WindowPane](../surfaces/window-pane)'s
 * title bar, a [Header](../layout/header) — and a sheet under a strip that is
 * already on a sheet is two sheets.
 */
export const Menubar = React.forwardRef<HTMLDivElement, MenubarProps>(
  function Menubar(rawProps, ref) {
    const {
      size = 'md',
      color = 'primary',
      density = 'default',
      orientation = 'horizontal',
      modal = true,
      loopFocus = true,
      disabled = false,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density']);

    const context = React.useMemo(() => ({ size, color, density }), [size, color, density]);

    return (
      <MenuContext.Provider value={context}>
        <BaseUIMenubar
          ref={ref}
          orientation={orientation}
          modal={modal}
          loopFocus={loopFocus}
          disabled={disabled}
          className={cx(
            'flex items-center',
            orientation === 'vertical' ? 'flex-col items-stretch' : 'flex-row',
            gapClasses[size],
            className ?? ''
          )}
          style={
            {
              '--n-soft': `var(--neba-${color}-soft)`,
              '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
              '--n-accent': `var(--neba-${color}-accent)`,
              '--n-ring': `var(--neba-${color}-ring)`,
              ...style
            } as React.CSSProperties
          }
          {...props}
        >
          {children}
        </BaseUIMenubar>
      </MenuContext.Provider>
    );
  }
);
