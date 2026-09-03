'use client';

import * as React from 'react';
import { NavigationMenu as BaseUINavigationMenu } from '@base-ui/react/navigation-menu';
import { ChevronIcon } from '../../internal/icons.js';
import { safeRel } from '../../internal/link.js';
import {
  controlHeightClasses,
  controlTextClasses,
  controlTextLeadingClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  popupFadeStateClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaOrientation, NebaSize, NebaStyleProps } from '../../types.js';

/**
 * What every part of a navigation menu inherits from the root.
 *
 * The same arrangement `menu.ts` makes one folder over, kept local because only
 * this component's own parts read it — an item, its trigger and the links in its
 * panel are three things that only exist inside a `NavigationMenu`.
 */
interface NavigationMenuContextValue {
  size: NebaSize;
  density: NebaStyleProps['density'];
}

const NavigationMenuContext = React.createContext<NavigationMenuContextValue>({
  size: 'md',
  density: 'default'
});

export interface NavigationMenuProps
  extends
    Pick<NebaStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Which way the row runs. `vertical` is a nav rail whose panels open beside
   * it; the arrow keys follow either way.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /** Which item's panel is open, by its `value`. Nullish means closed. */
  value?: string | null;
  /** Which starts open, for an uncontrolled menu. */
  defaultValue?: string | null;
  onValueChange?: (value: string | null) => void;
  /** How long the pointer rests before a panel opens, in milliseconds. @default 50 */
  delay?: number;
  /** How long a panel stays after the pointer leaves, in milliseconds. @default 50 */
  closeDelay?: number;
  /** Distance from the row, in pixels. @default 8 */
  sideOffset?: number;
  /** The items. */
  children?: React.ReactNode;
}

export interface NavigationMenuItemProps {
  /** The word in the row. */
  label: React.ReactNode;
  /**
   * Makes the item a plain link rather than something that opens a panel. An
   * item with an `href` and no children is a destination, and it is announced as
   * one — which is the whole reason a site nav is not a Menu.
   */
  href?: string;
  /**
   * Where the link opens. Ignored without `href`.
   *
   * Anything other than this tab also gets `rel="noopener noreferrer"`, merged
   * with whatever `rel` was asked for, exactly as on [TextLink].
   */
  target?: string;
  /** The link's `rel`. The two tokens a new tab needs are added to it. */
  rel?: string;
  /** Content before the label. Sized in `em`, so it tracks it. */
  startIcon?: React.ReactNode;
  /**
   * Identifies the item, for a controlled menu. Defaults to nothing, which is
   * fine for an uncontrolled one — Base UI gives each item an identity of its
   * own.
   */
  value?: string;
  /** Unavailable. The word stays in the row and opens nothing. */
  disabled?: boolean;
  /** How many columns the panel lays its links out in. @default 1 */
  columns?: number;
  /** The panel's contents — usually `NavigationMenuLink`s. */
  children?: React.ReactNode;
}

export interface NavigationMenuLinkProps extends Omit<
  React.ComponentPropsWithoutRef<'a'>,
  'color' | 'title'
> {
  /** Where it goes. */
  href: string;
  /** The row's name. */
  title: React.ReactNode;
  /** A second line under it, one step down the scale and muted. */
  description?: React.ReactNode;
  /** A glyph before the title. */
  startIcon?: React.ReactNode;
}

/** The row of words. A nav's items sit at control height — they are the page's. */
const triggerClasses = [
  'inline-flex shrink-0 cursor-pointer select-none items-center justify-center',
  'whitespace-nowrap font-medium leading-none no-underline',
  'text-(--neba-fg) bg-transparent',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  iconClasses,
  'hover:bg-(--n-soft)',
  'data-[popup-open]:bg-(--n-soft-hover) data-[popup-open]:text-(--n-accent)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
  'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)',
  'data-[disabled]:hover:bg-transparent'
].join(' ');

/** The panel. The same frosted sheet a Menu and a Popover draw. */
const popupClasses = [
  surfaceClasses,
  'relative border text-(--neba-fg) bg-(--n-panel-press)',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none] overflow-hidden',
  // Opacity and the viewport's own size only. A panel that slid in would drag a
  // page's worth of links across the screen.
  '[transition:opacity_var(--neba-duration)_var(--neba-ease),width_var(--neba-duration)_var(--neba-ease),height_var(--neba-duration)_var(--neba-ease)]',
  popupFadeStateClasses
].join(' ');

const linkClasses = [
  'flex min-w-0 cursor-pointer items-start no-underline',
  'text-(--neba-fg) bg-transparent',
  transitionClasses,
  iconClasses,
  'hover:bg-(--n-soft)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]'
].join(' ');

/** How much room the panel keeps around its links, per step. */
const panelPaddingClasses: Record<NebaSize, string> = {
  xs: 'p-1',
  sm: 'p-1.5',
  md: 'p-2',
  lg: 'p-2.5',
  xl: 'p-3'
};

/**
 * One row inside a panel: where it goes, what it is called, and a line saying
 * what is there.
 *
 * It is a real `<a>`, which is the point of the whole component — a site's
 * navigation is a list of destinations, and a destination that is a `<div>` with
 * a click handler is not in the link list, not on the status bar and not in a
 * crawler's index.
 */
