/**
 * Shared prop vocabulary for every Neba component.
 *
 * These names and values are deliberately generic: a `size` of `md` or a
 * `color` of `primary` has to mean the same thing on a Button, a Chip, a
 * TextField or a Dialog. Components pick the subset they need from here and
 * never invent a parallel spelling of the same idea.
 */

import type * as React from 'react';

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

/* ---------------------------------------------------------------------------
 * Charts
 *
 * The vocabulary the chart components share, and the reason it is here rather
 * than in one of them: a `series` handed to a LineChart has to be the same
 * `series` a BarChart takes, or switching a dashboard tile from one to the
 * other is a rewrite instead of a rename. The same argument `NebaSize` makes.
 *
 * Everything below describes *data*. How a chart draws it — the curve, the
 * stacking, the hole in a donut — belongs to the component, because that is
 * exactly the part that differs.
 * ------------------------------------------------------------------------- */

/**
 * Where a point sits along the category axis.
 *
 * A `Date` is accepted because a time series is the common case and converting
 * one to a string at the call site is what makes two charts of the same data
 * label their axes differently.
 */
export type NebaChartCategory = string | number | Date;

/**
 * One value, with everything the chart might want to know about it.
 *
 * `y` of `null` is a **gap** and not a zero — a sensor that was offline, a month
 * that has not closed yet. A line breaks across it, an area breaks with it, and
 * a bar is not drawn. This distinction is the whole reason a datum may be
 * `null` at all: a chart that renders missing data as zero is a chart that
 * reports an outage as a collapse.
 */
export interface NebaChartPoint {
  /**
   * Its place on the category axis. Optional — without it the point is placed
   * by its index, against `categories` if the chart was given any.
   */
  x?: NebaChartCategory;
  /** The value. `null` is a gap. */
  y: number | null;
  /**
   * A second magnitude, for the marks that have one: the radius of a bubble,
   * the weight of a tile. Ignored by the charts that do not.
   */
  z?: number;
  /**
   * Overrides the series' colour for this one point — the slice worth pointing
   * at, the bar that is over budget. Any CSS colour, or a `NebaColor` family.
   */
  color?: string;
  /** What the tooltip, the legend and any value label say instead of `y`. */
  label?: React.ReactNode;
}

/** A number, a gap, or a point that says more about itself. */
export type NebaChartDatum = number | null | NebaChartPoint;

/**
 * One line, one band of bars, one ring of slices — and the unit identity is
 * attached to.
 *
 * Colour follows the series, never its position in the drawing: a chart whose
 * legend is filtered keeps every survivor on the colour it had. That is why the
 * slot a series takes is decided by where it sits in this array and not by how
 * many of its neighbours are currently visible.
 */
export interface NebaChartSeries {
  /**
   * Its name in the legend, the tooltip and the data table. A chart with two or
   * more series always shows a legend, so a series without a name is a series
   * the reader cannot identify.
   */
  name?: string;
  /** The values, in category order. */
  data: readonly NebaChartDatum[];
  /**
   * Overrides the palette slot this series would otherwise take. A `NebaColor`
   * family name, or any CSS colour.
   *
   * This is the one place in the library where a colour is not a semantic role,
   * and it is deliberate: a series is an *entity* — a region, a plan, a
   * competitor — and nothing about it means success or danger. Reach for it to
   * match a brand or to hold a colour steady across two charts, not to say how
   * a number should be felt.
   */
  color?: NebaColor | (string & {});
  /**
   * Starts the series hidden. Only meaningful with an interactive legend, which
   * is what turns it back on.
   * @default false
   */
  hidden?: boolean;
}

