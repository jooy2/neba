'use client';

import * as React from 'react';
import { Tabs as BaseUITabs } from '@base-ui/react/tabs';
import {
  controlHeightClasses,
  controlTextClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaDensity,
  NebaOrientation,
  NebaSize,
  NebaStyleProps,
  NebaVariant
} from '../../types.js';

/**
 * What a Tab inherits from the Tabs around it.
 *
 * The same arrangement ButtonGroup, List and Accordion use: `variant`, `size`,
 * `color`, `density` and the orientation are properties of the *set*, and a tab
 * that could disagree with its neighbours about any of them is a tab bar with a
 * hole in it.
 */
interface TabsContextValue {
  variant: NebaVariant;
  size: NebaSize;
  density: NebaDensity;
  orientation: NebaOrientation;
  fullWidth: boolean;
}

const TabsContext = React.createContext<TabsContextValue>({
  variant: 'outline',
  size: 'md',
  density: 'default',
  orientation: 'horizontal',
  fullWidth: false
});

/** A tab's value. The same restraint Select puts on its own — an identifier. */
export type TabValue = string | number;

export interface TabsProps
  extends
    Omit<NebaStyleProps, 'variant'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Weight of the tab *bar*, not of the panels under it.
   *
   * - `solid` — a segmented control: the bar is a frosted trough and the
   *   indicator is a filled tile that slides between the tabs.
   * - `outline` — the classic: a rule along the edge of the bar with the
   *   indicator riding on it.
   * - `text` — the same bar with the rule taken away, for tabs inside a Card
   *   that already has an edge of its own.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /** The chosen tab. Use with `onValueChange` for a controlled set. */
  value?: TabValue | null;
  /** Which starts chosen, for an uncontrolled set. */
  defaultValue?: TabValue | null;
  onValueChange?: (value: TabValue | null) => void;
  /**
   * Which way the bar runs. `vertical` puts the tabs down the side and the
   * panel beside them, and moves the arrow keys onto the other axis — which is
   * Base UI's doing, and is what makes a vertical tab bar reachable.
   * @default 'horizontal'
   */
  orientation?: NebaOrientation;
  /**
   * Whether moving the arrow keys also chooses the tab it lands on.
   *
   * `false` by default. Automatic activation is only kind when every panel is
   * already on the page; the moment one of them fetches, walking past four tabs
   * fires four requests.
   * @default false
   */
  activateOnFocus?: boolean;
  /**
   * Whether the arrow keys wrap from the last tab back to the first.
   * @default true
   */
  loopFocus?: boolean;
  /** The tabs share the bar's full width, each taking an equal share of it. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

export interface TabProps extends Omit<
  React.ComponentPropsWithoutRef<'button'>,
  'value' | 'color'
> {
  /** Identifies the tab, and picks out the panel with the same value. */
  value: TabValue;
  /** Content before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content after the label — a count, a Badge, a status dot. */
  endIcon?: React.ReactNode;
  /** Unavailable, but still listed. */
  disabled?: boolean;
  children?: React.ReactNode;
}

export interface TabPanelProps extends React.ComponentPropsWithoutRef<'div'> {
  /** Which tab shows this panel. */
  value: TabValue;
  /**
   * Keeps the panel in the DOM while it is hidden. For a panel that is expensive
   * to build, or that holds form state which should survive being switched away
   * from.
   * @default false
   */
  keepMounted?: boolean;
  children?: React.ReactNode;
}

/* ---------------------------------------------------------------------------
 * The bar
 * ------------------------------------------------------------------------- */

/**
 * What the bar itself looks like, per variant and per axis.
 *
 * `outline` is one border on one edge rather than a box, which is why it needs
 * the axis: the rule belongs under a horizontal bar and beside a vertical one.
 */
const listClasses: Record<NebaVariant, Record<NebaOrientation, string>> = {
  solid: {
    horizontal: `${surfaceClasses} inline-flex bg-(--n-panel) p-1 [box-shadow:var(--neba-plate-glass)]`,
    vertical: `${surfaceClasses} inline-flex flex-col bg-(--n-panel) p-1 [box-shadow:var(--neba-plate-glass)]`
  },
  outline: {
    horizontal: 'flex border-b [border-color:var(--n-line)]',
    vertical: 'flex flex-col border-e [border-color:var(--n-line)]'
  },
  text: {
    horizontal: 'flex',
    vertical: 'flex flex-col'
  }
};

