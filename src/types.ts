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
 * How a bar sits in the page's scroll.
 *
 * The three CSS `position` values that mean something for a bar, spelled the
 * way CSS spells them — this is one of the few ideas where inventing a nicer
 * word (`pinned`, `floating`) would only make a reader look up which CSS it
 * maps to. Toolbar and Pill both read it.
 *
 * - `static` — in the flow, scrolling away with the content.
 * - `sticky` — in the flow until the edge, then held there.
 * - `fixed` — out of the flow entirely, against the viewport.
 */
export type NebaPosition = 'static' | 'sticky' | 'fixed';

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
 * Which day a week starts on, counted the way `Date.prototype.getDay` counts it:
 * Sunday is `0`, Saturday is `6`.
 *
 * A number rather than `'sunday' | 'monday' | …`, and for once not because the
 * number is shorter. Every date API in the platform already speaks this
 * encoding, so a caller computing the value rather than typing it in — from a
 * user setting, from `Intl`, from a row in a database — has nothing to translate.
 * The pickers default it from the locale, so it is rarely written down at all.
 */
export type NebaWeekday = 0 | 1 | 2 | 3 | 4 | 5 | 6;

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

/**
 * The six effects the `Animate*` components are built out of, and the six
 * values the `transition` prop takes.
 *
 * They are named after what a reader sees rather than after the CSS property
 * underneath: `zoom` and `grow` are both a change of scale, and they are two
 * words because they are two *gestures* — one arrives from the middle of where
 * it will end up, the other unfolds from nothing.
 *
 * Everything past these six is a component rather than a value. Typing, a
 * marquee and a headline reel need to know what their children *are*, and a
 * prop that only sets class names cannot.
 */
export type NebaAnimation = 'fade' | 'grow' | 'slide' | 'zoom' | 'rotate' | 'blink';

/**
 * What makes an animation run.
 *
 * - `mount` — as soon as it is on the page. The default, and the only one that
 *   needs nothing from the caller.
 * - `visible` — when it is scrolled into view. Once, unless `once` is off.
 * - `hover` — while the pointer is on it, restarting from the beginning on each
 *   entry. Keyboard focus counts as a pointer here, or the effect would be
 *   unreachable without a mouse.
 * - `manual` — never on its own. `play` is what runs it.
 */
export type NebaAnimateTrigger = 'mount' | 'visible' | 'hover' | 'manual';

/** Whether an effect brings its child in or takes it away. */
export type NebaAnimateMode = 'in' | 'out';

/**
 * How many times an animation runs. `'infinite'` rather than `Infinity`,
 * because it is written into CSS as that word and a caller who types the
 * number would be surprised by which one worked.
 */
export type NebaAnimateRepeat = number | 'infinite';

/**
 * The settings every `Animate*` component takes, and the reason they are one
 * interface: a `delay` of 200 has to mean the same thing on a fade and on a
 * marquee, exactly as a `size` of `md` means one height everywhere.
 *
 * Durations and delays are milliseconds — numbers, not CSS strings. A prop
 * whose type is `string` invites `'0.4s'`, and then two components in the same
 * screen are written in two units.
 */
export interface NebaAnimateProps {
  /** How long one run takes, in milliseconds. */
  duration?: number;
  /** How long before it starts, in milliseconds. @default 0 */
  delay?: number;
  /** The easing curve, as CSS writes it. @default the house curve */
  easing?: string;
  /** How many times it runs. @default 1 */
  repeat?: NebaAnimateRepeat;
  /** Runs every other pass backwards, so a repeat returns instead of jumping. */
  alternate?: boolean;
  /** Holds the animation where it is. @default false */
  paused?: boolean;
  /** What starts it. @default 'mount' */
  trigger?: NebaAnimateTrigger;
  /** Runs it, when `trigger` is `manual`. Each `false` → `true` starts it over. */
  play?: boolean;
  /**
   * With `trigger="visible"`, whether it runs only the first time. Off, it runs
   * again every time the element comes back into view.
   * @default true
   */
  once?: boolean;
  /**
   * With `trigger="visible"`, how much of the element has to be on screen
   * before it counts as visible, from `0` to `1`.
   * @default 0.2
   */
  threshold?: number;
}

/** The options a `transition` prop takes when a bare effect name is not enough. */
export interface NebaTransitionOptions {
  /** Which effect. */
  type: NebaAnimation;
  /** Milliseconds. */
  duration?: number;
  /** Milliseconds. @default 0 */
  delay?: number;
  /** CSS easing. @default the house curve */
  easing?: string;
  /** @default 1 */
  repeat?: NebaAnimateRepeat;
  /** Runs every other pass backwards. */
  alternate?: boolean;
  /** Which edge a `slide` comes from. @default 'bottom' */
  from?: NebaSide;
  /** How far a `slide` travels — a CSS length, or a number in pixels. */
  distance?: number | string;
  /** Where a `grow` or a `zoom` starts, as a multiple of its final size. */
  scale?: number;
  /** How far a `rotate` turns from, in degrees. */
  angle?: number;
}

/**
 * An entrance animation on a component that displays something.
 *
 * A bare effect name is the whole of what most callers want —
 * `transition="fade"` — and the object form is there for the rest.
 *
 * It runs on mount and once. Anything else — replaying on scroll, on hover, or
 * under your own control — is what the `Animate*` components are, and any
 * component can be wrapped in one. This prop exists so the common case does not
 * need an extra element in the tree.
 *
 * It is offered on components that *display* something and on none that are
 * pressed. A control that moves under the pointer is the one thing the design
 * language rules out, and a `transition` on a Button would be exactly that.
 */
export type NebaTransition = NebaAnimation | NebaTransitionOptions;

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
