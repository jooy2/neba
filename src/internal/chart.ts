/**
 * The arithmetic every chart is made of.
 *
 * Here rather than in a component for the reason `progress.ts` is: five
 * components draw five different marks and ask exactly the same four questions
 * first — what is the range, where does a value land in the plot, what are the
 * clean numbers to tick at, and what colour is series four. A chart file that
 * also has to answer those is a file where the drawing cannot be read.
 *
 * There is no React in here and nothing in it knows what an SVG is. What it
 * knows is data and pixels; `chart-frame.tsx` is where those become elements.
 *
 * The scales are deliberately not a `d3-scale`. A linear scale is six lines, a
 * band scale is four, and `nice numbers` is twelve — and the package still has
 * one runtime dependency, which is the same trade `color.ts` makes.
 */

import type * as React from 'react';
import type {
  NebaChartCategory,
  NebaChartDatum,
  NebaChartPoint,
  NebaChartSeries,
  NebaColor,
  NebaDensity,
  NebaSize
} from '../types';

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/**
 * How tall a plot is when nobody said, in pixels.
 *
 * A chart is one of the few things in the library with no intrinsic height — it
 * is as tall as it is given — so this ladder is what stops every chart on a
 * dashboard being a different shape. The steps climb faster than the control
 * ladder because the thing being scaled is a *picture*: at `xs` this is a strip
 * beside a number, at `xl` it is what the screen is about.
 *
 * The axis band is drawn *inside* this, not added to it. A card sized to the
 * plot and then handed axis labels is the card that grows a two-line scrollbar.
 */
export const plotHeights: Record<NebaSize, number> = {
  xs: 120,
  sm: 160,
  md: 220,
  lg: 280,
  xl: 360
};

/**
 * A Sparkline's own ladder, which is a different object: it has no axes, no
 * legend and nothing to read off it but the shape, so it is sized against the
 * line of text it sits next to rather than against the page.
 */
export const sparklineHeights: Record<NebaSize, number> = {
  xs: 16,
  sm: 20,
  md: 28,
  lg: 40,
  xl: 56
};

/**
 * The weight of a line, in pixels. `md` is 2, which is the width a data line
 * wants everywhere — thin enough to stay a line where two of them cross, heavy
 * enough to hold a hue at 3:1.
 */
export const lineWidths: Record<NebaSize, number> = {
  xs: 1.5,
  sm: 1.75,
  md: 2,
  lg: 2.25,
  xl: 2.5
};

/**
 * The radius of a marker. `md` is 4, so the dot is 8px across before its ring —
 * the floor below which a marker stops being something a pointer can find.
 */
export const markerRadii: Record<NebaSize, number> = {
  xs: 3,
  sm: 3.5,
  md: 4,
  lg: 4.5,
  xl: 5
};

/**
 * Tick and label type, in pixels rather than as a class.
 *
 * SVG text does not inherit a Tailwind utility usefully — the `<text>` has to
 * carry a `font-size` the layout arithmetic can also read, because the room the
 * axis reserves is measured from it. These are `metaTextClasses` as numbers;
 * keep the two in step.
 */
export const chartFontSizes: Record<NebaSize, number> = {
  xs: 10,
  sm: 11,
  md: 12,
  lg: 13,
  xl: 14
};

/**
 * How thick a bar is allowed to get, in pixels.
 *
 * A cap and not a width: the band a bar sits in is whatever the plot divided by
 * the category count gives, and a bar that fills its band leaves the chart with
 * no air in it at all. Past this the leftover stays as space.
 */
export const barMaxThickness: Record<NebaSize, number> = {
  xs: 14,
  sm: 18,
  md: 24,
  lg: 30,
  xl: 36
};

/**
 * How much of a band the bars in it take, before the cap above applies.
 * `density` is the only thing that moves it — the same rule as everywhere else,
 * spacing and nothing but spacing.
 */
export const barBandRatio: Record<NebaDensity, number> = {
  default: 0.62,
  compact: 0.82
};

/** The gap the surface shows through between two touching marks, in pixels. */
export const markGap = 2;

