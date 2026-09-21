'use client';

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

import { useStyleDefaults } from './defaults.js';
import * as React from 'react';
import { Box, type BoxProps } from '../components/box/Box.js';
import {
  bandScale,
  categoryAt,
  categoryCount,
  categoryExtent,
  chartFontSizes,
  compactNumber,
  extentOf,
  fitsLast,
  formatCategory,
  markerRadii,
  plotHeights,
  resolveColor,
  seriesColor,
  showsTick,
  textWidth,
  tickStride,
  toFullShares,
  toValues,
  truncate,
  turnedAxis,
  valueScale,
  warnPaletteOverflow,
  type BandScale,
  type ChartValue,
  type PlotBox,
  type TurnedAxis,
  type ValueScale
} from './chart.js';
import { numberFormatter } from './format.js';
import { observeResize } from './observe.js';
import { chartMessages, emptyMessages, fillMessage, useMessages } from './i18n.js';
import { cx, hasContent, metaTextClasses, srOnlyClasses, transitionClasses } from './styles.js';
import type {
  NebaChartAxis,
  NebaChartCategory,
  NebaChartLegend,
  NebaChartReference,
  NebaChartSeries,
  NebaChartTooltip,
  NebaSize
} from '../types.js';

/* ---------------------------------------------------------------------------
 * Measurement
 * ------------------------------------------------------------------------- */

/** A layout read where there is a layout, and a no-op where there is not. */
const useMeasureEffect = typeof document === 'undefined' ? React.useEffect : React.useLayoutEffect;

/** One array rather than a fresh `[]` per render, for the charts with no marks. */
const noMarks: readonly ChartMark[] = [];

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

    return observeResize(host, measure);
  }, [ref]);

  return width;
}

/**
 * The host's height, for a chart whose `height` is a CSS length rather than a
 * number. A drawing is laid out in pixels, so `height="16rem"` has to be read
 * back off the box it produced; without this a Cartesian chart drew into a
 * `viewBox` 0 pixels tall and a pie, a heatmap and a gauge ignored the string.
 * It measures nothing when the height is already a number.
 */
function useMeasuredHeight(ref: React.RefObject<HTMLElement | null>, enabled: boolean): number {
  const [height, setHeight] = React.useState(0);

  useMeasureEffect(() => {
    const host = ref.current;

    if (!enabled || !host) {
      return;
    }

    const measure = () => setHeight(host.clientHeight);

    measure();

    return observeResize(host, measure);
  }, [ref, enabled]);

  return height;
}

/**
 * How tall a chart draws, in pixels: the number it was given, the `size`
 * ladder when it was given nothing, and the measured box for a CSS length.
 */
