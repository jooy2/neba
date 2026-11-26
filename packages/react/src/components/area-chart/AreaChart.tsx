'use client';

import * as React from 'react';
import { CartesianChart, type CartesianChartProps } from '../../internal/chart-frame.js';
import { LineSeries, type ChartMarkers } from '../../internal/chart-line.js';
import { zeroGaps } from '../../internal/chart.js';
import type { NebaChartCurve, NebaChartNulls, NebaChartValueLabels } from '../../types.js';

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
   * What the band does where a value is missing, and it matters more here than
   * on a line: a fill that closes over a missing month paints a made-up number
   * across a whole region rather than along a segment.
   *
   * `gap` is the default. `zero` reads the hole as a nought everywhere — the
   * axis, the tooltip and the table with it — which on a stacked chart is often
   * what a caller actually meant, since a band that breaks takes the bands
   * above it with it.
   * @default 'gap'
   */
  nulls?: NebaChartNulls;
  /**
   * Draws the band straight through a `null` instead of breaking at it.
   * @deprecated Pass `nulls="connect"`. Read only when `nulls` is left out.
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
  nulls,
  connectNulls = false,
  series,
  yAxis,
  format,
  ...props
}: AreaChartProps) {
  const id = React.useId().replace(/:/g, '');
  const full = stacked === 'full';
  const gaps = nulls ?? (connectNulls ? 'connect' : 'gap');
  // Memoised for the reason LineChart's is: the frame keys its unpack on this
  // array's identity, and a fresh one per render would re-measure the plot
  // while the pointer is only crossing it.
  const drawn = React.useMemo(() => (gaps === 'zero' ? zeroGaps(series) : series), [series, gaps]);

  return (
    <CartesianChart
      {...props}
      series={drawn}
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
          connectNulls={gaps === 'connect'}
          gradient={false}
          idPrefix={id}
        />
      )}
    </CartesianChart>
  );
}
