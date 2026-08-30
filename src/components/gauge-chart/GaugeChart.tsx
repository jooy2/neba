'use client';

import * as React from 'react';
import { ChartSurface, useMeasuredWidth, type ChartBaseProps } from '../../internal/chart-frame.js';
import { arcPath, chartFontSizes, compactNumber, plotHeights } from '../../internal/chart.js';
import { numberFormatter } from '../../internal/format.js';
import { emptyMessages, useMessages } from '../../internal/i18n.js';
import { cx, metaTextClasses } from '../../internal/styles.js';
import type { NebaColor, NebaThreshold } from '../../types.js';

export interface GaugeChartProps extends Omit<ChartBaseProps, 'legend' | 'tooltip'> {
  /**
   * The reading. `null` draws the dial with nothing on it, which is the honest
   * picture of an instrument that has not been told anything.
   */
  value: number | null;
  /** @default 0 */
  min?: number;
  /** @default 100 */
  max?: number;
  /**
   * How far round the dial goes, in degrees, opened symmetrically about twelve
   * o'clock. `180` is the half-dial a dashboard tile wants; `270` is the
   * instrument shape; `360` is a ring.
   * @default 180
   */
  sweep?: number;
  /** How thick the arc is, as a fraction of its radius. @default 0.22 */
  thickness?: number;
  /**
   * Where the arc changes colour — the same `{ from, color }` entries a
   * [Meter](../feedback/meter) takes, and with the same rule: the last one the
   * value has reached wins, and below all of them `color` stands.
   */
  thresholds?: readonly NebaThreshold[];
  /**
   * How many marks are drawn around the dial, ends included. `false` — the
   * default — draws none: a gauge on a dashboard is read as a proportion, and
   * ticks are for an instrument somebody takes a *number* off.
   * @default false
   */
  ticks?: number | false;
  /** Writes `min` and `max` at the two ends of the arc. @default true */
  showRange?: boolean;
  /**
   * What goes in the middle. Left out, it is the value written through `format`
   * — which is what the dial is for, so replacing it is for adding to it rather
   * than for taking it away.
   */
  center?: React.ReactNode;
  /** A line under the value: the unit, or what is being measured. */
  caption?: React.ReactNode;
}

/** Which family the reading has earned. `Meter`'s rule, on a different shape. */
function thresholdColor(
  value: number,
  color: NebaColor,
  thresholds: readonly NebaThreshold[] | undefined
): NebaColor {
  if (!thresholds || thresholds.length === 0) return color;

  let current = color;

  for (const threshold of thresholds) {
    if (value >= threshold.from) current = threshold.color;
  }

  return current;
}

/** Degrees clockwise from twelve o'clock to a point on a circle of radius `r`. */
function pointAt(cx: number, cy: number, r: number, degrees: number): [number, number] {
  const radians = ((degrees - 90) * Math.PI) / 180;

  return [cx + r * Math.cos(radians), cy + r * Math.sin(radians)];
}

/**
 * One number on a scale that is known in advance, drawn as a dial.
 *
 * It is a [Meter](../feedback/meter) bent into an arc, and the two are
 * deliberately the same component in two shapes: `value`, `min`, `max` and
 * `thresholds` mean exactly what they mean there, so a page can move a reading
 * from a bar to a dial without changing what it says. Reach for the bar in a
 * row of fields and for this one in a tile of its own, where a dial reads at a
 * glance from across a room and a four-pixel bar does not.
 *
 * It is not a [PieChart](./pie-chart) with `shape="semi"`. A pie is *parts of a
 * whole* and every slice is a category; this is one value against a scale, and
 * the unfilled part of the arc is not a second category — it is the rest of the
 * dial.
 */