function chartHeight(
  height: number | string | undefined,
  size: NebaSize,
  measured: number
): number {
  return typeof height === 'number' ? height : height === undefined ? plotHeights[size] : measured;
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
/**
 * How a mark answers the pointer: the three properties one is allowed to change
 * when the reader points at it, and how long each takes.
 *
 * One declaration and one class on every mark, rather than one per property.
 * `transition` is a shorthand, so two of them on the same element are decided by
 * their order in the generated stylesheet rather than by intent — a scatter mark
 * carrying a fade *and* a grow written separately keeps whichever Tailwind
 * happened to emit last, which is the kind of bug that looks like the browser's
 * fault. A property an element never changes costs it nothing.
 *
 * **`opacity`** is two states that are the same sentence at two scales. A whole
 * *series* drops to 0.28 when the legend is pointed at one of the others; a
 * single *datum* sits at 0.92 until the crosshair reaches it. Both mean "this is
 * the one you asked about". It is also the one place a chart may say something
 * with opacity at all: nothing here is a control, and "not the one you are
 * pointing at" is not a state a colour family can carry without recolouring the
 * data.
 *
 * **`r`** and **`scale`** are the same pixel of growth reached two ways, because
 * the two shapes that grow are drawn differently. A line's marker is a
 * `<circle>`, whose radius is the geometry property `r` — a number, which
 * travels. A scatter's mark is an arbitrary `<path>`, whose size lives inside
 * `d`, which does not; that one grows on the independent `scale` property about
 * the point it is pinned to, so a triangle grows where it stands rather than
 * drifting toward the middle of its own bounding box.
 *
 * Only the pie and the heatmap ever moved on any of this. The line, the area,
 * the bar, the scatter and the timeline snapped, and a dashboard holding two of
 * each showed both answers at once.
 */
export const markTransitionClasses = [
  '[transition:opacity_var(--neba-duration)_var(--neba-ease),',
  'r_var(--neba-duration)_var(--neba-ease),',
  'scale_var(--neba-duration)_var(--neba-ease)]'
].join('');

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
  /**
   * Adds a small button in the corner that writes the chart's data out as a
   * CSV file — the same numbers the hidden table under the plot holds.
   *
   * A picture is the one form of a number nobody can paste anywhere, and the
   * table a screen reader gets is not reachable with a pointer. This is the
   * pointer's way to the same thing.
   *
   * The file is built by a module that is **fetched when the button is
   * pressed** rather than imported with the chart, so a page that never turns
   * this on downloads none of it.
   * @default false
   */
  exportable?: boolean;
  /** What the downloaded file is called. @default 'chart.csv' */
  exportFileName?: string;
  /**
   * Takes the CSV instead of downloading it — to post it somewhere, to open it
   * in a viewer of your own, or to put a sheet around it.
   */
  onExport?: (csv: string) => void;
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
  /**
   * Lines and bands drawn across the plot at values the data has none of — a
   * target, an SLA, a budget, the window a forecast covers.
   *
   * The scale is widened to hold them, so a target above everything measured
   * is still on the chart. They are drawn under the marks and over the grid,
   * and each one that names itself is read out with the data.
   */
  references?: readonly NebaChartReference[];
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
 * What a series is called for the legend's memory: its name, and which of the
 * series with that name it is, or its index when it has no name.
 *
 * Not the index alone. The hidden state outlives the data, and a refresh that
 * brings the same series back in another order moved the hiding onto whichever
 * series now sat at that index. The occurrence count keeps two series that
 * share a name apart.
 */
function seriesKeys(series: readonly NebaChartSeries[]): string[] {
  const seen = new Map<string, number>();

  return series.map((one, index) => {
    if (one.name === undefined) {
      return `index:${index}`;
    }

    const count = seen.get(one.name) ?? 0;

    seen.set(one.name, count + 1);

    return `name:${count}:${one.name}`;
  });
}

/**
 * Which series are drawn, and which one the pointer is resting on in the legend.
 *
 * What the reader chose is remembered per series key rather than per index, so
 * hiding Europe keeps Europe hidden when new data puts it somewhere else in the
 * list. A series nobody has toggled follows its own `hidden`, on every render
 * and not only the first. The colours still come off the index the series was
 * passed at, so hiding Europe leaves Asia exactly the colour it was.
 */
function useVisibility(series: readonly NebaChartSeries[]): Visibility {
  const [chosen, setChosen] = React.useState<ReadonlyMap<string, boolean>>(() => new Map());
  const [hovered, setHovered] = React.useState<number | null>(null);

  const keys = seriesKeys(series);
  const latest = React.useRef({ series, keys });

  React.useEffect(() => {
    latest.current = { series, keys };
  });

  const toggle = React.useCallback((index: number) => {
    const { series: current, keys: currentKeys } = latest.current;
    const key = currentKeys[index];

    if (key === undefined) {
      return;
    }

    setChosen((choices) => {
      const next = new Map(choices);

      next.set(key, !(choices.get(key) ?? !current[index]?.hidden));

      return next;
    });
  }, []);

  return {
    visible: series.map((one, index) => chosen.get(keys[index]) ?? !one.hidden),
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
  swatch?: (index: number, color: string) => React.ReactNode;
}

/**
 * The dependable identity channel.
 *
 * A swatch and a word, and the swatch is the only thing on it wearing the
 * series colour — the name is ink, at whatever the size ladder says, because a
 * light hue is illegible as text and because colour is what the swatch beside
 * it is for.
 *
 * A hidden series stays in the legend and fades rather than disappearing: a
 * list that shortens when you click it is a list you cannot click twice. It
 * fades whole — swatch and name together, at its own colour — rather than
 * turning grey, because grey is a ninth colour on a chart that already has
 * eight, and a row recoloured to say "off" is a row that no longer says which
 * series it is. This is the second of the two places a chart is allowed to say
 * something with opacity, and it is the same sentence the dimming makes one
 * scale up: not the one you are looking at.
 *
 * `swatch` is for the chart whose marks carry a second identity channel. A
 * scatter past the third series tells its series apart by shape as well as by
 * hue, and a legend that answered with eight identical squares would be back to
 * colour alone — which is the thing the shapes were added to fix.
 */
/**
 * Puts a reading down when a press lands anywhere outside the plot.
 *
 * A mouse puts it down by leaving. A finger cannot: a touch's `pointerleave`
 * arrives the moment it lifts, so a plot that cleared on leave showed a tap's
 * tooltip for one frame. A tap pins the reading instead, and this is the way
 * out of it. It listens only while something is being read.
 */
function useReleaseOutside(
  ref: React.RefObject<HTMLElement | null>,
  active: boolean,
  release: () => void
) {
  const latest = React.useRef(release);

  React.useEffect(() => {
    latest.current = release;
  });

  React.useEffect(() => {
    if (!active) {
      return;
    }

    const onPress = (event: PointerEvent) => {
      const host = ref.current;

      if (host && event.target instanceof Node && !host.contains(event.target)) {
        latest.current();
      }
    };

    document.addEventListener('pointerdown', onPress, true);

    return () => document.removeEventListener('pointerdown', onPress, true);
  }, [ref, active]);
}

function ChartLegendBar({
  series,
  colors,
  options,
  visibility,
  size,
  values,
  swatch
}: LegendProps) {
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

        const ink = colors[index];

        const content = (
          <>
            {swatch ? (
              <span
                aria-hidden="true"
                className="flex size-2.5 shrink-0 items-center justify-center"
              >
                {swatch(index, ink)}
              </span>
            ) : (
              <span
                aria-hidden="true"
                className={`size-2.5 shrink-0 rounded-[0.1875rem] ${transitionClasses}`}
                style={{ backgroundColor: ink }}
              />
            )}
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
                  // Its own list rather than the house one: `transitionClasses`
                  // names the four properties a control answers a pointer with,
                  // and `opacity` — the only thing that changes when a *sibling*
                  // row is hovered — is not among them, so the dimming below was
                  // written down and never ran.
                  '[transition-property:background-color,color,opacity]',
                  '[transition-duration:var(--neba-duration)]',
                  '[transition-timing-function:var(--neba-ease)]',
                  'hover:bg-(--n-soft)',
                  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
                  // One branch and not two variants stacked: both states are
                  // the same property, so written separately they would be
                  // decided by the order Tailwind emitted them in. Hidden wins
                  // over dimmed, which is the stronger statement of the two.
                  shown ? (dimmed ? 'opacity-55' : '') : 'opacity-40'
                )}
              >
                {content}
              </button>
            ) : (
              <span
                className={cx(
                  'flex min-w-0 items-center gap-1.5 px-1 py-0.5 text-(--neba-fg)',
                  shown ? '' : 'opacity-40'
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

interface ScaleLegendProps {
  /** The steps, palest first, as the `var()`s that resolve them. */
  steps: readonly string[];
  /** What the two ends of the scale say. */
  from: string;
  to: string;
  /** And the middle, on a diverging scale where the middle means something. */
  middle?: string;
  align: NonNullable<NebaChartLegend['align']>;
  vertical: boolean;
  size: NebaSize;
}

/**
 * The legend a magnitude needs, which is a bar and not a list of swatches.
 *
 * `ChartLegendBar` answers "which one is Europe" — a set of names, in no order,
 * each with a colour beside it. A sequential scale is the other question
 * entirely: nothing here has a name, the order *is* the meaning, and what the
 * reader needs is the two numbers at the ends. A key of five unnamed swatches
 * would say neither.
 *
 * The steps are drawn as five joined blocks rather than as a CSS gradient,
 * because five is what the cells are actually coloured with — a smooth bar
 * would promise a continuum the chart cannot deliver, and a reader matching a
 * cell against it would be guessing.
 */
function ChartScaleLegend({ steps, from, to, middle, align, vertical, size }: ScaleLegendProps) {
  return (
    <div className={cx('flex', vertical ? '' : legendAlignClasses[align])}>
      {/* A grid rather than a row, so the middle label can sit in the bar's own
          column. Written beside the bar it reads as a third end. */}
      <div
        className={cx(
          'grid grid-cols-[auto_auto_auto] items-center gap-x-2',
          metaTextClasses[size]
        )}
      >
        <span className="shrink-0 tabular-nums text-(--neba-muted-fg)">{from}</span>
        <span
          aria-hidden="true"
          className={cx(
            'flex h-2.5 overflow-hidden rounded-[0.1875rem]',
            vertical ? 'w-20' : 'w-24'
          )}
        >
          {steps.map((step) => (
            <span key={step} className="h-full flex-1" style={{ backgroundColor: step }} />
          ))}
        </span>
        <span className="shrink-0 tabular-nums text-(--neba-muted-fg)">{to}</span>

        {middle ? (
          <>
            <span />
            <span className="text-center tabular-nums text-(--neba-muted-fg)">{middle}</span>
            <span />
          </>
        ) : null}
      </div>
    </div>
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
      // The panel carries no role at all. It is drawn inside the element that
      // carries `role="img"`, which prunes its whole subtree from the
      // accessibility tree — so anything semantic written here would be
      // written for nobody. `ChartStatus` is the half a reader hears; this is
      // the half they see, and the attribute is what a stylesheet or a test
      // reaches it by.
      data-neba-tooltip=""
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

/**
 * The same reading, said out loud rather than drawn.
 *
 * It cannot be the panel above, and that is not a preference. The panel is
 * drawn inside the element carrying `role="img"`, and `img` is a leaf role:
 * everything under it is cut out of the accessibility tree, so a live region
 * in there announces to nobody. This is a *sibling* of the picture, clipped
 * instead of painted, and it is what makes the arrow keys mean something to a
 * reader who is not looking at the plot.
 *
 * Empty when nothing is active, so leaving the chart clears what was said
 * rather than leaving the last column standing in the region forever.
 */
/**
 * The sentence a plot is described by.
 *
 * The plot used to be described by the hidden table itself, so a year of daily
 * points was three hundred and sixty-five numbers read out on every focus. This
 * says how many there are and between which two they fall, and the table stays
 * where a reader who wants the numbers can walk it. `hidden` keeps it out of the
 * reading order: a description is computed from a hidden element all the same.
 */
function ChartSummary({
  id,
  template,
  count,
  min,
  max,
  locale
}: {
  id: string;
  template: string;
  count: number;
  min: string;
  max: string;
  locale?: string;
}) {
  return (
    <span id={id} hidden>
      {fillMessage(template, { count: numberFormatter(locale, {}).format(count), min, max })}
    </span>
  );
}

/** The count and extremes of every non-`null` value in the rows still shown. */
function summarise(
  rows: readonly (readonly ChartValue[])[],
  format: (value: number) => string
): { count: number; min: string; max: string } {
  let count = 0;
  let low = Infinity;
  let high = -Infinity;

  for (const row of rows) {
    for (const one of row) {
      if (one.value === null || Number.isNaN(one.value)) {
        continue;
      }

      count += 1;
      low = Math.min(low, one.value);
      high = Math.max(high, one.value);
    }
  }

  return count === 0 ? { count, min: '', max: '' } : { count, min: format(low), max: format(high) };
}

function ChartStatus({
  heading,
  items
}: {
  heading?: React.ReactNode;
  items: readonly ChartTooltipItem[];
}) {
  return (
    <span role="status" aria-live="polite" className={srOnlyClasses}>
      {items.length === 0 ? null : (
        <>
          {hasContent(heading) ? <>{heading}, </> : null}
          {items.map((item, index) => (
            <React.Fragment key={item.seriesIndex}>
              {index > 0 ? ', ' : null}
              {item.name ? `${item.name}: ` : null}
              {item.label ?? item.formatted}
            </React.Fragment>
          ))}
        </>
      )}
    </span>
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
 *
 * Memoised, and it is the one component in this file that has to be. It is a
 * row per category and a cell per series, and it is built in the same render
 * body that holds the crosshair's state — so without this every cell of it is
 * reconciled again for each pixel the pointer travels across the picture, on a
 * table nobody is looking at. Every prop it takes is either a primitive or
 * something already memoised above.
 */
const ChartDataTable = React.memo(function ChartDataTable({
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
});

/* ---------------------------------------------------------------------------
 * Export
 * ------------------------------------------------------------------------- */

interface ExportProps {
  /** The sheet, built when the button is pressed and not before. */
  rows: () => readonly (readonly unknown[])[];
  fileName: string;
  onExport?: (csv: string) => void;
  label: string;
}

/**
 * The button that hands the chart's numbers over.
 *
 * A plain `<button>` rather than an IconButton, for the reason the legend's
 * rows are plain buttons too: this is inside the frame every chart imports, so
 * a component pulled in here is one every chart pays for whether it draws the
 * button or not.
 *
 * The CSV writer is **loaded** rather than imported, which is `highlight.ts`'
 * arrangement in miniature. Escaping a spreadsheet field correctly is a page
 * of rules nobody should carry to read a chart, and a bundler emits it as a
 * chunk of its own behind the `import()` — so a page that never turns this on
 * downloads none of it, and one that does fetches it on the press.
 */
function ChartExport({ rows, fileName, onExport, label }: ExportProps) {
  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      onClick={async () => {
        const { toCsv, downloadText } = await import('./csv.js');
        const csv = toCsv(rows());

        if (onExport) {
          onExport(csv);
          return;
        }

        downloadText(csv, fileName, 'text/csv;charset=utf-8');
      }}
      className={cx(
        'absolute end-0 top-0 z-10 inline-flex size-6 cursor-pointer items-center justify-center',
        'rounded-(--neba-radius-xs) text-(--neba-muted-fg)',
        'hover:bg-(--n-soft) hover:text-(--neba-fg)',
        'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
        transitionClasses
      )}
    >
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
        className="size-3.5"
      >
        <path d="M12 3v12m0 0 4-4m-4 4-4-4M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2" />
      </svg>
    </button>
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
 * References
 * ------------------------------------------------------------------------- */

interface ReferencesProps {
  references: readonly NebaChartReference[];
  plot: PlotBox;
  horizontal: boolean;
  valuePx: (value: number) => number;
  categoryPx: (index: number) => number;
  categoryScale: ValueScale | null;
  categoryValuePx: (value: number) => number;
  fontSize: number;
}

/**
 * The lines and bands a caller draws across the plot.
 *
 * The one thing on a chart that is neither a mark nor chrome, and it is drawn
 * as exactly that: heavier than a gridline because it carries meaning, dashed
 * and neutral because it is not the reader's data and must not take one of the
 * eight series hues. A band is the same line twice with a wash between, so a
 * tolerance and the two edges of it are one idea rather than three elements a
 * caller has to line up.
 *
 * Under the marks and over the grid. A reference the data is hidden behind is
 * a reference that has become the chart.
 */
function ChartReferences({
  references,
  plot,
  horizontal,
  valuePx,
  categoryPx,
  categoryScale,
  categoryValuePx,
  fontSize
}: ReferencesProps) {
  return (
    <g>
      {references.map((one, index) => {
        const onValue = (one.axis ?? 'value') === 'value';
        /* Where a number lands. On the value axis that is one call; on the
           category axis it is the scale's when the categories are numbers or
           dates, and the band's centre when they are columns — which is what
           makes `value` an index there and says so in the type. */
        const at = (number: number) =>
          onValue
            ? valuePx(number)
            : categoryScale
              ? categoryValuePx(number)
              : (horizontal ? plot.top : plot.left) + categoryPx(number);

        /* Which way the rule runs. A value on the value axis is drawn across
           the *other* one, and `horizontal` swaps which of the two that is. */
        const across = onValue ? !horizontal : horizontal;
        const from = at(one.value);
        const to = one.to === undefined ? null : at(one.to);
        const near = to === null ? from : Math.min(from, to);
        const far = to === null ? from : Math.max(from, to);
        const ink = one.color ? resolveColor(one.color) : 'var(--neba-muted-fg)';
        const dash = one.solid ? undefined : '4 4';

        /* The label goes at the far end of the rule and just clear of it, so a
           band's name does not sit inside the wash it belongs to. */
        const label = one.label ? (
          <text
            x={across ? plot.left + plot.width - 4 : near + 4}
            y={across ? near - 5 : plot.top + fontSize}
            textAnchor={across ? 'end' : 'start'}
            fontSize={fontSize}
            fontWeight={500}
            fill={ink}
          >
            {one.label}
          </text>
        ) : null;

        return (
          <g key={index}>
            {to === null ? null : (
              <rect
                x={across ? plot.left : near}
                y={across ? near : plot.top}
                width={across ? plot.width : Math.max(0, far - near)}
                height={across ? Math.max(0, far - near) : plot.height}
                fill={`color-mix(in oklab, ${ink} 12%, transparent)`}
              />
            )}

            {(to === null ? [from] : [near, far]).map((along, edge) => (
              <line
                key={edge}
                x1={across ? plot.left : along}
                x2={across ? plot.left + plot.width : along}
                y1={across ? along : plot.top}
                y2={across ? along : plot.top + plot.height}
                stroke={ink}
                strokeWidth={1}
                strokeDasharray={dash}
              />
            ))}

            {label}
          </g>
        );
      })}
    </g>
  );
}

/* ---------------------------------------------------------------------------
 * Cartesian charts
 * ------------------------------------------------------------------------- */

/**
 * One mark on a plot whose marks are not arranged in columns.
 *
 * A scatter has no shared categories, so there is no column for a pointer to
 * be inside and nothing for a crosshair to be dropped through: the only
 * question a reader can be asking is "which of these dots". A chart that says
 * so hands the frame its marks and gets the nearest-mark search, the arrow
 * keys and the tooltip anchoring for free.
 */
export interface ChartMark {
  /** Its series' place in the array as it was passed — where its colour is from. */
  series: number;
  /** Its own place within that series. */
  index: number;
  /** Its centre, in pixels from the chart's top-left. */
  x: number;
  y: number;
  /** How big it is. Widens the hit target, so a bubble is easier to hit than a dot. */
  r: number;
  /**
   * Its half-width and half-height, when the mark is a box rather than a disc.
   *
   * A span on a Gantt is two hundred pixels of bar whose centre a pointer may
   * never go near, so measuring to the centre would hand the row's short bar a
   * hover the reader is plainly not making. Given these, the pointer is tested
   * against the *body*.
   */
  rx?: number;
  ry?: number;
}

/**
 * Where everything goes — the half of the context that is settled before the
 * pointer is consulted.
 *
 * It is split out because the marks are built from it: a chart hands the frame
 * a builder, the frame runs it on the layout, and only then is there a list for
 * the pointer to be nearest to. A builder that could read what is active would
 * be reading a value that does not exist yet.
 */
export interface CartesianLayout {
  plot: PlotBox;
  /** Every series unpacked, in the order it was passed. */
  values: readonly ChartValue[][];
  /** Which of them are drawn. */
  visible: readonly boolean[];
  /** And what colour each one is, by its original index. */
  colors: readonly string[];
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
  /**
   * The scale the *category* axis runs on, when `xScale` made it a second value
   * axis. `null` on every chart whose categories are columns.
   */
  categoryScale: ValueScale | null;
  /**
   * Where a value sits along the category axis, in pixels from the chart's
   * edge — the same absolute reckoning `valuePx` uses, and deliberately not
   * `categoryPx`'s offset-along-the-axis. Only meaningful with `xScale="value"`.
   */
  categoryValuePx: (value: number) => number;
  /** Where the baseline is along the value axis. */
  zeroPx: number;
  categories: readonly NebaChartCategory[];
  format: (value: number) => string;
  size: NebaSize;
}

/** The layout, plus everything the pointer decides. */
export interface CartesianContext extends CartesianLayout {
  /** The series the legend is being hovered over, if any. */
  hovered: number | null;
  /** The category under the pointer, if any. */
  activeIndex: number | null;
  /** Every mark, when the chart supplied a builder. Empty otherwise. */
  marks: readonly ChartMark[];
  /** The one the pointer is on, or the one the arrow keys walked to. */
  activeMark: ChartMark | null;
}

interface CartesianProps extends CartesianChartProps {
  /**
   * Makes the category axis a second value axis instead of a row of columns.
   * `value` is what a scatter needs and what nothing else does.
   * @default 'band'
   */
  xScale?: 'band' | 'value';
  /**
   * Builds every mark on the plot, which swaps the frame's column hit-testing
   * for a nearest-mark search and makes the arrow keys walk this list. The
   * result comes back on the context, so the marks are laid out once and drawn
   * from the same array they are hit-tested against.
   */
  marks?: (layout: CartesianLayout) => readonly ChartMark[];
  /**
   * How far off a mark the pointer still counts as on it, in pixels. Added to
   * the mark's own radius — a 4px dot is not a hit target.
   * @default 24
   */
  markRadius?: number;
  /**
   * The table under the chart, for a chart whose data is not a grid.
   *
   * It is handed the frame's own `format`, already stable across a render, so a
   * table of its own is memoised on the same terms `ChartDataTable` is rather
   * than building a formatter that a pointer moving over the picture rebuilds.
   */
  table?: (id: string, format: (value: number) => string) => React.ReactNode;
  /**
   * What the plot's one-sentence description counts, for a chart whose drawn
   * values are not its series' values — a timeline's spans. Left out, it is
   * every visible non-`null` value and their extremes, through `format`.
   */
  summary?: { count: number; min: string; max: string };
  /** The legend's swatch, for a chart whose marks are not all the same shape. */
  swatch?: (index: number, color: string) => React.ReactNode;
  /**
   * The value axis' scale, already worked out.
   *
   * For the axis that is not a count. `valueScale` rounds to 1-2-5, which is
   * the family a reader does arithmetic in and exactly the wrong one for an
   * instant — sixty, twenty-four, seven, twelve. A chart whose axis has its own
   * arithmetic builds the scale itself and hands it over.
   */
  scale?: ValueScale;
  /**
   * What the tooltip says about a mark.
   *
   * Without it a mark is read as "this series at this category", which is right
   * for anything whose marks sit in a grid the frame already understands. A
   * Gantt's rows are the frame's *categories* and its marks are spans within
   * them, so there is no cell for the frame to look the answer up in.
   */
  markTooltip?: (mark: ChartMark) => {
    heading: React.ReactNode;
    items: readonly ChartTooltipItem[];
  } | null;
  /** Bars, and only bars, run the other way. */
  horizontal?: boolean;
  /** The value axis measures totals rather than parts. */
  stacked?: boolean;
  /** Every category is renormalised to a hundred — `stacked="full"`. See `toFullShares`. */
  stackedFull?: boolean;
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
  /**
   * Room on **every** side of the plot, for marks drawn from their centre.
   *
   * `headroom` is not enough for those: a bubble at the largest x hangs over the
   * right edge and one at the smallest hangs over the value axis' own labels.
   * A line's marker gets away with it because a line is inset from both ends
   * anyway; a scatter places a mark wherever the number says, including exactly
   * on the corner.
   */
  markInset?: number;
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
export function CartesianChart(rawProps: CartesianProps) {
  const {
    series,
    categories,
    xAxis,
    yAxis,
    references,
    horizontal = false,
    stacked = false,
    stackedFull = false,
    includeZero = true,
    bandRatio = 1,
    inset = false,
    headroom = 0,
    markInset = 0,
    xScale = 'band',
    marks,
    markRadius = 24,
    table,
    summary,
    swatch,
    scale: givenScale,
    markTooltip,
    height,
    format,
    locale,
    label,
    legend,
    tooltip,
    empty,
    exportable = false,
    exportFileName = 'chart.csv',
    onExport,
    size = 'md',
    variant = 'text',
    padded = false,
    className,
    children,
    ...box
  } = useStyleDefaults(rawProps, ['size', 'variant', 'locale']);
  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const messages = useMessages(emptyMessages, locale);
  const chartWords = useMessages(chartMessages, locale);
  const tableId = React.useId();
  const summaryId = React.useId();

  const visibility = useVisibility(series);

  React.useEffect(() => {
    warnPaletteOverflow(series.length);
  }, [series.length]);
  const [columnIndex, setColumnIndex] = React.useState<number | null>(null);
  /** Which entry of `markList` the pointer is on — the other way to be active. */
  const [markIndex, setMarkIndex] = React.useState<number | null>(null);
  /** Where the pointer is along the value axis. `null` when it arrived by key. */
  const [pointer, setPointer] = React.useState<number | null>(null);

  /* Keyed on what the options *say* rather than on their identity, for the
     reason `internal/format.ts` is: `format` is an options object and the
     ordinary way that prop gets written is a literal in the JSX, so a fresh one
     arrives on every render. Keyed on identity this function would be a new
     function every render too, and every memo below it — the data table above
     all — would miss on a chart the pointer is merely moving across. The stale
     `format` the closure then holds is content-identical to the current one, and
     `numberFormatter` is keyed on the content, so the same formatter comes
     back. */
  const formatKey = format ? JSON.stringify(format) : '';
  const formatValue = React.useCallback(
    (value: number) =>
      format ? numberFormatter(locale, format).format(value) : compactNumber(value, locale),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [formatKey, locale]
  );

  const given = React.useMemo(() => toValues(series), [series]);
  // Keyed on what is shown rather than on the array, which is a new one on
  // every render: a pointer crossing the plot must not renormalise the data.
  const shownKey = visibility.visible.map(Number).join('');
  const values = React.useMemo(
    () => (stackedFull ? toFullShares(given, visibility.visible, formatValue) : given),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [given, stackedFull, shownKey, formatValue]
  );
  const colors = React.useMemo(() => series.map((one, index) => seriesColor(one, index)), [series]);

  const count = categoryCount(series);
  const labels = React.useMemo(
    () => Array.from({ length: count }, (_, index) => categoryAt(index, categories, values)),
    [count, categories, values]
  );

  const shownValues = values.filter((_, index) => visibility.visible[index]);
  /* The scale takes the references in. A target drawn off the top of the plot
     is a target nobody can see, and moving every mark down a little to make
     room for it is the cheaper of the two costs. Only the ones read against
     the value axis: a rule that says *when* belongs to the other one. */
  const extent = React.useMemo(() => {
    const measured = extentOf(shownValues, stacked);
    const marks = (references ?? []).filter((one) => (one.axis ?? 'value') === 'value');

    if (marks.length === 0) {
      return measured;
    }

    const numbers = marks.flatMap((one) =>
      one.to === undefined ? [one.value] : [one.value, one.to]
    );

    return {
      min: Math.min(measured?.min ?? Infinity, ...numbers),
      max: Math.max(measured?.max ?? -Infinity, ...numbers)
    };
  }, [shownValues, stacked, references]);
  // Worked out here, beside the extent, rather than where it is drawn: read
  // after the scales are memoised, the call would count as a possible change to
  // `shownValues` and cost the compiler every memo below.
  const described = summary ?? summarise(shownValues, formatValue);

  const measuredHeight = useMeasuredHeight(hostRef, typeof height === 'string');
  const plotHeight = chartHeight(height, size, measuredHeight);

  const fontSize = chartFontSizes[size];

  /* `xAxis` is the category axis and `yAxis` is the value axis, on every chart
     and in both orientations — which is the whole point of naming them that
     way: turning a bar chart on its side is a change to the drawing, not to
     what the caller's data means, so it must not also move their axis options
     from one prop to the other.

     These were swapped by `horizontal`, and it produced exactly the collision
     that argument predicts: a horizontal `stacked="full"` BarChart sends the
     `%` tick format to the axis holding the category names and prints
     `Seoul%`. Where the axes are *drawn* is still decided by `horizontal`,
     below and in `ChartAxes`; that part was never in question. */
  const valueAxis = yAxis;
  const categoryAxis = xAxis;

  /* The scales. The value axis is rounded to clean numbers before anything is
     measured, because how much room the axis needs depends on how wide its
     widest tick prints — which is not knowable until the ticks exist. */
  const scale =
    givenScale ??
    valueScale(extent, {
      min: valueAxis?.min,
      max: valueAxis?.max,
      tickCount: valueAxis?.tickCount,
      includeZero
    });

  /* And a second one of the same kind when the categories are numbers rather
     than columns. Zero is deliberately not forced in: what a position along an
     axis encodes is a *place*, so cropping the scale moves every mark by the
     same amount and the picture survives — which is the argument a line chart
     already makes, and the opposite of the one a bar's length makes. An x that
     runs from 100 to 140 dragged down to zero is a plot with all of its data in
     one corner. */
  const spread = xScale === 'value' ? categoryExtent(shownValues, categories) : null;
  const categoryScale =
    xScale === 'value'
      ? valueScale(spread, {
          min: categoryAxis?.min,
          max: categoryAxis?.max,
          tickCount: categoryAxis?.tickCount,
          includeZero: false
        })
      : null;

  const tickTexts = scale.ticks.map((tick, index) =>
    valueAxis?.tickFormat ? String(valueAxis.tickFormat(tick, index)) : formatValue(tick)
  );

  /* The category axis writes either its labels or its own ticks. `format`
     belongs to the value axis and is not borrowed for these — a currency
     applied to an axis of years prints `$2,019` — so the fallback is the plain
     compaction and `xAxis.tickFormat` is how a caller says more. */
  const categoryTickFormat = categoryAxis?.tickFormat;
  const rawCategoryTexts = React.useMemo(
    () =>
      categoryScale
        ? categoryScale.ticks.map((tick, index) =>
            categoryTickFormat
              ? String(categoryTickFormat(tick, index))
              : compactNumber(tick, locale)
          )
        : labels.map((category, index) =>
            categoryTickFormat
              ? String(categoryTickFormat(category, index))
              : formatCategory(category, locale)
          ),
    // A value scale's ticks are a handful of numbers rebuilt with the scale, so
    // only the labels are worth keeping — and the labels are the part that grows
    // with the data: a pointer crossing a plot of ten thousand dates re-renders
    // for every column, and formatting all of them each time was most of it.
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [categoryScale ? categoryScale.ticks.join(' ') : labels, categoryTickFormat, locale]
  );

  const widestTick = tickTexts.reduce((most, text) => Math.max(most, textWidth(text, fontSize)), 0);
  const axisLabelBand = fontSize + 6;

  /* An axis name is written where its axis is: the one along the bottom under
     its ticks, and the one along the left above the plot, since a name turned on
     its side is unreadable at a glance. Each takes its band on that edge — the
     left axis' name used to take a band beside the ticks it was never drawn in,
     and on a horizontal chart it was not drawn at all. */
  const leftAxis = horizontal ? categoryAxis : valueAxis;
  const namesLeftAxis = Boolean(leftAxis?.label) && !leftAxis?.hidden;

  /* How far the category labels are turned, and every measurement that follows
     from it — see `turnedAxis`, which a HeatmapChart's column axis shares.

     Only the axis drawn along the *bottom*, and only when it is the category
     one: a horizontal chart hands each label a row of its own on the left,
     where turning it would take the room it already has, and a value tick is a
     number that was rounded short before it was ever measured. */
  /* Memoised because `categoryTexts` below reads it: a fresh object per render
     would make that memo miss every time, and it is the memo that keeps a
     `truncate` per label off the path a moving pointer re-renders. */
  const tickAngle = horizontal || categoryAxis?.hidden ? 0 : categoryAxis?.tickAngle;
  const turn = React.useMemo(() => turnedAxis(tickAngle, fontSize), [tickAngle, fontSize]);
  const tilted = turn.angle !== 0;

  /* How much room one category label has, before anything is laid out.
     A horizontal chart gives each label a row of its own on the left, so the
     limit is a column width; a vertical one gives it a slot along the bottom,
     so the limit is the slot. */
  const valueBand = valueAxis?.hidden ? 0 : widestTick + 10;
  const slot = (width - (horizontal ? 0 : valueBand) - 16) / Math.max(1, count);

  /* Cut a long name to its slot rather than dropping labels until the rest fit —
     five categories called "Onboarding flow" would otherwise leave one label on
     the axis. Below about four characters that stops helping, and the stride in
     `ChartAxes` takes over instead. A tick is a number that was already rounded
     to be short, so it is never cut: half of `12.4K` is not a smaller number,
     it is a wrong one. */
  /* And the depth a turned label is allowed to run to before it is eating the
     plot rather than getting out of its neighbour's way. Whichever is smaller
     of a fixed ceiling and a share of the box, so a 120px chart does not hand
     two thirds of itself to the axis. */
  const tiltRoom = Math.min(140, plotHeight * 0.4);
  const cutsLabels = !categoryScale && (horizontal || tilted || slot - 6 >= fontSize * 2.4);
  const cutTo = horizontal ? 150 : tilted ? turn.cut(tiltRoom) : slot - 6;
  const categoryTexts = React.useMemo(
    () =>
      cutsLabels
        ? rawCategoryTexts.map((text) => truncate(text, cutTo, fontSize))
        : rawCategoryTexts,
    [rawCategoryTexts, cutsLabels, cutTo, fontSize]
  );

  // A reduce rather than `Math.max(...widths)`: spreading an array passes every
  // element as an argument, and past about a hundred thousand of them that is a
  // RangeError rather than a number.
  const widestCategory = React.useMemo(
    () => categoryTexts.reduce((most, text) => Math.max(most, textWidth(text, fontSize)), 0),
    [categoryTexts, fontSize]
  );

  /* The two bands the axes take out of the box. `hidden` gives the room back to
     the plot, which is the whole reason a sparkline-shaped chart is the same
     component with both axes off rather than a different one. */
  const leftBand = horizontal ? (categoryAxis?.hidden ? 0 : widestCategory + 10) : valueBand;

  /* How deep the labels along the bottom run. One line of type flat, and the
     turned rectangle's own height once they are tilted. */
  const labelDepth = turn.depth(widestCategory);

  const bottomBand = horizontal
    ? valueAxis?.hidden
      ? 0
      : fontSize + 12 + (valueAxis?.label ? axisLabelBand : 0)
    : categoryAxis?.hidden
      ? 0
      : labelDepth + 12 + (categoryAxis?.label ? axisLabelBand : 0);

  // `thickness` belongs to whichever axis is actually on that edge, which swaps
  // with `horizontal` — read off the wrong one, a bar chart turned on its side
  // would take its left margin from the axis along the bottom.
  const left = (horizontal ? categoryAxis : valueAxis)?.thickness ?? leftBand;
  const bottom = (horizontal ? valueAxis : categoryAxis)?.thickness ?? bottomBand;

  // The last category's label is centred on the last tick, so half of it hangs
  // past the plot. Reserving that half is what stops a chart clipping the one
  // label a reader looks for first — and a value axis needs none of it, because
  // it anchors its two end labels inward instead.
  const rightPad =
    (horizontal || categoryScale
      ? 12
      : tilted
        ? // A turned label hangs off one side of its tick rather than both. Up
          // to the right it runs back over the plot, where there is already a
          // margin; down to the right it runs past the last tick, and that is
          // the half that has to be reserved or the last name is cut in two by
          // the edge of the drawing.
          turn.angle > 0
          ? turn.overhang(widestCategory) + 8
          : 8
        : Math.max(8, categoryTexts.length ? turn.overhang(widestCategory) : 8)) + markInset;
  // A mark is drawn from its centre, so half of the widest one hangs over the
  // top of the plot. On a scatter that half is a whole bubble, which is what
  // `markInset` is reserving on the other three sides.
  /* `exportable` draws a 24px button in the top-right corner of the box, so
     the plot starts below it — a button laid over the one series that peaked
     at the right-hand end is a button that ate the answer. */
  const topPad =
    markerRadii[size] +
    4 +
    headroom +
    markInset +
    (namesLeftAxis ? axisLabelBand + 2 : 0) +
    (exportable ? 20 : 0);

  const boxHeight = plotHeight;
  const plot: PlotBox = {
    left: left + markInset,
    top: topPad,
    width: Math.max(0, width - left - markInset - rightPad),
    height: Math.max(0, boxHeight - topPad - bottom - markInset)
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

  const categoryValuePx = React.useCallback(
    (value: number) =>
      horizontal
        ? plot.top + (1 - (categoryScale?.fraction(value) ?? 0)) * plot.height
        : plot.left + (categoryScale?.fraction(value) ?? 0) * plot.width,
    [horizontal, plot.left, plot.top, plot.width, plot.height, categoryScale]
  );

  const zeroPx = valuePx(Math.min(Math.max(0, scale.min), scale.max));

  const layout: CartesianLayout = {
    plot,
    values,
    visible: visibility.visible,
    colors,
    scale,
    band,
    horizontal,
    valuePx,
    categoryPx,
    point,
    categoryScale,
    categoryValuePx,
    zeroPx,
    categories: labels,
    format: formatValue,
    size
  };

  /* The marks, laid out once. They are what the pointer is tested against and
     what `children` draws, and they are the same array both times — a chart
     that placed its dots twice would eventually place them in two places. */
  const markList = marks ? marks(layout) : noMarks;

  /* What a reference is called and what it says, for the hidden list under the
     table. A value-axis number goes through the chart's own `format`; a
     category-axis one is a point on that scale when the categories are numbers
     or dates, and an index into them when they are columns. */
  /* The sheet, as a function so it is built on the press rather than on every
     render. One header row and one row per category, which is the hidden table
     read out sideways — the same numbers, so a reader who exports and a reader
     who is read the table cannot end up with two different files. */
  const exportRows = () => [
    [categoryAxis?.label ?? '', ...series.map((one, index) => one.name ?? `${index + 1}`)],
    ...labels.map((category, index) => [
      category,
      ...values.map((row) => row[index]?.value ?? null)
    ])
  ];

  const namedReferences = (references ?? []).filter((one) => Boolean(one.label));
  const referenceText = (one: NebaChartReference) => {
    const write = (value: number) =>
      (one.axis ?? 'value') === 'value'
        ? formatValue(value)
        : formatCategory(categoryScale ? value : (labels[value] ?? value), locale);

    return one.to === undefined ? write(one.value) : `${write(one.value)}–${write(one.to)}`;
  };

  /* Hover. The nearest category to the pointer rather than the one it is
     literally over: a two-pixel line is not something a pointer can be asked to
     land on, and the hit area for a category is its whole column. */
  const tooltipOptions: NebaChartTooltip =
    tooltip === false ? { mode: 'none' } : tooltip === true || tooltip === undefined ? {} : tooltip;
  const tooltipMode = tooltipOptions.mode ?? (marks ? 'item' : 'index');

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

  /**
   * The mark nearest the pointer, or `null` if it is not near one.
   *
   * A plain distance sweep over the visible marks. The textbook answer is a
   * Voronoi layer, and at the sizes a chart in a card is drawn at — a few
   * hundred marks, recomputed only while a pointer is actually moving over it —
   * building one costs more than it saves.
   *
   * `Math.sqrt` of the sum rather than `Math.hypot`, which is the same number
   * here and several times the work: `hypot` scales its inputs to survive an
   * overflow that two pixel offsets inside one chart cannot produce.
   *
   * The cap is the mark's own radius plus `markRadius`, so a bubble is easier
   * to hit than a dot and neither is as small as it looks: an 8px dot is not
   * something a pointer can be asked to land on.
   */
  const nearestMark = (clientX: number, clientY: number) => {
    const host = hostRef.current;

    if (!host || markList.length === 0) {
      return null;
    }

    const rect = host.getBoundingClientRect();
    const x = clientX - rect.left;
    const y = clientY - rect.top;

    let found: number | null = null;
    let best = Infinity;
    let tie = Infinity;

    // Hidden marks are the builder's business, not this loop's: it is the one
    // place that knows which of its own marks belong to a hidden row, and a
    // chart whose rows are not the frame's series has no `visible` to consult.
    markList.forEach((mark, at) => {
      const dx = mark.x - x;
      const dy = mark.y - y;
      const toCentre = Math.sqrt(dx * dx + dy * dy);
      // How far the pointer is from the mark's *edge*, which is zero anywhere
      // inside it. Ranking on this rather than on the centre is what stops a
      // small mark next door winning a hover the pointer is making on a big one.
      let body: number;

      if (mark.rx === undefined) {
        body = Math.max(0, toCentre - mark.r);
      } else {
        const outX = Math.max(0, Math.abs(dx) - mark.rx);
        const outY = Math.max(0, Math.abs(dy) - (mark.ry ?? mark.rx));

        body = Math.sqrt(outX * outX + outY * outY);
      }

      // Inside two overlapping marks the edge distance is zero for both, and
      // the nearer centre is the one being pointed at.
      if (body <= markRadius && (body < best || (body === best && toCentre < tie))) {
        best = body;
        tie = toCentre;
        found = at;
      }
    });

    return found;
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

  /* Which mark is being read, and the two ways of arriving at one. A chart with
     marks is walked mark by mark; a chart without them is walked column by
     column, and `activeIndex` is then the column. */
  const activeMark = markIndex === null ? null : (markList[markIndex] ?? null);
  const activeIndex = marks ? (activeMark ? activeMark.index : null) : columnIndex;
  const walkLength = marks ? markList.length : count;

  const clearActive = () => {
    setColumnIndex(null);
    setMarkIndex(null);
    setPointer(null);
  };

  useReleaseOutside(hostRef, activeIndex !== null, clearActive);

  const readPointer = (event: React.PointerEvent) => {
    if (tooltipMode === 'none') {
      return;
    }

    // Compared before it is set, not left to React's bail-out: a same-value
    // update right after a real one still renders the chart once before React
    // notices, so the first pixel inside a mark cost a full layout.
    if (marks) {
      const next = nearestMark(event.clientX, event.clientY);

      if (next !== markIndex) setMarkIndex(next);
    } else {
      const next = indexAt(event.clientX, event.clientY);

      if (next !== columnIndex) setColumnIndex(next);
    }

    // Only `item` mode over a column reads this, and only it may pay for it.
    // The index above settles to the same value everywhere inside one column,
    // so React bails out of the re-render — but a pointer offset is a fresh
    // pixel on every event, and storing one the tooltip never consults would
    // re-lay the whole chart out for each pixel the pointer moves. A chart of
    // marks never consults it: its item is the mark.
    if (tooltipMode === 'item' && !marks) {
      setPointer(valueAt(event.clientX, event.clientY));
    }
  };

  const goTo = (at: number | null) => {
    const bounded = at === null ? null : Math.min(walkLength - 1, Math.max(0, at));

    if (marks) {
      setMarkIndex(bounded);
    } else {
      setColumnIndex(bounded);
    }
  };

  const step = (delta: number) => {
    setPointer(null);

    const current = marks ? markIndex : columnIndex;

    goTo((current ?? (delta > 0 ? -1 : walkLength)) + delta);
  };

  const onKeyDown = (event: React.KeyboardEvent) => {
    const forward = horizontal ? 'ArrowDown' : 'ArrowRight';
    const back = horizontal ? 'ArrowUp' : 'ArrowLeft';

    if (event.key === forward) {
      step(1);
    } else if (event.key === back) {
      step(-1);
    } else if (event.key === 'Home') {
      goTo(0);
    } else if (event.key === 'End') {
      goTo(walkLength - 1);
    } else if (event.key === 'Escape') {
      clearActive();
    } else {
      return;
    }

    event.preventDefault();
  };

  const column: ChartTooltipItem[] =
    activeIndex === null
      ? []
      : series.flatMap((one, index) => {
          // A mark names its own series, so there is no column to narrow: two
          // dots at the same index are two unrelated points that happen to be
          // the nth of their series, not two readings of one category.
          if (!visibility.visible[index] || (activeMark && activeMark.series !== index)) {
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
  /* A chart whose marks are not cells of a grid answers for its own panel. */
  const supplied = activeMark && markTooltip ? markTooltip(activeMark) : null;

  const items = supplied
    ? supplied.items
    : tooltipMode === 'item' && column.length > 1 && pointer !== null
      ? [
          column.reduce((nearest, item) =>
            Math.abs(valuePx(item.value ?? 0) - pointer) <
            Math.abs(valuePx(nearest.value ?? 0) - pointer)
              ? item
              : nearest
          )
        ]
      : column;

  /* Where the panel hangs, and what it is titled. A column is anchored on its
     own centre and titled with the category every series in it shares; a mark
     is anchored on itself and titled with its own x, because on a plot with two
     value axes the x is data rather than a heading the marks were filed under. */
  const markCategory = activeMark
    ? (values[activeMark.series]?.[activeMark.index]?.x ??
      categories?.[activeMark.index] ??
      activeMark.index)
    : undefined;

  /* A mark's own x on a value axis is a number, which `formatCategory` wrote
     through `String`: `24000` under an axis reading `24K`. */
  const markHeading = (category: Parameters<typeof formatCategory>[0]) =>
    typeof category === 'number' && categoryScale
      ? numberFormatter(locale, {}).format(category)
      : formatCategory(category, locale);

  const anchorX = activeMark
    ? activeMark.x
    : horizontal
      ? valuePx(items[0]?.value ?? 0)
      : plot.left + categoryPx(activeIndex ?? 0);
  const anchorY = activeMark
    ? activeMark.y
    : horizontal
      ? plot.top + categoryPx(activeIndex ?? 0)
      : plot.top;
  const anchorFlip = activeMark
    ? (activeMark.x - plot.left) / Math.max(1, plot.width) > 0.6
    : (horizontal
        ? scale.fraction(items[0]?.value ?? 0)
        : categoryPx(activeIndex ?? 0) / Math.max(1, categoryLength)) > 0.6;

  const legendOptions: NebaChartLegend =
    legend === false
      ? { interactive: false }
      : legend === true || legend === undefined
        ? {}
        : legend;
  const showLegend = legend === true || (legend !== false && series.length > 1);
  const legendSide = legendOptions.side ?? 'bottom';

  const context: CartesianContext = {
    ...layout,
    hovered: visibility.hovered,
    activeIndex,
    marks: markList,
    activeMark
  };

  // A category axis running on numbers has one more way to have nothing to
  // draw: every point placed by a string, which is not a position on a number
  // line. Drawing the empty state is the honest answer — the alternative is an
  // axis of zeroes with every mark stacked on it.
  const nothing = count === 0 || extent === null || (xScale === 'value' && spread === null);

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
            swatch={swatch}
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
          <>
            {table?.(tableId, formatValue) ?? (
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
            )}

            {/* The references, for the reader who gets the table instead of
                the picture. A target drawn across the plot is context the
                numbers alone do not carry, and a list of two lines is cheaper
                to hear than a sentence that has to be built for it. */}
            {namedReferences.length > 0 ? (
              <ul className={srOnlyClasses}>
                {namedReferences.map((one, index) => (
                  <li key={index}>
                    {one.label}: {referenceText(one)}
                  </li>
                ))}
              </ul>
            ) : null}
          </>
        )
      }
    >
      {exportable && !nothing ? (
        <ChartExport
          rows={exportRows}
          fileName={exportFileName}
          onExport={onExport}
          label={chartWords.exportCsv}
        />
      ) : null}

      {/* Two children rather than one: the readout under the picture has to be
          a *sibling* of it and not a child — see `ChartStatus`. */}
      <div
        ref={hostRef}
        role="img"
        tabIndex={nothing ? undefined : 0}
        // Never the bare prop: `label` is optional, and a focusable `role="img"`
        // with nothing to be called by is a tab stop that announces silence.
        aria-label={label ?? chartWords.label}
        aria-describedby={nothing ? undefined : summaryId}
        onPointerMove={readPointer}
        // A tap moves nothing, so the press itself is what reads the point.
        onPointerDown={(event) => {
          if (event.pointerType === 'touch') {
            readPointer(event);
          }
        }}
        // A finger "leaves" the moment it lifts, which would take the reading
        // away as soon as it appeared. A tap pins it instead, and a press
        // anywhere else puts it down — see `useReleaseOutside`.
        onPointerLeave={(event) => {
          if (event.pointerType !== 'touch') {
            clearActive();
          }
        }}
        // A key press moves the crosshair without a pointer, so `item` mode has
        // nothing to measure against and falls back to the whole column.
        onKeyDown={tooltipMode === 'none' ? undefined : onKeyDown}
        onBlur={clearActive}
        className={cx(
          'relative w-full',
          'rounded-(--neba-radius-xs)',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
        )}
        style={{ height: typeof height === 'string' ? height : plotHeight }}
      >
        {nothing ? (
          <div
            className={cx(
              'flex h-full items-center justify-center text-(--neba-muted-fg)',
              metaTextClasses[size]
            )}
          >
            {empty ?? messages.title}
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
              widestTick={widestTick}
              categoryTexts={categoryTexts}
              widestCategory={widestCategory}
              categoryScale={categoryScale}
              categoryValuePx={categoryValuePx}
              valueAxis={valueAxis}
              categoryAxis={categoryAxis}
              fontSize={fontSize}
              turn={turn}
              labelDepth={labelDepth}
              zeroPx={zeroPx}
            />

            {references && references.length > 0 ? (
              <ChartReferences
                references={references}
                plot={plot}
                horizontal={horizontal}
                valuePx={valuePx}
                categoryPx={categoryPx}
                categoryScale={categoryScale}
                categoryValuePx={categoryValuePx}
                fontSize={fontSize}
              />
            ) : null}

            {/* No crosshair on a chart with marks, whatever mode was asked for:
                a crosshair says "these numbers all belong to this column", and
                there is no column — it would be a line through one dot. */}
            {activeIndex !== null &&
            !marks &&
            tooltipMode === 'index' &&
            tooltipOptions.crosshair !== false
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
                anchorFlip
                  ? { right: `calc(100% - ${anchorX}px + 10px)`, top: anchorY }
                  : { left: anchorX + 10, top: anchorY }
              }
            >
              {tooltipOptions.render({
                index: activeIndex,
                category: markCategory ?? labels[activeIndex],
                items
              })}
            </div>
          ) : (
            <ChartTooltipPanel
              heading={
                supplied ? supplied.heading : markHeading(markCategory ?? labels[activeIndex])
              }
              items={items}
              x={anchorX}
              y={anchorY}
              flip={anchorFlip}
              size={size}
            />
          )
        ) : null}
      </div>

      {/* Only where there is a crosshair to report. A chart with its tooltip
          turned off has nothing to announce, and a live region standing empty
          in the tree forever is a promise it never keeps. */}
      {nothing ? null : (
        <ChartSummary id={summaryId} template={chartWords.summary} locale={locale} {...described} />
      )}

      {tooltipMode === 'none' ? null : (
        <ChartStatus
          heading={
            activeIndex === null
              ? undefined
              : (supplied?.heading ?? markHeading(markCategory ?? labels[activeIndex]))
          }
          items={items}
        />
      )}
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
  /** How wide the widest of `tickTexts` renders, measured once by the chart. */
  widestTick: number;
  /** Either the category labels or, with `categoryScale`, that scale's ticks. */
  categoryTexts: readonly string[];
  /** How wide the widest of `categoryTexts` renders. */
  widestCategory: number;
  categoryScale: ValueScale | null;
  categoryValuePx: (value: number) => number;
  valueAxis?: NebaChartAxis;
  categoryAxis?: NebaChartAxis;
  fontSize: number;
  /** What the category labels measure once turned. An `angle` of 0 is flat. */
  turn: TurnedAxis;
  /** How deep the labels along the bottom run, turned or not. */
  labelDepth: number;
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
  widestTick,
  categoryTexts,
  widestCategory,
  categoryScale,
  categoryValuePx,
  valueAxis,
  categoryAxis,
  fontSize,
  turn,
  labelDepth,
  zeroPx
}: AxesProps) {
  const grid = valueAxis?.grid !== false && !valueAxis?.hidden;
  const leftAxis = horizontal ? categoryAxis : valueAxis;
  const bottomAxis = horizontal ? valueAxis : categoryAxis;
  /* A grid in both directions is graph paper, and on a chart of columns the
     vertical rules do the job the crosshair is already doing under the pointer.
     A plot with two value axes is the exception that makes the rule: there is
     no column to be in, and reading a mark's x off the picture is half of what
     the reader came for — so there, graph paper is the point. */
  const categoryGrid = categoryAxis?.hidden
    ? false
    : (categoryAxis?.grid ?? categoryScale !== null);

  /* Where each category label goes, and how many of them there is room for.
     Ticks and labels are the same problem either way: a value scale's steps are
     already evenly spaced, so both paths are `categoryTexts` laid along an axis
     at a stride. */
  const categoryAlong = (index: number) =>
    categoryScale
      ? categoryValuePx(categoryScale.ticks[index])
      : (horizontal ? plot.top : plot.left) + categoryPx(index);

  /* Zero everywhere but a bottom category axis the caller turned. */
  const tilted = turn.angle !== 0;
  const categoryRoom = turn.room(widestCategory);

  const stride = tickStride(
    categoryTexts.length,
    horizontal ? plot.height : plot.width,
    horizontal ? fontSize * 1.8 : categoryRoom
  );

  /* The value axis needs a stride of its own once it is the *horizontal* one:
     five stacked labels never touch, and five laid across a narrow card read as
     one long number. The gridlines are not thinned with them — a line at a value
     with no label on it is still a line the eye can measure against. */
  const valueStride = tickStride(
    scale.ticks.length,
    horizontal ? plot.width : plot.height,
    horizontal ? Math.max(widestTick, 1) + 16 : fontSize * 2
  );

  /* Whether the end of each axis still has room to be written down. Measured
     from the step it would sit at rather than assumed from the stride. */
  const categoryStep =
    categoryTexts.length > 1 ? Math.abs(categoryAlong(1) - categoryAlong(0)) : plot.width;
  const valueStep =
    scale.ticks.length > 1
      ? Math.abs(valuePx(scale.ticks[1]) - valuePx(scale.ticks[0]))
      : plot.height;

  const lastCategory = fitsLast(
    categoryTexts.length,
    stride,
    categoryStep,
    horizontal
      ? fontSize * 1.8
      : tilted
        ? categoryRoom
        : textWidth(categoryTexts[categoryTexts.length - 1] ?? '', fontSize)
  );
  /* Where a bottom category label is pinned. Flat, one line of type under the
     axis. Turned, the top of the rotated box is what has to clear the axis, and
     `central` puts the anchor half a line-height inside it — measured along the
     turn, which is the `cos`. */
  const categoryBaseline = plot.top + plot.height + turn.offset;

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
            const along = categoryAlong(index);
            // The grid is drawn at every tick and the labels are thinned, for
            // the same reason the value axis does it: a rule with no number on
            // it is still a rule the eye can measure against.
            const labelled = showsTick(index, categoryTexts.length, stride, lastCategory);

            return horizontal ? (
              labelled ? (
                <text
                  key={index}
                  x={plot.left - 8}
                  y={along}
                  textAnchor="end"
                  dominantBaseline="central"
                  fontSize={fontSize}
                  fill="var(--neba-muted-fg)"
                  className={categoryScale ? 'tabular-nums' : undefined}
                >
                  {text}
                </text>
              ) : null
            ) : (
              <g key={index}>
                {categoryGrid ? (
                  <line
                    x1={along}
                    x2={along}
                    y1={plot.top}
                    y2={plot.top + plot.height}
                    stroke="var(--neba-chart-grid)"
                    strokeWidth={1}
                  />
                ) : null}
                {labelled ? (
                  <text
                    x={along}
                    y={categoryBaseline}
                    /* Turned, the label hangs off one end of its tick rather
                       than sitting either side of it: up to the right it ends
                       at the tick, down to the right it starts there. Flat, a
                       value scale's two end ticks sit on the ends of the plot,
                       so half of each would hang outside — the same inward
                       anchor the horizontal value axis makes, and the reason a
                       scatter needs no margin reserved on its right. */
                    textAnchor={
                      tilted
                        ? turn.anchor
                        : !categoryScale
                          ? 'middle'
                          : index === 0
                            ? 'start'
                            : index === categoryTexts.length - 1
                              ? 'end'
                              : 'middle'
                    }
                    /* About the anchor, which is the point the label is pinned
                       to the axis by. `central` puts that point at the middle
                       of the type rather than on its baseline, so the turn is
                       about the text itself and a quarter turn stands a name
                       on the tick rather than beside it. */
                    transform={
                      tilted ? `rotate(${turn.angle} ${along} ${categoryBaseline})` : undefined
                    }
                    dominantBaseline={tilted ? 'central' : undefined}
                    fontSize={fontSize}
                    fill="var(--neba-muted-fg)"
                    className={categoryScale ? 'tabular-nums' : undefined}
                  >
                    {text}
                  </text>
                ) : null}
              </g>
            );
          })}
        </>
      )}

      {/* The axis names, in the bands the frame reserved for them: the left
          axis' along the top of the box, starting where the plot does, and the
          bottom axis' under its ticks at the far end. A hidden axis has neither
          a band nor a name. */}
      {leftAxis?.label && !leftAxis.hidden ? (
        // Two pixels below one em, and the band two taller: a font with a tall
        // ascent (the Noto Sans many Linux systems default to) reaches above a
        // baseline set at one em, and the SVG clips at its top edge.
        <text
          x={plot.left}
          y={fontSize + 2}
          textAnchor="start"
          fontSize={fontSize}
          fill="var(--neba-muted-fg)"
          fontWeight={500}
        >
          {leftAxis.label}
        </text>
      ) : null}
      {bottomAxis?.label && !bottomAxis.hidden ? (
        <text
          x={plot.left + plot.width}
          // Under the labels rather than under one line of them: a turned axis
          // is as deep as its longest name, and the name of the axis was
          // written straight through it.
          y={plot.top + plot.height + labelDepth + fontSize + 12}
          textAnchor="end"
          fontSize={fontSize}
          fill="var(--neba-muted-fg)"
          fontWeight={500}
        >
          {bottomAxis.label}
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
  ChartExport,
  ChartLegendBar,
  ChartScaleLegend,
  ChartStatus,
  ChartSummary,
  ChartSurface,
  ChartTooltipPanel,
  summarise,
  chartHeight,
  useMeasuredHeight,
  useMeasuredWidth,
  useReleaseOutside,
  useVisibility
};
export type { Visibility };
