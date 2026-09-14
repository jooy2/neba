'use client';

import * as React from 'react';
import { CartesianChart, type CartesianChartProps } from '../../internal/chart-frame.js';
import { LineSeries, type ChartMarkers } from '../../internal/chart-line.js';
import type { NebaChartCurve, NebaChartValueLabels } from '../../types.js';

export interface AreaChartProps extends CartesianChartProps {
  /**
   * How the edge of the band gets from one point to the next. The same three
   * shapes a [LineChart](./line-chart) offers, and they mean the same things.
   * @default 'linear'
   */
  curve?: NebaChartCurve;
  /**
   * Stacks the bands, each one riding on the total of those below it.
   *
   * - `true` — absolute totals. The top edge is the sum, which is the thing a
   *   stacked area is usually drawn to show.
   * - `'full'` — every category normalised to 100%, so the chart is about
   *   *share* and stops being about size. The value axis becomes a percentage
   *   and says so.
   * @default false
   */
  stacked?: boolean | 'full';
  /**
   * Dots on the points. `none` by default rather than `auto`: a filled band
   * already has a visible edge, and a row of dots on it is ink that says
   * nothing the fill did not.
   * @default 'none'
   */
  markers?: ChartMarkers;
  /** @default 'none' */
  valueLabels?: NebaChartValueLabels;
  /**
   * Draws the band straight through a `null` instead of breaking at it. Off,
   * and on an area it matters more than on a line: a fill that closes across a
   * missing month paints a made-up number over a larger part of the chart.
   * @default false
   */
  connectNulls?: boolean;
}

/**
 * A line with the space under it filled — which changes what the chart is
 * about.
 *
 * A line says where a value went. An area says how much of something there was,
 * and stacked it says how that amount was made up. That is the whole test for
 * reaching for this instead of a [LineChart](./line-chart): if the quantity
 * does not add up to anything — a temperature, a rate, a score — the fill under
 * it is decoration, and a chart with two of them is two washes fighting.
 *
 * Unstacked bands are a wash at about a quarter opacity, fading out downward,
 * so two of them overlapping stay readable. Stacked bands are opaquer, because
 * there the fill *is* the mark rather than a hint at the line above it.
 */
export function AreaChart({
  curve = 'linear',
  stacked = false,
  markers = 'none',
  valueLabels = 'none',
  connectNulls = false,
  series,
  yAxis,
  format,
  ...props
}: AreaChartProps) {
  const id = React.useId().replace(/:/g, '');
  const full = stacked === 'full';

  return (
    <CartesianChart
      {...props}
      series={series}
      // 100% stacking is done by the frame, which knows which series the legend
      // has hidden and so which ones the hundred is shared between.
      stackedFull={full}
      format={format}
      yAxis={full ? { min: 0, max: 100, tickFormat: (value) => `${value}%`, ...yAxis } : yAxis}
      stacked={stacked !== false}
      inset
      // Unlike a line, an area's *fill* is its magnitude, so the baseline has to
      // be zero or the band's thickness stops meaning anything.
      includeZero
      headroom={valueLabels === 'none' ? 0 : 10}
    >
      {(context) => (
        <LineSeries
          context={context}
          curve={curve}
          filled
          stacked={stacked !== false}
          markers={markers}
          valueLabels={valueLabels}
          connectNulls={connectNulls}
          gradient={false}
          idPrefix={id}
        />
      )}
    </CartesianChart>
  );
}
