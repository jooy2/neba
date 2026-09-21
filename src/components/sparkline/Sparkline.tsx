'use client';

import * as React from 'react';
import {
  areaPath,
  barMaxThickness,
  barPath,
  barRadius,
  extentOf,
  lineWidths,
  markerRadii,
  markGap,
  resolveColor,
  sparklineHeights,
  toValue
} from '../../internal/chart.js';
import { useMeasuredWidth } from '../../internal/chart-frame.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type {
  NebaChartCurve,
  NebaChartDatum,
  NebaChartNulls,
  NebaColor,
  NebaSize
} from '../../types.js';
import { linePath } from '../../internal/chart.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface SparklineProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /** The values. `null` is a gap, exactly as it is on every other chart. */
  data: readonly NebaChartDatum[];
  /**
   * Which mark. A line for a trend, an area for a quantity, bars for a count of
   * discrete things — the same three sentences the full charts say, at a size
   * where nothing else is being said at all.
   * @default 'line'
   */
  shape?: 'line' | 'area' | 'bar';
  /** @default 'linear' */
  curve?: NebaChartCurve;
  /**
   * What the strip does where a value is missing: break at it, bridge it, or
   * read it as a nought. The same three answers a
   * [LineChart](./line-chart) gives, and they mean the same things.
   *
   * It matters more here than on a full chart, because there is no tooltip and
   * no axis to notice the hole with: a strip that quietly closes over three
   * missing weeks is a trend nobody can tell was interpolated. `zero` rewrites
   * the values, so the range the strip scales itself to takes the nought in and
   * the numbers read out to a screen reader say `0` as well.
   * @default 'gap'
   */
  nulls?: NebaChartNulls;
  /**
   * How tall the strip is. Sized against the line of text it sits beside rather
   * than against the page — a sparkline is a word in a sentence, not a picture.
   * @default 'md'
   */
  size?: NebaSize;
  /**
   * The mark's colour. A `NebaColor` family, or any CSS colour.
   *
   * Unlike the full charts this one takes it directly: a sparkline has exactly
   * one series and no legend, so there is nothing for a palette to hand out.
   * @default the first chart slot
   */
  color?: NebaColor | (string & {});
  /**
   * Puts a dot on the last point. The one direct label a strip this small has
   * room for, and it says where the series ended up.
   * @default false
   */
  endDot?: boolean;
  /**
   * Draws a rule across the strip at this value — a target, a budget, last
   * year's average. The one piece of context a sparkline can carry.
   */
  baseline?: number;
  /**
   * The ends of the scale. Left out, the strip fills itself with its own range,
   * which is what makes a sparkline legible at twenty pixels tall — and what
   * makes two of them side by side incomparable. Pass the same `min` and `max`
   * to a row of them and they become a small-multiples chart.
   */
  min?: number;
  max?: number;
  /** How wide. Fills its container by default. */
  width?: number | string;
  /** A name for the strip, read out in place of it. */
  label?: string;
}

/**
 * A chart with everything taken away except the shape.
 *
 * No axes, no grid, no legend, no tooltip — it is not a small chart, it is a
 * different thing: a word-sized picture that goes inside a sentence, beside a
 * [Statistic](./statistic), or in a table cell, and says which way something has
 * been going. Every number it could label is one the surrounding text already
 * has, which is why it labels none of them.
 *
 * It scales itself to its own range, so the strip is always full. That is what
 * makes it readable this small and it is also the trap: two sparklines side by
 * side are drawn on two different scales unless they are given the same `min`
 * and `max`.
 */
