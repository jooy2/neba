/**
 * Everything a chart draws that is not its marks.
 *
 * The split this file makes is the one the whole `internal/` folder is about:
 * a LineChart, an AreaChart and a BarChart differ in about forty lines each —
 * a path, a band, a rounded end — and agree on everything else. The axes, the
 * grid, the legend, the crosshair, the tooltip, the empty state, the hidden
 * table a screen reader reads instead of the picture, and the measurement that
 * turns a percentage width into the pixels an SVG needs are all the same
 * problem five times over.
 *
 * So `CartesianChart` is the chart, and a component hands it a function that
 * draws the marks. What is left in `LineChart.tsx` is the line.
 *
 * `chart.ts` is the arithmetic under this; nothing in there knows what an
 * element is, and nothing in here does arithmetic that is not layout.
 */

import * as React from 'react';
import { Box, type BoxProps } from '../components/box/Box';
import {
  bandScale,
  categoryAt,
  categoryCount,
  chartFontSizes,
  compactNumber,
  extentOf,
  fitsLast,
  formatCategory,
  markerRadii,
  plotHeights,
  seriesColor,
  showsTick,
  textWidth,
  tickStride,
  toValues,
  truncate,
  valueScale,
  type BandScale,
  type ChartValue,
  type PlotBox,
  type ValueScale
} from './chart';
import { useMessages } from './i18n';
import { cx, metaTextClasses, srOnlyClasses, transitionClasses } from './styles';
import type {
  NebaChartAxis,
  NebaChartCategory,
  NebaChartLegend,
  NebaChartSeries,
  NebaChartTooltip,
  NebaSize
} from '../types';

/* ---------------------------------------------------------------------------
 * Measurement
 * ------------------------------------------------------------------------- */

/** A layout read where there is a layout, and a no-op where there is not. */
const useMeasureEffect = typeof document === 'undefined' ? React.useEffect : React.useLayoutEffect;

/**
 * How wide the chart actually is, in pixels.
 *
 * An SVG cannot lay a chart out from a percentage: every tick position, every
 * bar width and the decision about how many category labels fit are arithmetic
 * on a number, and `100%` is not one. So the host element is measured and the
 * drawing waits for the answer.
 *
 * The wait is one frame and not one paint — `useLayoutEffect` runs before the
 * browser draws, so the empty state never reaches the screen. What does reach
 * it on a server-rendered page is a box of the right height with nothing in it,
 * which is why the height is a prop and not something measured too: a reserve
 * that is dropped when the content arrives is the same jump twice.
 */
function useMeasuredWidth(ref: React.RefObject<HTMLElement | null>): number {
  const [width, setWidth] = React.useState(0);

  useMeasureEffect(() => {
    const host = ref.current;

    if (!host) {
      return;
    }

    const measure = () => setWidth(host.clientWidth);

    measure();

    if (typeof ResizeObserver === 'undefined') {
      return;
    }

    const observer = new ResizeObserver(measure);

    observer.observe(host);

    return () => observer.disconnect();
  }, [ref]);

  return width;
}

/* ---------------------------------------------------------------------------
 * Shared props
 * ------------------------------------------------------------------------- */

/**
 * What every chart takes, and the reason it is one interface: a dashboard is
 * built by copying a tile and changing the component in it, and that only works
 * if `height`, `legend`, `tooltip` and `format` mean the same thing on all of
 * them.
 *
 * `variant` defaults to `text` and `padded` to `false`, which is the one place
 * a chart deviates from Box. A chart is a *drawing*, not a sheet — it goes on a
 * Card, next to the number it explains, and a sheet of its own inside that Card
 * would be two edges where the design language wants one. `variant="outline"`
 * is there for the chart that stands on the page by itself.
 */
export interface ChartBaseProps extends Omit<BoxProps, 'children' | 'title'> {
  /**
   * How tall the drawing is. A number is pixels; a string is any CSS length.
   * Defaults to the `size` ladder.
   *
   * The axis labels are drawn *inside* this, not under it, so a card sized to
   * the chart is a card the chart fits in.
   */
  height?: number | string;
  /**
   * How the numbers are written, everywhere they appear — the axis, the
   * tooltip, the labels on the marks. `Intl.NumberFormat` options, the same
   * prop Statistic and the progress indicators take.
   *
   * Without it an axis tick is compacted past ten thousand (`12.4K`), because
   * four labels of seven digits is a chart with a column of numbers beside it.
   */
  format?: Intl.NumberFormatOptions;
  /** Which language the chart's own words and dates are in. @default the reader's */
  locale?: string;
  /**
   * The chart's accessible name — what it is a chart *of*. Read out in place of
   * the drawing, and used as the caption of the table underneath it.
   */
  label?: string;
  /**
   * The legend. Shown automatically from two series up and left off below that,
   * because a legend with one swatch in it restates the title.
   *
   * `false` turns it off; an object places it and says whether it does anything
   * when clicked.
   */
  legend?: boolean | NebaChartLegend;
  /**
   * What the pointer uncovers. On by default — a chart drawn in a browser is
   * interactive, and a reader who wants the number for March should not have to
   * measure it against a gridline.
   *
   * It never carries a value that is not readable another way: the table under
   * every chart has all of them.
   */
  tooltip?: boolean | NebaChartTooltip;
  /** What to draw when there is nothing to draw. */
  empty?: React.ReactNode;
}

