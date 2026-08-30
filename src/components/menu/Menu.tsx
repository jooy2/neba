'use client';

import * as React from 'react';
import { Menu as BaseUIMenu } from '@base-ui/react/menu';
import { ContextMenu as BaseUIContextMenu } from '@base-ui/react/context-menu';
import { MenuContext } from '../../internal/menu.js';
import { CheckIcon, ChevronIcon, DotIcon } from '../../internal/icons.js';
import {
  controlTextLeadingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaAlign,
  NebaColor,
  NebaDensity,
  NebaSide,
  NebaSize,
  NebaStyleProps
} from '../../types.js';

/**
 * A menu takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`, for the reason Dialog has none: the three weights
 * answer "how much does this surface assert itself against the page", and a
 * popup that has taken the pointer has already answered it. There is no
 * `elevation` either — a menu genuinely floats, which is the one case elevation
 * exists for, so it is fixed at 3.
 */
interface MenuSurfaceProps extends Pick<NebaStyleProps, 'size' | 'color' | 'density'> {
  className?: string;
  style?: React.CSSProperties;
}

export interface MenuProps extends MenuSurfaceProps {
  /**
   * The element that opens the menu, wired up by Base UI. Optional — a
   * controlled menu opened from elsewhere needs no trigger of its own.
   */
  trigger?: React.ReactElement;
  /** Whether the menu is open. Use with `onOpenChange` for a controlled menu. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which edge of the trigger it hangs off. @default 'bottom' */
  side?: NebaSide;
  /** Where it sits along that edge. @default 'start' */
  align?: NebaAlign;
  /** Distance from the trigger, in pixels. @default 6 */
  sideOffset?: number;
  /**
   * Whether the page behind is taken away while the menu is open.
   *
   * Left undefined rather than defaulted here on purpose: Base UI's own default
   * is the same `true`, and it warns when the prop is set on a menu that turns
   * out to be nested — which is every menu on a [Menubar](./menubar) and every
   * submenu. Not passing it is how the default stays a default.
   * @default true
   */
  modal?: boolean;
  /**
   * Opens on hover as well as on click. For a menu bar, where crossing the row
   * with an open menu should walk through the others rather than close them.
   * @default false
   */
  openOnHover?: boolean;
  /**
   * Whether the arrow keys wrap from the last item back to the first.
   * @default true
   */
  loopFocus?: boolean;
  /** Unavailable. The trigger stops opening anything. */
  disabled?: boolean;
  /** The rows. */
  children?: React.ReactNode;
}

export interface ContextMenuProps extends MenuSurfaceProps {
  /** The rows, exactly as they are written inside a `Menu`. */
  content: React.ReactNode;
  /**
   * The area that answers a right-click or a long press. Rendered inside a
   * `<div>` of Base UI's, which is what listens for the gesture.
   */
  children: React.ReactNode;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** @default true */
  loopFocus?: boolean;
  disabled?: boolean;
}

