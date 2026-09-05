'use client';

import * as React from 'react';
import { IconButton } from '../icon-button/IconButton.js';
import { carouselMessages, fillMessage, useMessages } from '../../internal/i18n.js';
import { ChevronIcon, PauseIcon, PlayIcon } from '../../internal/icons.js';
import { usePrefersReducedMotion } from '../../internal/media.js';
import {
  cx,
  radiusClasses,
  srOnlyClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface CarouselProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Drop shadow depth of the frame. `0` — the default — is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Which slide is showing, counted from 0. Use with `onValueChange`. */
  value?: number;
  /** Which starts showing, for an uncontrolled carousel. @default 0 */
  defaultValue?: number;
  onValueChange?: (index: number) => void;
  /**
   * Whether the arrows wrap from the last slide back to the first. With it off
   * they go inert at the ends instead, which is the honest thing for a set that
   * has a beginning and an end — a gallery of three photographs does, a rotating
   * banner does not.
   * @default true
   */
  loop?: boolean;
  /**
   * Advances on its own.
   *
   * Off by default and deliberately so: a carousel that moves while it is being
   * read is the most complained-about pattern on the web. It pauses on hover,
   * on focus anywhere inside it, while the tab is in the background, and it does
   * not start at all for a reader who has asked for reduced motion.
   *
   * Turning it on draws a button that stops it, first in the frame and first in
   * the tab order. There is no prop to take that button away: hover and focus
   * are not a mechanism for a reader holding a phone or a magnifier, and a
   * caller who wants a control of their own can drive `value` and leave this
   * off.
   * @default false
   */
  autoPlay?: boolean;
  /** How long each slide is held, in milliseconds. @default 5000 */
  interval?: number;
  /** The previous/next buttons. @default true */
  arrows?: boolean;
  /** The row of position dots under the frame. @default true */
  indicators?: boolean;
  /**
   * Which language the carousel names itself in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * The strings below write the words out instead; this is for the far more
   * common case where the page already knows its own language.
   */
  locale?: string;
  /** The carousel's accessible name. Defaults to the `locale`'s word for it. */
  label?: string;
  previousLabel?: string;
  nextLabel?: string;
  /**
   * The rotation control's two names — what it says while the slides are
   * advancing, and what it says once they have been stopped. Default to the
   * `locale`'s wording.
   */
  pauseLabel?: string;
  playLabel?: string;
  /**
   * How one slide is named to a screen reader, and how its dot is labelled.
   * Defaults to the `locale`'s wording.
   */
  slideLabel?: (index: number, count: number) => string;
  /** The slides. Every top-level child becomes one. */
  children?: React.ReactNode;
}

/**
 * The frame, in the three weights a *container* says them — undyed, exactly as
 * on Box and Accordion. A carousel holds other people's pictures.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  // No frame at all — the slides are the whole component. What to reach for when
  // the pictures already have edges of their own.
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * How far the overlaid controls sit in from the frame's edges — the arrows down
 * both sides, the rotation control in the top corner. One table rather than
 * two, so the two cannot drift into different margins at the same size.
 */
const insetClasses: Record<NebaSize, { arrows: string; rotation: string }> = {
  xs: { arrows: 'start-1 end-1', rotation: 'top-1 start-1' },
  sm: { arrows: 'start-1.5 end-1.5', rotation: 'top-1.5 start-1.5' },
  md: { arrows: 'start-2 end-2', rotation: 'top-2 start-2' },
  lg: { arrows: 'start-3 end-3', rotation: 'top-3 start-3' },
  xl: { arrows: 'start-4 end-4', rotation: 'top-4 start-4' }
};

/**
 * The dot ladder. A current dot is a short bar rather than a bigger circle: it
 * grows along the row it is in, so the row's height never changes and the dots
 * either side of it do not move.
 */