/** The props a chart with two axes adds. */
export interface CartesianChartProps extends ChartBaseProps {
  /** The series, in the order their colours are handed out. */
  series: readonly NebaChartSeries[];
  /** The category axis' labels. Points may carry their own `x` instead. */
  categories?: readonly NebaChartCategory[];
  /** The category axis. */
  xAxis?: NebaChartAxis;
  /** The value axis. */
  yAxis?: NebaChartAxis;
}

/* ---------------------------------------------------------------------------
 * Visibility
 * ------------------------------------------------------------------------- */

interface Visibility {
  visible: boolean[];
  hovered: number | null;
  toggle: (index: number) => void;
  setHovered: (index: number | null) => void;
}

/**
 * Which series are drawn, and which one the pointer is resting on in the legend.
 *
 * Keyed by index into the array as it was passed, which is what keeps a hidden
 * series from renumbering the ones after it. The colours come off the same
 * index, so hiding Europe leaves Asia exactly the colour it was.
 */
function useVisibility(series: readonly NebaChartSeries[]): Visibility {
  const [hidden, setHidden] = React.useState<ReadonlySet<number>>(() => {
    const initial = new Set<number>();

    series.forEach((one, index) => {
      if (one.hidden) {
        initial.add(index);
      }
    });

    return initial;
  });

  const [hovered, setHovered] = React.useState<number | null>(null);

  const toggle = React.useCallback((index: number) => {
    setHidden((current) => {
      const next = new Set(current);

      if (next.has(index)) {
        next.delete(index);
      } else {
        next.add(index);
      }

      return next;
    });
  }, []);

  return {
    visible: series.map((_, index) => !hidden.has(index)),
    hovered,
    toggle,
    setHovered
  };
}

/* ---------------------------------------------------------------------------
 * Legend
 * ------------------------------------------------------------------------- */

const legendSideClasses = {
  top: 'flex-col-reverse',
  bottom: 'flex-col',
  left: 'flex-row-reverse',
  right: 'flex-row'
} as const;

const legendAlignClasses = {
  start: 'justify-start',
  center: 'justify-center',
  end: 'justify-end'
} as const;

interface LegendProps {
  series: readonly NebaChartSeries[];
  colors: readonly string[];
  options: NebaChartLegend;
  visibility: Visibility;
  size: NebaSize;
  values?: readonly (string | undefined)[];
}

/**
 * The dependable identity channel.
 *
 * A swatch and a word, and the swatch is the only thing on it wearing the
 * series colour — the name is ink, at whatever the size ladder says, because a
 * light hue is illegible as text and because colour is what the swatch beside
 * it is for.
 *
 * A hidden series stays in the legend and goes grey rather than disappearing:
 * a list that shortens when you click it is a list you cannot click twice.
 */
function ChartLegendBar({ series, colors, options, visibility, size, values }: LegendProps) {
  const interactive = options.interactive !== false;
  const vertical = options.side === 'left' || options.side === 'right';

  return (
    <ul
      className={cx(
        'flex list-none flex-wrap items-center gap-x-3 gap-y-1 p-0',
        vertical ? 'min-w-0 flex-col items-start' : '',
        legendAlignClasses[options.align ?? 'center'],
        metaTextClasses[size]
      )}
    >
      {series.map((one, index) => {
        const shown = visibility.visible[index];
        const dimmed = visibility.hovered !== null && visibility.hovered !== index;
        const name = one.name ?? `${index + 1}`;

        const content = (
          <>
            <span
              aria-hidden="true"
              className="size-2.5 shrink-0 rounded-[0.1875rem]"
              style={{ backgroundColor: shown ? colors[index] : 'var(--neba-disabled-fg)' }}
            />
            <span className="min-w-0 truncate">{name}</span>
            {values?.[index] ? (
              <span className="shrink-0 tabular-nums text-(--neba-muted-fg)">{values[index]}</span>
            ) : null}
          </>
        );

        return (
          <li key={one.name ?? index} className="min-w-0">
            {interactive ? (
              <button
                type="button"
                aria-pressed={shown}
                onClick={() => visibility.toggle(index)}
                onPointerEnter={() => visibility.setHovered(index)}
                onPointerLeave={() => visibility.setHovered(null)}
                onFocus={() => visibility.setHovered(index)}
                onBlur={() => visibility.setHovered(null)}
                className={cx(
                  'flex min-w-0 cursor-pointer items-center gap-1.5 rounded-(--neba-radius-xs)',
                  'px-1 py-0.5 text-(--neba-fg)',
                  transitionClasses,
                  'hover:bg-(--n-soft)',
                  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
                  shown ? '' : 'text-(--neba-disabled-fg)',
                  dimmed ? 'opacity-55' : ''
                )}
              >
                {content}
              </button>
            ) : (
              <span
                className={cx(
                  'flex min-w-0 items-center gap-1.5 px-1 py-0.5 text-(--neba-fg)',
                  shown ? '' : 'text-(--neba-disabled-fg)'
                )}
              >
                {content}
              </span>
            )}
          </li>
        );
      })}
    </ul>
  );
}

