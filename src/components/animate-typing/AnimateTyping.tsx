'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimationRun, usePrefersReducedMotion } from '../../internal/animate.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import { graphemesOf, textOf } from '../../internal/text.js';
import type { NebaAnimateProps } from '../../types.js';

export interface AnimateTypingProps
  extends
    Omit<NebaAnimateProps, 'alternate' | 'easing'>,
    Omit<React.ComponentPropsWithoutRef<'span'>, 'children'> {
  /**
   * Renders something other than a `<span>`, such as `render={<h1 />}` for a
   * headline being typed. A `<span>` by default, with a block display, so the
   * component can sit inside a paragraph. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  /**
   * The text, when it is easier to pass than to nest. Overrides `children`.
   */
  text?: string;
  /**
   * How fast it is typed, in characters per second.
   * @default 24
   */
  speed?: number;
  /**
   * How long the finished text is held before it repeats, in milliseconds.
   * @default 1400
   */
  hold?: number;
  /**
   * Deletes the text again before repeating, rather than clearing it in one
   * frame. Only means anything when `repeat` is more than once.
   * @default false
   */
  erase?: boolean;
  /**
   * How fast it is deleted, in characters per second. Deleting is usually about
   * twice as fast as typing, which is what a person actually does.
   * @default twice `speed`
   */
  eraseSpeed?: number;
  /**
   * The block after the text.
   * @default true
   */
  caret?: boolean;
  /** What the caret is drawn as. @default '|' */
  caretChar?: React.ReactNode;
  /** The text to type. Only text is typed — see below. */
  children?: React.ReactNode;
}

/**
 * Text appearing one character at a time.
 *
 * The whole string is in the document from the first frame — in a clipped box
 * for a screen reader, which reads it once and is not made to sit through the
 * performance — and what animates is a visible copy that is `aria-hidden`. So
 * the effect costs a reader who cannot see it nothing, and costs a reader who
 * can nothing either: the box is laid out from the whole string rather than
 * from the characters that have arrived, so the text around it does not reflow
 * on every frame.
 *
 * `repeat`, `hold` and `erase` are what make it a loop: type, hold, delete,
 * type again. Without `erase` a repeat clears in one frame, which is right for
 * a line that is being replaced rather than rewritten.
 *
 * Only text is typed. Pass a string, or strings; an element among the children
 * contributes its text and nothing about its markup, because there is no honest
 * way to reveal half of a link.
 */
