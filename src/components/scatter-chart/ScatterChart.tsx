import * as React from 'react';
import {
  CartesianChart,
  type CartesianChartProps,
  type CartesianContext,
  type CartesianLayout,
  type ChartMark
} from '../../internal/chart-frame';
import {
  bubbleRadius,
  formatCategory,
  markerRadii,
  markGap,
  markPath,
  markShapes,
  plotHeights,
  pointX,
  type MarkShape
} from '../../internal/chart';
import { cx, srOnlyClasses } from '../../internal/styles';
import type { NebaChartCategory, NebaChartSeries } from '../../types';

/**
 * How many series the palette can tell apart on a plot where any two marks may
 * end up side by side.
 *
 * Not a guess and not a house preference. Scatter is the form with no reading
 * order, so the palette has to clear the colour-vision check on **every** pair
 * rather than on the pairs that happen to touch — and run that way the shipped
 * ramp separates three slots and no more: slot 4 against slot 2 is ΔE 2.3 under
 * deuteranopia on the light sheet and 1.0 on the dark one, against a floor of
 * 8. Of the seventy ways to pick four of the eight, three clear it, and none of
 * them starts at slot 1 — so there is no reordering that buys a fourth without
 * also making a scatter's series 1 a different colour from every other chart's.
 */
const separableSeries = 3;

/** Nothing smaller than this, or a small-but-real value disappears. */
const minBubble = 2;

export interface ScatterChartProps extends CartesianChartProps {
  /**
   * What each mark is drawn as.
   *
   * - `auto` — the default. A circle while colour alone can carry identity, and
   *   a shape per series from the fourth on, because past three series it
   *   cannot: two of the palette's hues are indistinguishable under
   *   deuteranopia, and a shape is the one channel a dot has going spare.
   * - `varied` — a shape per series always, in the fixed order circle, square,
   *   triangle, diamond, cross. Reach for it when the chart will be printed or
   *   read in greyscale.
   * - one of the five names — every mark the same shape. On four or more series
   *   this is opting out of the second channel; do it only when each series
   *   carries a `color` of its own.
   * @default 'auto'
   */
  shape?: MarkShape | 'varied' | 'auto';
  /**
   * The radius of a mark with no `z`, in pixels.
   * @default the `size` ladder — 4 at `md`
   */
  pointRadius?: number;
  /**
   * The radius of the largest bubble, in pixels. Everything else is scaled
   * under it by area.
   * @default a twelfth of the chart's height
   */
  maxRadius?: number;
}

/**
 * Two numbers per point, and whether they move together.
 *
 * Both axes measure, which is what makes this the only chart in the library
 * with no categories: there is no column a mark belongs to and no order the
 * points could be shuffled out of. A point with a `z` is drawn as a bubble and
 * one without it as a dot, so a scatter and a bubble chart are the same
 * component reading the same data — the third number is simply present or not.
 *
 * `x` must be a number or a `Date`. A string has no place on a number line, and
 * a chart of named things against one measure is a [BarChart](./bar-chart).
 */
export function ScatterChart({
  shape = 'auto',
  pointRadius,
  maxRadius,
  series,
  categories,
  size = 'md',
  xAxis,
  ...props
}: ScatterChartProps) {
  const dot = pointRadius ?? markerRadii[size];

  /**
   * How much room the biggest mark needs, which is also how big it is allowed
   * to get.
   *
   * One number for both, and measured off the chart's *height* rather than off
   * the laid-out plot, because the two would otherwise chase each other: the
   * plot is only that size once the room has been taken out of it. The height
   * is known before anything is measured, which breaks the loop and makes the
   * reserve exactly the radius rather than a guess at it.
   */
  const reserve =
    maxRadius ??
    Math.max(dot + 2, (typeof props.height === 'number' ? props.height : plotHeights[size]) / 12);

  /* Only the series taking a palette slot count against the ceiling: a caller
     who gave every series a colour of their own has already answered the
     question the ceiling exists to ask. */
  const palettes = series.reduce((count, one) => (one.color ? count : count + 1), 0);

  /** What every mark is when they are not being told apart by shape. */
  const plain: MarkShape = shape === 'auto' || shape === 'varied' ? 'circle' : shape;
  const varied = shape === 'varied' || (shape === 'auto' && palettes > separableSeries);

  const shapeOf = React.useCallback(
    (index: number): MarkShape =>
      // By its place in the array it was passed, exactly as the colour is, so
      // hiding a series from the legend cannot reshape the ones that are left.
      varied ? markShapes[index % markShapes.length] : plain,
    [varied, plain]
  );

  /**
   * Every mark, in the order the data was given.
   *
   * Which is deliberately not the order they are painted in — the arrow keys
   * walk this list, and walking a scatter largest-bubble-first would be walking
   * it in an order the reader has no way to anticipate.
   */
  const marks = React.useCallback(
    (layout: CartesianLayout): ChartMark[] => {
      const list: ChartMark[] = [];

      /* One `z` scale for the whole chart rather than one per series, and taken
         over every series rather than the visible ones. Two bubbles the same
         size have to mean the same number wherever they are, and a size that
         changes when a legend is clicked is the same broken promise as a colour
         that does. */
      let biggest = 0;

      layout.values.forEach((one) => {
        one.forEach((value) => {
          if (value.value !== null && value.z !== undefined && Number.isFinite(value.z)) {
            biggest = Math.max(biggest, value.z);
          }
        });
      });

      layout.values.forEach((one, index) => {
        if (!layout.visible[index]) {
          return;
        }

        one.forEach((value, at) => {
          if (value.value === null) {
            return;
          }

          const x = pointX(value, at, categories);

          if (x === null) {
            return;
          }

          list.push({
            series: index,
            index: at,
            x: layout.categoryValuePx(x),
            y: layout.valuePx(value.value),
            r: value.z === undefined ? dot : bubbleRadius(value.z, biggest, reserve, minBubble)
          });
        });
      });

      return list;
    },
    [categories, dot, reserve]
  );

  return (
    <CartesianChart
      {...props}
      series={series}
      categories={categories}
      size={size}
      xScale="value"
      xAxis={xAxis}
      marks={marks}
      markInset={reserve}
      // Neither axis is forced to zero. What a position encodes is a *place*,
      // so cropping a scale slides every mark by the same amount and the shape
      // of the cloud — which is the whole of what a scatter says — survives. A
      // bar's length is the case where that is not true, and this is not one.
      includeZero={false}
      swatch={(index, color) => (
        <svg viewBox="0 0 10 10" className="size-2.5 overflow-visible" aria-hidden="true">
          <path d={markPath(shapeOf(index), 5, 5, 4)} fill={color} />
        </svg>
      )}
      table={(id) => (
        <ScatterTable
          id={id}
          series={series}
          categories={categories}
          label={props.label}
          xLabel={xAxis?.label}
          yLabel={props.yAxis?.label}
          locale={props.locale}
          format={props.format}
        />
      )}
    >
      {(context) => <ScatterMarks context={context} shapeOf={shapeOf} />}
    </CartesianChart>
  );
}