export interface MenuItemProps {
  /** What the row does. Not given, and not a link, the row is a label. */
  onClick?: (event: React.MouseEvent<HTMLElement>) => void;
  /** Renders the row as a real `<a>`. A menu of links has to be links. */
  href?: string;
  /** Where the link opens — `_blank` and the rest. Ignored without `href`. */
  target?: string;
  /** Content before the label — an icon, a swatch, a check. */
  startIcon?: React.ReactNode;
  /** Content after the label, before any `shortcut`. */
  endIcon?: React.ReactNode;
  /**
   * The keystroke that does the same thing, set at the end of the row and
   * muted. Text only — the row does not bind it, the application does.
   */
  shortcut?: React.ReactNode;
  /** A second line under the label, one step down the type scale and muted. */
  description?: React.ReactNode;
  /**
   * Re-points the row's colour family — `danger` for the one that deletes.
   * Defaults to the menu's own.
   */
  color?: NebaColor;
  /**
   * Whether picking the row closes the menu.
   * @default true
   */
  closeOnClick?: boolean;
  /** Unavailable. Still listed, and still found by typeahead. */
  disabled?: boolean;
  /** What typeahead matches against, when the label is not a plain string. */
  label?: string;
  /** The label. */
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export interface MenuSubmenuProps {
  /** The label on the row that opens it. */
  label?: React.ReactNode;
  startIcon?: React.ReactNode;
  disabled?: boolean;
  /** Which edge of the parent row it opens against. @default 'right' */
  side?: NebaSide;
  /** Distance from the parent menu, in pixels. @default 4 */
  sideOffset?: number;
  /** The nested rows. */
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export interface MenuGroupProps {
  /** The heading over the group. Wired to it by Base UI. */
  label?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
}

export interface MenuCheckboxItemProps extends Omit<
  MenuItemProps,
  'href' | 'target' | 'startIcon' | 'onClick'
> {
  checked?: boolean;
  defaultChecked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  /**
   * Whether ticking the row closes the menu. `false` here rather than the `true`
   * a plain item takes: a list of things to tick is a list you tick more than
   * one of.
   * @default false
   */
  closeOnClick?: boolean;
}

export interface MenuRadioGroupProps {
  value?: string | number;
  defaultValue?: string | number;
  onValueChange?: (value: string | number) => void;
  disabled?: boolean;
  children?: React.ReactNode;
  className?: string;
}

export interface MenuRadioItemProps extends Omit<
  MenuItemProps,
  'href' | 'target' | 'startIcon' | 'onClick'
> {
  /** What this row sets the group to. */
  value: string | number;
  /** @default false */
  closeOnClick?: boolean;
}

export type MenuSeparatorProps = React.ComponentPropsWithoutRef<'div'>;

/* ---------------------------------------------------------------------------
 * The surface
 * ------------------------------------------------------------------------- */

/**
 * The popup, which is the Select popup to the pixel — deliberately, because a
 * select *is* a menu that remembers what you picked, and two floating lists of
 * rows that do not match are two lists the eye has to learn separately.
 */
const popupClasses = [
  surfaceClasses,
  'max-h-[min(24rem,var(--available-height))] min-w-40 overflow-y-auto overscroll-contain',
  'border bg-(--n-panel-press) p-1',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  // Opacity only. A menu that slides in has moved the row you were already
  // reaching for, which is the one thing a menu must never do.
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/**
 * A row's padding, and a ladder of its own rather than Box's.
 *
 * A List row spans a sheet that something else decided the width of; a menu row
 * is inside a popup that is exactly as wide as its longest label. Box's `px-4`
 * at `md` would add 32px to a menu that says "Cut", which is how a five-item
 * menu ends up the width of a dialog.
 */
const rowPaddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: {
    xs: 'px-1.5 py-0.5',
    sm: 'px-2 py-1',
    md: 'px-2.5 py-1.5',
    lg: 'px-3 py-2',
    xl: 'px-3.5 py-2.5'
  },
  compact: {
    xs: 'px-1 py-0.5',
    sm: 'px-1.5 py-0.5',
    md: 'px-2 py-1',
    lg: 'px-2.5 py-1',
    xl: 'px-3 py-1.5'
  }
};

/**
 * A row sits one step down the radius ladder from the popup it is inside, the
 * same step a ListItem takes: a tile cut out of a sheet cannot carry the sheet's
 * own corner, or the two curves fight along the edge.
 */
const rowRadiusClasses: Record<NebaSize, string> = {
  xs: radiusClasses.xs,
  sm: radiusClasses.xs,
  md: radiusClasses.sm,
  lg: radiusClasses.sm,
  xl: radiusClasses.md
};

/**
 * The row, in every one of its shapes — plain, link, submenu trigger, checkbox,
 * radio. They differ in what Base UI part renders them and in nothing else.
 *
 * `data-highlighted` rather than `:hover`, exactly as on a Select option: it is
 * also what the arrow keys move, so the mouse and the keyboard light the same
 * row instead of the keyboard lighting nothing.
 *
 * `accented` is a parameter rather than a class the caller appends, and that is
 * not a style preference. Appending `text-(--n-accent)` next to the default
 * `text-(--neba-fg)` puts two utilities of equal specificity on one element, and
 * which of them wins is decided by their order in the generated stylesheet
 * rather than by the order they were written in — so `color="danger"` on a row
 * silently did nothing. Branching here is what makes only one of the two exist.
 */
function rowClasses(
  size: NebaSize,
  density: NebaDensity,
  accented: boolean,
  className?: string
): string {
  return [
    'relative flex w-full cursor-pointer items-center select-none',
    accented ? 'text-(--n-accent)' : 'text-(--neba-fg)',
    rowPaddingClasses[density][size],
    rowRadiusClasses[size],
    gapClasses[size],
    controlTextLeadingClasses[size],
    transitionClasses,
    iconClasses,
    'data-[highlighted]:bg-(--n-soft-hover)',
    'data-[popup-open]:bg-(--n-soft)',
    'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)',
    // Base UI moves focus onto the highlighted row itself, so a ring here would
    // draw a rectangle inside the popup on every arrow press. The tint is the
    // focus indicator, which is what makes it the same one the mouse gets.
    '[outline:none]',
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');
}

/** The fixed-width slot a check, a dot or a `startIcon` lands in. */
const slotClasses = 'flex h-[1lh] w-[1.2em] shrink-0 items-center justify-center';

/**
 * The label, and the description under it when there is one.
 *
 * `min-w-0` so a long label truncates rather than pushing the shortcut off the
 * end of a popup that has already been positioned.
 */
function RowBody({
  children,
  description,
  size
}: {
  children: React.ReactNode;
  description?: React.ReactNode;
  size: NebaSize;
}) {
  if (!hasContent(description)) {
    return <span className="min-w-0 flex-1 truncate text-start">{children}</span>;
  }

  return (
    <span className="flex min-w-0 flex-1 flex-col text-start">
      <span className="truncate">{children}</span>
      <span className={`truncate text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
        {description}
      </span>
    </span>
  );
}

/* ---------------------------------------------------------------------------
 * The parts
 * ------------------------------------------------------------------------- */

/**
 * One row of a menu.
 *
 * Renders a real `<a>` when it is given an `href` and Base UI's own item
 * otherwise — the same split ListItem makes, for the same reason. A menu of
 * links that are not links cannot be opened in a new tab, cannot be copied, and
 * tells a screen reader the wrong thing about every one of them.
 */
export function MenuItem({
  onClick,
  href,
  target,
  startIcon,
  endIcon,
  shortcut,
  description,
  color,
  closeOnClick = true,
  disabled = false,
  label,
  children,
  className,
  style
}: MenuItemProps) {
  const menu = React.useContext(MenuContext);
  const { size, density } = menu;

  const body = (
    <>
      {hasContent(startIcon) ? (
        <span className={`${slotClasses} text-(--neba-muted-fg)`}>{startIcon}</span>
      ) : null}
      <RowBody description={description} size={size}>
        {children}
      </RowBody>
      {hasContent(endIcon) ? (
        <span className={`${slotClasses} text-(--neba-muted-fg)`}>{endIcon}</span>
      ) : null}
      {hasContent(shortcut) ? (
        <span
          className={`ms-2 shrink-0 text-(--neba-muted-fg) tabular-nums ${metaTextClasses[size]}`}
        >
          {shortcut}
        </span>
      ) : null}
    </>
  );

  // A row can name its own family — `color="danger"` on the one that deletes —
  // and the slots are re-declared on the row so the tint, the hairline and the
  // text all turn over together rather than one of them staying blue.
  const slots = color ? surfaceSlots(color, 0) : undefined;
  const rowStyle = slots || style ? { ...slots, ...style } : undefined;

  if (href !== undefined) {
    return (
      <BaseUIMenu.LinkItem
        href={href}
        target={target}
        label={label}
        closeOnClick={closeOnClick}
        onClick={onClick}
        className={rowClasses(size, density, Boolean(color), className)}
        style={rowStyle}
      >
        {body}
      </BaseUIMenu.LinkItem>
    );
  }

  return (
    <BaseUIMenu.Item
      disabled={disabled}
      label={label}
      closeOnClick={closeOnClick}
      onClick={onClick}
      className={rowClasses(size, density, Boolean(color), className)}
      style={rowStyle}
    >
      {body}
    </BaseUIMenu.Item>
  );
}

/** A row that ticks. The tick lands in the same slot a `startIcon` would. */
export function MenuCheckboxItem({
  checked,
  defaultChecked,
  onCheckedChange,
  endIcon,
  shortcut,
  description,
  color,
  closeOnClick = false,
  disabled = false,
  label,
  children,
  className,
  style
}: MenuCheckboxItemProps) {
  const { size, density } = React.useContext(MenuContext);
  const slots = color ? surfaceSlots(color, 0) : undefined;

  return (
    <BaseUIMenu.CheckboxItem
      checked={checked}
      defaultChecked={defaultChecked}
      onCheckedChange={(next) => onCheckedChange?.(next)}
      disabled={disabled}
      label={label}
      closeOnClick={closeOnClick}
      className={rowClasses(size, density, Boolean(color), className)}
      style={slots || style ? { ...slots, ...style } : undefined}
    >
      <span className={`${slotClasses} text-(--n-accent)`}>
        <BaseUIMenu.CheckboxItemIndicator className="flex items-center justify-center">
          <CheckIcon />
        </BaseUIMenu.CheckboxItemIndicator>
      </span>
      <RowBody description={description} size={size}>
        {children}
      </RowBody>
      {hasContent(endIcon) ? (
        <span className={`${slotClasses} text-(--neba-muted-fg)`}>{endIcon}</span>
      ) : null}
      {hasContent(shortcut) ? (
        <span
          className={`ms-2 shrink-0 text-(--neba-muted-fg) tabular-nums ${metaTextClasses[size]}`}
        >
          {shortcut}
        </span>
      ) : null}
    </BaseUIMenu.CheckboxItem>
  );
}

/** One choice out of a set. Wraps the rows that make up the set. */
export function MenuRadioGroup({
  value,
  defaultValue,
  onValueChange,
  disabled = false,
  children,
  className
}: MenuRadioGroupProps) {
  return (
    <BaseUIMenu.RadioGroup
      value={value}
      defaultValue={defaultValue}
      onValueChange={(next) => onValueChange?.(next as string | number)}
      disabled={disabled}
      className={className}
    >
      {children}
    </BaseUIMenu.RadioGroup>
  );
}

/**
 * A row inside a `MenuRadioGroup`.
 *
 * Marked with a dot rather than a tick, which is the same distinction Checkbox
 * and Radio make everywhere else: a tick says "and", a dot says "instead of".
 */
export function MenuRadioItem({
  value,
  endIcon,
  shortcut,
  description,
  color,
  closeOnClick = false,
  disabled = false,
  label,
  children,
  className,
  style
}: MenuRadioItemProps) {
  const { size, density } = React.useContext(MenuContext);
  const slots = color ? surfaceSlots(color, 0) : undefined;

  return (
    <BaseUIMenu.RadioItem
      value={value}
      disabled={disabled}
      label={label}
      closeOnClick={closeOnClick}
      className={rowClasses(size, density, Boolean(color), className)}
      style={slots || style ? { ...slots, ...style } : undefined}
    >
      <span className={`${slotClasses} text-(--n-accent)`}>
        <BaseUIMenu.RadioItemIndicator className="flex items-center justify-center">
          <DotIcon />
        </BaseUIMenu.RadioItemIndicator>
      </span>
      <RowBody description={description} size={size}>
        {children}
      </RowBody>
      {hasContent(endIcon) ? (
        <span className={`${slotClasses} text-(--neba-muted-fg)`}>{endIcon}</span>
      ) : null}
      {hasContent(shortcut) ? (
        <span
          className={`ms-2 shrink-0 text-(--neba-muted-fg) tabular-nums ${metaTextClasses[size]}`}
        >
          {shortcut}
        </span>
      ) : null}
    </BaseUIMenu.RadioItem>
  );
}

/** A named run of rows. The label is a heading, not a row — it cannot be picked. */
export function MenuGroup({ label, children, className }: MenuGroupProps) {
  const { size, density } = React.useContext(MenuContext);

  return (
    <BaseUIMenu.Group className={className}>
      {hasContent(label) ? (
        <BaseUIMenu.GroupLabel
          className={[
            rowPaddingClasses[density][size],
            metaTextClasses[size],
            'font-semibold tracking-wide text-(--neba-muted-fg) uppercase'
          ].join(' ')}
        >
          {label}
        </BaseUIMenu.GroupLabel>
      ) : null}
      {children}
    </BaseUIMenu.Group>
  );
}

/** The hairline between two runs of rows. */
export function MenuSeparator({ className, ...props }: MenuSeparatorProps) {
  return (
    <BaseUIMenu.Separator
      className={['-mx-1 my-1 h-px bg-(--n-line)', className ?? ''].filter(Boolean).join(' ')}
      {...props}
    />
  );
}

/**
 * A menu inside a menu.
 *
 * The row that opens it is the same row every other item is, wearing a chevron
 * — and it opens on hover, on Enter and on the arrow key that points at it,
 * all of which is Base UI's. What is here is the surface and the glyph.
 *
 * Nesting is unlimited: a `MenuSubmenu` renders its children inside a popup
 * that is itself a menu, so a submenu of a submenu needs no different component.
 */
export function MenuSubmenu({
  label,
  startIcon,
  disabled = false,
  side = 'right',
  sideOffset = 4,
  children,
  className,
  style
}: MenuSubmenuProps) {
  const menu = React.useContext(MenuContext);
  const { size, density, color } = menu;

  return (
    <BaseUIMenu.SubmenuRoot>
      <BaseUIMenu.SubmenuTrigger disabled={disabled} className={rowClasses(size, density, false)}>
        {hasContent(startIcon) ? (
          <span className={`${slotClasses} text-(--neba-muted-fg)`}>{startIcon}</span>
        ) : null}
        <span className="min-w-0 flex-1 truncate text-start">{label}</span>
        {/* The chevron is drawn pointing down and turned — the one allowance
            the no-transform rule makes, because a glyph has no text to resample.
            `-rotate-90` in a logical world would be wrong under RTL, so it reads
            the side Base UI actually placed the submenu on. */}
        <span className={`${slotClasses} text-(--neba-muted-fg) -rotate-90`}>
          <ChevronIcon />
        </span>
      </BaseUIMenu.SubmenuTrigger>

      <BaseUIMenu.Portal>
        <BaseUIMenu.Positioner
          className="neba-portal z-50 [outline:none]"
          side={side}
          sideOffset={sideOffset}
          align="start"
        >
          <BaseUIMenu.Popup
            className={[
              popupClasses,
              radiusClasses[size],
              controlTextLeadingClasses[size],
              className ?? ''
            ]
              .filter(Boolean)
              .join(' ')}
            style={{ ...surfaceSlots(color, 3), ...style }}
          >
            {children}
          </BaseUIMenu.Popup>
        </BaseUIMenu.Positioner>
      </BaseUIMenu.Portal>
    </BaseUIMenu.SubmenuRoot>
  );
}

/**
 * A list of actions that appears when something is pressed.
 *
 * Everything that makes a menu a menu rather than a floating list of divs is
 * Base UI's: roving focus with the arrow keys, Home and End, typeahead, Escape,
 * closing on an outside click, restoring focus to the trigger, submenus opening
 * on hover with the safe-triangle so a diagonal reach does not close them, and
 * the `menu` / `menuitem` roles that make any of it mean something to a screen
 * reader. What is here is the surface, the ladders and the row layout.
 *
 * The rows are composed rather than passed as data — the opposite of Select,
 * and deliberately. A select's options are values from a list a caller already
 * has; a menu's rows are *code*, each one a different handler, a different icon,
 * sometimes a submenu. Data would mean an `items` type with a variant for every
 * shape a row can take, which is a component tree spelled as a discriminated
 * union.
 */
export function Menu({
  size = 'md',
  color = 'primary',
  density = 'default',
  trigger,
  open,
  defaultOpen,
  onOpenChange,
  side = 'bottom',
  align = 'start',
  sideOffset = 6,
  modal,
  openOnHover = false,
  loopFocus = true,
  disabled = false,
  className,
  style,
  children
}: MenuProps) {
  const context = React.useMemo(() => ({ size, color, density }), [size, color, density]);

  return (
    <MenuContext.Provider value={context}>
      <BaseUIMenu.Root
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        modal={modal}
        loopFocus={loopFocus}
        disabled={disabled}
      >
        {trigger ? (
          <BaseUIMenu.Trigger render={trigger} openOnHover={openOnHover} disabled={disabled} />
        ) : null}

        <BaseUIMenu.Portal>
          {/* `neba-portal` is a hook, not a style: a portalled popup leaves the
              subtree a host may have scoped its CSS reset to. */}
          <BaseUIMenu.Positioner
            className="neba-portal z-50 [outline:none]"
            side={side}
            align={align}
            sideOffset={sideOffset}
          >
            <BaseUIMenu.Popup
              className={[
                popupClasses,
                radiusClasses[size],
                controlTextLeadingClasses[size],
                className ?? ''
              ]
                .filter(Boolean)
                .join(' ')}
              style={{ ...surfaceSlots(color, 3), ...style }}
            >
              {children}
            </BaseUIMenu.Popup>
          </BaseUIMenu.Positioner>
        </BaseUIMenu.Portal>
      </BaseUIMenu.Root>
    </MenuContext.Provider>
  );
}

/**
 * The same menu, opened by a right-click or a long press instead of by a button.
 *
 * It takes the rows as `content` and the area as `children`, which is Tooltip's
 * shape rather than Menu's — because here the trigger is not one element you
 * hand over, it is a region of the page, and the region is the thing being
 * wrapped. Base UI positions the popup at the pointer rather than against an
 * anchor, and the long press is what makes it reachable on a touch screen at all.
 */
export function ContextMenu({
  size = 'md',
  color = 'primary',
  density = 'default',
  content,
  children,
  open,
  defaultOpen,
  onOpenChange,
  loopFocus = true,
  disabled = false,
  className,
  style
}: ContextMenuProps) {
  const context = React.useMemo(() => ({ size, color, density }), [size, color, density]);

  return (
    <MenuContext.Provider value={context}>
      <BaseUIContextMenu.Root
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        loopFocus={loopFocus}
        disabled={disabled}
      >
        <BaseUIContextMenu.Trigger>{children}</BaseUIContextMenu.Trigger>

        <BaseUIContextMenu.Portal>
          <BaseUIContextMenu.Positioner className="neba-portal z-50 [outline:none]">
            <BaseUIContextMenu.Popup
              className={[
                popupClasses,
                radiusClasses[size],
                controlTextLeadingClasses[size],
                className ?? ''
              ]
                .filter(Boolean)
                .join(' ')}
              style={{ ...surfaceSlots(color, 3), ...style }}
            >
              {content}
            </BaseUIContextMenu.Popup>
          </BaseUIContextMenu.Positioner>
        </BaseUIContextMenu.Portal>
      </BaseUIContextMenu.Root>
    </MenuContext.Provider>
  );
}