/**
 * One span on a [TimelineChart] — a stretch of time with two ends.
 *
 * Its own type rather than a `z2` or an `x2` bolted onto `NebaChartPoint`,
 * because a second position on the axis is a field the other six charts would
 * carry and never read. The trade the whole `types.ts` makes is that a name
 * means one thing everywhere; a `NebaChartPoint` that sometimes has an end and
 * usually does not is the opposite of that.
 *
 * `start` and `end` rather than `x` and `end`: a span has two places on the
 * axis, and naming one of them `x` only reads correctly to someone who already
 * knows which one it is.
 */
export interface NebaTimelinePoint {
  /** When it begins. A `Date`, or a number of milliseconds. */
  start: NebaChartCategory;
  /** And when it is done. A span that ends before it starts is drawn either way round. */
  end: NebaChartCategory;
  /** What the span is called, in the tooltip and the table. */
  label?: React.ReactNode;
  /** Overrides its row's colour for this one span. */
  color?: NebaColor | (string & {});
}

/**
 * One row of a TimelineChart, and everything on it.
 *
 * A row is a series — one entity, one name, one colour — but its data are
 * spans rather than values, so it cannot be a `NebaChartSeries`. There is no
 * `hidden` here and no legend to pair it with: a Gantt's rows *are* its
 * category axis, already named down the side, and a twenty-entry legend
 * restating them is not a filter anyone wants.
 */
export interface NebaTimelineSeries {
  /** Its name on the axis, in the tooltip and in the table. */
  name?: string;
  /** The spans on this row. Overlapping ones are drawn over each other. */
  data: readonly NebaTimelinePoint[];
  /** Overrides the palette slot this row would otherwise take. */
  color?: NebaColor | (string & {});
}

/** How a line gets from one point to the next. */
export type NebaChartCurve = 'linear' | 'smooth' | 'step';

/**
 * Which values are written onto the marks themselves.
 *
 * The default is `none` everywhere, and that is not timidity — a number beside
 * every point is the most reliable way to make a chart unreadable. Label the
 * end, or the extremes, and let the axis and the tooltip carry the rest;
 * `'all'` is there for the eight-bar chart where it genuinely is the answer.
 */
export type NebaChartValueLabels = 'none' | 'last' | 'extremes' | 'all';

/**
 * What the pointer uncovers.
 *
 * - `index` — every series at the category under the pointer, with a crosshair.
 *   The default on anything with a shared x axis, because the question a line
 *   chart is asked is "what happened in March", not "what is this pixel".
 * - `item` — the one mark being pointed at.
 * - `none` — no tooltip. The values still have to be readable some other way.
 */
export type NebaChartTooltipMode = 'index' | 'item' | 'none';

/** One series' answer at the category the pointer is on. */
export interface NebaChartTooltipItem {
  /** Its place in the `series` array — the same index its colour came from. */
  seriesIndex: number;
  name?: string;
  color: string;
  value: number | null;
  /** `value` run through the chart's `format`. */
  formatted: string;
  /** What the point called itself, if it said. */
  label?: React.ReactNode;
}

/** What a custom tooltip is handed. */
export interface NebaChartTooltipContext {
  index: number;
  category: NebaChartCategory;
  /** Only the series that are visible and have a value here. */
  items: readonly NebaChartTooltipItem[];
}

/** The tooltip, when a bare `true` or `false` is not enough. */
export interface NebaChartTooltip {
  /** @default 'index' */
  mode?: NebaChartTooltipMode;
  /**
   * The line dropped through the plot at the active category. On in `index`
   * mode, where it is what says which column the numbers belong to.
   */
  crosshair?: boolean;
  /** Draws the panel. Without it the chart draws its own. */
  render?: (context: NebaChartTooltipContext) => React.ReactNode;
}

