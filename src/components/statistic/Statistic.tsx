'use client';

import * as React from 'react';
import { Box, type BoxProps } from '../box/Box.js';
import { Chip } from '../chip/Chip.js';
import { MinusIcon, TrendDownIcon, TrendUpIcon } from '../../internal/icons.js';
import { numberFormatter } from '../../internal/format.js';
import { cx, hasContent, metaTextClasses, sheetSectionGapClasses } from '../../internal/styles.js';
import type { NebaAlign, NebaSize } from '../../types.js';

/** Which way a figure moved, and the third case that is neither. */
type Trend = 'up' | 'down' | 'flat';

export interface StatisticProps extends Omit<BoxProps, 'title' | 'prefix'> {
  /**
   * What the number is. The name of the measure, not a sentence about it —
   * "Active users", "MRR", "이탈률".
   *
   * `label` rather than `title`, which is what Card calls the same slot: this is
   * the name of a *value*, which is the thing the library already spells `label`
   * on every field it has.
   */
  label?: React.ReactNode;
  /**
   * The figure. A number is formatted; a string is printed exactly as given, for
   * the values that are not numbers at all — "3h 42m", "A+", "—".
   */
  value: number | string;
  /**
   * How to write a numeric `value` — `Intl.NumberFormat` options, the same prop
   * the progress indicators take. Without it a number is grouped by the reader's
   * own locale and otherwise left alone.
   */
  format?: Intl.NumberFormatOptions;
  /**
   * Which language the figure is written in, the same prop every chart takes.
   * A Statistic is the smallest chart on the page and sits next to the others in
   * a dashboard, so a locale set on one of them has to be settable on all.
   * @default the reader's
   */
  locale?: string;
  /** Set before the figure and never wrapped away from it — a currency sign. */
  prefix?: React.ReactNode;
  /**
   * Set after the figure: `%`, `MB`, `명`.
   *
   * A second slot rather than one `adornment` with a side, because the two are
   * typographically different things and always have been — a currency symbol
   * leads its number and a unit follows it, in every locale that has both.
   */
  unit?: React.ReactNode;
  /** A glyph before the label. An `Icon`, or anything else that draws. */
  icon?: React.ReactNode;
  /**
   * The figure this one is being compared against — last month's, last quarter's,
   * the target. Passing it is what makes the delta appear.
   *
   * Only meaningful for a numeric `value`; with a string there is nothing to
   * subtract and the delta is left out.
   */
  previousValue?: number;
  /**
   * How the difference is written.
   *
   * - `percent` — the change relative to `previousValue`. The default, because a
   *   report is nearly always asking "how much has this moved", not "by how many".
   * - `absolute` — the difference itself, in the figure's own units.
   * - `both` — the percentage with the difference after it.
   * - `none` — no delta, even with a `previousValue` given.
   * @default 'percent'
   */
  delta?: 'percent' | 'absolute' | 'both' | 'none';
  /**
   * Which direction counts as good, and so which way the delta is coloured.
   *
   * `up` for revenue, `down` for churn and error rate and page weight. This is
   * not decoration: green-for-larger on a bounce rate says the opposite of what
   * the report means, and it says it to exactly the reader who is skimming.
   * @default 'up'
   */
  betterWhen?: 'up' | 'down';
  /** A line under the figure — "vs. last month", "as of 3 July". */
  caption?: React.ReactNode;
  /**
   * Where the block sits in the card. `center` for a row of tiles that read as
   * one band; `start` — the default — for a card with anything else in it.
   * @default 'start'
   */
  align?: NebaAlign;
  /** Anything below the caption: a sparkline, a ProgressLinear against a target. */
  children?: React.ReactNode;
}

/**
 * The figure's own type scale, and the one ladder in the library that is not a
 * step off something else.
 *
 * A statistic is read from across a room at a glance, which is a different job
 * from a card's heading — `sheetTitleClasses` tops out at 20px, and a number
 * that has to beat everything else on a dashboard cannot. The steps are the
 * display sizes: the gap widens as it climbs, because a figure at `xl` is the
 * one thing on the screen.
 */
const valueClasses: Record<NebaSize, string> = {
  xs: 'text-[1.125rem]/[1.375rem]',
  sm: 'text-[1.375rem]/[1.625rem]',
  md: 'text-[1.75rem]/[2rem]',
  lg: 'text-[2.25rem]/[2.5rem]',
  xl: 'text-[2.875rem]/[3.25rem]'
};

/** The prefix and the unit: a step down from the figure, and never bolder. */
const affixClasses: Record<NebaSize, string> = {
  xs: 'text-[0.75rem]',
  sm: 'text-[0.875rem]',
  md: 'text-[1rem]',
  lg: 'text-[1.25rem]',
  xl: 'text-[1.5rem]'
};

/**
 * The delta and the caption sit on one line until the card is too narrow for
 * them, so the two axes need separate gaps: a fixed one across, and the header
 * ladder's own down. Written out rather than assembled from
 * `sheetHeaderGapClasses` at runtime — Tailwind only ever sees class names that
 * appear literally in the source.
 */
const footerGapYClasses: Record<NebaSize, string> = {
  xs: 'gap-y-0.5',
  sm: 'gap-y-0.5',
  md: 'gap-y-1',
  lg: 'gap-y-1',
  xl: 'gap-y-1.5'
};

const alignClasses: Record<NebaAlign, string> = {
  start: 'items-start text-start',
  center: 'items-center text-center',
  end: 'items-end text-end'
};

