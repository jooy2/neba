/**
 * Shared prop vocabulary for every Neba component.
 *
 * These names and values are deliberately generic: a `size` of `md` or a
 * `color` of `primary` has to mean the same thing on a Button, a Chip, a
 * TextField or a Dialog. Components pick the subset they need from here and
 * never invent a parallel spelling of the same idea.
 */

/** Scale of a component. `md` is the desktop default. */
export type NebaSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

/** Semantic color role. Maps to a token family in `styles.css`. */
export type NebaColor = 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info';

/**
 * How tightly a component packs its content. Only spacing changes — never the
 * type scale or the control's own height — so a compact and a default control
 * of the same `size` still line up on a shared baseline.
 */
export type NebaDensity = 'default' | 'compact';

/**
 * Which way a component runs. `horizontal` everywhere it is offered, because a
 * vertical control is the exception and an exception should have to be asked
 * for. Divider, ButtonGroup, RadioGroup and Slider all read this.
 */
export type NebaOrientation = 'horizontal' | 'vertical';

/**
 * Which edge of an anchor something is placed against. Tooltip reads this, and
 * so does anything else that hangs a popup off an element.
 *
 * Logical rather than physical — `start`/`end` would be wrong here, because a
 * tooltip above a button is above it in every writing direction.
 */
export type NebaSide = 'top' | 'right' | 'bottom' | 'left';

/**
 * Where something sits along the axis it is not placed on: a tooltip against
 * its trigger, a label set into a divider, the content of a table cell.
 *
 * `start`/`end` rather than `left`/`right` because these flip under RTL, which
 * is the whole reason the library never says `left`.
 */
export type NebaAlign = 'start' | 'center' | 'end';

/**
 * Which corner of a box something is pinned to. Badge reads this.
 *
 * Deliberately one word built out of the two the library already has —
 * `top`/`bottom` from `NebaSide`, `start`/`end` from `NebaAlign` — rather than
 * a pair of props. A corner is one decision, and splitting it into two would
 * let a caller spell `{ vertical: 'left' }`.
 */
export type NebaCorner = 'top-start' | 'top-end' | 'bottom-start' | 'bottom-end';

/**
 * The viewport widths the layout components branch on, smallest first.
 *
 * Deliberately the same five names as `NebaSize`, and deliberately *not* the
 * same idea: a `size` of `md` is how big a control is, a breakpoint of `md` is
 * how wide the window is. They share a spelling because a caller who has
 * learned one ladder should not have to learn a second set of words for the
 * other, and because every CSS framework worth copying already spells them this
 * way.
 *
 * The widths are Tailwind's own defaults — `sm` 40rem, `md` 48rem, `lg` 64rem,
 * `xl` 80rem — so a Neba grid and a `md:` utility change at the same moment.
 * `xs` is 0: it is the value with no media query around it.
 */
export type NebaBreakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

/**
 * A value that may differ per breakpoint.
 *
 * A bare value applies from `xs` up; a partial map applies each entry from its
 * own breakpoint up, so `{ xs: 12, md: 6 }` is full width until 48rem and half
 * from there on. There is no `NebaBreakpoint` that means "only at this width" —
 * every entry is a floor, which is what makes a two-entry map enough to
 * describe most layouts.
 */
export type NebaResponsive<T> = T | Partial<Record<NebaBreakpoint, T>>;

/**
 * How a row distributes the space it has left over along its main axis.
 *
 * The three positional values are `NebaAlign`'s — logical, so they flip under
 * RTL — and the three distribution values keep their CSS spelling, because
 * `space-between` is what the property is called and inventing `between` would
 * be a second name for something that already has one.
 */
export type NebaJustifyContent =
  NebaAlign | 'space-between' | 'space-around' | 'space-evenly' | 'stretch';

/**
 * How items sit across the axis they are laid out on. `stretch` is the default
 * everywhere it is offered: a row of cards is a row of cards of one height.
 */
export type NebaAlignItems = NebaAlign | 'stretch' | 'baseline';

/** The same, for one item overriding the row around it. */
export type NebaAlignSelf = NebaAlignItems | 'auto';

/**
 * Visual weight of a component's surface.
 *
 * - `solid` — filled, carries the color. One per view, for the primary action.
 * - `outline` — translucent surface with a hairline border. Secondary actions.
 * - `text` — no surface until hovered. Tertiary/inline actions.
 */
export type NebaVariant = 'solid' | 'outline' | 'text';

/**
 * How far a surface sits off the page, as a drop shadow.
 *
 * `0` is the default everywhere and means flat — the acrylic edge alone is what
 * separates the control from its background. Raise it only for surfaces that
 * genuinely float above the content around them. Hovering adds a level and
 * pressing removes one, so a flat control still answers a press without moving.
 */
export type NebaElevation = 0 | 1 | 2 | 3;

/** Style props shared by most components; spread into their own prop types. */
export interface NebaStyleProps {
  /** @default 'solid' */
  variant?: NebaVariant;
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** @default 'default' */
  density?: NebaDensity;
}