/**
 * The indicator.
 *
 * `solid` fills the tab — a tile that slides between them. The other two draw a
 * 2px bar along the bar's own edge. All three move by animating `left`/`top` and
 * `width`/`height`, which Base UI measures onto `--active-tab-*`. That is a
 * layout animation on an empty box, not a transform on a label: nothing with
 * text in it moves, which is the distinction the house rule actually draws.
 *
 * `left`, not `inset-inline-start`, and this is the one place in the library
 * that reaches for a physical property on purpose. `--active-tab-left` is a
 * measurement — the distance from the list's left edge to the active tab's, in
 * pixels — and it stays a distance from the *left* under RTL. Pairing a physical
 * measurement with a logical property is what would break the direction, not
 * what would fix it. The edge the bar sits on is logical, because that one
 * genuinely flips.
 */
const indicatorClasses: Record<NebaVariant, Record<NebaOrientation, string>> = {
  solid: {
    horizontal:
      'absolute left-(--active-tab-left) top-(--active-tab-top) h-(--active-tab-height) w-(--active-tab-width)',
    vertical:
      'absolute left-(--active-tab-left) top-(--active-tab-top) h-(--active-tab-height) w-(--active-tab-width)'
  },
  outline: {
    horizontal: 'absolute bottom-0 left-(--active-tab-left) h-0.5 w-(--active-tab-width)',
    vertical: 'absolute end-0 top-(--active-tab-top) h-(--active-tab-height) w-0.5'
  },
  text: {
    horizontal: 'absolute bottom-0 left-(--active-tab-left) h-0.5 w-(--active-tab-width)',
    vertical: 'absolute end-0 top-(--active-tab-top) h-(--active-tab-height) w-0.5'
  }
};

const indicatorSurfaceClasses: Record<NebaVariant, string> = {
  solid: `${surfaceClasses} bg-(--n-panel-press) [box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]`,
  outline: 'bg-(--n-accent)',
  text: 'bg-(--n-accent)'
};

/**
 * A tab is a control, so it takes the control height ladder — a `md` tab and a
 * `md` Button are the same 32px, which is what lets a tab bar sit in a toolbar
 * next to one without the row losing its baseline.
 */
const tabRestClasses: Record<NebaVariant, string> = {
  // `data-active`, not `data-selected` — Base UI spells a chosen tab's state
  // that way, and the wrong attribute is a class that silently never matches.
  solid: 'text-(--neba-muted-fg) hover:text-(--neba-fg) data-[active]:text-(--n-accent)',
  outline: 'text-(--neba-muted-fg) hover:text-(--neba-fg) data-[active]:text-(--n-accent)',
  text: 'text-(--neba-muted-fg) hover:text-(--neba-fg) data-[active]:text-(--n-accent)'
};

/**
 * One tab, and one place a tab differs from a Button: `solid` puts the tile
 * *behind* the tab rather than on it, so the tab needs a stacking context of its
 * own or the indicator would cover the label it is meant to be under.
 */
export const Tab = React.forwardRef<HTMLButtonElement, TabProps>(function Tab(
  { value, startIcon, endIcon, disabled = false, className, children, ...props },
  ref
) {
  const { variant, size, density, fullWidth } = React.useContext(TabsContext);

  return (
    <BaseUITabs.Tab
      ref={ref}
      value={value}
      disabled={disabled}
      className={cx(
        'relative z-10 inline-flex shrink-0 cursor-pointer items-center justify-center select-none',
        'whitespace-nowrap font-medium',
        '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
        controlHeightClasses[size],
        controlTextClasses[size],
        gapClasses[size],
        paddingXClasses[density][size],
        variant === 'solid' ? radiusClasses[size] : '',
        transitionClasses,
        iconClasses,
        tabRestClasses[variant],
        // The ring is inset rather than offset: an offset ring on a tab inside a
        // `solid` trough is drawn on top of its neighbours.
        'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
        'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)',
        fullWidth ? 'flex-1' : '',
        className ?? ''
      )}
      {...props}
    >
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
      ) : null}
      {children}
      {hasContent(endIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
      ) : null}
    </BaseUITabs.Tab>
  );
});