/** The corner cut off the data end of a bar. Square at the baseline. */
export const barRadius = 4;

/* ---------------------------------------------------------------------------
 * Colour
 * ------------------------------------------------------------------------- */

/** The eight slots, as the `var()`s that resolve them per theme. */
export const chartPalette: readonly string[] = [
  'var(--neba-chart-1)',
  'var(--neba-chart-2)',
  'var(--neba-chart-3)',
  'var(--neba-chart-4)',
  'var(--neba-chart-5)',
  'var(--neba-chart-6)',
  'var(--neba-chart-7)',
  'var(--neba-chart-8)'
];

const colorFamilies = new Set<string>([
  'primary',
  'secondary',
  'success',
  'warning',
  'danger',
  'info'
]);

/** A `NebaColor` resolves to its readable-on-surface accent; anything else is CSS. */
export function resolveColor(value: string): string {
  return colorFamilies.has(value) ? `var(--neba-${value as NebaColor}-accent)` : value;
}

/**
 * What colour a mark is, in the fixed order the palette is handed out in.
 *
 * `index` is the series' place in the array it was passed in, not its place
 * among the ones currently visible. That is the whole point: filtering a legend
 * must not repaint the survivors, because a reader who learned that Europe is
 * blue has learned something that a re-render is not allowed to take back.
 *
 * Past the eighth slot it wraps, and a chart that gets there should not have —
 * a ninth hue is indistinguishable from one of the first eight under colour
 * vision deficiency no matter which one is chosen. Fold the tail into an
 * "Other" series, or draw a second chart.
 */
export function seriesColor(
  series: Pick<NebaChartSeries, 'color'> | undefined,
  index: number,
  palette: readonly string[] = chartPalette
): string {
  if (series?.color) {
    return resolveColor(series.color);
  }

  return resolveColor(palette[index % palette.length] ?? chartPalette[0]);
}

/* ---------------------------------------------------------------------------
 * Data
 * ------------------------------------------------------------------------- */

/** A datum unpacked into the shape the drawing code reads. */
export interface ChartValue {
  value: number | null;
  x?: NebaChartCategory;
  z?: number;
  color?: string;
  label?: React.ReactNode;
}

const isPoint = (datum: NebaChartDatum): datum is NebaChartPoint =>
  typeof datum === 'object' && datum !== null;

/**
 * One datum, whichever of the three ways it was written.
 *
 * `NaN` is folded into `null` here rather than at every call site: it arrives
 * from a division somewhere upstream, it means the same thing a gap means, and
 * a scale that is handed one produces a path with the letters `NaN` in it —
 * which fails silently as a blank chart rather than loudly as an error.
 */
export function toValue(datum: NebaChartDatum): ChartValue {
  if (datum === null || datum === undefined) {
    return { value: null };
  }

  if (typeof datum === 'number') {
    return { value: Number.isFinite(datum) ? datum : null };
  }

  if (!isPoint(datum)) {
    return { value: null };
  }

  return {
    value: datum.y === null || !Number.isFinite(datum.y) ? null : datum.y,
    x: datum.x,
    z: datum.z,
    color: datum.color ? resolveColor(datum.color) : undefined,
    label: datum.label
  };
}

/** Every series unpacked, in the order it was given. */
export function toValues(series: readonly NebaChartSeries[]): ChartValue[][] {
  return series.map((one) => one.data.map(toValue));
}

/** How many categories the widest series has. */
export function categoryCount(series: readonly NebaChartSeries[]): number {
  return series.reduce((most, one) => Math.max(most, one.data.length), 0);
}

/**
 * What the category axis says at position `index`.
 *
 * `categories` wins, then whatever the first series that has one calls its own
 * point, then the index. Three sources rather than one because a chart is
 * written both ways in the wild — a column of labels beside a column of
 * numbers, or points that carry their own `x` — and neither is wrong.
 */
export function categoryAt(
  index: number,
  categories: readonly NebaChartCategory[] | undefined,
  values: readonly ChartValue[][]
): NebaChartCategory {
  if (categories && index < categories.length) {
    return categories[index];
  }

  for (const one of values) {
    const found = one[index]?.x;

    if (found !== undefined) {
      return found;
    }
  }

  return index;
}

