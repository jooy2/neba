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
