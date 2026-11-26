/**
 * The marks a LineChart and an AreaChart draw.
 *
 * They are one picture with one part switched off, which is exactly the case
 * `internal/` exists for: an area is a line with the space under it filled, and
 * a stacked area is that with each band sitting on the one below. Writing the
 * path arithmetic twice would mean a `curve="smooth"` that curves differently
 * depending on which of the two components a caller reached for.
 *
 * Sparkline deliberately does *not* come through here. It has no axes, no
 * legend and no stacking, and what it needs from `chart.ts` is two function
 * calls — routing it through a component built for a full plot would cost it
 * the thing that makes it a sparkline.
 */

import * as React from 'react';
import {
  areaPath,
  chartFontSizes,
  labelInk,
  labelledPoints,
  linePath,
  lineWidths,
  markerRadii,
  markGap,
  type ChartValue,
  type PlotBox
} from './chart.js';
import { markTransitionClasses } from './chart-frame.js';
import type { CartesianContext } from './chart-frame.js';
import type { NebaChartCurve, NebaChartValueLabels, NebaSize } from '../types.js';

/** Whether a point gets a dot on it. */
export type ChartMarkers = 'none' | 'auto' | 'all';

/** Past this many points a dot per point is a row of dots, not a series. */
const autoMarkerLimit = 14;

export interface LineSeriesProps {
  context: CartesianContext;
  curve: NebaChartCurve;
  /** Fills the space between the line and whatever is under it. */
  filled: boolean;
  /** Each band sits on the total of the ones before it. */
  stacked: boolean;
  markers: ChartMarkers;
  valueLabels: NebaChartValueLabels;
  /**
   * Bridges a gap instead of breaking at it. Off by default, and it should
   * stay off unless the caller knows the gap is an artefact of collection
   * rather than a month where nothing happened.
   */
  connectNulls: boolean;
  /**
   * Fades the line from a paler step of its own hue at the old end to the full
   * colour at the new one. One hue throughout — a stroke that changes hue along
   * its length is a second series pretending to be one.
   */
  gradient: boolean;
  /** Unique per chart instance, so two charts' gradient defs cannot collide. */
  idPrefix: string;
}

/**
 * A point on the plot, or `null` where the series has a gap.
 *
 * The `null` is the whole reason this is built as an array rather than filtered:
 * it is what breaks the path, and a filtered array would silently join the two
 * sides of a missing month into one straight line.
 */
type Vertex = { x: number; y: number } | null;

/** One series, laid out: where its points are, and the three paths it can draw. */
interface Traced {
  tops: Vertex[];
  area: string | null;
  gap: string | null;
  line: string | null;
  labelled: (index: number) => boolean;
}

/** Drops the gaps out of a run of vertices, for a series that bridges them. */
const bridged = (vertices: Vertex[]) => vertices.filter(Boolean) as { x: number; y: number }[];

