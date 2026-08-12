import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  cx,
  hasContent,
  iconSizeClasses,
  metaTextClasses,
  radiusClasses,
  srOnlyClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles';
import type {
  NebaDensity,
  NebaElevation,
  NebaPosition,
  NebaSize,
  NebaStyleProps,
  NebaVariant
} from '../../types';

/** A destination's value. The same restraint Tabs and SegmentedButton put on theirs. */
export type BottomNavigationValue = string | number;

/**
 * Which labels are drawn.
 *
 * - `all` — every destination is named. The default, and the only one that
 *   works for a reader who has not used the app before.
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
 */
interface BottomNavigationContextValue {
  value: BottomNavigationValue | null;
  change: (value: BottomNavigationValue) => void;
  size: NebaSize;
  density: NebaDensity;
  labels: BottomNavigationLabels;
  disabled: boolean;
}

const BottomNavigationContext = React.createContext<BottomNavigationContextValue>({
  value: null,
  change: () => {},
  size: 'md',
  density: 'default',
  labels: 'all',
  disabled: false
});

export interface BottomNavigationProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'nav'>, 'color' | 'defaultValue' | 'onChange'> {
  /** The destination the reader is on. Use with `onValueChange` for a controlled bar. */
  value?: BottomNavigationValue | null;
  /** Which starts current, for an uncontrolled bar. */
  defaultValue?: BottomNavigationValue | null;
  onValueChange?: (value: BottomNavigationValue) => void;
  /**
   * How the bar sits in the page's scroll. `fixed` — the default here, against
   * the `static` everything else defaults to — is what a bottom navigation is:
   * it is held against the bottom edge of the window whatever the page does,
   * and the page pads itself out of the way.
   * @default 'fixed'
   */
  position?: NebaPosition;
  /** Which names are drawn. @default 'all' */
  labels?: BottomNavigationLabels;
  /**
   * Draws a hairline along the top edge, against the content the bar is over.
   *
   * On by default, which is the other way round from Toolbar: a bar pinned over
   * a scrolling page has content passing underneath it at every moment, and a
   * translucent sheet with nothing marking its edge reads as part of that.
   * @default true
   */
  divider?: boolean;
  /**
   * Keeps the bar clear of the home indicator on a phone, by adding
   * `env(safe-area-inset-bottom)` under it. The sheet still reaches the bottom
   * of the screen; only the items move up.
   * @default true
   */
  safeArea?: boolean;
  /**
   * Drop shadow depth. `0` (the default) is flat: the bar is attached to the
   * edge of the window rather than floating over the middle of it, and
   * `divider` is what separates it from the content.
   * @default 0
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
  /** The BottomNavigationItems. */
  children?: React.ReactNode;
}

export interface BottomNavigationItemProps extends Omit<
  React.ComponentPropsWithoutRef<'button'>,
  'value' | 'color'
> {
  /** Identifies the destination. What `onValueChange` reports. */
  value: BottomNavigationValue;
  /** The glyph above the name. Sized on the standalone-glyph ladder. */
  icon?: React.ReactNode;
  /** Renders the item as a link rather than as a button. */
  href?: string;
  /** Unavailable, but still part of the set. */
  disabled?: boolean;
  /** The destination's name. Read out even when `labels` keeps it undrawn. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the bar is never
 * dyed, exactly as on Toolbar and Box. What carries the colour family is the
 * one item that is current.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
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
  sticky: 'sticky bottom-0 z-20',
  fixed: 'fixed inset-x-0 bottom-0 z-30'
};

/**
 * The row's floor.
 *
 * `md` is 56px, which is the height a bottom navigation has had since the first
 * one — tall enough for a glyph with a word under it and short enough that it
 * is not competing with the page it is on. The ladder around it keeps the same
 * proportion to the glyph and the name it holds.
 */
const rowMinHeightClasses: Record<NebaSize, string> = {
  xs: 'min-h-10',
  sm: 'min-h-12',
  md: 'min-h-14',
  lg: 'min-h-16',
  xl: 'min-h-18'
};

/** The air inside the sheet, around the row of items. */
const rowPaddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'p-1', sm: 'p-1', md: 'p-1.5', lg: 'p-2', xl: 'p-2.5' },
  compact: { xs: 'p-0.5', sm: 'p-0.5', md: 'p-1', lg: 'p-1', xl: 'p-1.5' }
};

/** Between the glyph and the name under it. */
const itemGapClasses: Record<NebaSize, string> = {
  xs: 'gap-0.5',
  sm: 'gap-0.5',
  md: 'gap-1',
  lg: 'gap-1',
  xl: 'gap-1.5'
};

/**
 * A row of destinations held against the bottom edge of the window.
 *
 * It is a `<nav>` rather than a `role="tablist"`, and its items are ordinary
 * links or buttons rather than tabs, which is a deliberate choice about what is
 * being promised. A tab list owes a keyboard reader one tab stop for the whole
 * set and arrow keys within it, and it owes a screen reader a panel per tab; a
 * bottom navigation switches what the *page* is, not which panel of one is
 * showing. Claiming the role without the behaviour is worse for a keyboard
 * reader than never claiming it. What is claimed instead is `aria-current`,
 * which is the honest statement: this is the destination you are on.
 *
 * The sheet reaches the bottom of the screen and the items are held clear of the
 * home indicator by `safeArea`, so the acrylic runs under it rather than
 * stopping in a stripe above it.
 */