/**
 * The extent of the values, with the stacking rule applied.
 *
 * Stacked charts measure the *totals* and not the parts, and the two arms are
 * accumulated separately so a series that goes negative does not shorten the
 * bar above it. An all-`null` chart has no extent at all, which is what the
 * `null` return says — the caller draws its empty state rather than an axis
 * from `Infinity` to `-Infinity`.
 */
export function extentOf(
  values: readonly ChartValue[][],
  stacked: boolean
): { min: number; max: number } | null {
  let min = Infinity;
  let max = -Infinity;
  let seen = false;

  if (stacked) {
    const length = values.reduce((most, one) => Math.max(most, one.length), 0);

    for (let i = 0; i < length; i++) {
      let positive = 0;
      let negative = 0;

      for (const one of values) {
        const value = one[i]?.value;

        if (value === null || value === undefined) {
          continue;
        }

        seen = true;

        if (value >= 0) {
          positive += value;
        } else {
          negative += value;
        }
      }

      min = Math.min(min, negative);
      max = Math.max(max, positive);
    }
  } else {
    for (const one of values) {
      for (const { value } of one) {
        if (value === null) {
          continue;
        }

        seen = true;
        min = Math.min(min, value);
        max = Math.max(max, value);
      }
    }
  }

  return seen ? { min, max } : null;
}

/* ---------------------------------------------------------------------------
 * Ticks
 * ------------------------------------------------------------------------- */

/** 1, 2, 5, 10 — the steps a reader can do arithmetic on in their head. */
function niceStep(rough: number): number {
  const magnitude = 10 ** Math.floor(Math.log10(rough));
  const normalised = rough / magnitude;

  if (normalised <= 1) {
    return magnitude;
  }

  if (normalised <= 2) {
    return 2 * magnitude;
  }

  if (normalised <= 5) {
    return 5 * magnitude;
  }

  return 10 * magnitude;
}

/**
 * A step that lands on both ends of a range the caller pinned.
 *
 * When a scale is free to move, rounding the *ends* outward to the step is what
 * gives clean ticks. When `min` and `max` are given they cannot move, so the
 * step has to be the thing that gives — and a step that does not divide the
 * range leaves the top tick missing, which on a `min: 99.5, max: 100` axis
 * means the one number the reader came for is the one not written down.
 *
 * So the 1-2-5 family is widened by a half step (2.5, 25, 250 — the divisor
 * every quarter-scale needs) and searched for the step that divides the range
 * exactly and comes closest to the tick count asked for.
 */
function dividingStep(range: number, tickCount: number): number {
  const magnitude = 10 ** Math.floor(Math.log10(range / Math.max(1, tickCount)));
  let best = niceStep(range / Math.max(1, tickCount));
  let closest = Infinity;

  for (const scale of [0.1, 1, 10]) {
    for (const unit of [1, 2, 2.5, 5]) {
      const step = unit * scale * magnitude;
      const count = range / step;
      const whole = Math.round(count);

      // The tolerance is a floating-point guard: 0.5 / 0.1 is 4.999999999999999.
      if (whole < 1 || Math.abs(count - whole) > 1e-9) {
        continue;
      }

      const distance = Math.abs(whole - tickCount);

      if (distance < closest) {
        closest = distance;
        best = step;
      }
    }
  }

  return best;
}

/** A value scale: where it starts, where it ends, and what it ticks at. */
export interface ValueScale {
  min: number;
  max: number;
  ticks: number[];
  /** A value → a fraction of the plot, `0` at `min` and `1` at `max`. */
  fraction: (value: number) => number;
}

/**
 * The scale a value axis runs on, rounded out to clean numbers.
 *
 * Rounding *outward* is the part that matters: a maximum of 4,830 becomes 5,000
 * and not 4,830, so the top tick is a number and the tallest bar stops short of
 * the ceiling. A scale whose last bar touches the frame reads as clipped even
 * when it is exactly right.
 *
 * Zero is included unless the caller says otherwise, because bar length is only
 * proportional to value when the baseline is zero. A line chart of a quantity
 * that never approaches zero is the case for passing `min` — and it is a case
 * the caller has to make, not one the chart makes for them.
 */