export function LineSeries({
  context,
  curve,
  filled,
  stacked,
  markers,
  valueLabels,
  connectNulls,
  gradient,
  idPrefix
}: LineSeriesProps) {
  const { values, visible, colors, hovered, activeIndex, plot, point, zeroPxOf, size, formatFor } =
    context;

  const stroke = lineWidths[size];
  const radius = markerRadii[size];

  /* Every point and every path, worked out once per layout rather than once per
     render. The pointer moving from one column to the next changes which marker
     is drawn and nothing else, and tracing three thousand points into path data
     on each of those moves was most of what the move cost. `point` and
     `zeroPxOf` keep their identity until the plot itself changes. */
  const traced = React.useMemo(() => {
    /** The band that sits on the axis, and so the one with nothing to be parted from. */
    const first = visible.indexOf(true);

    /* The running totals each band sits on, one per sign. A positive value
       stacks up from the zero line and a negative one down from it, which is
       how `extentOf` sums the axis: added together regardless of sign, a
       negative series pulled every band above it down, so the top of the stack
       no longer met the axis and the bands overlapped. Only the visible series
       contribute: hiding one from the legend has to close the gap it left, or a
       stacked chart with a series turned off reads as a chart with a hole in it. */
    const baselines: number[][] = [];
    const above: number[] = [];
    const below: number[] = [];

    values.forEach((one, index) => {
      const under = one.map((value, category) =>
        (value.value ?? 0) < 0 ? (below[category] ?? 0) : (above[category] ?? 0)
      );

      baselines.push(under);

      if (!stacked || !visible[index]) {
        return;
      }

      one.forEach((value, category) => {
        const amount = value.value ?? 0;

        if (amount < 0) {
          below[category] = (below[category] ?? 0) + amount;
        } else {
          above[category] = (above[category] ?? 0) + amount;
        }
      });
    });

    return values.map((one, index): Traced | null => {
      if (!visible[index]) {
        return null;
      }

      const tops: Vertex[] = one.map((value, category) => {
        if (value.value === null) {
          return null;
        }

        const total = stacked ? baselines[index][category] + value.value : value.value;

        // The series' index goes with the number: with a second value axis on
        // the plot, where a value sits is no longer a property of the value
        // alone. `stacked` and the second axis never both apply.
        return point(category, total, index);
      });

      // `connectNulls` drops the gaps rather than bridging them in the path
      // builder: a bridged segment and a real one have to be the same shape,
      // and the only way to guarantee that is for the builder never to know
      // the difference.
      const line = connectNulls ? bridged(tops) : tops;

      const base = zeroPxOf(index);
      const under: Vertex[] = one.map((value, category) =>
        value.value === null
          ? null
          : stacked
            ? point(category, baselines[index][category], index)
            : { x: point(category, value.value, index).x, y: base }
      );
      const floor = connectNulls ? bridged(under) : under;

      // A stacked band's fill *is* its mark, so it does not also get a line
      // drawn along the top: the band above would then be separated from it
      // by a coloured stroke, and a stroke between two marks is ink that is
      // not data. What separates them is the gap below.
      const banded = filled && stacked;

      return {
        tops,
        area: filled ? areaPath(line, floor, curve) : null,
        // The 2px of surface between this band and the one under it. Drawn on
        // the *lower* edge so the top of the stack keeps its silhouette, and
        // skipped on the first band, whose lower edge is the axis.
        gap: banded && index !== first ? linePath(floor, curve) : null,
        line: banded ? null : linePath(line, curve),
        labelled: labelledPoints(one, valueLabels)
      };
    });
  }, [values, visible, stacked, filled, connectNulls, curve, point, zeroPxOf, valueLabels]);

  return (
    <g>
      <defs>
        {/* Across the plot rather than across the line's own box. A flat
            series has a box with no height, and a gradient measured against
            one is ignored — which leaves the stroke painted with nothing. */}
        {gradient
          ? colors.map((color, index) => (
              <linearGradient
                key={`stroke-${index}`}
                id={`${idPrefix}-stroke-${index}`}
                gradientUnits="userSpaceOnUse"
                x1={plot.left}
                y1={0}
                x2={plot.left + plot.width}
                y2={0}
              >
                <stop offset="0%" stopColor={`color-mix(in oklab, ${color} 45%, transparent)`} />
                <stop offset="100%" stopColor={color} />
              </linearGradient>
            ))
          : null}

        {/* A wash and not a block: an area that is a saturated slab hides
            whatever it overlaps and makes the line on top of it redundant.
            Stacked bands skip this and take a flat tint, because there the
            fill *is* the mark and a band that fades out has no bottom edge. */}
        {filled && !stacked
          ? colors.map((color, index) => (
              <linearGradient
                key={`fill-${index}`}
                id={`${idPrefix}-fill-${index}`}
                x1="0"
                y1="0"
                x2="0"
                y2="1"
              >
                <stop offset="0%" stopColor={`color-mix(in oklab, ${color} 28%, transparent)`} />
                <stop offset="100%" stopColor={`color-mix(in oklab, ${color} 2%, transparent)`} />
              </linearGradient>
            ))
          : null}
      </defs>

      {values.map((one, index) => {
        const trace = traced[index];

        if (!trace) {
          return null;
        }

        const { tops, labelled } = trace;
        const color = colors[index];
        const dimmed = hovered !== null && hovered !== index;

        /* Which points get a dot. All of them, or none but the one under the
           crosshair — and in the second case only that one is visited, since a
           walk over every point to draw one of them is the cost the memo above
           exists to take off a moving pointer. All of them are drawn in runs
           for the same reason: see `markerRun`. */
        const everyMarker =
          markers === 'all' || (markers === 'auto' && one.length <= autoMarkerLimit);

        return (
          <g key={index} opacity={dimmed ? 0.28 : 1} className={markTransitionClasses}>
            {trace.area === null ? null : (
              <path
                d={trace.area}
                fill={
                  stacked
                    ? `color-mix(in oklab, ${color} 70%, transparent)`
                    : `url(#${idPrefix}-fill-${index})`
                }
                stroke="none"
              />
            )}

            {trace.gap === null ? null : (
              <path
                d={trace.gap}
                fill="none"
                stroke="var(--neba-chart-gap)"
                strokeWidth={markGap}
              />
            )}

            {trace.line === null ? null : (
              <path
                d={trace.line}
                fill="none"
                stroke={gradient ? `url(#${idPrefix}-stroke-${index})` : color}
                strokeWidth={stroke}
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            )}

            {everyMarker
              ? runsOf(tops.length).map(([from, to]) => (
                  <MarkerRun
                    key={from}
                    tops={tops}
                    values={one}
                    from={from}
                    to={to}
                    color={color}
                    radius={radius}
                    active={
                      activeIndex !== null && activeIndex >= from && activeIndex < to
                        ? activeIndex
                        : null
                    }
                  />
                ))
              : activeIndex === null
                ? null
                : marker(tops, one, activeIndex, color, radius, activeIndex)}

            {valueLabels === 'none' ? null : (
              <ValueLabels
                tops={tops}
                values={one}
                labelled={labelled}
                color={color}
                plot={plot}
                radius={radius}
                size={size}
                series={index}
                formatFor={formatFor}
              />
            )}
          </g>
        );
      })}
    </g>
  );
}

