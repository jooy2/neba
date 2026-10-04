'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimationRun, usePrefersReducedMotion } from '../../internal/animate.js';
import { graphemesOf, portableGraphemesOf, standsAlone, textOf } from '../../internal/text.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type { NebaAnimateProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { useHydrated } from '../../internal/media.js';

export interface AnimateScrambleProps
  extends
    Omit<NebaAnimateProps, 'easing' | 'alternate'>,
    Omit<React.ComponentPropsWithoutRef<'span'>, 'children'> {
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
  /**
   * Renders something other than a `<span>`. A `<span>` by default, so it can
   * sit inside a sentence or a Statistic's value. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  /** The text to settle. Only text is settled. */
  children?: React.ReactNode;
}

/** Monospaced-ish and all one height, so the line does not jump as it settles. */
const DEFAULT_POOL = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&$@*';

/** A word that has settled: the final text, drawn where the line puts it. */
const settledWordClasses = 'visible before:content-[attr(data-sample)]';

/** A word that has not: the final text laid out unseen, and its noise over it. */
const scramblingWordClasses =
  'relative before:content-[attr(data-sample)] after:visible after:absolute after:inset-0 after:flex after:items-center after:overflow-x-clip after:whitespace-pre after:content-[attr(data-text)]';

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
 * this one resolves it out of a line that was already the right length. The box
 * is laid out from the final text, so nothing around it reflows and a heading
 * does not push the page down as it lands. Each word's noise is drawn over the
 * word it settles into, so the line breaks where the final text breaks. In a
 * proportional font a word's noise can be wider than the word for a moment, and
 * is cut off at the word's end rather than moving anything.
 *
 * Whitespace is never scrambled. A space that flickers into a letter and back
 * reads as the words having moved, which is the one thing this effect is for
 * avoiding.
 *
 * The finished string is in the document from the first frame, in a clipped box
 * for a screen reader; the noise is a visible copy that is `aria-hidden`. A
 * reader who has asked for less motion is shown the text.
 *
 * That clipped string is the only text the element holds. The noise is drawn
 * as generated content off a data attribute, as the final string underneath it
 * already was, so a copy, a crawler and `textContent` read the text once rather
 * than the text followed by a line of noise.
 */