export function valueScale(
  extent: { min: number; max: number } | null,
  options: {
    min?: number;
    max?: number;
    tickCount?: number;
    /** Keeps zero in range. Off for a line chart told an explicit `min`. */
    includeZero?: boolean;
  } = {}
): ValueScale {
  const { tickCount = 5, includeZero = true } = options;

  let low = options.min ?? (extent ? extent.min : 0);
  let high = options.max ?? (extent ? extent.max : 1);

  if (includeZero && options.min === undefined) {
    low = Math.min(low, 0);
  }

  if (includeZero && options.max === undefined) {
    high = Math.max(high, 0);
  }

  // A flat series — every value the same — has no extent to divide by. Open a
  // band around it rather than dividing by zero and drawing a line off the top.
  if (high === low) {
    const pad = Math.abs(high) > 0 ? Math.abs(high) * 0.5 : 1;

    low -= pad;
    high += pad;
  }

  // Both ends pinned means the *step* is what has to give; otherwise it is the
  // ends that round outward to a step chosen from the data.
  const pinned = options.min !== undefined && options.max !== undefined;
  const step = pinned
    ? dividingStep(high - low, tickCount)
    : niceStep((high - low) / Math.max(1, tickCount));

  const start = options.min !== undefined ? low : Math.floor(low / step) * step;
  const end = options.max !== undefined ? high : Math.ceil(high / step) * step;
  const span = end - start || 1;

  const ticks: number[] = [];

  // The epsilon is a floating-point guard, not a fudge: `0.1 * 3` lands at
  // 0.30000000000000004, which without it drops the last tick off every scale
  // whose step is not a power of two.
  for (let tick = start; tick <= end + step * 1e-9; tick += step) {
    // And the rounding is the other half of it — a tick printed as
    // `0.30000000000000004` is worse than a missing one.
    ticks.push(Number(tick.toFixed(12)));
  }

  return {
    min: start,
    max: end,
    ticks,
    fraction: (value) => (value - start) / span
  };
}

/**
 * How many ticks a category axis can show before the labels collide, and which
 * ones they are.
 *
 * Every nth label rather than rotating them: a rotated axis is unreadable at a
 * glance and it steals a band of the plot to be unreadable in. `n` is chosen so
 * the labels clear each other at the measured width, and it always keeps the
 * first — a reader who cannot see where the axis starts cannot read any of it.
 */
export function tickStride(count: number, available: number, labelWidth: number): number {
  if (count <= 1 || available <= 0) {
    return 1;
  }

  const fits = Math.max(1, Math.floor(available / Math.max(1, labelWidth)));

  return Math.max(1, Math.ceil(count / fits));
}

/**
 * Whether the label at `index` survives the stride.
 *
 * Every nth, and — when it fits — the last one, which is the part a plain
 * modulo gets wrong: a fourteen-day axis at a stride of two ends at day
 * thirteen, and a percentage axis ends at 80%. The end of a scale is the number
 * a reader looks for first, and dropping it to keep the arithmetic tidy is the
 * wrong trade.
 *
 * `roomForLast` is the other half of it and is measured rather than guessed —
 * see `fitsLast`. Forcing a label that does not fit turns a missing "Jun" into
 * an overlapping "MayJun", which is worse than what it fixed.
 */
export function showsTick(
  index: number,
  count: number,
  stride: number,
  roomForLast: boolean
): boolean {
  return index % stride === 0 || (roomForLast && index === count - 1);
}

/**
 * Whether the last label clears the last one the stride kept.
 *
 * The two are `(count - 1) % stride` steps apart, and they need half of each
 * label plus a little air between them — labels are centred on their tick, so
 * only the inner halves can collide.
 */
export function fitsLast(count: number, stride: number, step: number, labelWidth: number): boolean {
  const over = (count - 1) % stride;

  return over > 0 && over * step >= labelWidth + 8;
}