/* ---------------------------------------------------------------------------
 * Tooltip
 * ------------------------------------------------------------------------- */

/** One row of a tooltip: a series, and what it says at the active category. */
export interface ChartTooltipItem {
  seriesIndex: number;
  name?: string;
  color: string;
  value: number | null;
  formatted: string;
  label?: React.ReactNode;
}

interface TooltipProps {
  heading: React.ReactNode;
  items: readonly ChartTooltipItem[];
  /** Where along the plot the anchor sits, in pixels from the chart's left. */
  x: number;
  /** And how far down. */
  y: number;
  /** Which half of the chart the anchor is in — the tooltip opens the other way. */
  flip: boolean;
  size: NebaSize;
}

/**
 * The panel under the pointer.
 *
 * Anchored by its near edge rather than centred with a translate: the design
 * language spends no `transform` on anything, and anchoring left-or-right by
 * which half of the plot the pointer is in is also the only placement that
 * cannot run off the side of a narrow card.
 *
 * It is `pointer-events-none` because it is a readout, not a surface — a panel
 * that the pointer can enter is a panel that steals the hover that produced it
 * and then flickers.
 */
function ChartTooltipPanel({ heading, items, x, y, flip, size }: TooltipProps) {
  return (
    <div
      role="status"
      aria-live="polite"
      className={cx(
        'pointer-events-none absolute z-10 max-w-56 min-w-24',
        'rounded-(--neba-radius-sm) border p-2',
        '[background-image:var(--neba-grain),var(--neba-sheen)]',
        '[background-blend-mode:overlay,normal] [backdrop-filter:var(--neba-blur)]',
        'bg-(--neba-panel-press) [border-color:var(--n-line)]',
        '[box-shadow:var(--neba-shadow-2),var(--neba-plate-glass)]',
        metaTextClasses[size]
      )}
      style={flip ? { right: `calc(100% - ${x}px + 10px)`, top: y } : { left: x + 10, top: y }}
    >
      <div className="mb-1 font-medium text-(--neba-fg)">{heading}</div>
      <ul className="flex list-none flex-col gap-0.5 p-0">
        {items.map((item) => (
          <li key={item.seriesIndex} className="flex items-center gap-1.5">
            <span
              aria-hidden="true"
              className="size-2 shrink-0 rounded-[0.125rem]"
              style={{ backgroundColor: item.color }}
            />
            {item.name ? (
              <span className="min-w-0 flex-1 truncate text-(--neba-muted-fg)">{item.name}</span>
            ) : null}
            <span className="ms-auto shrink-0 font-medium tabular-nums text-(--neba-fg)">
              {item.label ?? item.formatted}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

/* ---------------------------------------------------------------------------
 * The table under every chart
 * ------------------------------------------------------------------------- */

interface DataTableProps {
  id: string;
  caption?: string;
  corner?: React.ReactNode;
  categories: readonly NebaChartCategory[];
  series: readonly NebaChartSeries[];
  values: readonly ChartValue[][];
  format: (value: number) => string;
  locale?: string;
}

/**
 * The chart, as a table, for the readers a drawing does not reach.
 *
 * Not an option and not a toggle. A tooltip that is the only way to a number
 * gates that number behind a pointer, and an SVG with an `aria-label` on it
 * says "revenue by month" and then says nothing else at all. This is the same
 * data in the one form every assistive technology already reads, so the picture
 * is free to be a picture.
 *
 * It is clipped rather than `display: none`, for the reason `srOnlyClasses`
 * gives: the second one takes it off the accessibility tree along with the
 * screen, which would leave the chart exactly as mute as before.
 */
function ChartDataTable({
  id,
  caption,
  corner,
  categories,
  series,
  values,
  format,
  locale
}: DataTableProps) {
  return (
    <table id={id} className={srOnlyClasses}>
      {caption ? <caption>{caption}</caption> : null}
      <thead>
        <tr>
          <th scope="col">{corner ?? ''}</th>
          {series.map((one, index) => (
            <th key={one.name ?? index} scope="col">
              {one.name ?? index + 1}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {categories.map((category, index) => (
          <tr key={index}>
            <th scope="row">{formatCategory(category, locale)}</th>
            {series.map((one, seriesIndex) => {
              const datum = values[seriesIndex]?.[index];

              // A point's own `label` wins, exactly as it does in the tooltip.
              // That is what keeps the caller's number reachable on a chart
              // stacked to `full`, where the value being *drawn* is a share.
              if (datum?.label !== undefined) {
                return <td key={one.name ?? seriesIndex}>{datum.label}</td>;
              }

              return (
                <td key={one.name ?? seriesIndex}>
                  {datum?.value === null || datum?.value === undefined ? '' : format(datum.value)}
                </td>
              );
            })}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

/* ---------------------------------------------------------------------------
 * The surface every chart sits on
 * ------------------------------------------------------------------------- */

interface SurfaceProps extends Omit<BoxProps, 'children'> {
  legend: React.ReactNode;
  legendSide: NonNullable<NebaChartLegend['side']>;
  children: React.ReactNode;
  table: React.ReactNode;
}

/** Box, with the legend on one of its four sides and the table underneath. */
function ChartSurface({ legend, legendSide, children, table, className, ...box }: SurfaceProps) {
  return (
    <Box
      {...box}
      className={cx('relative flex gap-3', legendSideClasses[legendSide], className ?? undefined)}
    >
      <div className="relative min-w-0 flex-1">{children}</div>
      {legend}
      {table}
    </Box>
  );
}

/* ---------------------------------------------------------------------------
 * Cartesian charts
 * ------------------------------------------------------------------------- */

/** Everything a mark needs to know about where it goes. */
export interface CartesianContext {
  plot: PlotBox;
  /** Every series unpacked, in the order it was passed. */
  values: readonly ChartValue[][];
  /** Which of them are drawn. */
  visible: readonly boolean[];
  /** And what colour each one is, by its original index. */
  colors: readonly string[];
  /** The series the legend is being hovered over, if any. */
  hovered: number | null;
  /** The category under the pointer, if any. */
  activeIndex: number | null;
  scale: ValueScale;
  band: BandScale;
  /** Bars run along the category axis rather than across it. */
  horizontal: boolean;
  /** Where a value sits along the value axis, in pixels from the chart's edge. */
  valuePx: (value: number) => number;
  /** Where a category's centre sits along the category axis. */
  categoryPx: (index: number) => number;
  /** The two combined, whichever way round the chart runs. */
  point: (index: number, value: number) => { x: number; y: number };
  /** Where the baseline is along the value axis. */
  zeroPx: number;
  categories: readonly NebaChartCategory[];
  format: (value: number) => string;
  size: NebaSize;
}

interface CartesianProps extends CartesianChartProps {
  /** Bars, and only bars, run the other way. */
  horizontal?: boolean;
  /** The value axis measures totals rather than parts. */
  stacked?: boolean;
  /** A line chart is free to leave zero out; a bar chart is not. */
  includeZero?: boolean;
  /** How much of a band the marks take — bars need room reserved, lines do not. */
  bandRatio?: number;
  /**
   * Lines and areas sit *on* the category ticks; bars sit *between* them. The
   * difference is one half-step, and getting it wrong is what makes a line
   * chart's first point float a centimetre off the axis.
   */
  inset?: boolean;
  /** Extra room at the top of the plot, for value labels that ride the marks. */
  headroom?: number;
  /** Draws the marks. */
  children: (context: CartesianContext) => React.ReactNode;
}

/**
 * The frame: two axes, a grid, a crosshair, a legend, a tooltip and the table.
 *
 * Everything here is one of two things — a measurement, or a piece of chrome
 * that is identical on a line chart and a bar chart. The marks are the `children`
 * function's business, and they are handed pixels rather than values so a
 * component never has to know which way round the axes are.
 */
export function CartesianChart({
  series,
  categories,
  xAxis,
  yAxis,
  horizontal = false,
  stacked = false,
  includeZero = true,
  bandRatio = 1,
  inset = false,
  headroom = 0,
  height,
  format,
  locale,
  label,
  legend,
  tooltip,
  empty,
  size = 'md',
  variant = 'text',
  padded = false,
  className,
  children,
  ...box
}: CartesianProps) {
  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const messages = useMessages(locale);
  const tableId = React.useId();

  const visibility = useVisibility(series);
  const [activeIndex, setActiveIndex] = React.useState<number | null>(null);
  /** Where the pointer is along the value axis. `null` when it arrived by key. */
  const [pointer, setPointer] = React.useState<number | null>(null);

  const numberFormat = React.useMemo(
    () => (format ? new Intl.NumberFormat(locale, format) : null),
    [format, locale]
  );
  const formatValue = React.useCallback(
    (value: number) => (numberFormat ? numberFormat.format(value) : compactNumber(value, locale)),
    [numberFormat, locale]
  );

  const values = React.useMemo(() => toValues(series), [series]);
  const colors = React.useMemo(() => series.map((one, index) => seriesColor(one, index)), [series]);

  const count = categoryCount(series);
  const labels = React.useMemo(
    () => Array.from({ length: count }, (_, index) => categoryAt(index, categories, values)),
    [count, categories, values]
  );

  const shownValues = values.filter((_, index) => visibility.visible[index]);
  const extent = extentOf(shownValues, stacked);

  const plotHeight =
    typeof height === 'number' ? height : height === undefined ? plotHeights[size] : null;

  const fontSize = chartFontSizes[size];

  /* The scales. The value axis is rounded to clean numbers before anything is
     measured, because how much room the axis needs depends on how wide its
     widest tick prints — which is not knowable until the ticks exist. */
  const scale = valueScale(extent, {
    min: yAxis?.min,
    max: yAxis?.max,
    tickCount: yAxis?.tickCount,
    includeZero
  });

  const valueAxis = horizontal ? xAxis : yAxis;
  const categoryAxis = horizontal ? yAxis : xAxis;

  const tickTexts = scale.ticks.map((tick, index) =>
    valueAxis?.tickFormat ? String(valueAxis.tickFormat(tick, index)) : formatValue(tick)
  );
  const rawCategoryTexts = labels.map((category, index) =>
    categoryAxis?.tickFormat
      ? String(categoryAxis.tickFormat(category, index))
      : formatCategory(category, locale)
  );

  const widestTick = tickTexts.reduce((most, text) => Math.max(most, textWidth(text, fontSize)), 0);
  const axisLabelBand = fontSize + 6;

  /* How much room one category label has, before anything is laid out.
     A horizontal chart gives each label a row of its own on the left, so the
     limit is a column width; a vertical one gives it a slot along the bottom,
     so the limit is the slot. */
  const valueBand = valueAxis?.hidden
    ? 0
    : widestTick + 10 + (valueAxis?.label ? axisLabelBand : 0);
  const slot = (width - (horizontal ? 0 : valueBand) - 16) / Math.max(1, count);

  /* Cut a long name to its slot rather than dropping labels until the rest fit —
     five categories called "Onboarding flow" would otherwise leave one label on
     the axis. Below about four characters that stops helping, and the stride in
     `ChartAxes` takes over instead. */
  const categoryTexts =
    horizontal || slot - 6 >= fontSize * 2.4
      ? rawCategoryTexts.map((text) => truncate(text, horizontal ? 150 : slot - 6, fontSize))
      : rawCategoryTexts;

  const widestCategory = categoryTexts.reduce(
    (most, text) => Math.max(most, textWidth(text, fontSize)),
    0
  );

  /* The two bands the axes take out of the box. `hidden` gives the room back to
     the plot, which is the whole reason a sparkline-shaped chart is the same
     component with both axes off rather than a different one. */
  const leftBand = horizontal
    ? categoryAxis?.hidden
      ? 0
      : widestCategory + 10 + (categoryAxis?.label ? axisLabelBand : 0)
    : valueBand;

  const bottomBand = horizontal
    ? valueAxis?.hidden
      ? 0
      : fontSize + 12 + (valueAxis?.label ? axisLabelBand : 0)
    : categoryAxis?.hidden
      ? 0
      : fontSize + 12 + (categoryAxis?.label ? axisLabelBand : 0);

  // `thickness` belongs to whichever axis is actually on that edge, which swaps
  // with `horizontal` — read off the wrong one, a bar chart turned on its side
  // would take its left margin from the axis along the bottom.
  const left = (horizontal ? categoryAxis : valueAxis)?.thickness ?? leftBand;
  const bottom = (horizontal ? valueAxis : categoryAxis)?.thickness ?? bottomBand;

  // The last category's label is centred on the last tick, so half of it hangs
  // past the plot. Reserving that half is what stops a chart clipping the one
  // label a reader looks for first.
  const rightPad = horizontal ? 12 : Math.max(8, categoryTexts.length ? widestCategory / 2 : 8);
  const topPad = markerRadii[size] + 4 + headroom;

  const boxHeight = plotHeight ?? 0;
  const plot: PlotBox = {
    left,
    top: topPad,
    width: Math.max(0, width - left - rightPad),
    height: Math.max(0, boxHeight - topPad - bottom)
  };

  const categoryLength = horizontal ? plot.height : plot.width;
  // Bars divide the axis into `count` slots and sit in the middle of one; lines
  // divide it into `count - 1` gaps and sit on the joins. Both need a `step`,
  // because the hit target for a category is one step wide either way.
  const band = bandScale(inset ? Math.max(1, count - 1) : count, categoryLength, bandRatio);

  /* A line's first point sits *on* the axis and a bar's first band starts at
     it, which is one half-step apart. `inset` is which of the two this is. */
  const categoryPx = React.useCallback(
    (index: number) =>
      inset
        ? count <= 1
          ? categoryLength / 2
          : (categoryLength * index) / (count - 1)
        : band.centre(index),
    [inset, count, categoryLength, band]
  );

  const valuePx = React.useCallback(
    (value: number) =>
      horizontal
        ? plot.left + scale.fraction(value) * plot.width
        : plot.top + (1 - scale.fraction(value)) * plot.height,
    [horizontal, plot.left, plot.top, plot.width, plot.height, scale]
  );

  const point = React.useCallback(
    (index: number, value: number) =>
      horizontal
        ? { x: valuePx(value), y: plot.top + categoryPx(index) }
        : { x: plot.left + categoryPx(index), y: valuePx(value) },
    [horizontal, valuePx, categoryPx, plot.left, plot.top]
  );

  const zeroPx = valuePx(Math.min(Math.max(0, scale.min), scale.max));

  /* Hover. The nearest category to the pointer rather than the one it is
     literally over: a two-pixel line is not something a pointer can be asked to
     land on, and the hit area for a category is its whole column. */
  const tooltipOptions: NebaChartTooltip =
    tooltip === false ? { mode: 'none' } : tooltip === true || tooltip === undefined ? {} : tooltip;
  const tooltipMode = tooltipOptions.mode ?? 'index';

  const indexAt = (clientX: number, clientY: number) => {
    const host = hostRef.current;

    if (!host || count === 0) {
      return null;
    }

    const rect = host.getBoundingClientRect();
    const along = horizontal ? clientY - rect.top - plot.top : clientX - rect.left - plot.left;

    if (along < -band.step || along > categoryLength + band.step) {
      return null;
    }

    const raw = inset
      ? count <= 1
        ? 0
        : Math.round((along / categoryLength) * (count - 1))
      : Math.floor(along / band.step);

    return Math.min(count - 1, Math.max(0, raw));
  };

  /** Where the pointer sits along the *value* axis — `item` mode's other half. */
  const valueAt = (clientX: number, clientY: number) => {
    const host = hostRef.current;

    if (!host) {
      return null;
    }

    const rect = host.getBoundingClientRect();

    return horizontal ? clientX - rect.left : clientY - rect.top;
  };

  const step = (delta: number) => {
    setPointer(null);
    setActiveIndex((current) => {
      const next = (current ?? (delta > 0 ? -1 : count)) + delta;

      return Math.min(count - 1, Math.max(0, next));
    });
  };

  const onKeyDown = (event: React.KeyboardEvent) => {
    const forward = horizontal ? 'ArrowDown' : 'ArrowRight';
    const back = horizontal ? 'ArrowUp' : 'ArrowLeft';

    if (event.key === forward) {
      step(1);
    } else if (event.key === back) {
      step(-1);
    } else if (event.key === 'Home') {
      setActiveIndex(0);
    } else if (event.key === 'End') {
      setActiveIndex(count - 1);
    } else if (event.key === 'Escape') {
      setActiveIndex(null);
    } else {
      return;
    }

    event.preventDefault();
  };

  const column: ChartTooltipItem[] =
    activeIndex === null
      ? []
      : series.flatMap((one, index) => {
          if (!visibility.visible[index]) {
            return [];
          }

          const value = values[index]?.[activeIndex];

          if (!value || value.value === null) {
            return [];
          }

          return [
            {
              seriesIndex: index,
              name: one.name,
              color: value.color ?? colors[index],
              value: value.value,
              formatted: formatValue(value.value),
              label: value.label
            }
          ];
        });

  /* `item` is the whole column narrowed to the one mark the pointer is nearest,
     measured along the *value* axis — the category is already decided by where
     the pointer is across the plot, so the only question left is which of the
     series stacked at that category it is closest to. */
  const items =
    tooltipMode === 'item' && column.length > 1 && pointer !== null
      ? [
          column.reduce((nearest, item) =>
            Math.abs(valuePx(item.value ?? 0) - pointer) <
            Math.abs(valuePx(nearest.value ?? 0) - pointer)
              ? item
              : nearest
          )
        ]
      : column;

  const legendOptions: NebaChartLegend =
    legend === false
      ? { interactive: false }
      : legend === true || legend === undefined
        ? {}
        : legend;
  const showLegend = legend === true || (legend !== false && series.length > 1);
  const legendSide = legendOptions.side ?? 'bottom';

  const context: CartesianContext = {
    plot,
    values,
    visible: visibility.visible,
    colors,
    hovered: visibility.hovered,
    activeIndex,
    scale,
    band,
    horizontal,
    valuePx,
    categoryPx,
    point,
    zeroPx,
    categories: labels,
    format: formatValue,
    size
  };

  const nothing = count === 0 || extent === null;

  return (
    <ChartSurface
      {...box}
      size={size}
      variant={variant}
      padded={padded}
      className={className}
      legendSide={legendSide}
      legend={
        showLegend ? (
          <ChartLegendBar
            series={series}
            colors={colors}
            options={legendOptions}
            visibility={visibility}
            size={size}
            values={
              legendOptions.showValue && activeIndex !== null
                ? series.map((_, index) => {
                    const value = values[index]?.[activeIndex]?.value;

                    return value === null || value === undefined ? undefined : formatValue(value);
                  })
                : undefined
            }
          />
        ) : null
      }
      table={
        nothing ? null : (
          <ChartDataTable
            id={tableId}
            caption={label}
            corner={categoryAxis?.label}
            categories={labels}
            series={series}
            values={values}
            format={formatValue}
            locale={locale}
          />
        )
      }
    >
      <div
        ref={hostRef}
        role="img"
        tabIndex={nothing ? undefined : 0}
        aria-label={label}
        aria-describedby={nothing ? undefined : tableId}
        onPointerMove={(event) => {
          if (tooltipMode !== 'none') {
            setActiveIndex(indexAt(event.clientX, event.clientY));
            setPointer(valueAt(event.clientX, event.clientY));
          }
        }}
        onPointerLeave={() => {
          setActiveIndex(null);
          setPointer(null);
        }}
        // A key press moves the crosshair without a pointer, so `item` mode has
        // nothing to measure against and falls back to the whole column.
        onKeyDown={tooltipMode === 'none' ? undefined : onKeyDown}
        onBlur={() => setActiveIndex(null)}
        className={cx(
          'relative w-full',
          'rounded-(--neba-radius-xs)',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
        )}
        style={{ height: plotHeight ?? height }}
      >
        {nothing ? (
          <div
            className={cx(
              'flex h-full items-center justify-center text-(--neba-muted-fg)',
              metaTextClasses[size]
            )}
          >
            {empty ?? messages.empty.title}
          </div>
        ) : width > 0 ? (
          <svg
            width={width}
            height={boxHeight || '100%'}
            viewBox={`0 0 ${width} ${boxHeight}`}
            aria-hidden="true"
            className="block overflow-visible"
          >
            <ChartAxes
              plot={plot}
              scale={scale}
              band={band}
              horizontal={horizontal}
              inset={inset}
              categoryPx={categoryPx}
              valuePx={valuePx}
              tickTexts={tickTexts}
              categoryTexts={categoryTexts}
              valueAxis={valueAxis}
              categoryAxis={categoryAxis}
              fontSize={fontSize}
              zeroPx={zeroPx}
            />

            {activeIndex !== null && tooltipMode === 'index' && tooltipOptions.crosshair !== false
              ? (() => {
                  const along = categoryPx(activeIndex);

                  return horizontal ? (
                    <line
                      x1={plot.left}
                      x2={plot.left + plot.width}
                      y1={plot.top + along}
                      y2={plot.top + along}
                      stroke="var(--neba-chart-baseline)"
                      strokeWidth={1}
                    />
                  ) : (
                    <line
                      x1={plot.left + along}
                      x2={plot.left + along}
                      y1={plot.top}
                      y2={plot.top + plot.height}
                      stroke="var(--neba-chart-baseline)"
                      strokeWidth={1}
                    />
                  );
                })()
              : null}

            {children(context)}
          </svg>
        ) : null}

        {activeIndex !== null && items.length > 0 && tooltipMode !== 'none' ? (
          tooltipOptions.render ? (
            <div
              className="pointer-events-none absolute z-10"
              style={
                categoryPx(activeIndex) > categoryLength / 2 && !horizontal
                  ? {
                      right: `calc(100% - ${plot.left + categoryPx(activeIndex)}px + 10px)`,
                      top: plot.top
                    }
                  : {
                      left: horizontal
                        ? valuePx(items[0].value ?? 0) + 10
                        : plot.left + categoryPx(activeIndex) + 10,
                      top: horizontal ? plot.top + categoryPx(activeIndex) : plot.top
                    }
              }
            >
              {tooltipOptions.render({
                index: activeIndex,
                category: labels[activeIndex],
                items
              })}
            </div>
          ) : (
            <ChartTooltipPanel
              heading={formatCategory(labels[activeIndex], locale)}
              items={items}
              x={horizontal ? valuePx(items[0].value ?? 0) : plot.left + categoryPx(activeIndex)}
              y={horizontal ? plot.top + categoryPx(activeIndex) : plot.top}
              flip={
                (horizontal
                  ? scale.fraction(items[0].value ?? 0)
                  : categoryPx(activeIndex) / Math.max(1, categoryLength)) > 0.6
              }
              size={size}
            />
          )
        ) : null}
      </div>
    </ChartSurface>
  );
}

/* ---------------------------------------------------------------------------
 * Axes
 * ------------------------------------------------------------------------- */

interface AxesProps {
  plot: PlotBox;
  scale: ValueScale;
  band: BandScale;
  horizontal: boolean;
  inset: boolean;
  categoryPx: (index: number) => number;
  valuePx: (value: number) => number;
  tickTexts: readonly string[];
  categoryTexts: readonly string[];
  valueAxis?: NebaChartAxis;
  categoryAxis?: NebaChartAxis;
  fontSize: number;
  zeroPx: number;
}

/**
 * The grid, the rules and the labels.
 *
 * Gridlines run from the value axis only, and they are solid hairlines one step
 * off the surface. The category axis casts none by default: a grid in both
 * directions is graph paper, and the vertical rules would be doing the job the
 * crosshair already does under the pointer.
 */
function ChartAxes({
  plot,
  scale,
  horizontal,
  categoryPx,
  valuePx,
  tickTexts,
  categoryTexts,
  valueAxis,
  categoryAxis,
  fontSize,
  zeroPx
}: AxesProps) {
  const grid = valueAxis?.grid !== false && !valueAxis?.hidden;
  const categoryGrid = categoryAxis?.grid === true && !categoryAxis?.hidden;

  const stride = tickStride(
    categoryTexts.length,
    horizontal ? plot.height : plot.width,
    horizontal
      ? fontSize * 1.8
      : Math.max(...categoryTexts.map((t) => textWidth(t, fontSize)), 1) + 12
  );

  /* The value axis needs a stride of its own once it is the *horizontal* one:
     five stacked labels never touch, and five laid across a narrow card read as
     one long number. The gridlines are not thinned with them — a line at a value
     with no label on it is still a line the eye can measure against. */
  const valueStride = tickStride(
    scale.ticks.length,
    horizontal ? plot.width : plot.height,
    horizontal ? Math.max(...tickTexts.map((t) => textWidth(t, fontSize)), 1) + 16 : fontSize * 2
  );

  /* Whether the end of each axis still has room to be written down. Measured
     from the step it would sit at rather than assumed from the stride. */
  const categoryStep =
    categoryTexts.length > 1 ? Math.abs(categoryPx(1) - categoryPx(0)) : plot.width;
  const valueStep =
    scale.ticks.length > 1
      ? Math.abs(valuePx(scale.ticks[1]) - valuePx(scale.ticks[0]))
      : plot.height;

  const lastCategory = fitsLast(
    categoryTexts.length,
    stride,
    categoryStep,
    horizontal ? fontSize * 1.8 : textWidth(categoryTexts[categoryTexts.length - 1] ?? '', fontSize)
  );
  const lastValue = fitsLast(
    scale.ticks.length,
    valueStride,
    valueStep,
    horizontal ? textWidth(tickTexts[tickTexts.length - 1] ?? '', fontSize) : fontSize * 1.6
  );

  return (
    <g>
      {/* The value axis' gridlines, and its labels beside them. */}
      {scale.ticks.map((tick, index) => {
        const along = valuePx(tick);
        const isZero = Math.abs(tick) < 1e-9;

        return (
          <g key={tick}>
            {grid ? (
              horizontal ? (
                <line
                  x1={along}
                  x2={along}
                  y1={plot.top}
                  y2={plot.top + plot.height}
                  stroke={isZero ? 'var(--neba-chart-baseline)' : 'var(--neba-chart-grid)'}
                  strokeWidth={1}
                />
              ) : (
                <line
                  x1={plot.left}
                  x2={plot.left + plot.width}
                  y1={along}
                  y2={along}
                  stroke={isZero ? 'var(--neba-chart-baseline)' : 'var(--neba-chart-grid)'}
                  strokeWidth={1}
                />
              )
            ) : null}

            {valueAxis?.hidden ||
            !showsTick(index, scale.ticks.length, valueStride, lastValue) ? null : horizontal ? (
              <text
                x={along}
                // The first and last labels are centred on the ends of the plot,
                // so half of each hangs outside it. Anchoring them inward is
                // cheaper than reserving a margin nothing else would use.
                y={plot.top + plot.height + fontSize + 6}
                textAnchor={
                  index === 0 ? 'start' : index === scale.ticks.length - 1 ? 'end' : 'middle'
                }
                fontSize={fontSize}
                fill="var(--neba-muted-fg)"
                className="tabular-nums"
              >
                {tickTexts[index]}
              </text>
            ) : (
              <text
                x={plot.left - 8}
                y={along}
                textAnchor="end"
                dominantBaseline="central"
                fontSize={fontSize}
                fill="var(--neba-muted-fg)"
                className="tabular-nums"
              >
                {tickTexts[index]}
              </text>
            )}
          </g>
        );
      })}

      {/* The category axis. Its rule sits at the baseline rather than at the
          bottom of the plot: on a chart with negative values those are not the
          same line, and the one the bars grow from is the one that means zero. */}
      {categoryAxis?.hidden ? null : (
        <>
          {horizontal ? (
            <line
              x1={zeroPx}
              x2={zeroPx}
              y1={plot.top}
              y2={plot.top + plot.height}
              stroke="var(--neba-chart-axis)"
              strokeWidth={1}
            />
          ) : (
            <line
              x1={plot.left}
              x2={plot.left + plot.width}
              y1={zeroPx}
              y2={zeroPx}
              stroke="var(--neba-chart-axis)"
              strokeWidth={1}
            />
          )}

          {categoryTexts.map((text, index) => {
            if (!showsTick(index, categoryTexts.length, stride, lastCategory)) {
              return null;
            }

            const along = categoryPx(index);

            return horizontal ? (
              <text
                key={index}
                x={plot.left - 8}
                y={plot.top + along}
                textAnchor="end"
                dominantBaseline="central"
                fontSize={fontSize}
                fill="var(--neba-muted-fg)"
              >
                {text}
              </text>
            ) : (
              <g key={index}>
                {categoryGrid ? (
                  <line
                    x1={plot.left + along}
                    x2={plot.left + along}
                    y1={plot.top}
                    y2={plot.top + plot.height}
                    stroke="var(--neba-chart-grid)"
                    strokeWidth={1}
                  />
                ) : null}
                <text
                  x={plot.left + along}
                  y={plot.top + plot.height + fontSize + 6}
                  textAnchor="middle"
                  fontSize={fontSize}
                  fill="var(--neba-muted-fg)"
                >
                  {text}
                </text>
              </g>
            );
          })}
        </>
      )}

      {/* The axis names. The value axis' name is set above its ticks rather than
          turned on its side — a rotated label is unreadable at a glance and it
          takes a band of the plot to be unreadable in. */}
      {valueAxis?.label ? (
        <text
          x={horizontal ? plot.left + plot.width : plot.left}
          y={horizontal ? plot.top + plot.height + fontSize * 2 + 12 : plot.top - 8}
          textAnchor={horizontal ? 'end' : 'start'}
          fontSize={fontSize}
          fill="var(--neba-muted-fg)"
          fontWeight={500}
        >
          {valueAxis.label}
        </text>
      ) : null}
      {categoryAxis?.label && !horizontal ? (
        <text
          x={plot.left + plot.width}
          y={plot.top + plot.height + fontSize * 2 + 12}
          textAnchor="end"
          fontSize={fontSize}
          fill="var(--neba-muted-fg)"
          fontWeight={500}
        >
          {categoryAxis.label}
        </text>
      ) : null}
    </g>
  );
}

/* ---------------------------------------------------------------------------
 * Pieces the non-cartesian charts need too
 * ------------------------------------------------------------------------- */

export {
  ChartDataTable,
  ChartLegendBar,
  ChartSurface,
  ChartTooltipPanel,
  useMeasuredWidth,
  useVisibility
};
export type { Visibility };
