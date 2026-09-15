'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { useAnimationRun, usePrefersReducedMotion } from '../../internal/animate.js';
import { numberFormatter } from '../../internal/format.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type { NebaAnimateProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface AnimateCounterProps
  // `paused` is out with the three a count has no use for: a count is a
  // hundred renders of one number and nothing here holds one, which is what
  // `trigger="manual"` with `play` is for.
  extends
    Omit<NebaAnimateProps, 'easing' | 'repeat' | 'alternate' | 'paused'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'children'> {
  /** Where it lands. */
  value: number;
  /**
   * Where it starts.
   * @default 0
   */
  from?: number;
  /**
   * How long the count takes, in milliseconds.
   * @default 1200
   */
  duration?: number;
  /**
   * How the number is written — `Intl.NumberFormat` options, so a currency, a
   * percentage or a compact `1.2M` is a prop rather than a `format` callback.
   * While it counts, the number keeps the decimal places of `value` or `from`,
   * whichever has more.
   */
  format?: Intl.NumberFormatOptions;
  /** Which language it is written in. Defaults to the reader's own. */
  locale?: string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
}

/**
 * The curve the count runs on.
 *
 * Ease-out, and it is not the house curve. `--neba-ease` is written for
 * something *arriving* — it overshoots slightly at the end, which on a distance
 * is a settle and on a number is the total going past itself and coming back.
 * A number may only ever approach its value from one side.
 */
function easeOut(t: number): number {
  return 1 - (1 - t) ** 3;
}

/**
 * How many decimal places a number is written with, read off the shortest
 * string that stands for it, so `0.1` is one place and `1e-7` is seven.
 */
function decimalsOf(value: number): number {
  if (!Number.isFinite(value)) {
    return 0;
  }

  const [digits, exponent = '0'] = String(Math.abs(value)).split('e');
  const places = (digits.split('.')[1]?.length ?? 0) - Number(exponent);

  return Math.min(20, Math.max(0, places));
}

/**
 * A number counted up to its value.
 *
 * The one animation in the library whose subject is the content rather than the
 * box around it, and the reason it is a component: a count is a value being
 * interpolated and formatted on every frame, which is not something a
 * `@keyframes` can do.
 *
 * It pairs with [Statistic](../charts/statistic) — a dashboard that draws its
 * numbers instantly and animates everything around them has the emphasis
 * exactly backwards.
 *
 * The finished number is in the document from the first frame, in a clipped box
 * for a screen reader; what counts is a visible copy that is `aria-hidden`.
 * A reader who cannot see the count is told the answer rather than a hundred
 * intermediate ones, and a reader who has asked for less motion is shown the
 * answer too.
 */
export const AnimateCounter = React.forwardRef<HTMLDivElement, AnimateCounterProps>(
  function AnimateCounter(rawProps, ref) {
    const {
      value,
      from = 0,
      duration = 1200,
      delay = 0,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      format,
      locale,
      render,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['locale']);
    const run = useAnimationRun({
      caller: props,
      trigger,
      play,
      once,
      threshold,
      // A count runs once and stops; there is no version of it that loops.
      infinite: false
    });
    const reduced = usePrefersReducedMotion();

    const [shown, setShown] = React.useState(from);

    // Keyed on the *contents* of the options rather than on their identity: a
    // caller writing `format={{ style: 'currency', currency: 'KRW' }}` inline
    // hands us a new object every render, and building an `Intl.NumberFormat` a
    // hundred times a second is the most expensive thing on the page.
    const key = format === undefined ? '' : JSON.stringify(format);
    // And through the library's own cache, so a row of counters in one currency
    // shares one formatter rather than building one each.
    const formatter = React.useMemo(
      () => numberFormatter(locale, format),
      // eslint-disable-next-line react-hooks/exhaustive-deps
      [locale, key]
    );

    React.useEffect(() => {
      // Waiting shows the first frame, which is `from`. That is the same rule
      // the CSS effects follow — an untriggered animation is paused on its own
      // opening frame rather than showing its last — and without it a counter
      // waiting to be scrolled to would already be displaying the answer. A
      // reader who asked for less motion is the exception: there is no count to
      // wait for, only the answer.
      if (!run.started && !reduced) {
        setShown(from);

        return;
      }

      if (reduced || duration <= 0) {
        setShown(value);

        return;
      }

      let frame = 0;
      let started: number | null = null;

      const step = (now: number) => {
        if (started === null) {
          started = now;
        }

        const elapsed = now - started - delay;

        if (elapsed < 0) {
          frame = requestAnimationFrame(step);

          return;
        }

        const t = Math.min(1, elapsed / duration);

        setShown(from + (value - from) * easeOut(t));

        if (t < 1) {
          frame = requestAnimationFrame(step);
        }
      };

      setShown(from);
      frame = requestAnimationFrame(step);

      return () => cancelAnimationFrame(frame);
    }, [run.started, reduced, value, from, duration, delay]);

    // Held to the decimal places of whichever end has more while it counts. The
    // default format writes up to three, which put `29,851.407` on the screen on
    // the way to a whole number and changed the width of the line every frame.
    const places = Math.max(decimalsOf(value), decimalsOf(from));
    const counted = Math.round(shown * 10 ** places) / 10 ** places;

    return useRender({
      render,
      ref: [ref, run.ref],
      props: {
        ...props,
        // Figures of one width, so the words beside the count stay where they
        // are while it runs.
        className: cx('tabular-nums', className),
        style,
        'data-neba-animation': 'counter',
        'data-state': run.state,
        ...run.handlers,
        children: (
          <>
            <span className={srOnlyClasses}>{formatter.format(value)}</span>
            <span aria-hidden="true">{formatter.format(reduced ? value : counted)}</span>
          </>
        )
      }
    });
  }
);