/**
 * Roughly how wide a string renders at a given font size.
 *
 * An estimate on purpose. The alternative is a canvas measurement per label per
 * render, which is a layout read on a path that runs on every resize — and what
 * this number is used for is deciding how much room to reserve, where being a
 * few pixels generous costs nothing and being exact costs a reflow.
 *
 * 0.6em is the average advance of a digit in the sans-serifs a UI runs in;
 * anything CJK is close to a full em, so the widest character decides.
 */
export function textWidth(text: string, fontSize: number): number {
  let width = 0;

  for (const character of text) {
    width += /[ᄀ-ᇿ⺀-꓏가-퟿豈-﫿︰-﹏]/.test(character) ? 1 : 0.6;
  }

  return width * fontSize;
}

/**
 * A label cut to the room it has, with an ellipsis.
 *
 * The alternative when a category name is wider than its slot is to drop
 * labels until the survivors fit, and on five categories called things like
 * "Onboarding flow" that leaves exactly one of them on the axis — an axis with
 * one label is not a shorter axis, it is an unlabelled one. Cut instead: the
 * first few characters distinguish five words, and the tooltip and the table
 * both still have the whole thing.
 */
export function truncate(text: string, maxWidth: number, fontSize: number): string {
  if (maxWidth <= 0 || textWidth(text, fontSize) <= maxWidth) {
    return text;
  }

  const room = maxWidth - textWidth('…', fontSize);
  let cut = '';

  for (const character of text) {
    if (textWidth(cut + character, fontSize) > room) {
      break;
    }

    cut += character;
  }

  return cut.length > 0 ? `${cut.trimEnd()}…` : '…';
}

/* ---------------------------------------------------------------------------
 * Geometry
 * ------------------------------------------------------------------------- */

/** The plot's box inside the chart, once the axes have taken their bands. */
export interface PlotBox {
  left: number;
  top: number;
  width: number;
  height: number;
}

/** A band scale: one slot per category, with the marks centred in it. */
export interface BandScale {
  /** The centre of category `index`, in pixels along the axis. */
  centre: (index: number) => number;
  /** How wide one slot is. */
  step: number;
  /** How wide the marks in a slot are allowed to be, together. */
  band: number;
}

export function bandScale(count: number, length: number, ratio: number): BandScale {
  const step = count > 0 ? length / count : length;

  return {
    step,
    band: step * ratio,
    centre: (index) => step * (index + 0.5)
  };
}

/**
 * A path through the points, in whichever of the three shapes was asked for.
 *
 * `null` breaks the path rather than interpolating across it — the `M` that
 * starts a new subpath is the gap. A line that bridges a missing month is a
 * line that invents a number.
 *
 * `smooth` is a monotone cubic and not a Catmull-Rom, which is not a detail: a
 * plain spline overshoots between two close points, so a series that never goes
 * below zero draws a curve that does. A chart is allowed to be curved and it is
 * not allowed to show a value that is not in the data.
 */
export function linePath(
  points: readonly ({ x: number; y: number } | null)[],
  curve: 'linear' | 'smooth' | 'step'
): string {
  const path: string[] = [];
  let run: { x: number; y: number }[] = [];

  const flush = () => {
    if (run.length === 0) {
      return;
    }

    if (run.length === 1) {
      // A lone point between two gaps has no line to be part of. Draw it as a
      // zero-length stroke, which a round cap renders as the dot it is.
      path.push(`M${run[0].x} ${run[0].y}h0`);
    } else if (curve === 'step') {
      path.push(`M${run[0].x} ${run[0].y}`);

      for (let i = 1; i < run.length; i++) {
        const middle = (run[i - 1].x + run[i].x) / 2;

        path.push(`H${middle}V${run[i].y}H${run[i].x}`);
      }
    } else if (curve === 'smooth') {
      path.push(`M${run[0].x} ${run[0].y}`);
      path.push(monotonePath(run));
    } else {
      path.push(`M${run[0].x} ${run[0].y}`);

      for (let i = 1; i < run.length; i++) {
        path.push(`L${run[i].x} ${run[i].y}`);
      }
    }

    run = [];
  };

  for (const point of points) {
    if (point === null) {
      flush();
    } else {
      run.push(point);
    }
  }

  flush();

  return path.join('');
}