/**
 * How many points one memoised run of markers draws.
 *
 * With a dot on every point, the crosshair moving from one column to the next
 * grows one dot and shrinks another, and only the runs holding those two are
 * drawn again. Without runs every dot on every line was — twelve hundred on a
 * chart of three 400-point series with `markers="all"`, for two that changed.
 */
const markerRun = 64;

/** The ranges a series of `count` points is drawn in, `markerRun` points each. */
function runsOf(count: number): [number, number][] {
  const runs: [number, number][] = [];

  for (let from = 0; from < count; from += markerRun) {
    runs.push([from, Math.min(count, from + markerRun)]);
  }

  return runs;
}

/** One point's dot, a pixel bigger when it is the active one. */
function marker(
  tops: readonly Vertex[],
  values: readonly ChartValue[],
  category: number,
  color: string,
  radius: number,
  active: number | null
) {
  const vertex = tops[category];

  if (!vertex) {
    return null;
  }

  return (
    <circle
      key={category}
      cx={vertex.x}
      cy={vertex.y}
      r={category === active ? radius + 1 : radius}
      fill={values[category].color ?? color}
      // The ring is the surface showing through, which is what keeps a marker
      // legible where two lines cross — and it is part of the hit target, not
      // only spacing.
      stroke="var(--neba-chart-gap)"
      strokeWidth={markGap}
      className={markTransitionClasses}
    />
  );
}

interface MarkerRunProps {
  tops: readonly Vertex[];
  values: readonly ChartValue[];
  /** The first point this run draws, and the one after its last. */
  from: number;
  to: number;
  color: string;
  radius: number;
  /** The active column, when it is one of these points. */
  active: number | null;
}

/** A run of one series' dots, drawn again only when something in it changes. */
const MarkerRun = React.memo(function MarkerRun({
  tops,
  values,
  from,
  to,
  color,
  radius,
  active
}: MarkerRunProps) {
  const dots: React.ReactNode[] = [];

  for (let category = from; category < to; category++) {
    dots.push(marker(tops, values, category, color, radius, active));
  }

  return <>{dots}</>;
});

interface ValueLabelsProps {
  tops: readonly Vertex[];
  values: readonly ChartValue[];
  labelled: (index: number) => boolean;
  color: string;
  plot: PlotBox;
  radius: number;
  size: NebaSize;
  /** Which series these are, for the format its axis writes numbers in. */
  series: number;
  formatFor: (series: number) => (value: number) => string;
}

/**
 * The numbers written on one line.
 *
 * Memoised because nothing in them depends on the pointer: every prop is a
 * number or something laid out once per layout, so the crosshair moving from
 * one column to the next leaves them alone instead of writing every label on
 * every line again.
 */
const ValueLabels = React.memo(function ValueLabels({
  tops,
  values,
  labelled,
  color,
  plot,
  radius,
  size,
  series,
  formatFor
}: ValueLabelsProps) {
  const write = formatFor(series);

  return (
    <>
      {tops.map((vertex, category) => {
        const value = values[category].value;

        if (!vertex || value === null || !labelled(category)) {
          return null;
        }

        return (
          <text
            key={`label-${category}`}
            x={vertex.x}
            y={vertex.y - radius - 5}
            textAnchor={
              vertex.x > plot.left + plot.width - 24
                ? 'end'
                : vertex.x < plot.left + 24
                  ? 'start'
                  : 'middle'
            }
            fontSize={chartFontSizes[size]}
            fontWeight={500}
            // Its own series' colour, one step toward the page's ink. Four
            // lines on one plot is four numbers floating over them, and which
            // line each belongs to is exactly what a reader cannot work out
            // where two of them cross.
            fill={labelInk(values[category].color ?? color)}
            className="tabular-nums"
          >
            {values[category].label ?? write(value)}
          </text>
        );
      })}
    </>
  );
});
