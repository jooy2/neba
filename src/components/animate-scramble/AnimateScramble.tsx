'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimationRun, usePrefersReducedMotion } from '../../internal/animate.js';
import { graphemesOf, textOf } from '../../internal/text.js';
import { srOnlyClasses } from '../../internal/styles.js';
import type { NebaAnimateProps } from '../../types.js';

export interface AnimateScrambleProps
  extends
    Omit<NebaAnimateProps, 'easing' | 'alternate'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'children'> {
  /** The text, when it is easier to pass than to nest. Overrides `children`. */
  text?: string;
  /**
   * How fast the text settles, in characters per second.
   * @default 18
   */
  speed?: number;
  /**
   * How often an unsettled character is redrawn, in milliseconds. Lower is
   * busier; below about 30 it stops reading as characters at all.
   * @default 45
   */
  tick?: number;
  /**
   * The pool an unsettled character is drawn from. Deliberately narrow — a pool
   * with tall and short glyphs in it makes the line jump as it settles.
   */
  characters?: string;
  /**
   * Which language the text is in, for finding the character boundaries.
   */
  locale?: string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  /** The text to settle. Only text is settled. */
  children?: React.ReactNode;
}

/** Monospaced-ish and all one height, so the line does not jump as it settles. */
const DEFAULT_POOL = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&$@*';

/**
 * Which glyph an unsettled position shows on a given tick.
 *
 * A mix of the two numbers rather than `Math.random()`, and the difference is
 * what happens on a render this component did not ask for. The noise is picked
 * during the render, so with a random source every re-render from anywhere
 * above — a parent's state, a route change, a resize — reshuffled every letter
 * that had not settled yet, at whatever moment that render happened to land.
 * The effect is meant to be a clock, and it was answering to the whole page.
 *
 * Keyed on the tick and the position, the same pair always gives the same
 * glyph: a render that is not a tick redraws exactly what was already there.
 * It also settles the one hydration mismatch this component had, since the
 * server and the browser now pick the same opening frame.
 */
function glyphAt(tick: number, index: number, size: number): number {
  let mixed = Math.imul(tick + 1, 0x85ebca6b) ^ Math.imul(index + 1, 0xc2b2ae35);

  mixed ^= mixed >>> 15;
  mixed = Math.imul(mixed, 0x2545f491);
  mixed ^= mixed >>> 13;

  return (mixed >>> 0) % size;
}

/**
 * Text arriving through noise, one character at a time.
 *
 * `AnimateTyping`'s sibling: a typewriter reveals a string from an empty line,
 * this one resolves it out of a line that was already the right length. That is
 * the whole reason to choose it — the box never changes size, so nothing around
 * it reflows and a heading does not push the page down as it lands.
 *
 * Whitespace is never scrambled. A space that flickers into a letter and back
 * reads as the words having moved, which is the one thing this effect is for
 * avoiding.
 *
 * The finished string is in the document from the first frame, in a clipped box
 * for a screen reader; the noise is a visible copy that is `aria-hidden`. A
 * reader who has asked for less motion is shown the text.
 */
export const AnimateScramble = React.forwardRef<HTMLDivElement, AnimateScrambleProps>(
  function AnimateScramble(
    {
      text,
      speed = 18,
      tick = 45,
      characters = DEFAULT_POOL,
      duration,
      delay = 0,
      repeat = 1,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      locale,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const run = useAnimationRun({
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: isInfinite(repeat)
    });
    const reduced = usePrefersReducedMotion();

    const source = text ?? textOf(children);
    const graphemes = React.useMemo(() => graphemesOf(source, locale), [source, locale]);
    const total = graphemes.length;

    // How many characters have settled, counted from the left.
    const [settled, setSettled] = React.useState(0);
    // Bumped on every tick. It is both the redraw and the seed the glyphs are
    // picked with, which is what keeps a render that is not a tick from
    // reshuffling letters the clock has not reached yet.
    const [noise, redraw] = React.useReducer((n: number) => n + 1, 0);

    const settleDelay = React.useMemo(() => {
      // `duration` wins when it is given: it is the whole run, so the per
      // character delay falls out of it rather than being asked for twice.
      if (duration !== undefined && total > 0) {
        return Math.max(1, duration / total);
      }

      return 1000 / Math.max(1, speed);
    }, [duration, speed, total]);

    React.useEffect(() => {
      if (!run.started || paused) {
        return;
      }

      if (reduced || total === 0) {
        setSettled(total);

        return;
      }

      let settle: ReturnType<typeof setTimeout>;
      let done = 0;

      const advance = () => {
        done += 1;
        setSettled(done);

        if (done < total) {
          settle = setTimeout(advance, settleDelay);
        } else {
          clearInterval(noise);
        }
      };

      setSettled(0);

      const noise = setInterval(redraw, tick);

      settle = setTimeout(advance, delay + settleDelay);

      return () => {
        clearTimeout(settle);
        clearInterval(noise);
      };
    }, [run.started, paused, reduced, total, settleDelay, tick, delay]);

    const pool = characters.length > 0 ? characters : DEFAULT_POOL;
    const shown = graphemes
      .map((grapheme, index) => {
        if (index < settled || grapheme.trim() === '') {
          return grapheme;
        }

        return pool[glyphAt(noise, index, pool.length)];
      })
      .join('');

    return useRender({
      render,
      ref: [ref, run.ref],
      props: {
        ...props,
        className,
        style,
        'data-neba-animation': 'scramble',
        'data-state': run.state,
        ...run.handlers,
        children: (
          <>
            <span className={srOnlyClasses}>{source}</span>
            <span aria-hidden="true" className="whitespace-pre-wrap">
              {shown}
            </span>
          </>
        )
      }
    });
  }
);