/** One axis of a cartesian chart. */
export interface NebaChartAxis {
  /** Leaves the axis undrawn — its rule, its ticks and its labels. */
  hidden?: boolean;
  /** A name for what the axis measures, set beside it. */
  label?: React.ReactNode;
  /**
   * The gridlines this axis casts across the plot. On by default for the value
   * axis and off for the category axis, which is the only arrangement where the
   * grid helps read a value without turning the plot into graph paper.
   */
  grid?: boolean;
  /**
   * Where the scale starts and ends. Left out, both are taken from the data —
   * the value axis from zero, so a bar's length stays proportional to its
   * value. Set `min` only when zero is genuinely not the baseline.
   */
  min?: number;
  max?: number;
  /** Roughly how many ticks. The scale still rounds to clean numbers. */
  tickCount?: number;
  /** How a tick is written, overriding the chart's own `format`. */
  tickFormat?: (value: NebaChartCategory, index: number) => React.ReactNode;
  /**
   * How much room the axis keeps for its ticks and its label, in pixels.
   * Measured from the ticks themselves otherwise; set it when a long category
   * name needs more, or when two charts stacked on a dashboard have to line
   * their plots up.
   */
  thickness?: number;
}

/** Where the legend sits, and whether it does anything when clicked. */
export interface NebaChartLegend {
  /** Which edge of the plot. @default 'bottom' */
  side?: NebaSide;
  /** Where along that edge. @default 'center' */
  align?: NebaAlign;
  /**
   * Clicking an entry hides and shows its series; hovering one dims the rest.
   * @default true
   */
  interactive?: boolean;
  /** Draws each series' current value beside its name. @default false */
  showValue?: boolean;
}

/**
 * A point on a scale, and the colour family a reading takes once it has reached
 * it.
 *
 * The one place in the library where a semantic colour is *computed*, and the
 * reason it is here rather than in whichever component needed it first: a Meter
 * and a GaugeChart are the same reading in two shapes, and a page carrying both
 * must not disagree about where amber starts. Left to the caller that would be
 * a ternary at every call site, and the fourth one would.
 */
export interface NebaThreshold {
  /** The value from which this family applies, in the reading's own units. */
  from: number;
  /** What the bar, or the arc, turns at and above that point. */
  color: NebaColor;
}

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

/* ---------------------------------------------------------------------------
 * Slots
 *
 * `className` is the root, everywhere and without exception. What follows is
 * for everything behind it.
 * ------------------------------------------------------------------------- */

/**
 * Class names for the parts of a component that its `className` cannot reach.
 *
 * A component that draws one element needs none of this: `className` lands on
 * that element and there is nothing else to say. A component that draws six —
 * a field with a label, a shell, a control and two lines of text under it — has
 * five parts a caller can see, can want to change, and has no way to name. That
 * is what this is for, and it is the whole of what it is for.
 *
 * **There is never a `root` key.** `className` is the root, on every component
 * in the library, and a `classNames.root` beside it would be a second spelling
 * of an idea that already has one. The rule that keeps `size` meaning one thing
 * applies here too.
 *
 * A slot name is a promise about the element behind it, so the union each
 * component declares is deliberately short. Only parts that are *structurally*
 * there — a label is a label whatever the field is — get a name; the wrappers
 * that exist to hold a flex direction do not, because naming one freezes a
 * layout decision into the public API.
 */
export type NebaSlots<Slot extends string> = Partial<Record<Slot, string>>;

/**
 * The parts every field-shaped component draws, and the reason they are one
 * type: a `classNames.label` has to mean the label on a TextField, a Select, a
 * Checkbox and a RadioGroup alike, exactly as a `size` of `md` means one height
 * everywhere.
 *
 * - `label` — the field's own name, above it or beside it.
 * - `control` — the thing the reader actually operates: the `<input>`, the
 *   trigger, the tick, the track.
 * - `description` — the helper line under it.
 * - `error` — the message that replaces it when the field is invalid.
 *
 * Four rather than more, because these four are the ones that exist on all of
 * them. A shell around the control, a popup, a chip — those are real parts, but
 * only some fields have them, and a slot offered on a component that cannot
 * draw it is a slot that does nothing.
 */
export type NebaFieldSlot = 'label' | 'control' | 'description' | 'error';