export function GaugeChart({
  value,
  min = 0,
  max = 100,
  sweep = 180,
  thickness = 0.22,
  thresholds,
  ticks = false,
  showRange = true,
  center,
  caption,
  height,
  format,
  locale,
  label,
  empty,
  size = 'md',
  variant = 'text',
  color = 'primary',
  padded = false,
  className,
  ...box
}: GaugeChartProps) {
  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const messages = useMessages(emptyMessages, locale);

  const formatValue = React.useCallback(
    (each: number) =>
      format ? numberFormatter(locale, format).format(each) : compactNumber(each, locale),
    [format, locale]
  );

  const span = Math.max(1, Math.min(360, sweep));
  const half = span / 2;
  const from = -half;
  const to = half;

  const range = max - min;
  const fraction =
    value === null || Number.isNaN(value) || range === 0
      ? null
      : Math.min(1, Math.max(0, (value - min) / range));

  const family = value === null ? color : thresholdColor(value, color, thresholds);

  const plotHeight = typeof height === 'number' ? height : plotHeights[size];
  const fontSize = chartFontSizes[size];

  /*
   * How much room the arc needs, as multiples of its own radius.
   *
   * The top of the dial is always a full radius above the centre; how far it
   * reaches *below* depends on the sweep — a half-dial stops level with its
   * centre, a 270° one drops most of a radius past it. Sizing against the box
   * rather than assuming a circle is what keeps a wide, short card from drawing
   * a thin band with an empty half above it.
   */
  const belowFactor = span >= 360 ? 1 : Math.max(0, -Math.cos((half * Math.PI) / 180));
  const sideFactor = span >= 180 ? 1 : Math.sin((half * Math.PI) / 180);

  const margin = fontSize * (showRange ? 1.6 : 0.6);
  const outer = Math.max(
    0,
    Math.min(
      (width - margin * 2) / (sideFactor * 2),
      (plotHeight - margin * (belowFactor > 0 ? 2 : 1)) / (1 + belowFactor)
    )
  );
  const inner = outer * (1 - Math.min(0.9, Math.max(0.05, thickness)));

  const centreX = width / 2;
  const centreY = margin + outer;

  const nothing = outer <= 0 || range === 0;
  const filledTo = fraction === null ? from : from + span * fraction;

  // The reading sits inside the arc rather than at the geometric centre: on a
  // half-dial the centre is the bottom edge of the drawing, and text pinned
  // there would hang out of the box.
  const textY = centreY - outer + (outer * (1 + belowFactor)) / 2;

  const tickCount = ticks === false ? 0 : Math.max(2, Math.floor(ticks));

  return (
    <ChartSurface
      {...box}
      variant={variant}
      color={color}
      size={size}
      padded={padded}
      legendSide="bottom"
      className={className}
      legend={null}
      table={null}
    >
      <div
        ref={hostRef}
        className="relative w-full"
        style={{ height: plotHeight }}
        // Named, the dial is one image saying one thing — which is what it is,
        // and it saves a reader hearing the two end labels as loose numbers.
        // Unnamed there is nothing to call it, so it stays a plain box and the
        // reading in the middle is read as the text it already is.
        role={label === undefined ? undefined : 'img'}
        aria-label={
          label === undefined
            ? undefined
            : value === null
              ? label
              : `${label}: ${formatValue(value)} / ${formatValue(max)}`
        }
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
          <>
            <svg
              width={width}
              height={plotHeight}
              viewBox={`0 0 ${width} ${plotHeight}`}
              aria-hidden="true"
              className="block"
            >
              {/* The rest of the dial. Not a second value — a groove. */}
              <path
                d={arcPath(centreX, centreY, outer, inner, from, to)}
                fill={`var(--neba-${color}-soft)`}
              />

              {fraction !== null && fraction > 0 ? (
                <path
                  d={arcPath(centreX, centreY, outer, inner, from, filledTo)}
                  fill={`var(--neba-${family}-fill)`}
                  // An arc's length, never a transform: a dial that scaled would
                  // resample the numbers written across it.
                  style={{
                    transition: 'fill var(--neba-duration) var(--neba-ease)'
                  }}
                />
              ) : null}

              {tickCount > 0
                ? Array.from({ length: tickCount }, (_, index) => {
                    const at = from + (span * index) / (tickCount - 1);
                    const [x1, y1] = pointAt(centreX, centreY, outer + fontSize * 0.25, at);
                    const [x2, y2] = pointAt(centreX, centreY, outer + fontSize * 0.6, at);

                    return (
                      <line
                        key={index}
                        x1={x1}
                        y1={y1}
                        x2={x2}
                        y2={y2}
                        stroke="var(--neba-chart-grid)"
                        strokeWidth={1}
                        strokeLinecap="round"
                      />
                    );
                  })
                : null}

              {showRange
                ? ([[min, from, 'start'] as const, [max, to, 'end'] as const] as const).map(
                    ([each, at, which]) => {
                      const [x, y] = pointAt(centreX, centreY, (outer + inner) / 2, at);
                      // Pushed out along the axis the end actually points down,
                      // so a half-dial's labels sit beside the arc and a 270°
                      // dial's sit under it.
                      const dx = which === 'start' ? -fontSize * 0.6 : fontSize * 0.6;

                      return (
                        <text
                          key={which}
                          x={x + (span >= 300 ? 0 : dx)}
                          y={y + fontSize * (span >= 300 ? 1.4 : 0.35)}
                          textAnchor={span >= 300 ? 'middle' : which === 'start' ? 'end' : 'start'}
                          fontSize={fontSize}
                          fill="var(--neba-muted-fg)"
                        >
                          {formatValue(each)}
                        </text>
                      );
                    }
                  )
                : null}
            </svg>

            {/* Real text rather than an SVG `<text>`: this is the one number the
                chart is about, so it has to be selectable, findable and in the
                accessibility tree. */}
            <div
              className="pointer-events-none absolute inset-x-0 flex flex-col items-center gap-0.5"
              style={{ top: textY, transform: 'translateY(-50%)' }}
            >
              <span
                className="font-semibold tabular-nums text-(--neba-fg)"
                style={{ fontSize: fontSize * 2 }}
              >
                {center ?? (value === null ? '—' : formatValue(value))}
              </span>
              {caption ? (
                <span className={cx('text-(--neba-muted-fg)', metaTextClasses[size])}>
                  {caption}
                </span>
              ) : null}
            </div>
          </>
        ) : null}
      </div>
    </ChartSurface>
  );
}
