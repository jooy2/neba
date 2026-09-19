'use client';

import * as React from 'react';
import { Meter as BaseUIMeter } from '@base-ui/react/meter';
import {
  contextMessages,
  fillMessage,
  useMessages,
  type ContextMessages
} from '../../internal/i18n.js';
import { numberFormatter } from '../../internal/format.js';
import { progressFraction, progressSlots, thresholdColor } from '../../internal/progress.js';
import {
  cx,
  gapClasses,
  hasContent,
  metaTextClasses,
  sheetTitleClasses,
  stackGapClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaSize, NebaSlots, NebaThreshold } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * What a context window is spent on.
 *
 * Four, in the order they are drawn, and the order is the point: it is the
 * order the tokens were *spent* in, so a reader comparing two turns is
 * comparing the same rows in the same places. Every one is optional — a model
 * with no reasoning trace and no cache reports two of them, and the rows it did
 * not report are not drawn.
 */
export interface ContextTokens {
  /** Everything sent: the prompt, the history, the tool definitions. */
  input?: number;
  /** Everything the model wrote back. */
  output?: number;
  /** What it spent thinking, where the model bills that separately. */
  reasoning?: number;
  /**
   * The part of the input that was served from a cache.
   *
   * A **portion of `input`** rather than a fifth thing beside it, which is what
   * every model that reports it means by it — so it is drawn as a row and left
   * out of the total. Adding it would report the window as fuller than it is,
   * by exactly the number the cache saved.
   */
  cached?: number;
}

/** The parts a ContextWindow draws behind its root. */
export type ContextWindowSlot = 'ring' | 'label' | 'breakdown';

/**
 * The four rows, and the palette slot each takes.
 *
 * `cached` is last because it is the odd one: the other three are what the turn
 * *spent*, and this one is how much of the first of them was free.
 */
const PARTS: ReadonlyArray<{ key: keyof ContextTokens; slot: number }> = [
  { key: 'input', slot: 1 },
  { key: 'output', slot: 2 },
  { key: 'reasoning', slot: 3 },
  { key: 'cached', slot: 4 }
];

export interface ContextWindowProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** How many tokens the window holds. */
  max: number;
  /**
   * How many have gone. Left out, it is `input` plus `output` plus `reasoning`
   * — which is the usual case, since a caller who has the split has the total.
   *
   * `cached` is deliberately not in that sum: it is a portion of `input`, and
   * counting it twice would report the window as fuller than it is.
   */
  used?: number;
  /**
   * The split. Drawn as a row per part under the ring, in the fixed order
   * above, and only for the parts that were reported.
   */
  tokens?: ContextTokens;
  /** What the turn cost, in `currency`. Drawn under the split. */
  cost?: number;
  /**
   * The currency `cost` is in, as an ISO 4217 code.
   * @default 'USD'
   */
  currency?: string;
  /**
   * Where the ring changes colour. Read in the order given, in tokens — so
   * `{ from: 0.8 * max, color: 'warning' }` rather than a percentage.
   */
  thresholds?: readonly NebaThreshold[];
  /** What the gauge is called. Defaults to the `locale`'s word for it. */
  label?: React.ReactNode;
  /**
   * Draws the split under the ring. Off, the gauge is the ring and the counts
   * beside it, which is what fits in a toolbar.
   * @default true
   */
  breakdown?: boolean;
  /** @default 'md' */
  size?: NebaSize;
  /** The family the ring carries before any threshold is reached. @default 'primary' */
  color?: NebaColor;
  /**
   * The language the counts and the money are written in, as a BCP 47 tag. It
   * is what decides whether 12,400 tokens read as `12.4K` or `1.2만`.
   */
  locale?: string;
  /** The gauge's own words, written out. Overrides the `locale`'s. */
  labels?: Partial<ContextMessages>;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<ContextWindowSlot>;
  /** Anything to put under the split — a model name, a "clear the thread" link. */
  children?: React.ReactNode;
}

/** The ring, one step above the progress ladder: this one is read, not glanced at. */
const ringDiameters: Record<NebaSize, number> = {
  xs: 26,
  sm: 30,
  md: 36,
  lg: 44,
  xl: 54
};

/** Its stroke, thickening with it so the hole stays in proportion. */
const ringStrokes: Record<NebaSize, number> = {
  xs: 3,
  sm: 3.5,
  md: 4,
  lg: 5,
  xl: 6
};

/** The square beside a row of the split. */
const swatchClasses: Record<NebaSize, string> = {
  xs: 'size-1.5',
  sm: 'size-2',
  md: 'size-2',
  lg: 'size-2.5',
  xl: 'size-3'
};

/**
 * How much of the context window has gone, and what went into it.
 *
 * A [Meter](../feedback/meter) draws the same reading as a bar and would do
 * most of this. What it cannot do is the part that makes this a component: the
 * counts are tokens, which are five and six digits long and have to be written
 * compactly *in the reader's own language*; the split into input, output,
 * reasoning and cached is four numbers that only mean something next to each
 * other; and the money underneath is a third unit again.
 *
 * Base UI's Meter owns the semantics — `role="meter"`, the value and the range
 * — so the reading is announced as a reading rather than as a picture.
 *
 * The four parts take the first four chart palette slots rather than four
 * colour families, and that is deliberate: input and output are *entities*,
 * not severities, and nothing about either means success or danger. The slots
 * are handed out in order because it is the adjacent pairs that were checked
 * for colour-vision separation.
 */