export const AnimateTyping = React.forwardRef<HTMLElement, AnimateTypingProps>(
  function AnimateTyping(
    {
      text,
      speed = 24,
      hold = 1400,
      erase = false,
      eraseSpeed,
      caret = true,
      caretChar = '|',
      duration,
      delay = 0,
      repeat = 1,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
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
    const graphemes = React.useMemo(() => graphemesOf(source), [source]);
    const total = graphemes.length;

    const [shown, setShown] = React.useState(0);

    /**
     * Where the performance is, outside React's state: how many characters are
     * showing, which pass it is on, and whether it is deleting.
     *
     * The typing loop is a chain of timeouts rather than a render, so pausing
     * tears it down and resuming builds a new one — and a new one has to know
     * where the old one stopped, all three of those included. Keeping only the
     * count started a resumed loop on its first pass, so every pause gave a
     * repeat one pass more than it asked for. Reading `shown` would put the
     * effect in a loop with its own output.
     */
    const progress = React.useRef({ count: 0, pass: 1, deleting: false });

    /**
     * `duration` is honoured as the time for the whole string, because a caller
     * who has set a duration on every other Animate component will reach for it
     * here too. `speed` is the natural unit for a typewriter — a long paragraph
     * and a short one should be typed at the same pace, not in the same time —
     * so it is the default and the duration overrides it.
     */
    const typeDelay = duration && total > 0 ? duration / total : 1000 / Math.max(speed, 1);
    const deleteDelay = 1000 / Math.max(eraseSpeed ?? speed * 2, 1);

    // A new string starts a new performance rather than continuing the last.
    // Keyed on the string itself: keyed on its length, a replacement of the same
    // length appeared whole.
    React.useEffect(() => {
      progress.current = { count: 0, pass: 1, deleting: false };
    }, [source]);

    React.useEffect(() => {
      if (reduced || total === 0) {
        // Not "nothing happens" — the text is simply there, which is the only
        // outcome that still delivers what the component was carrying.
        setShown(total);

        return;
      }

      if (!run.started) {
        // Waiting is empty, not finished: a typewriter that showed its whole
        // string until it scrolled into view and then blanked would be worse
        // than no effect at all.
        progress.current = { count: 0, pass: 1, deleting: false };
        setShown(0);

        return;
      }

      if (paused || run.offscreen) {
        return;
      }

      let cancelled = false;
      let timer: ReturnType<typeof setTimeout>;
      const position = progress.current;
      const passes = repeat === 'infinite' ? Infinity : Math.max(1, repeat);

      if (position.count >= total && position.pass >= passes && !position.deleting) {
        return;
      }

      const step = () => {
        if (cancelled) {
          return;
        }

        if (position.deleting) {
          position.count -= 1;
          setShown(position.count);

          if (position.count <= 0) {
            position.deleting = false;
            position.pass += 1;
          }

          timer = setTimeout(step, position.deleting ? deleteDelay : typeDelay);

          return;
        }

        // A loop resumed at the end of a pass has nothing left to type before
        // the hold.
        if (position.count < total) {
          position.count += 1;
          setShown(position.count);
        }

        if (position.count < total) {
          timer = setTimeout(step, typeDelay);

          return;
        }

        if (position.pass >= passes) {
          return;
        }

        if (erase) {
          position.deleting = true;
          timer = setTimeout(step, hold);

          return;
        }

        timer = setTimeout(() => {
          if (cancelled) {
            return;
          }

          // Counted when the line clears rather than when the hold begins, so a
          // pause inside the hold does not skip the pass that follows it.
          position.count = 0;
          position.pass += 1;
          setShown(0);
          timer = setTimeout(step, typeDelay);
        }, hold);
      };

      setShown(position.count);
      // Resuming picks up at the next step; starting waits out the delay.
      timer = setTimeout(
        step,
        position.count === 0 && position.pass === 1
          ? delay
          : position.deleting
            ? deleteDelay
            : typeDelay
      );

      return () => {
        cancelled = true;
        clearTimeout(timer);
      };
    }, [
      run.started,
      run.offscreen,
      paused,
      reduced,
      source,
      total,
      typeDelay,
      deleteDelay,
      delay,
      hold,
      erase,
      repeat
    ]);

    // Held rather than written inline: an inline callback is a new function on
    // every render, which React answers by calling the old one with `null` and
    // the new one with the node — every render, and this one renders for every
    // character it types.
    const runRef = run.ref;
    const attach = React.useCallback(
      (node: HTMLElement | null) => {
        runRef(node);

        if (typeof ref === 'function') {
          ref(node);
        } else if (ref) {
          (ref as React.MutableRefObject<HTMLElement | null>).current = node;
        }
      },
      [ref, runRef]
    );

    return useRender({
      render: render ?? <span />,
      ref: attach,
      props: {
        className: cx('grid', className),
        style,
        'data-neba-animation': 'typing',
        'data-state': run.state,
        ...props,
        ...run.handlers,
        children: (
          <>
            <span className={srOnlyClasses}>{source}</span>
            <span aria-hidden="true" className="whitespace-pre-wrap [grid-area:1/1]">
              {graphemes.slice(0, shown).join('')}
              {caret ? <span className={cx('neba-typing-caret')}>{caretChar}</span> : null}
            </span>
            {/* The final string, laid out underneath and drawn by nobody, so the box
                takes its size from what the line will be rather than from what
                has arrived. Generated content off `data-sample`, as the width
                sizer draws its samples, so it leaves nothing for a find-in-page
                or a query for the text to match. */}
            <span
              aria-hidden="true"
              data-sample={source}
              className="invisible whitespace-pre-wrap [grid-area:1/1] before:content-[attr(data-sample)]"
            />
          </>
        )
      }
    });
  }
);