const dotClasses: Record<NebaSize, { rest: string; current: string; gap: string }> = {
  xs: { rest: 'h-1 w-1', current: 'h-1 w-3', gap: 'gap-1' },
  sm: { rest: 'h-1 w-1', current: 'h-1 w-3.5', gap: 'gap-1' },
  md: { rest: 'h-1.5 w-1.5', current: 'h-1.5 w-4', gap: 'gap-1.5' },
  lg: { rest: 'h-1.5 w-1.5', current: 'h-1.5 w-5', gap: 'gap-2' },
  xl: { rest: 'h-2 w-2', current: 'h-2 w-6', gap: 'gap-2' }
};

/**
 * A strip of slides, one of which is in view.
 *
 * The mechanism is a scroll container with CSS scroll snapping, and everything
 * good about this component follows from that one choice. Swiping on a phone and
 * two-finger dragging on a trackpad both work because they are the browser's own
 * scrolling and not a gesture handler pretending to be it. The strip runs the
 * other way under RTL without being told, because scrolling is directional and
 * `translate` is not. And nothing is transformed — the house rule against moving
 * a surface holds here for free, where a translated track would have had to
 * argue for an exception.
 *
 * The motion is `scroll-behavior: smooth`, which means a reader who has asked
 * for reduced motion gets an instant cut from the same code path rather than
 * from a second one written to remember them.
 *
 * Slides are not a sub-component. Every top-level child is wrapped in its own
 * slide, so `<Carousel><img /><img /></Carousel>` is the whole API — and the
 * wrapper is what carries the snap point, the width and the
 * `role="group"`/`aria-roledescription="slide"` pair a screen reader needs, none
 * of which a caller should have to remember to put on a photograph.
 */