/** The content behind one tab. */
export const TabPanel = React.forwardRef<HTMLDivElement, TabPanelProps>(function TabPanel(
  { value, keepMounted = false, className, children, ...props },
  ref
) {
  const { size } = React.useContext(TabsContext);

  return (
    <BaseUITabs.Panel
      ref={ref}
      value={value}
      keepMounted={keepMounted}
      className={[
        'min-w-0 flex-1 text-(--neba-fg)',
        // The panel takes focus when it holds nothing focusable of its own, so
        // it is reachable by keyboard — and it gets the house ring rather than
        // the browser's.
        'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
        radiusClasses[size],
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      {...props}
    >
      {children}
    </BaseUITabs.Panel>
  );
});

/**
 * One set of panels, one of which is shown.
 *
 * Base UI owns everything that makes a tab bar a tab bar rather than a row of
 * buttons: roving focus so the whole bar is one tab stop, the arrow keys on
 * whichever axis the bar runs, Home and End, the `tab` / `tabpanel` roles and
 * the `aria-controls` wiring between them, and the measurement that puts the
 * indicator under the chosen tab. What is here is the surface and the ladders.
 *
 * The tabs and the panels are composed rather than passed as data, unlike
 * Select — because a panel is a subtree, and there is no useful shape for
 * "an array of arbitrary React trees" that is not just children.
 */
export const Tabs = React.forwardRef<HTMLDivElement, TabsProps>(function Tabs(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    value,
    defaultValue,
    onValueChange,
    orientation = 'horizontal',
    activateOnFocus = false,
    loopFocus = true,
    fullWidth = false,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const context = React.useMemo(
    () => ({ variant, size, density, orientation, fullWidth }),
    [variant, size, density, orientation, fullWidth]
  );

  // Everything a caller writes between the tags is either a Tab or a Panel, and
  // the two go in different boxes — so they are sorted here rather than made the
  // caller's problem with a `<TabList>` wrapper they would have to remember.
  const tabs: React.ReactNode[] = [];
  const panels: React.ReactNode[] = [];

  React.Children.forEach(children, (child) => {
    if (React.isValidElement(child) && child.type === TabPanel) {
      panels.push(child);
    } else if (child !== null && child !== undefined && child !== false) {
      tabs.push(child);
    }
  });

  return (
    <TabsContext.Provider value={context}>
      <BaseUITabs.Root
        ref={ref}
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next as TabValue | null)}
        orientation={orientation}
        className={cx(
          'flex min-w-0',
          orientation === 'vertical' ? 'flex-row gap-4' : 'flex-col gap-4',
          className ?? ''
        )}
        style={{ ...surfaceSlots(color, 0), ...style }}
        {...props}
      >
        <BaseUITabs.List
          activateOnFocus={activateOnFocus}
          loopFocus={loopFocus}
          className={cx(
            'relative shrink-0',
            listClasses[variant][orientation],
            variant === 'solid' ? radiusClasses[size] : '',
            fullWidth && orientation === 'horizontal' ? 'w-full' : '',
            // A bar with more tabs than room scrolls rather than wrapping: a tab
            // bar on two lines has stopped being a bar, and the indicator has
            // nowhere sensible to sit.
            orientation === 'horizontal' ? 'overflow-x-auto overflow-y-hidden' : ''
          )}
        >
          {tabs}

          <BaseUITabs.Indicator
            className={[
              'pointer-events-none',
              indicatorClasses[variant][orientation],
              indicatorSurfaceClasses[variant],
              variant === 'solid' ? radiusClasses[size] : 'rounded-full',
              // The same easing everything else uses, on the four properties the
              // measurement actually writes.
              '[transition-property:left,top,width,height]',
              '[transition-duration:var(--neba-duration)]',
              '[transition-timing-function:var(--neba-ease)]'
            ].join(' ')}
          />
        </BaseUITabs.List>

        {panels}
      </BaseUITabs.Root>
    </TabsContext.Provider>
  );
});
