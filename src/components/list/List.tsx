'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses } from '../box/Box.js';
import {
  focusRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaDensity, NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';

/**
 * What a ListItem inherits from the List around it.
 *
 * A row is meaningless on its own — it is a row *of* something — so `size`,
 * `density` and whether the rows are separated by hairlines belong to the list,
 * not to the member. Passing them on every item would be three chances per row
 * to get one of them wrong, and the failure is silent: a list where item four
 * is a size bigger than the rest.
 *
 * A context rather than `React.Children.map` with `cloneElement`, for the same
 * reason ButtonGroup uses one: the moment a caller `.map()`s their data or
 * wraps a row in a Tooltip, cloning stops reaching the item.
 */
interface ListContextValue {
  size: NebaSize;
  density: NebaDensity;
  dividers: boolean;
}

const ListContext = React.createContext<ListContextValue>({
  size: 'md',
  density: 'default',
  dividers: false
});

export interface ListProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'ul'>, 'color'> {
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Separates the rows with a hairline instead of with space.
   *
   * It changes more than it sounds like: with dividers the rules have to reach
   * both edges of the sheet, so the list gives up its inner padding and the rows
   * give up their rounded corners. A row cannot be a floating tile and a ruled
   * line at the same time.
   * @default false
   */
  dividers?: boolean;
  /**
   * Renders something other than a `<ul>` — `render={<ol />}` for a list where
   * the order is the point. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

export interface ListItemProps extends Omit<
  React.ComponentPropsWithoutRef<'li'>,
  'color' | 'onClick'
> {
  /**
   * Passing it is what turns the row into a real `<button>`. It lands on that
   * button rather than on the `<li>`, which is why the type is loosened from
   * the list item the shell actually is.
   */
  onClick?: React.MouseEventHandler<HTMLElement>;
  /** Content before the label — an icon, an avatar, a status dot. */
  startIcon?: React.ReactNode;
  /** Content after the label, inside the pressable area. */
  endIcon?: React.ReactNode;
  /** A second line under the label, one step down the type scale and muted. */
  description?: React.ReactNode;
  /**
   * A control pinned to the end of the row — a switch, a menu button.
   *
   * Deliberately outside the pressable area: a row that both navigates and
   * holds a toggle has two things to press, and nesting one button inside
   * another is markup the browser rewrites on parse.
   */
  action?: React.ReactNode;
  /** Renders the row as a link. Mutually exclusive with `onClick` in practice. */
  href?: string;
  /** Marks the row as the chosen one — the open page, the current filter. */
  selected?: boolean;
  /** Unavailable. Drops the colour family for neutral grey, as everywhere else. */
  disabled?: boolean;
  /** The label. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on Box. A list holds other people's content, and that content
 * arrives with its own colours.
 *
 * `text` is the one to reach for inside a Card: the card is already a sheet, and
 * a second bordered rectangle inside it is a second rectangle.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * A row's vertical padding. Its own ladder rather than Box's, because a row is
 * a line of text in a stack of them and a box is a container: the same `md`
 * that gives a box 16px of air would give a list of eight rows the height of a
 * page.
 */
const rowPaddingYClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'py-1', sm: 'py-1.5', md: 'py-2', lg: 'py-2.5', xl: 'py-3' },
  compact: { xs: 'py-0.5', sm: 'py-0.5', md: 'py-1', lg: 'py-1.5', xl: 'py-2' }
};

/**
 * A row sits one step down the radius ladder from the sheet it is inside — a
 * tile cut out of a sheet cannot have the same corner as the sheet, or the two
 * curves fight along the edge.
 */
const rowRadiusClasses: Record<NebaSize, string> = {
  xs: radiusClasses.xs,
  sm: radiusClasses.xs,
  md: radiusClasses.sm,
  lg: radiusClasses.sm,
  xl: radiusClasses.md
};

/**
 * The rule between two rows, and the rule that makes the sheet give up its
 * padding: `>li+li` rather than a class on each item, so it holds however the
 * caller composed the rows — through a `.map()`, through fragments, through a
 * component of their own that renders a ListItem.
 */
const dividerClasses = '[&>li+li]:border-t [&>li+li]:[border-color:var(--n-line)]';

/**
 * A stack of rows.
 *
 * The list is a sheet and the rows are what is on it, which is the whole reason
 * the two are separate components: `size` and `density` are properties of the
 * stack, not of any one line in it, and a context is what carries them down.
 *
 * There is no Base UI primitive under this on purpose. A list is not a
 * composite widget — it has no roving focus, no selection model, no keyboard
 * contract of its own. Reaching for a menu or a listbox primitive to get one
 * would hand every consumer's plain list of links the semantics of a menu,
 * which is the most common way a component library breaks a screen reader.
 */