export const NavigationMenuLink = React.forwardRef<HTMLAnchorElement, NavigationMenuLinkProps>(
  function NavigationMenuLink(
    { href, title, description, startIcon, className, children, ...props },
    ref
  ) {
    const { size, density } = React.useContext(NavigationMenuContext);

    return (
      <BaseUINavigationMenu.Link
        ref={ref}
        href={href}
        className={cx(
          linkClasses,
          radiusClasses[size],
          gapClasses[size],
          paddingXClasses[density ?? 'default'][size],
          'py-2',
          className ?? ''
        )}
        {...props}
      >
        {hasContent(startIcon) ? (
          <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
        ) : null}
        <span className="flex min-w-0 flex-col gap-0.5">
          <span className={`font-medium ${controlTextLeadingClasses[size]}`}>{title}</span>
          {hasContent(description) ? (
            <span className={`text-(--neba-muted-fg) ${metaTextClasses[size]}`}>{description}</span>
          ) : null}
          {children}
        </span>
      </BaseUINavigationMenu.Link>
    );
  }
);

/**
 * One word in the row, and what opens under it.
 *
 * With children it is a trigger and a panel; with an `href` and nothing else it
 * is a link, and the difference is not cosmetic — the second one is announced as
 * a destination and the first as something that expands.
 */
export function NavigationMenuItem({
  label,
  href,
  target,
  rel,
  startIcon,
  value,
  disabled = false,
  columns = 1,
  children
}: NavigationMenuItemProps) {
  const { size, density } = React.useContext(NavigationMenuContext);
  const isLink = href !== undefined && !hasContent(children);

  const chrome = [
    triggerClasses,
    controlHeightClasses[size],
    controlTextClasses[size],
    gapClasses[size],
    paddingXClasses[density ?? 'default'][size],
    radiusClasses[size]
  ].join(' ');

  return (
    <BaseUINavigationMenu.Item value={value}>
      {isLink ? (
        <BaseUINavigationMenu.Link
          href={href}
          target={target}
          rel={safeRel(target, rel)}
          className={chrome}
        >
          {hasContent(startIcon) ? startIcon : null}
          {label}
        </BaseUINavigationMenu.Link>
      ) : (
        <>
          <BaseUINavigationMenu.Trigger disabled={disabled} className={chrome}>
            {hasContent(startIcon) ? startIcon : null}
            {label}
            {/* Drawn pointing down and turned when the panel is open, which is
                the one allowance the no-transform rule makes: a glyph rotating
                is not a control moving. */}
            <BaseUINavigationMenu.Icon className="flex items-center [transition:rotate_var(--neba-duration)_var(--neba-ease)] data-[popup-open]:rotate-180">
              <ChevronIcon />
            </BaseUINavigationMenu.Icon>
          </BaseUINavigationMenu.Trigger>

          <BaseUINavigationMenu.Content
            className={`grid gap-1 ${panelPaddingClasses[size]}`}
            style={
              columns > 1
                ? { gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))` }
                : undefined
            }
          >
            {children}
          </BaseUINavigationMenu.Content>
        </>
      )}
    </BaseUINavigationMenu.Item>
  );
}

/**
 * A site's navigation: a row of destinations, some of which open a panel of
 * more of them.
 *
 * The difference from a [Menu](./menu) is what the rows *are*. A menu holds
 * actions, so its rows are `menuitem`s and the whole thing is a widget that
 * traps the arrow keys. This holds links, so it is a `<nav>` full of real
 * `<a>`s — which is what puts them in the link list, on the status bar and in a
 * crawler's index. Reach for a Menu when the row does something and for this
 * when the row goes somewhere.
 *
 * One panel is open at a time and it resizes between items rather than closing
 * and reopening, which is Base UI's doing and is what makes crossing the row
 * read as one surface rather than three.
 */
export const NavigationMenu = React.forwardRef<HTMLElement, NavigationMenuProps>(
  function NavigationMenu(
    {
      size = 'md',
      color = 'primary',
      density = 'default',
      orientation = 'horizontal',
      value,
      defaultValue,
      onValueChange,
      delay,
      closeDelay,
      sideOffset = 8,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const context = React.useMemo(() => ({ size, density }), [size, density]);

    return (
      <NavigationMenuContext.Provider value={context}>
        <BaseUINavigationMenu.Root
          ref={ref}
          orientation={orientation}
          value={value}
          defaultValue={defaultValue}
          onValueChange={(next) => onValueChange?.(next)}
          delay={delay}
          closeDelay={closeDelay}
          className={className}
          style={
            {
              ...surfaceSlots(color, 3),
              '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
              ...style
            } as React.CSSProperties
          }
          {...props}
        >
          <BaseUINavigationMenu.List
            className={[
              'flex items-center',
              orientation === 'vertical' ? 'flex-col items-stretch' : 'flex-row',
              gapClasses[size]
            ].join(' ')}
          >
            {children}
          </BaseUINavigationMenu.List>

          <BaseUINavigationMenu.Portal>
            {/* `neba-portal` is a hook, not a style: a portalled popup leaves
                the subtree a host may have scoped its CSS reset to. */}
            <BaseUINavigationMenu.Positioner
              className="neba-portal z-50 [outline:none]"
              sideOffset={sideOffset}
              collisionPadding={12}
            >
              <BaseUINavigationMenu.Popup className={`${popupClasses} ${radiusClasses[size]}`}>
                <BaseUINavigationMenu.Viewport />
              </BaseUINavigationMenu.Popup>
            </BaseUINavigationMenu.Positioner>
          </BaseUINavigationMenu.Portal>
        </BaseUINavigationMenu.Root>
      </NavigationMenuContext.Provider>
    );
  }
);
