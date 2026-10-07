'use client';

import * as React from 'react';
import {
  CartesianChart,
  markTransitionClasses,
  type CartesianChartProps,
  type CartesianContext
} from '../../internal/chart-frame.js';
import {
  barBandRatio,
  barMaxThickness,
  barPath,
  barRadius,
  chartFontSizes,
  labelInk,
  labelledPoints,
  markGap,
  type ChartValue
} from '../../internal/chart.js';
import type { NebaChartValueLabels, NebaOrientation, NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface BarChartProps extends CartesianChartProps {
  /**
   * Which way the bars run.
   *
   * `vertical` — the default — grows them up from the bottom, which is what
   * most people mean by a bar chart. `horizontal` grows them out from the left,
   * and it is the right answer whenever the category names are words: a
   * horizontal chart has a whole column for them, and a vertical one has the
   * width of one bar.
   * @default 'vertical'
   */
  orientation?: NebaOrientation;
  /**
   * Puts the series on top of each other instead of beside each other.
   *
   * - `false` — grouped. Comparing series within a category.
   * - `true` — stacked. The bar's whole length is the total, and the segments
   *   are what it is made of.
   * - `'full'` — every bar the same length, so the chart is about share rather
   *   than size. The value axis becomes a percentage.
   * @default false
   */
  stacked?: boolean | 'full';
  /**
   * Cuts the corners off the data end of each bar. The baseline end stays
   * square — that is where the value starts from, and a rounded foot makes the
   * axis look scalloped.
   * @default true
   */
  rounded?: boolean;
  /**
   * How thick a bar may get, in pixels. Below the cap the bars fill their share
   * of the band; above it the leftover stays as air.
   * @default the `size` ladder — 24 at `md`
   */
  barSize?: number;
  /**
   * Which values are written on the bars.
   *
   * `all` is defensible here in a way it is not on a line chart: eight bars
   * with their numbers on them is a chart and a table at once. Past about a
   * dozen it stops being either.
   * @default 'none'
   */
  valueLabels?: NebaChartValueLabels;
}

/**
 * Lengths, compared.
 *
 * A bar says *how much*, and it says it by being longer — which is the whole
 * reason its axis includes zero unless `yAxis` pins an end. Crop the scale
 * and a bar twice as long stops meaning twice as much, and the reader has no
 * way to know it happened. Reach for a [LineChart](./line-chart) when what
 * matters is the shape of a change rather than the size of each value.
 *
 * Grouped bars answer "which series is bigger here"; stacked bars answer "what
 * is this total made of". They are different questions and the chart should be
 * asked only one of them at a time.
 */
export function BarChart(rawProps: BarChartProps) {
  const {
    orientation = 'vertical',
    stacked = false,
    rounded = true,
    barSize,
    valueLabels = 'none',
    series,
    yAxis,
    size = 'md',
    density = 'default',
    ...props
  } = useStyleDefaults(rawProps, ['size', 'density']);

  const horizontal = orientation === 'horizontal';
  const full = stacked === 'full';

  return (
    <CartesianChart
      {...props}
      series={series}
      // 100% stacking is done by the frame, which knows which series the legend
      // has hidden and so which ones the hundred is shared between.
      stackedFull={full}
      size={size}
      density={density}
      horizontal={horizontal}
      stacked={stacked !== false}
      yAxis={full ? { min: 0, max: 100, tickFormat: (value) => `${value}%`, ...yAxis } : yAxis}
      // A bar's length is its value, so zero is not optional.
      includeZero
      bandRatio={barBandRatio[density]}
      headroom={valueLabels === 'none' ? 0 : 12}
    >
      {(context) => (
        <Bars
          context={context}
          stacked={stacked !== false}
          rounded={rounded}
          barSize={barSize ?? barMaxThickness[size]}
          valueLabels={valueLabels}
          size={size}
        />
      )}
    </CartesianChart>
  );
}

interface BarsProps {
  context: CartesianContext;
  stacked: boolean;
  rounded: boolean;
  barSize: number;
  valueLabels: NebaChartValueLabels;
  size: NebaSize;
}

/** One bar, laid out: its outline, its fill, and the number written past its end. */
interface PlacedBar {
  category: number;
  path: string;
  fill: string;
  label: {
    x: number;
    y: number;
    anchor: 'start' | 'middle' | 'end';
    baseline: 'central' | undefined;
    fill: string;
    text: React.ReactNode;
  } | null;
}

/** One series' bars, in runs a column's change can draw again on their own. */
interface PlacedSeries {
  index: number;
  runs: PlacedBar[][];
}

/**
 * How many bars one memoised run draws.
 *
 * The crosshair moving from one column to the next changes two bars per
 * series, and only the runs holding them are drawn again. Without runs every
 * bar's path was written again on each move — on a year of daily bars in three
 * series, eleven hundred of them for six that changed.
 */
const barRun = 64;

/**
 * The bars themselves, and the only part of a BarChart that is not the shared
 * frame.
 *
 * Two arrangements out of one loop: grouped bars split the band between the
 * visible series, stacked ones take the whole band and are pushed along by
 * whatever came before them. In both, the 2px between two touching marks is the
 * surface showing through and never a stroke — a border drawn around a bar is
 * ink that is not data.
 *
 * Laid out once per layout rather than once per render. What the pointer
 * changes is which column is active and which series the legend is pointing
 * at, and neither moves a bar: the active column is handed only to the run
 * that holds it, and the dimming is a group's opacity.
 */
function Bars({ context, stacked, rounded, barSize, valueLabels, size }: BarsProps) {
  const {
    values,
    visible,
    colors,
    hovered,
    activeIndex,
    plot,
    band,
    horizontal,
    valuePx,
    categoryPx,
    zeroPx,
    zeroPxOf,
    formatFor
  } = context;

  // The same type as an axis tick. A value written on a mark is the same kind
  // of thing as one written under it, and two sizes of number on one chart
  // reads as two levels of importance that are not there.
  const labelSize = chartFontSizes[size];

  const placed = React.useMemo(() => {
    const drawn = values
      .map((one, index) => ({ one, index }))
      .filter((entry) => visible[entry.index]);
    const lanes = stacked ? 1 : Math.max(1, drawn.length);

    const laneWidth = Math.min(barSize, Math.max(1, (band.band - markGap * (lanes - 1)) / lanes));
    const groupWidth = laneWidth * lanes + markGap * (lanes - 1);

    /* Where each stacked segment starts, kept per category and per sign: a
       negative segment grows down from zero while the positives grow up, or a
       series that dips takes a bite out of the one above it. */
    const positive: number[] = [];
    const negative: number[] = [];

    return drawn.map(({ one, index }, lane): PlacedSeries => {
      const color = colors[index];
      // `last` is the last value there is, as LineChart reads it: a trailing
      // `null` left the series with no label at all.
      const extreme =
        valueLabels === 'extremes' || valueLabels === 'last'
          ? labelledPoints(one, valueLabels)
          : null;
      const bars: PlacedBar[] = [];

      one.forEach((value: ChartValue, category: number) => {
        if (value.value === null) {
          return;
        }

        const centre = categoryPx(category);
        const offset = stacked ? 0 : lane * (laneWidth + markGap) - groupWidth / 2 + laneWidth / 2;

        const base = stacked
          ? value.value >= 0
            ? (positive[category] ?? 0)
            : (negative[category] ?? 0)
          : 0;

        // With the index, so a bar on the far edge's scale is measured
        // against that one. `stacked` and a second axis never both apply,
        // so `base` is zero wherever `index` changes the answer.
        const from = base === 0 ? zeroPxOf(index) : valuePx(base, index);
        const to = valuePx(base + value.value, index);

        if (stacked) {
          if (value.value >= 0) {
            positive[category] = base + value.value;
          } else {
            negative[category] = base + value.value;
          }
        }

        // The gap between two stacked segments is taken off the far end of
        // each, so the stack still totals the right length and the seam is
        // the sheet rather than a line drawn on it.
        const shrink = stacked && base !== 0 ? markGap : 0;
        const length = Math.abs(to - from) - shrink;

        if (length <= 0) {
          return;
        }

        const grows = to < from;

        const path = horizontal
          ? barPath(
              Math.min(from, to) + (grows ? 0 : shrink),
              plot.top + centre + offset - laneWidth / 2,
              length,
              laneWidth,
              rounded && !stacked ? barRadius : rounded ? barRadius / 2 : 0,
              value.value >= 0 ? 'right' : 'left'
            )
          : barPath(
              plot.left + centre + offset - laneWidth / 2,
              Math.min(from, to) + (grows ? 0 : shrink),
              laneWidth,
              length,
              rounded && !stacked ? barRadius : rounded ? barRadius / 2 : 0,
              value.value >= 0 ? 'up' : 'down'
            );

        bars.push({
          category,
          path,
          fill: value.color ?? color,
          label:
            valueLabels === 'none' || (extreme && !extreme(category))
              ? null
              : {
                  // Always just past the data end, on the outside — which for
                  // a bar that grows downward means *below* it. Kept at the
                  // end rather than inside the fill so it never has to be
                  // white on one bar and ink on the next.
                  x: horizontal ? to + (value.value >= 0 ? 5 : -5) : plot.left + centre + offset,
                  y: horizontal
                    ? plot.top + centre + offset
                    : value.value >= 0
                      ? to - 5
                      : to + labelSize + 2,
                  anchor: horizontal ? (value.value >= 0 ? 'start' : 'end') : 'middle',
                  baseline: horizontal ? 'central' : undefined,
                  // Its own bar's colour, one step toward the page's ink —
                  // see `labelInk`. On a grouped chart the label sits over
                  // the gap between two bands, and the hue is what says
                  // which of the two it belongs to.
                  fill: labelInk(value.color ?? color),
                  text: value.label ?? formatFor(index)(value.value)
                }
        });
      });

      const runs: PlacedBar[][] = [];

      for (let at = 0; at < bars.length; at += barRun) {
        runs.push(bars.slice(at, at + barRun));
      }

      return { index, runs };
    });
  }, [
    values,
    visible,
    colors,
    plot,
    band,
    horizontal,
    valuePx,
    categoryPx,
    zeroPxOf,
    formatFor,
    stacked,
    rounded,
    barSize,
    valueLabels,
    labelSize
  ]);

  return (
    <g>
      {placed.map(({ index, runs }) => {
        const dimmed = hovered !== null && hovered !== index;

        return (
          <g key={index} opacity={dimmed ? 0.28 : 1} className={markTransitionClasses}>
            {runs.map((run, at) => (
              <BarRun
                key={at}
                bars={run}
                active={
                  activeIndex !== null &&
                  activeIndex >= run[0].category &&
                  activeIndex <= run[run.length - 1].category
                    ? activeIndex
                    : null
                }
                labelSize={labelSize}
              />
            ))}
          </g>
        );
      })}

      {/* The baseline, redrawn over the bars. Every bar starts here and the line
          is what says so; under them it is half-hidden by the first pixel of
          each one. */}
      {horizontal ? (
        <line
          x1={zeroPx}
          x2={zeroPx}
          y1={plot.top}
          y2={plot.top + plot.height}
          stroke="var(--neba-chart-baseline)"
          strokeWidth={1}
        />
      ) : (
        <line
          x1={plot.left}
          x2={plot.left + plot.width}
          y1={zeroPx}
          y2={zeroPx}
          stroke="var(--neba-chart-baseline)"
          strokeWidth={1}
        />
      )}
    </g>
  );
}

interface BarRunProps {
  bars: readonly PlacedBar[];
  /** The active column, when one of these bars is in it. */
  active: number | null;
  labelSize: number;
}

/** A run of one series' bars, drawn again only when something in it changes. */
const BarRun = React.memo(function BarRun({ bars, active, labelSize }: BarRunProps) {
  return (
    <>
      {bars.map((bar) => (
        <g key={bar.category}>
          <path
            d={bar.path}
            fill={bar.fill}
            opacity={bar.category === active ? 1 : 0.92}
            className={markTransitionClasses}
          />

          {bar.label ? (
            <text
              x={bar.label.x}
              y={bar.label.y}
              textAnchor={bar.label.anchor}
              dominantBaseline={bar.label.baseline}
              fontSize={labelSize}
              fontWeight={500}
              fill={bar.label.fill}
              className="tabular-nums"
            >
              {bar.label.text}
            </text>
          ) : null}
        </g>
      ))}
    </>
  );
});