const trendIcons: Record<Trend, React.ReactNode> = {
  up: <TrendUpIcon />,
  down: <TrendDownIcon />,
  flat: <MinusIcon />
};

/**
 * A number with its name on it, and — when there is something to compare it
 * against — how far it has moved.
 *
 * A Box with a fixed arrangement laid on it, exactly as Card is. The slots are
 * props and not compound sub-components for the reason Card gives: the order
 * never varies, so what a caller wants to decide is what goes in each slot.
 *
 * The delta is a Chip rather than a coloured span, and that is the whole reason
 * it looks right next to everything else — it is the same token the rest of the
 * library uses, at the same step down the control ladder, with the same acrylic
 * on it. It also carries a shape and not only a colour: a report whose "down" is
 * red and nothing else is a report that says nothing to a reader who cannot
 * separate red from green.
 */
export const Statistic = React.forwardRef<HTMLDivElement, StatisticProps>(function Statistic(
  {
    size = 'md',
    color = 'primary',
    density = 'default',
    label,
    value,
    format,
    locale,
    prefix,
    unit,
    icon,
    previousValue,
    delta = 'percent',
    betterWhen = 'up',
    caption,
    align = 'start',
    className,
    children,
    ...props
  },
  ref
) {
  // An `Intl.NumberFormat` is expensive to construct and free to reuse, and a
  // dashboard is a page full of these. The cache is keyed on what `format` says
  // rather than on the object it arrived in, so the literal a caller writes
  // inline — which is how that prop is nearly always written — still hits it.
  const numeric = typeof value === 'number' ? value : null;
  const shown = numeric === null ? value : numberFormatter(locale, format).format(numeric);

  /**
   * The comparison, or `null` when there is nothing to compare.
   *
   * A percentage against a `previousValue` of zero is not a large number, it is
   * an undefined one — so the ratio is dropped and the absolute difference is
   * what gets written instead. Reporting "+∞%" because last month was the first
   * month is the kind of thing a dashboard does exactly once before nobody
   * trusts it again.
   */
  const difference =
    numeric !== null && previousValue !== undefined ? numeric - previousValue : null;
  const ratio =
    difference !== null && previousValue !== 0 && previousValue !== undefined
      ? difference / Math.abs(previousValue)
      : null;

  const trend: Trend | null =
    difference === null ? null : difference > 0 ? 'up' : difference < 0 ? 'down' : 'flat';

  let deltaText: string | null = null;

  if (difference !== null && trend !== null && delta !== 'none') {
    const sign = difference > 0 ? '+' : difference < 0 ? '-' : '';
    const absolute = `${sign}${numberFormatter(locale, format).format(Math.abs(difference))}`;
    const percent =
      ratio === null ? null : `${sign}${(Math.abs(ratio) * 100).toFixed(1).replace(/\.0$/, '')}%`;

    deltaText =
      delta === 'absolute'
        ? absolute
        : delta === 'both'
          ? [percent, absolute].filter(Boolean).join(' · ')
          : (percent ?? absolute);
  }

  // Flat is neither good nor bad, and saying so in grey is the honest answer.
  const deltaColor =
    trend === null || trend === 'flat' ? 'secondary' : trend === betterWhen ? 'success' : 'danger';

  const hasFooter = deltaText !== null || hasContent(caption);

  return (
    <Box
      ref={ref}
      size={size}
      color={color}
      density={density}
      className={cx(
        'flex flex-col',
        sheetSectionGapClasses[size],
        alignClasses[align],
        className ?? ''
      )}
      {...props}
    >
      {hasContent(label) || hasContent(icon) ? (
        <div
          className={[
            'flex min-w-0 items-center gap-1.5 font-medium text-(--neba-muted-fg)',
            metaTextClasses[size]
          ].join(' ')}
        >
          {hasContent(icon) ? <span className="flex shrink-0 items-center">{icon}</span> : null}
          {hasContent(label) ? <span className="min-w-0 truncate">{label}</span> : null}
        </div>
      ) : null}

      {/* `items-baseline`, so the unit sits on the figure's baseline rather than
          floating in the middle of its cap height — the one detail that decides
          whether "42%" reads as one number or as a number and a symbol. */}
      <div
        className={[
          'flex min-w-0 flex-wrap items-baseline gap-1 font-semibold text-(--neba-fg) tabular-nums',
          valueClasses[size]
        ].join(' ')}
      >
        {hasContent(prefix) ? (
          <span className={`font-medium text-(--neba-muted-fg) ${affixClasses[size]}`}>
            {prefix}
          </span>
        ) : null}
        <span className="min-w-0 break-words">{shown}</span>
        {hasContent(unit) ? (
          <span className={`font-medium text-(--neba-muted-fg) ${affixClasses[size]}`}>{unit}</span>
        ) : null}
      </div>

      {hasFooter ? (
        <div className={`flex min-w-0 flex-wrap items-center gap-x-2 ${footerGapYClasses[size]}`}>
          {deltaText !== null && trend !== null ? (
            <Chip
              size={size}
              variant="text"
              color={deltaColor}
              startIcon={trendIcons[trend]}
              className="tabular-nums"
            >
              {deltaText}
            </Chip>
          ) : null}
          {hasContent(caption) ? (
            <span className={`min-w-0 text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
              {caption}
            </span>
          ) : null}
        </div>
      ) : null}

      {children}
    </Box>
  );
});