export const ContextWindow = React.forwardRef<HTMLDivElement, ContextWindowProps>(
  function ContextWindow(rawProps, ref) {
    const {
      max,
      used,
      tokens,
      cost,
      currency = 'USD',
      thresholds,
      label,
      breakdown = true,
      size = 'md',
      color = 'primary',
      locale,
      labels,
      classNames,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'locale']);

    const messages = useMessages(contextMessages, locale);
    const words = { ...messages, ...labels };

    const parts = PARTS.filter(({ key }) => typeof tokens?.[key] === 'number');
    /*
     * `cached` is drawn and not added. Every model that reports it means "this
     * much of the input came out of a cache", so it is already inside `input`;
     * a total counting it again would say the window was fuller than it is by
     * exactly the number the cache saved.
     */
    const total =
      used ??
      parts.reduce((sum, { key }) => (key === 'cached' ? sum : sum + (tokens?.[key] ?? 0)), 0);

    const fraction = progressFraction(total, 0, max);
    const family = thresholdColor(total, color, thresholds);

    // Compact, because a context window is six digits and "124,000 of 200,000"
    // is two numbers nobody compares. `Intl` knows what compact looks like in
    // each language, which is why none of this is a table in `i18n.ts`.
    const count = numberFormatter(locale, { notation: 'compact', maximumFractionDigits: 1 });
    const money = numberFormatter(locale, { style: 'currency', currency });
    const usage = fillMessage(words.usage, {
      used: count.format(total),
      max: count.format(max)
    });

    const diameter = ringDiameters[size];
    const centre = diameter / 2;
    const stroke = ringStrokes[size];
    // The stroke straddles the path, so the radius comes in by half of it or
    // the ring is clipped by its own viewBox.
    const radius = centre - stroke / 2;
    const circumference = 2 * Math.PI * radius;

    return (
      <BaseUIMeter.Root
        ref={ref}
        value={total}
        min={0}
        max={max}
        // The reading announced is the reading drawn: the same compact sentence
        // rather than Base UI's own percentage of a range nobody described.
        getAriaValueText={() => usage}
        className={cx('flex w-full flex-col', stackGapClasses[size], className ?? '')}
        style={{ ...progressSlots(family), ...style }}
        {...props}
      >
        <div className={cx('flex items-center', gapClasses[size])}>
          <svg
            className={cx('shrink-0', classNames?.ring ?? '')}
            width={diameter}
            height={diameter}
            viewBox={`0 0 ${diameter} ${diameter}`}
            fill="none"
            aria-hidden="true"
          >
            <circle
              cx={centre}
              cy={centre}
              r={radius}
              stroke="var(--n-soft)"
              strokeWidth={stroke}
            />
            <circle
              cx={centre}
              cy={centre}
              r={radius}
              stroke="var(--n-fill)"
              strokeWidth={stroke}
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={circumference * (1 - (fraction ?? 0))}
              // A geometry attribute rather than a CSS transform: this is where
              // the arc starts, not something the ring does when it changes.
              transform={`rotate(-90 ${centre} ${centre})`}
              className="[transition:stroke-dashoffset_var(--neba-duration-fill)_var(--neba-ease),stroke_var(--neba-duration)_var(--neba-ease)]"
            />
          </svg>

          <div className={cx('flex min-w-0 flex-1 flex-col', classNames?.label ?? '')}>
            <BaseUIMeter.Label
              className={cx('min-w-0 truncate font-medium text-(--neba-fg)', metaTextClasses[size])}
            >
              {hasContent(label) ? label : words.label}
            </BaseUIMeter.Label>
            <BaseUIMeter.Value
              className={cx(
                'min-w-0 truncate tabular-nums text-(--neba-fg)',
                sheetTitleClasses[size]
              )}
            >
              {() => usage}
            </BaseUIMeter.Value>
          </div>

          {typeof cost === 'number' ? (
            <div className="flex shrink-0 flex-col items-end">
              <span className={cx('text-(--neba-muted-fg)', metaTextClasses[size])}>
                {words.cost}
              </span>
              <span className={cx('tabular-nums text-(--neba-fg)', sheetTitleClasses[size])}>
                {money.format(cost)}
              </span>
            </div>
          ) : null}
        </div>

        {breakdown && parts.length > 0 ? (
          <ul
            className={cx(
              'm-0 flex list-none flex-wrap gap-x-4 gap-y-1 p-0',
              metaTextClasses[size],
              classNames?.breakdown ?? ''
            )}
          >
            {parts.map(({ key, slot }) => (
              <li key={key} className="flex items-center gap-1.5">
                <span
                  aria-hidden="true"
                  className={cx('shrink-0 rounded-[2px]', swatchClasses[size])}
                  style={{ background: `var(--neba-chart-${slot})` }}
                />
                <span className="text-(--neba-muted-fg)">{words[key]}</span>
                <span className="tabular-nums text-(--neba-fg)">
                  {count.format(tokens?.[key] ?? 0)}
                </span>
              </li>
            ))}
          </ul>
        ) : null}

        {children}
      </BaseUIMeter.Root>
    );
  }
);