export const List = React.forwardRef<HTMLUListElement, ListProps>(function List(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    dividers = false,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const context = React.useMemo(() => ({ size, density, dividers }), [size, density, dividers]);

  const classNames = [
    'flex flex-col',
    radiusClasses[size],
    variantClasses[variant],
    transitionClasses,
    // Without dividers the rows are tiles and the sheet keeps a hair of padding
    // so a hovered row does not run into the edge. With them the rules have to
    // reach the edge, so the padding goes and the rows square off.
    dividers ? `overflow-hidden ${dividerClasses}` : 'p-1',
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  const element = useRender({
    render,
    ref,
    props: {
      // Tailwind's reset takes the bullets off every `<ul>`, and Safari takes
      // the list semantics off with them. Saying `role="list"` out loud is the
      // one-line fix, and it costs nothing when the reset is not there.
      role: 'list',
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      children,
      ...props
    }
  });

  return <ListContext.Provider value={context}>{element}</ListContext.Provider>;
});

/**
 * One row.
 *
 * The shell is always an `<li>`. What changes is what is inside it: a plain run
 * of content, or — when `onClick` or `href` is given — a real `<button>` or
 * `<a>` wrapping that content, with `action` sitting outside it as a separate
 * control. This is the same shape Chip uses, for the same two reasons: a
 * `<span>` carrying a click handler is invisible to a keyboard, and a
 * `<button>` inside a `<button>` is markup Chrome silently un-nests.
 */
export const ListItem = React.forwardRef<HTMLLIElement, ListItemProps>(function ListItem(
  {
    startIcon,
    endIcon,
    description,
    action,
    href,
    selected = false,
    disabled = false,
    className,
    children,
    onClick,
    ...props
  },
  ref
) {
  const { size, density, dividers } = React.useContext(ListContext);
  const interactive = Boolean(onClick || href) && !disabled;

  const padX = boxPaddingXClasses[density][size];
  const padY = rowPaddingYClasses[density][size];

  const bodyClassNames = [
    'flex min-w-0 flex-1 items-center text-start',
    padX,
    padY,
    gapClasses[size],
    sheetBodyClasses[size],
    transitionClasses,
    iconClasses,
    // Squared off when the rows are ruled, for the reason `dividerClasses`
    // exists: a tile and a line are two different ideas about what a row is.
    dividers ? '' : rowRadiusClasses[size],
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled
      ? 'cursor-not-allowed text-(--neba-disabled-fg)'
      : selected
        ? 'bg-(--n-soft-press) font-medium text-(--n-accent)'
        : '',
    interactive ? `cursor-pointer ${focusRingClasses}` : '',
    // Hover deepens the same tint `selected` already uses, one step down, so a
    // hovered row and the chosen row are the same idea at two strengths.
    interactive && !selected ? 'hover:bg-(--n-soft)' : '',
    interactive && selected ? 'hover:bg-(--n-soft-press)' : ''
  ]
    .filter(Boolean)
    .join(' ');

  const body = (
    <>
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
          {startIcon}
        </span>
      ) : null}

      <span className="flex min-w-0 flex-1 flex-col">
        {hasContent(children) ? <span className="truncate">{children}</span> : null}
        {hasContent(description) ? (
          <span className={`truncate text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
            {description}
          </span>
        ) : null}
      </span>

      {hasContent(endIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">{endIcon}</span>
      ) : null}
    </>
  );

  return (
    <li
      ref={ref}
      className={['flex w-full items-center', className ?? ''].filter(Boolean).join(' ')}
      {...props}
    >
      {interactive && href ? (
        // `aria-current="page"` on a link and `"true"` on a button: the first is
        // "this is the page you are on", the second is "this is the chosen one
        // of these". `aria-pressed` would be a third thing — a toggle — and a
        // selected row is not a toggle.
        <a
          href={href}
          className={bodyClassNames}
          aria-current={selected ? 'page' : undefined}
          onClick={onClick}
        >
          {body}
        </a>
      ) : interactive ? (
        <button
          type="button"
          className={bodyClassNames}
          aria-current={selected ? true : undefined}
          onClick={onClick}
        >
          {body}
        </button>
      ) : (
        <div className={bodyClassNames} aria-disabled={disabled || undefined}>
          {body}
        </div>
      )}

      {hasContent(action) ? (
        <div className={`flex shrink-0 items-center ${padX}`}>{action}</div>
      ) : null}
    </li>
  );
});