export const AnimateScramble = React.forwardRef<HTMLElement, AnimateScrambleProps>(
  function AnimateScramble(rawProps, ref) {
    const {
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
    } = useStyleDefaults(rawProps, ['locale']);
    const run = useAnimationRun({
      caller: props,
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: isInfinite(repeat)
    });
    const reduced = usePrefersReducedMotion();

    const source = text ?? textOf(children);
    // Cut the same way on every engine until the page has hydrated: the noise
    // is picked per character, and a server and a browser that count the
    // characters differently would draw two different opening frames.
    const hydrated = useHydrated();
    const graphemes = React.useMemo(
      () => (hydrated ? graphemesOf(source, locale) : portableGraphemesOf(source)),
      [hydrated, source, locale]
    );
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

    /**
     * How many letters have settled, outside React's state. A pause tears the
     * timers down, and the ones that resume have to start from where those
     * stopped: counting from zero again sent a paused heading back to noise.
     */
    const progress = React.useRef(0);
    // The run that count belongs to. A new one is a replay, scrambled again from
    // the first letter rather than resumed.
    const progressRun = React.useRef(run.run);

    // A text of another length starts again from its first letter, as it did
    // before the count was kept.
    React.useEffect(() => {
      progress.current = 0;
    }, [total]);

    React.useEffect(() => {
      if (!run.started) {
        // The next start is a new run rather than a resumed one.
        progress.current = 0;

        return;
      }

      if (progressRun.current !== run.run) {
        progressRun.current = run.run;
        progress.current = 0;
      }

      if (paused) {
        return;
      }

      if (reduced || total === 0) {
        setSettled(total);

        return;
      }

      let settle: ReturnType<typeof setTimeout>;
      let done = Math.min(progress.current, total);

      if (done >= total) {
        setSettled(total);

        return;
      }

      const advance = () => {
        done += 1;
        progress.current = done;
        setSettled(done);

        if (done < total) {
          settle = setTimeout(advance, settleDelay);
        } else {
          clearInterval(noise);
        }
      };

      setSettled(done);

      const noise = setInterval(redraw, tick);

      // Starting waits out the delay as well; resuming waits only for the next
      // letter.
      settle = setTimeout(advance, done === 0 ? delay + settleDelay : settleDelay);

      return () => {
        clearTimeout(settle);
        clearInterval(noise);
      };
    }, [run.started, run.run, paused, reduced, total, settleDelay, tick, delay]);

    const pool = characters.length > 0 ? characters : DEFAULT_POOL;

    /*
     * The line as words, each with what it shows on this tick and the
     * whitespace after it.
     *
     * Word by word because the noise is laid over the final text rather than
     * beside it. It shared a grid cell with the final text before, so the box
     * took the wider of the two and a heading could gain a line while it
     * settled. One layer of noise over the whole line, at the final text's
     * width, would wrap its last word early wherever the noise ran wider, and
     * drop it onto whatever was below. Laid over each word, the noise breaks
     * where the final text breaks, and the box is only ever the final text's
     * size. A character of a script written without spaces is a word of its
     * own: a line may break inside a run of them, and the noise over a word
     * has to stay on one line.
     */
    const words: { text: string; shown: string; gap: string; settled: boolean }[] = [];

    graphemes.forEach((grapheme, index) => {
      const blank = grapheme.trim() === '';
      const alone = !blank && standsAlone(grapheme);
      let word = words[words.length - 1];

      if (!word || (!blank && (word.gap || alone || standsAlone(graphemes[index - 1] ?? '')))) {
        word = { text: '', shown: '', gap: '', settled: true };
        words.push(word);
      }

      if (blank) {
        word.gap += grapheme;

        return;
      }

      // A reader who asked for less motion is shown the text, and not the
      // noise it would have resolved out of — including while it waits for a
      // trigger that, for `hover` or `manual`, may never come.
      const done = reduced || index < settled;

      word.text += grapheme;
      word.shown += done ? grapheme : pool[glyphAt(noise, index, pool.length)];
      word.settled &&= done;
    });

    return useRender({
      render: render ?? <span />,
      ref: [ref, run.ref],
      props: {
        ...props,
        className: cx('inline-grid', className),
        style,
        'data-neba-animation': 'scramble',
        'data-state': run.state,
        ...run.handlers,
        children: (
          <>
            <span className={srOnlyClasses}>{source}</span>
            {/* The final string, laid out from the first frame so the box takes
                its size from what the line will be rather than from what has
                arrived, and drawn a word at a time as each one settles.
                Generated content off `data-sample`, as the width sizer draws its
                samples, so it leaves nothing for a find-in-page or a query for
                the text to match. Every word and every gap is an inline span, so
                the line is laid out, broken and ordered exactly as the text
                itself would be — an inline block per word would put a
                right-to-left line's words in the wrong order. */}
            <span aria-hidden="true" className="invisible whitespace-pre-wrap [grid-area:1/1]">
              {words.map((word, index) => (
                <React.Fragment key={index}>
                  {/* A word that has settled is drawn where the line puts it, so
                      a finished line is plain text in every browser — Safari
                      places a box positioned against an inline wrongly when a
                      left-to-right word sits in a right-to-left line. One that
                      has not draws its noise as its `::after`, positioned over
                      it and centred on it, which puts its baseline on the
                      word's: an inline box is the text's own height, and the
                      line is the same distance taller above it as below. The
                      noise is cut off at the word's end rather than running
                      into the next word or the sentence after it — only across,
                      since a clip down the page would cut the descenders off a
                      heading set solid. */}
                  {word.text ? (
                    <span
                      data-sample={word.text}
                      data-text={word.settled ? undefined : word.shown}
                      className={word.settled ? settledWordClasses : scramblingWordClasses}
                    />
                  ) : null}
                  {word.gap ? (
                    <span data-sample={word.gap} className="before:content-[attr(data-sample)]" />
                  ) : null}
                </React.Fragment>
              ))}
            </span>
          </>
        )
      }
    });
  }
);