/**
 * The cubic segments of a monotone interpolation.
 *
 * Fritsch–Carlson: the tangent at each point is a harmonic mean of the slopes
 * either side of it, clamped to zero wherever they disagree in sign. That
 * clamp is what makes the curve monotone — it is why a run of increasing values
 * never dips on its way up, and why a minimum in the data is the minimum on
 * screen.
 */
function monotonePath(points: readonly { x: number; y: number }[]): string {
  const n = points.length;
  const slopes: number[] = [];

  for (let i = 0; i < n - 1; i++) {
    const dx = points[i + 1].x - points[i].x;

    slopes.push(dx === 0 ? 0 : (points[i + 1].y - points[i].y) / dx);
  }

  const tangents: number[] = [slopes[0] ?? 0];

  for (let i = 1; i < n - 1; i++) {
    const before = slopes[i - 1];
    const after = slopes[i];

    tangents.push(before * after <= 0 ? 0 : (2 * before * after) / (before + after));
  }

  tangents.push(slopes[n - 2] ?? 0);

  const segments: string[] = [];

  for (let i = 0; i < n - 1; i++) {
    const dx = (points[i + 1].x - points[i].x) / 3;

    segments.push(
      `C${points[i].x + dx} ${points[i].y + tangents[i] * dx}` +
        ` ${points[i + 1].x - dx} ${points[i + 1].y - tangents[i + 1] * dx}` +
        ` ${points[i + 1].x} ${points[i + 1].y}`
    );
  }

  return segments.join('');
}

/**
 * The same path closed down to a baseline, for an area.
 *
 * Built from the runs rather than from the whole line so a gap is a gap in the
 * fill too — an area that closes across a missing month fills in a value that
 * was never measured, which is the same lie the bridged line tells, painted
 * over a larger part of the chart.
 */
export function areaPath(
  points: readonly ({ x: number; y: number } | null)[],
  baseline: readonly ({ x: number; y: number } | null)[] | number,
  curve: 'linear' | 'smooth' | 'step'
): string {
  const path: string[] = [];
  let start = 0;

  const flush = (end: number) => {
    const run = points.slice(start, end).filter(Boolean) as { x: number; y: number }[];

    if (run.length === 0) {
      return;
    }

    const under =
      typeof baseline === 'number'
        ? run.map((point) => ({ x: point.x, y: baseline })).reverse()
        : (baseline.slice(start, end).filter(Boolean) as { x: number; y: number }[]).reverse();

    if (under.length === 0) {
      return;
    }

    const top = linePath(run, curve);
    // The underside runs back the other way, and it has to be drawn with the
    // same curve or a smoothed area and its own baseline disagree about where
    // the band is between two points. Only its opening `M` changes to an `L`:
    // a second `moveto` inside the path would lift the pen and leave the fill
    // with no side.
    const bottom = linePath(under, curve).replace(/^M/, 'L');

    path.push(`${top}${bottom}Z`);
  };

  for (let i = 0; i < points.length; i++) {
    if (points[i] === null) {
      flush(i);
      start = i + 1;
    }
  }

  flush(points.length);

  return path.join('');
}

/**
 * A rectangle with the two corners at its *data end* cut off.
 *
 * Rounded at the end and square at the baseline, which is not a stylistic
 * split: a bar that is rounded where it meets the axis has lost the exact
 * moment it starts, and a row of them turns the baseline into a scalloped edge.
 * The end is where the value is, and that is the end worth softening.
 *
 * The radius shrinks to fit rather than clipping, so a bar two pixels tall is a
 * bar and not a circle. `end` is which way the value grows.
 */