export const Sparkline = React.forwardRef<HTMLDivElement, SparklineProps>(
  function Sparkline(rawProps, ref) {
    const {
      data,
      shape = 'line',
      curve = 'linear',
      nulls = 'gap',
      size = 'md',
      color,
      endDot = false,
      baseline,
      min,
      max,
      width: widthProp,
      label,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size']);

    const hostRef = React.useRef<HTMLDivElement>(null);
    const measured = useMeasuredWidth(hostRef);
    const id = React.useId().replace(/:/g, '');

    /* `zero` is done here rather than to the points below, so everything that
       reads a value afterwards agrees: the range the strip scales itself to,
       the bars, and the list of numbers a screen reader is given instead of
       the picture. */
    const values = React.useMemo(() => {
      const unpacked = data.map(toValue);

      return nulls === 'zero'
        ? unpacked.map((value) => (value.value === null ? { ...value, value: 0 } : value))
        : unpacked;
    }, [data, nulls]);
    const height = sparklineHeights[size];
    const stroke = lineWidths[size];
    const radius = markerRadii[size];

    const extent = extentOf([values], false);
    // A bar grows from zero, so zero is inside the band: without it an
    // all-negative strip hung its bars from a baseline above the box, over the
    // text around it, and equal values drew one-pixel bars that read as zero.
    const bars = shape === 'bar';
    const low =
      min ?? (extent ? Math.min(extent.min, baseline ?? extent.min, bars ? 0 : extent.min) : 0);
    const high =
      max ?? (extent ? Math.max(extent.max, baseline ?? extent.max, bars ? 0 : extent.max) : 1);
    const span = high - low || 1;
    // A line with nothing to rise or fall between sits in the middle of the
    // strip rather than on its floor, where it read as a drop to the bottom.
    const level = high === low && !bars;
    const zero = Math.min(Math.max(low, 0), high);

    const width = typeof widthProp === 'number' ? widthProp : measured;
    const fill = resolveColor(color ?? 'var(--neba-chart-1)');

    // The stroke straddles the path, so the drawable band comes in by half of it
    // at both ends — otherwise the highest and lowest points are shaved off by
    // the edge of the box.
    const inset = shape === 'bar' ? 0 : stroke / 2 + (endDot ? radius : 0);
    const top = inset;
    const usable = Math.max(1, height - inset * 2);

    const y = (value: number) =>
      level ? top + usable / 2 : top + (1 - (value - low) / span) * usable;
    const step = values.length > 1 ? width / (values.length - 1) : width;

    const points = values.map((value, index) =>
      value.value === null ? null : { x: index * step, y: y(value.value) }
    );
    /* `connect` drops the gaps rather than bridging them in the path builder,
       for the reason `internal/chart-line.tsx` gives: a bridged segment and a
       real one have to be the same shape, and the only way to be sure of that
       is for the builder never to know the difference. */
    const drawn =
      nulls === 'connect' ? (points.filter(Boolean) as { x: number; y: number }[]) : points;

    const lastIndex = (() => {
      for (let index = values.length - 1; index >= 0; index--) {
        if (values[index].value !== null) {
          return index;
        }
      }

      return -1;
    })();

    const barWidth = Math.min(
      barMaxThickness[size] / 2,
      Math.max(1, width / Math.max(1, values.length) - markGap)
    );

    return (
      <div
        ref={ref}
        className={cx('relative block', className ?? undefined)}
        style={{ width: widthProp ?? '100%', height, ...style }}
        {...props}
      >
        <div ref={hostRef} className="absolute inset-0">
          {width > 0 && values.length > 0 ? (
            <svg
              width={width}
              height={height}
              viewBox={`0 0 ${width} ${height}`}
              role={label ? 'img' : 'presentation'}
              aria-label={label}
              aria-hidden={label ? undefined : true}
              className="block overflow-visible"
            >
              {shape === 'area' ? (
                <>
                  <defs>
                    <linearGradient id={`${id}-fill`} x1="0" y1="0" x2="0" y2="1">
                      <stop
                        offset="0%"
                        stopColor={`color-mix(in oklab, ${fill} 32%, transparent)`}
                      />
                      <stop
                        offset="100%"
                        stopColor={`color-mix(in oklab, ${fill} 2%, transparent)`}
                      />
                    </linearGradient>
                  </defs>
                  <path d={areaPath(drawn, height, curve)} fill={`url(#${id}-fill)`} />
                </>
              ) : null}

              {baseline !== undefined ? (
                <line
                  x1={0}
                  x2={width}
                  y1={y(baseline)}
                  y2={y(baseline)}
                  stroke="var(--neba-chart-baseline)"
                  strokeWidth={1}
                />
              ) : null}

              {shape === 'bar' ? (
                values.map((value, index) =>
                  value.value === null ? null : (
                    <path
                      key={index}
                      d={barPath(
                        index * (width / Math.max(1, values.length)) +
                          (width / Math.max(1, values.length) - barWidth) / 2,
                        Math.min(y(value.value), y(zero)),
                        barWidth,
                        Math.max(1, Math.abs(y(value.value) - y(zero))),
                        barRadius / 2,
                        value.value >= 0 ? 'up' : 'down'
                      )}
                      fill={value.color ?? fill}
                    />
                  )
                )
              ) : (
                <path
                  d={linePath(drawn, curve)}
                  fill="none"
                  stroke={fill}
                  strokeWidth={stroke}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              )}

              {endDot && lastIndex >= 0 && shape !== 'bar' ? (
                <circle
                  cx={points[lastIndex]!.x}
                  cy={points[lastIndex]!.y}
                  r={radius}
                  fill={fill}
                  stroke="var(--neba-chart-gap)"
                  strokeWidth={markGap}
                />
              ) : null}
            </svg>
          ) : null}
        </div>

        {/* The numbers, for the readers the strip does not reach. A sparkline is
          a picture of a trend and nothing else, so what it owes is the values —
          not a description of the shape they happen to make. */}
        {label ? (
          <span className={srOnlyClasses}>
            {values.map((value) => (value.value === null ? '—' : value.value)).join(', ')}
          </span>
        ) : null}
      </div>
    );
  }
);