export const Carousel = React.forwardRef<HTMLDivElement, CarouselProps>(
  function Carousel(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      value,
      defaultValue = 0,
      onValueChange,
      loop = true,
      autoPlay = false,
      interval = 5000,
      arrows = true,
      indicators = true,
      locale,
      label,
      previousLabel,
      nextLabel,
      pauseLabel,
      playLabel,
      slideLabel,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const messages = useMessages(carouselMessages, locale);
    const nameSlide =
      slideLabel ??
      ((index: number, total: number) =>
        fillMessage(messages.slide, { index: String(index), total: String(total) }));

    // `toArray` is what drops the `null`s and `false`s a conditional slide leaves
    // behind, and what gives every remaining child a stable key.
    const slides = React.Children.toArray(children);
    const count = slides.length;

    const [uncontrolled, setUncontrolled] = React.useState(defaultValue);
    const index = Math.min(Math.max(value ?? uncontrolled, 0), Math.max(count - 1, 0));

    const trackRef = React.useRef<HTMLDivElement>(null);
    const slideRefs = React.useRef<(HTMLDivElement | null)[]>([]);
    // Set while the index is catching up with a scroll the reader performed. The
    // effect below skips those, or every drag would be answered by a scroll back
    // to where the browser had already put us.
    const fromScroll = React.useRef(false);
    const mounted = React.useRef(false);
    // Raised while a smooth scroll of our own is still travelling. Without it the
    // scroll events thrown on the way from slide 0 to slide 2 would each be read
    // as the reader landing on slide 1.
    const settling = React.useRef(false);
    const [paused, setPaused] = React.useState(false);
    // Two ways of not advancing, and they have to stay apart. `paused` is the
    // pointer or the focus and lasts as long as they do; `stopped` is the reader
    // pressing the button and lasts until they press it again.
    const [stopped, setStopped] = React.useState(false);

    const go = React.useCallback(
      (next: number, viaScroll = false) => {
        if (count === 0) {
          return;
        }

        const wrapped = loop
          ? ((next % count) + count) % count
          : Math.min(Math.max(next, 0), count - 1);

        fromScroll.current = viaScroll;

        if (value === undefined) {
          setUncontrolled(wrapped);
        }
        if (wrapped !== index) {
          onValueChange?.(wrapped);
        }
      },
      [count, loop, value, index, onValueChange]
    );

    React.useEffect(() => {
      if (fromScroll.current) {
        fromScroll.current = false;
        return;
      }

      // The first pass would otherwise scroll the page down to a carousel nobody
      // has looked at yet, just to put slide 0 where the browser already had it.
      if (!mounted.current) {
        mounted.current = true;
        return;
      }

      slideRefs.current[index]?.scrollIntoView({ block: 'nearest', inline: 'start' });

      settling.current = true;
      const timer = window.setTimeout(() => {
        settling.current = false;
      }, 700);

      return () => window.clearTimeout(timer);
    }, [index]);

    /**
     * Where the strip has settled, read off the scroll offset rather than measured
     * per slide: every slide is exactly the width of the frame, so the offset
     * divided by that width *is* the index. `Math.abs` is what makes it hold under
     * RTL, where a scroll position counts backwards from zero.
     */
    const handleScroll = () => {
      const track = trackRef.current;
      // `settling` is tested before anything is measured, and that order is the
      // point: a smooth scroll of our own throws events for most of a second, and
      // those are exactly the ones with nothing to answer. Reading `clientWidth`
      // first would force a layout on every one of them.
      if (settling.current || !track || track.clientWidth === 0) {
        return;
      }

      const nearest = Math.round(Math.abs(track.scrollLeft) / track.clientWidth);
      if (nearest !== index && nearest >= 0 && nearest < count) {
        go(nearest, true);
      }
    };

    // Subscribed rather than read once inside the effect below: a reader who
    // turns the setting on while a strip is already running has asked for it to
    // stop, and a value read at setup would go on advancing until something else
    // happened to re-run the effect.
    const reduced = usePrefersReducedMotion();

    React.useEffect(() => {
      // A reader who has asked for less motion has asked for this in particular.
      if (!autoPlay || stopped || paused || reduced || count < 2) {
        return;
      }

      const timer = window.setInterval(() => {
        if (document.hidden) {
          return;
        }
        go(index + 1);
      }, interval);

      return () => window.clearInterval(timer);
    }, [autoPlay, stopped, paused, reduced, count, interval, index, go]);

    const atStart = index <= 0;
    const atEnd = index >= count - 1;

    /*
     * Whether this carousel rotates at all — which is the question the control
     * and the live region both turn on, and it is not the same as `autoPlay`. A
     * strip of one slide has nowhere to go, and a reader who has asked for less
     * motion is never going to see it move, so drawing a button that claims to
     * stop it would be a control with nothing behind it.
     */
    const rotates = autoPlay && !reduced && count > 1;

    return (
      <div
        ref={ref}
        role="region"
        aria-roledescription="carousel"
        aria-label={label ?? messages.label}
        className={cx('flex flex-col', className ?? '')}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        // Hover and focus both stop the timer. The second one is the important
        // one: a keyboard reader who has tabbed into a slide is reading it.
        onPointerEnter={() => setPaused(true)}
        onPointerLeave={() => setPaused(false)}
        onFocus={() => setPaused(true)}
        onBlur={() => setPaused(false)}
        {...props}
      >
        <div
          className={[
            'relative min-w-0 overflow-hidden',
            radiusClasses[size],
            variantClasses[variant],
            transitionClasses
          ].join(' ')}
        >
          {rotates ? (
            /*
             * Drawn before the strip, and therefore reached before it: a reader
             * on a keyboard meets the way to stop the slides before they meet
             * the slides. Hover and focus already pause it for them, which is
             * exactly what they do not do for a reader holding a phone or
             * running a magnifier — this is the mechanism those two have.
             *
             * Positioned by a wrapper rather than by a class on the button, for
             * the reason the arrows are: every Button root carries `relative`,
             * Tailwind emits `.relative` after `.absolute`, and two utilities of
             * equal specificity are decided by the stylesheet and not by the
             * class attribute. An `absolute` written on the button loses — and
             * loses silently, leaving it in the flow above the strip.
             */
            <span className={`absolute z-10 flex ${insetClasses[size].rotation}`}>
              <IconButton
                variant="solid"
                size={size}
                color={color}
                density={density}
                elevation={1}
                label={stopped ? (playLabel ?? messages.play) : (pauseLabel ?? messages.pause)}
                icon={stopped ? <PlayIcon /> : <PauseIcon />}
                onClick={() => setStopped((was) => !was)}
              />
            </span>
          ) : null}

          <div
            ref={trackRef}
            // Focusable, so the strip can be scrolled with the arrow keys by
            // whoever is not using a pointer. That is the browser's own key
            // handling on a scroll container, which means it is already right
            // under RTL — a handler of ours mapping ArrowRight to "next" would not
            // have been.
            tabIndex={0}
            role="group"
            aria-label={label ?? messages.label}
            className={[
              'flex min-w-0 snap-x snap-mandatory overflow-x-auto scroll-smooth',
              'motion-reduce:scroll-auto',
              // The strip is driven by buttons and by dragging; a scrollbar under
              // it is a third control saying the same thing.
              '[scrollbar-width:none] [&::-webkit-scrollbar]:hidden',
              'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]'
            ].join(' ')}
            onScroll={handleScroll}
          >
            {slides.map((slide, slideIndex) => (
              <div
                key={slideIndex}
                ref={(element) => {
                  slideRefs.current[slideIndex] = element;
                }}
                role="group"
                aria-roledescription="slide"
                aria-label={nameSlide(slideIndex + 1, count)}
                // Deliberately *not* `aria-hidden` when off-screen. A slide can
                // hold a link or a button, and an `aria-hidden` subtree that is
                // still in the tab order is the exact shape of the bug where a
                // keyboard reader lands somewhere their screen reader refuses to
                // describe. The strip is scrollable, so everything in it is
                // genuinely reachable — hiding it would be a lie.
                className="w-full shrink-0 grow-0 basis-full snap-start"
              >
                {slide}
              </div>
            ))}
          </div>

          {arrows && count > 1 ? (
            <div
              className={`pointer-events-none absolute inset-y-0 flex items-center ${insetClasses[size].arrows}`}
            >
              <IconButton
                variant="solid"
                size={size}
                color={color}
                density={density}
                elevation={1}
                label={previousLabel ?? messages.previous}
                disabled={!loop && atStart}
                className="pointer-events-auto"
                // Drawn pointing down and turned, which is the one allowance the
                // no-transform rule makes — and turned the other way under RTL,
                // where "previous" is on the other side of the frame.
                icon={
                  <span className="flex items-center rotate-90 rtl:-rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go(index - 1)}
              />
              <span className="flex-1" />
              <IconButton
                variant="solid"
                size={size}
                color={color}
                density={density}
                elevation={1}
                label={nextLabel ?? messages.next}
                disabled={!loop && atEnd}
                className="pointer-events-auto"
                icon={
                  <span className="flex items-center -rotate-90 rtl:rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go(index + 1)}
              />
            </div>
          ) : null}
        </div>

        {indicators && count > 1 ? (
          <div className={`flex shrink-0 items-center justify-center pt-2 ${dotClasses[size].gap}`}>
            {slides.map((_, dotIndex) => (
              <button
                key={dotIndex}
                type="button"
                aria-label={nameSlide(dotIndex + 1, count)}
                aria-current={dotIndex === index ? 'true' : undefined}
                className={[
                  'cursor-pointer rounded-full',
                  // Width and colour, never a transform: the current dot grows
                  // along the row instead of scaling, so nothing beside it moves.
                  '[transition-property:width,background-color]',
                  '[transition-duration:var(--neba-duration)]',
                  '[transition-timing-function:var(--neba-ease)]',
                  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
                  dotIndex === index
                    ? `${dotClasses[size].current} bg-(--n-accent)`
                    : `${dotClasses[size].rest} bg-(--n-line-hover) hover:bg-(--n-accent)`
                ].join(' ')}
                onClick={() => go(dotIndex)}
              />
            ))}
          </div>
        ) : null}

        {/* Where the reader is, as a sentence rather than as a highlighted dot.
          Silent while the carousel is advancing on its own: a live region that
          says a new slide's name every five seconds is what makes a screen
          reader unusable on a page that has one. Stopping it is what turns the
          announcements back on, since from then on the only thing that moves
          the strip is the reader. */}
        <span className={srOnlyClasses} aria-live={rotates && !stopped ? 'off' : 'polite'}>
          {count > 0 ? nameSlide(index + 1, count) : ''}
        </span>
      </div>
    );
  }
);