export function barPath(
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number,
  end: 'up' | 'down' | 'left' | 'right'
): string {
  const r = Math.max(0, Math.min(radius, width / 2, height / 2));

  if (r === 0 || width <= 0 || height <= 0) {
    return `M${x} ${y}h${width}v${height}h${-width}Z`;
  }

  // Every path below is drawn clockwise on screen, which is what makes the
  // sweep flag `1` on all four corners. Reversing one and leaving the flag is
  // how a rounded corner comes out as a bite taken from the bar.
  const arc = (dx: number, dy: number) => `a${r} ${r} 0 0 1 ${dx} ${dy}`;

  if (end === 'up') {
    return `M${x} ${y + height}V${y + r}${arc(r, -r)}H${x + width - r}${arc(r, r)}V${y + height}Z`;
  }

  if (end === 'down') {
    return `M${x} ${y}H${x + width}V${y + height - r}${arc(-r, r)}H${x + r}${arc(-r, -r)}Z`;
  }

  if (end === 'right') {
    return `M${x} ${y}H${x + width - r}${arc(r, r)}V${y + height - r}${arc(-r, r)}H${x}Z`;
  }

  return `M${x + width} ${y + height}H${x + r}${arc(-r, -r)}V${y + r}${arc(r, -r)}H${x + width}Z`;
}

/**
 * A slice of a ring, as a path.
 *
 * `inner` of 0 is a pie and anything above it is a donut. Angles are degrees
 * clockwise from twelve o'clock, which is where a reader starts reading a
 * circle — SVG's own zero is at three o'clock, and the offset is applied here
 * once rather than at four call sites.
 */
export function arcPath(
  cx: number,
  cy: number,
  outer: number,
  inner: number,
  from: number,
  to: number
): string {
  const point = (radius: number, degrees: number) => {
    const radians = ((degrees - 90) * Math.PI) / 180;

    return `${cx + radius * Math.cos(radians)} ${cy + radius * Math.sin(radians)}`;
  };

  const sweep = Math.abs(to - from) >= 360;

  // A full circle cannot be one arc — start and end are the same point, and the
  // renderer draws nothing at all. Two half-arcs are the standard answer.
  if (sweep) {
    const half = from + 180;

    return inner > 0
      ? `M${point(outer, from)}A${outer} ${outer} 0 1 1 ${point(outer, half)}` +
          `A${outer} ${outer} 0 1 1 ${point(outer, from)}Z` +
          `M${point(inner, from)}A${inner} ${inner} 0 1 0 ${point(inner, half)}` +
          `A${inner} ${inner} 0 1 0 ${point(inner, from)}Z`
      : `M${point(outer, from)}A${outer} ${outer} 0 1 1 ${point(outer, half)}` +
          `A${outer} ${outer} 0 1 1 ${point(outer, from)}Z`;
  }

  const large = Math.abs(to - from) > 180 ? 1 : 0;

  if (inner <= 0) {
    return `M${cx} ${cy}L${point(outer, from)}A${outer} ${outer} 0 ${large} 1 ${point(outer, to)}Z`;
  }

  return (
    `M${point(outer, from)}A${outer} ${outer} 0 ${large} 1 ${point(outer, to)}` +
    `L${point(inner, to)}A${inner} ${inner} 0 ${large} 0 ${point(inner, from)}Z`
  );
}

/* ---------------------------------------------------------------------------
 * Formatting
 * ------------------------------------------------------------------------- */

/**
 * How a category is written when nobody said.
 *
 * A `Date` gets the reader's own short form, because the alternative is an ISO
 * string across the bottom of every time series. Everything else is `String`,
 * which is what the caller wrote it as.
 */
export function formatCategory(value: NebaChartCategory, locale?: string): string {
  if (value instanceof Date) {
    return new Intl.DateTimeFormat(locale, { month: 'short', day: 'numeric' }).format(value);
  }

  return String(value);
}

/**
 * A number, compactly enough that a y-axis of thousands is not four labels of
 * seven characters.
 *
 * Only when the caller passed no `format` of their own — the moment they do,
 * they have said what the number means and the library's opinion about
 * thousands separators stops being welcome.
 */
export function compactNumber(value: number, locale?: string): string {
  const magnitude = Math.abs(value);

  if (magnitude >= 10000) {
    return new Intl.NumberFormat(locale, {
      notation: 'compact',
      maximumFractionDigits: 1
    }).format(value);
  }

  return new Intl.NumberFormat(locale, { maximumFractionDigits: 2 }).format(value);
}