interface MarksProps {
  context: CartesianContext;
  shapeOf: (index: number) => MarkShape;
}

/**
 * The marks, and the only part of a ScatterChart that is not the shared frame.
 *
 * Painted largest first, which is the whole of what keeps a bubble chart
 * readable: a small bubble sitting inside a big one is invisible if the big one
 * is drawn on top of it, and the usual fix — dropping every fill to half alpha
 * — would undo the contrast the palette was solved for. Paint order costs
 * nothing and takes nothing away.
 */
function ScatterMarks({ context, shapeOf }: MarksProps) {
  const { marks, values, colors, hovered, activeMark } = context;

  const painted = React.useMemo(() => [...marks].sort((a, b) => b.r - a.r), [marks]);

  return (
    <g>
      {painted.map((mark) => {
        const value = values[mark.series]?.[mark.index];
        const dimmed = hovered !== null && hovered !== mark.series;
        const active = activeMark?.series === mark.series && activeMark?.index === mark.index;

        return (
          <path
            key={`${mark.series}-${mark.index}`}
            d={markPath(shapeOf(mark.series), mark.x, mark.y, active ? mark.r + 1 : mark.r)}
            fill={value?.color ?? colors[mark.series]}
            // The surface showing through, not a stroke drawn around the mark —
            // which is what keeps two overlapping dots two dots, and is part of
            // the hit target rather than only spacing.
            stroke="var(--neba-chart-gap)"
            strokeWidth={markGap}
            opacity={dimmed ? 0.28 : 1}
          />
        );
      })}
    </g>
  );
}

interface TableProps {
  id: string;
  series: readonly NebaChartSeries[];
  categories?: readonly NebaChartCategory[];
  label?: string;
  xLabel?: React.ReactNode;
  yLabel?: React.ReactNode;
  locale?: string;
  format?: Intl.NumberFormatOptions;
}

/**
 * The scatter, as a table.
 *
 * A row per point rather than the frame's grid of categories against series,
 * because there are no categories to put down the side: two points that are
 * both the fifth of their series have nothing whatever to do with each other,
 * and a table that filed them in one row would be inventing a relationship.
 *
 * The columns are named from the axis labels when there are any, and `x`, `y`
 * and `z` when there are not — the names the data model itself uses, which is
 * the honest fallback for a heading nobody supplied.
 */
function ScatterTable({
  id,
  series,
  categories,
  label,
  xLabel,
  yLabel,
  locale,
  format
}: TableProps) {
  const numbers = React.useMemo(
    () => new Intl.NumberFormat(locale, format ?? { maximumFractionDigits: 2 }),
    [locale, format]
  );

  const sized = series.some((one) =>
    one.data.some((datum) => typeof datum === 'object' && datum !== null && datum.z !== undefined)
  );

  return (
    <table id={id} className={cx(srOnlyClasses)}>
      {label ? <caption>{label}</caption> : null}
      <thead>
        <tr>
          <th scope="col" />
          <th scope="col">{xLabel ?? 'x'}</th>
          <th scope="col">{yLabel ?? 'y'}</th>
          {sized ? <th scope="col">z</th> : null}
        </tr>
      </thead>
      <tbody>
        {series.flatMap((one, index) =>
          one.data.map((datum, at) => {
            const point = typeof datum === 'object' && datum !== null ? datum : null;
            const y = point ? point.y : typeof datum === 'number' ? datum : null;
            const x = point?.x ?? categories?.[at] ?? at;

            return (
              <tr key={`${index}-${at}`}>
                <th scope="row">{one.name ?? index + 1}</th>
                <td>{formatCategory(x, locale)}</td>
                {/* A `null` is a gap and prints as an empty cell, exactly as it
                    does on every other chart's table. A zero written here would
                    be the one place the library reported missing data as a
                    number. */}
                <td>{y === null || !Number.isFinite(y) ? '' : numbers.format(y)}</td>
                {sized ? <td>{point?.z === undefined ? '' : numbers.format(point.z)}</td> : null}
              </tr>
            );
          })
        )}
      </tbody>
    </table>
  );
}