export const BottomNavigation = React.forwardRef<HTMLElement, BottomNavigationProps>(
  function BottomNavigation(
    {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      value: valueProp,
      defaultValue = null,
      onValueChange,
      position = 'fixed',
      labels = 'all',
      divider = true,
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
      () => ({ value: value ?? null, change, size, density, labels, disabled }),
      [value, change, size, density, labels, disabled]
    );

    const classNames = cx(
      'w-full min-w-0',
      // A bar spanning an edge of the window has nothing behind its corners, so
      // only one sitting in the flow is a sheet with corners at all.
      position === 'static' ? radiusClasses[size] : '',
      variantClasses[variant],
      // A bar that is not in the flow has three edges against the window and one
      // against the content, so only that one is ever drawn — a hairline down
      // the left of the screen is a hairline nobody asked for. In the flow it is
      // an ordinary sheet and takes the whole outline.
      variant === 'outline' && position === 'static' ? 'border [border-color:var(--n-line)]' : '',
      divider ? 'border-t [border-color:var(--n-line)]' : '',
      positionClasses[position],
      // The sheet keeps reaching the bottom of the screen; what the inset moves
      // is the row inside it. A bar that stopped above the home indicator would
      // leave a stripe of page showing under the acrylic.
      safeArea ? 'pb-[env(safe-area-inset-bottom)]' : '',
      transitionClasses,
      className
    );

    return useRender({
      render: render ?? <nav />,
      ref,
      props: {
        'aria-label': label,
        className: classNames,
        style: { ...surfaceSlots(color, elevation), ...style },
        children: (
          <BottomNavigationContext.Provider value={context}>
            <div
              className={cx(
                'flex w-full items-stretch',
                rowMinHeightClasses[size],
                rowPaddingClasses[density][size]
              )}
            >
              {children}
            </div>
          </BottomNavigationContext.Provider>
        ),
        ...props
      }
    });
  }
);

/**
 * One destination.
 *
 * It has no `size`, no `color` and no `variant` of its own: all three belong to
 * the bar, which is the only place they can be set once and mean the same thing
 * for every item.
 *
 * With an `href` it is a real `<a>`, which is what makes a long press offer
 * "open in a new tab" and what puts the destination in the status bar — neither
 * of which a `<button>` that calls `router.push` can do. Without one it is a
 * `<button>`, because a `<div>` carrying a click handler is invisible to a
 * keyboard.
 */
export const BottomNavigationItem = React.forwardRef<HTMLElement, BottomNavigationItemProps>(
  function BottomNavigationItem(
    { value, icon, href, disabled: disabledProp = false, className, children, onClick, ...props },
    ref
  ) {
    const bar = React.useContext(BottomNavigationContext);
    const disabled = disabledProp || bar.disabled;
    const selected = bar.value !== null && bar.value === value;

    const named = bar.labels === 'all' || (bar.labels === 'selected' && selected);

    const classNames = cx(
      'flex min-w-0 flex-1 flex-col items-center justify-center px-1 py-1.5',
      itemGapClasses[bar.size],
      radiusClasses[bar.size],
      '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
      transitionClasses,
      'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
      // An if/else rather than stacked variants: two Tailwind classes of equal
      // specificity resolve by their order in the generated stylesheet.
      disabled
        ? 'cursor-not-allowed text-(--neba-disabled-fg)'
        : selected
          ? 'cursor-pointer font-medium text-(--n-accent) bg-(--n-soft) hover:bg-(--n-soft-hover)'
          : 'cursor-pointer text-(--neba-muted-fg) hover:text-(--neba-fg) hover:bg-(--n-panel-hover)',
      className
    );

    const body = (
      <>
        {hasContent(icon) ? (
          <span
            className={cx('flex shrink-0 items-center justify-center', iconSizeClasses[bar.size])}
          >
            {icon}
          </span>
        ) : null}

        {hasContent(children) ? (
          // Undrawn is not unsaid. A glyph on its own has no accessible name at
          // all, so the name a hidden label would have carried is kept in the
          // document rather than dropped with the pixels.
          <span
            className={
              named
                ? cx('max-w-full truncate leading-tight', metaTextClasses[bar.size])
                : srOnlyClasses
            }
          >
            {children}
          </span>
        ) : null}
      </>
    );

    const press = (event: React.MouseEvent<HTMLElement>) => {
      if (disabled) {
        event.preventDefault();
        return;
      }

      bar.change(value);
      onClick?.(event as React.MouseEvent<HTMLButtonElement>);
    };

    if (href) {
      return (
        <a
          ref={ref as React.Ref<HTMLAnchorElement>}
          href={disabled ? undefined : href}
          aria-current={selected ? 'page' : undefined}
          aria-disabled={disabled || undefined}
          className={classNames}
          onClick={press}
          {...(props as React.ComponentPropsWithoutRef<'a'>)}
        >
          {body}
        </a>
      );
    }

    return (
      <button
        ref={ref as React.Ref<HTMLButtonElement>}
        type="button"
        disabled={disabled}
        aria-current={selected ? 'page' : undefined}
        className={classNames}
        onClick={press}
        {...props}
      >
        {body}
      </button>
    );
  }
);
