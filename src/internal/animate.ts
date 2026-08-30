'use client';

/**
 * The machinery every `Animate*` component runs on, and the `transition` prop
 * with it.
 *
 * It lives in `internal/` for the reason `button-group.ts` and `menu.ts` do:
 * eleven components need it and none of them should have to import another. The
 * `transition` prop needs the same table from the other side — a Card and an
 * `AnimateFade` must produce the same fade, or the library has two fades.
 *
 * ## The shape of it
 *
 * Every effect is one `@keyframes` in `styles.css` running from a state written
 * entirely in custom properties to the element's natural one. Nothing here
 * generates CSS: it fills `--n-anim-*` slots, and the stylesheet decides what
 * they mean. That is the same split `styleSlots()` makes for colour, for the
 * same reason — Tailwind only ever sees class names that appear literally in
 * the source, so a per-value class would not scale past the first prop.
 *
 * Because the from-state is the *keyframe* rather than a second class, running
 * an effect backwards is `animation-direction: reverse` and nothing else. That
 * is what makes `mode="out"` free on all six.
 *
 * ## What is deliberately not here
 *
 * An animation that has to know what its children *are* — a marquee that
 * duplicates them, a headline that swaps between them, a typewriter that
 * counts characters — cannot be a class name and a few numbers. Those are
 * components, and their logic stays in their own files.
 */

import * as React from 'react';
import { observeVisibility } from './observe.js';
import type {
  NebaAnimateRepeat,
  NebaAnimateTrigger,
  NebaAnimation,
  NebaSide,
  NebaTransition
} from '../types.js';

/* ---------------------------------------------------------------------------
 * Slots
 * ------------------------------------------------------------------------- */

/**
 * Which keyframe an effect runs.
 *
 * `grow` and `zoom` share one: they are the same arithmetic at two strengths,
 * and a second identical `@keyframes` would only be a second place to fix a
 * bug. What separates them is their defaults and their origin, which is a
 * property rather than a keyframe.
 */
export const animationClasses: Record<NebaAnimation, string> = {
  fade: 'neba-anim-fade',
  grow: 'neba-anim-scale',
  slide: 'neba-anim-slide',
  zoom: 'neba-anim-scale',
  rotate: 'neba-anim-rotate',
  blink: 'neba-anim-blink'
};

/** The class that reads the slots. Always paired with one of the above. */
export const animBaseClass = 'neba-anim';

/**
 * How long each effect takes when nobody said.
 *
 * They are not one number because they do not travel the same distance. A fade
 * crosses one axis of opacity; a rotate crosses half a turn and reads as rushed
 * at the same duration. `blink` is the odd one out — it is a cycle rather than
 * an arrival, so its number is a period.
 */
export const defaultDurations: Record<NebaAnimation, number> = {
  fade: 320,
  grow: 340,
  slide: 380,
  zoom: 340,
  rotate: 460,
  blink: 900
};

/** A number is pixels; a string is already a CSS length. */
export function lengthValue(value: number | string): string {
  return typeof value === 'number' ? `${value}px` : value;
}

/** `'infinite'` reaches CSS as the word; a count reaches it as the number. */
function repeatValue(repeat: NebaAnimateRepeat): string {
  return repeat === 'infinite' ? 'infinite' : String(repeat);
}

export function isInfinite(repeat: NebaAnimateRepeat | undefined): boolean {
  return repeat === 'infinite';
}

/**
 * `normal`, `reverse`, `alternate`, `alternate-reverse` — the four CSS already
 * has, assembled from the two props that mean something to a caller.
 *
 * `mode="out"` is a reversed run rather than a keyframe of its own, which is
 * also why a reversed animation ends held on its own first frame: `fill-mode`
 * is `both`, so a faded-out element stays faded out instead of snapping back.
 */
function directionValue(mode: 'in' | 'out', alternate: boolean | undefined): string {
  if (mode === 'out') {
    return alternate ? 'alternate-reverse' : 'reverse';
  }

  return alternate ? 'alternate' : 'normal';
}

export interface AnimationSlotOptions {
  duration: number;
  delay: number;
  easing?: string;
  repeat: NebaAnimateRepeat;
  alternate?: boolean;
  mode?: 'in' | 'out';
  /** Where the animated properties start. Only the ones an effect reads. */
  opacity?: number;
  scale?: number;
  x?: string;
  y?: string;
  angle?: string;
  angleTo?: string;
}

/**
 * The `--n-anim-*` slots, as an inline style object.
 *
 * Inline rather than utilities for the reason the colour slots are: these are
 * per-instance numbers, and Tailwind cannot generate a class for a duration it
 * has never seen written down.
 */
export function animationSlots(options: AnimationSlotOptions): React.CSSProperties {
  const slots: Record<string, string> = {
    '--n-anim-duration': `${options.duration}ms`,
    '--n-anim-delay': `${options.delay}ms`,
    '--n-anim-repeat': repeatValue(options.repeat),
    '--n-anim-direction': directionValue(options.mode ?? 'in', options.alternate)
  };

  if (options.easing) {
    slots['--n-anim-ease'] = options.easing;
  }

  if (options.opacity !== undefined) {
    slots['--n-anim-opacity'] = String(options.opacity);
  }

  if (options.scale !== undefined) {
    slots['--n-anim-scale'] = String(options.scale);
  }

  if (options.x !== undefined) {
    slots['--n-anim-x'] = options.x;
  }

  if (options.y !== undefined) {
    slots['--n-anim-y'] = options.y;
  }

  if (options.angle !== undefined) {
    slots['--n-anim-angle'] = options.angle;
  }

  if (options.angleTo !== undefined) {
    slots['--n-anim-angle-to'] = options.angleTo;
  }

  return slots as React.CSSProperties;
}

/**
 * Which way a slide starts, given the edge it comes from.
 *
 * `NebaSide` is physical everywhere in the library, and it stays physical here:
 * something sliding in from the top of the window comes from the top in every
 * writing direction.
 */
export function slideOffsets(from: NebaSide, distance: number | string): { x: string; y: string } {
  const length = lengthValue(distance);
  const negative = typeof distance === 'number' ? `${-distance}px` : `calc(-1 * ${length})`;

  switch (from) {
    case 'top':
      return { x: '0px', y: negative };
    case 'bottom':
      return { x: '0px', y: length };
    case 'left':
      return { x: negative, y: '0px' };
    default:
      return { x: length, y: '0px' };
  }
}

/* ---------------------------------------------------------------------------
 * The `transition` prop
 * ------------------------------------------------------------------------- */

/**
 * What a component's `transition` prop turns into: one class pair and a handful
 * of custom properties, merged into whatever the component was already writing.
 *
 * No hook, no ref, no observer — which is the whole design. A component that
 * offers `transition` gains four lines and no behaviour it has to own, and a
 * caller who needs a trigger, a replay or a hover reaches for the `Animate*`
 * component that does exactly that.
 */
export function transitionProps(transition: NebaTransition | undefined): {
  className: string;
  style: React.CSSProperties;
} {
  if (!transition) {
    return { className: '', style: {} };
  }

  const options = typeof transition === 'string' ? { type: transition } : transition;
  const { type } = options;

  const slots: AnimationSlotOptions = {
    duration: options.duration ?? defaultDurations[type],
    delay: options.delay ?? 0,
    easing: options.easing,
    // A blink that ran once would be a flicker, which is a rendering bug rather
    // than an effect. Every other effect arrives and stops.
    repeat: options.repeat ?? (type === 'blink' ? 'infinite' : 1),
    alternate: options.alternate
  };

  if (type === 'grow' || type === 'zoom') {
    slots.scale = options.scale ?? (type === 'zoom' ? 0.4 : 0.8);
  }

  if (type === 'slide') {
    const { x, y } = slideOffsets(options.from ?? 'bottom', options.distance ?? '100%');

    slots.x = x;
    slots.y = y;
  }

  if (type === 'rotate') {
    slots.angle = `${options.angle ?? -180}deg`;
  }

  return {
    className: `${animBaseClass} ${animationClasses[type]}`,
    style: animationSlots(slots)
  };
}

/* ---------------------------------------------------------------------------
 * Running one
 * ------------------------------------------------------------------------- */

/**
 * Whether the reader has asked for less motion — the hook the three effects
 * with motion written in JavaScript read. It lives in `media.ts` beside the
 * query it asks, so a Carousel and a ScrollZone can ask the same question
 * without pulling the eleven effects below in with the answer.
 */
export { usePrefersReducedMotion } from './media.js';

export interface AnimationRunOptions {
  trigger: NebaAnimateTrigger;
  play?: boolean;
  once: boolean;
  threshold: number;
  paused?: boolean;
  /** An infinite effect stops when the pointer leaves; a finite one finishes. */
  infinite: boolean;
}

export interface AnimationRun {
  /** Goes on the animated element. */
  ref: React.RefCallback<HTMLElement>;
  /** `running` or `paused`, for `--n-anim-state`. */
  state: 'running' | 'paused';
  /** Whether the animation has been let go at all, for `data-state`. */
  started: boolean;
  /** Spread onto the element when `trigger` is `hover`; empty otherwise. */
  handlers: React.HTMLAttributes<HTMLElement>;
}

/**
 * Starts, restarts and holds an animation.
 *
 * Two things here are less obvious than they look.
 *
 * **Waiting is `animation-play-state: paused`, not a second class.** An
 * element that has not been triggered yet has to already look like its own
 * first frame, or a `visible` fade would be fully drawn until it scrolled into
 * view and then blink out to start. With `fill-mode: both` a paused animation
 * shows exactly that frame, so waiting and running are one animation in two
 * states rather than two states to keep in step.
 *
 * **Restarting reaches for the DOM.** There is no way to rewind a CSS animation
 * from React: re-rendering with the same class changes nothing, and a `key`
 * would restart the animation by unmounting the children, taking their state
 * with it. Clearing `animation-name`, reading a layout property to force the
 * style to settle, and putting it back is the one move that rewinds the element
 * and leaves everything inside it alone.
 */
export function useAnimationRun({
  trigger,
  play,
  once,
  threshold,
  paused,
  infinite
}: AnimationRunOptions): AnimationRun {
  const node = React.useRef<HTMLElement | null>(null);
  const [started, setStarted] = React.useState(trigger === 'mount');
  const [run, setRun] = React.useState(0);

  const start = React.useCallback(() => {
    setStarted(true);
    setRun((previous) => previous + 1);
  }, []);

  // Nothing to rewind on the first pass — the element has only just been drawn.
  React.useLayoutEffect(() => {
    const element = node.current;

    if (!element || run === 0) {
      return;
    }

    // The element itself for the six effects, and its descendants for the four
    // that animate their children rather than themselves — a staggered Appear
    // has nothing to rewind on its own root.
    const targets: HTMLElement[] = [
      element,
      ...element.querySelectorAll<HTMLElement>('.neba-anim, .neba-marquee-track')
    ];

    for (const target of targets) {
      target.style.animationName = 'none';
    }

    void element.offsetWidth;

    for (const target of targets) {
      target.style.animationName = '';
    }
  }, [run]);

  React.useEffect(() => {
    if (trigger !== 'visible') {
      return;
    }

    const element = node.current;

    if (!element) {
      return;
    }

    // Assigned before the callback can run, and read from inside it: a `once`
    // effect stops watching from within its own first delivery.
    let stop: (() => void) | null = null;

    stop = observeVisibility(element, threshold, (visible) => {
      if (visible) {
        start();

        if (once) {
          stop?.();
          stop = null;
        }
      } else if (!once) {
        setStarted(false);
      }
    });

    if (!stop) {
      // No observer means no way to know: show it rather than hide it forever.
      setStarted(true);

      return;
    }

    return () => stop?.();
  }, [trigger, once, threshold, start]);

  React.useEffect(() => {
    if (trigger !== 'manual') {
      return;
    }

    // `play` is a caller pressing go, and what it starts is a CSS animation.
    // There is no external system to push to: the run counter *is* the rewind.
    if (play) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      start();
    } else {
      setStarted(false);
    }
  }, [trigger, play, start]);

  const handlers: React.HTMLAttributes<HTMLElement> =
    trigger === 'hover'
      ? {
          onPointerEnter: start,
          // Focus counts, or an effect on something keyboard-reachable would
          // never run for a reader who is not holding a mouse.
          onFocus: start,
          onPointerLeave: () => {
            if (infinite) {
              setStarted(false);
            }
          },
          onBlur: () => {
            if (infinite) {
              setStarted(false);
            }
          }
        }
      : {};

  return {
    ref: React.useCallback((element: HTMLElement | null) => {
      node.current = element;
    }, []),
    state: started && !paused ? 'running' : 'paused',
    started,
    handlers
  };
}

/* ---------------------------------------------------------------------------
 * The six, assembled
 * ------------------------------------------------------------------------- */

export interface AnimateElementParams extends AnimationSlotOptions, AnimationRunOptions {
  /** Which keyframe. `null` for the components that write their own. */
  effect: NebaAnimation | null;
}

export interface AnimateElement {
  ref: React.RefCallback<HTMLElement>;
  className: string;
  style: React.CSSProperties;
  /** The hover handlers and the two data attributes, ready to be spread. */
  props: React.HTMLAttributes<HTMLElement> & Record<string, unknown>;
}

/**
 * Everything an `Animate*` root needs, in one call.
 *
 * The six effect components differ only in their defaults and in which slots
 * they fill, so this is where the identical two-thirds of each of them lives.
 * The four that have to understand their children — Typing, Marquee, Headline,
 * Appear — call `useAnimationRun` directly and put the classes where their own
 * structure needs them, which is why `effect` is allowed to be `null`.
 *
 * `data-neba-animation` and `data-state` are here rather than in each component
 * because they are the same two facts every time, and because a test that has
 * to assert on a class name is a test that breaks when a class name changes.
 */
export function useAnimateElement(params: AnimateElementParams): AnimateElement {
  const { effect, trigger, play, once, threshold, paused, infinite, ...slots } = params;

  const run = useAnimationRun({ trigger, play, once, threshold, paused, infinite });

  return {
    ref: run.ref,
    className: effect ? `${animBaseClass} ${animationClasses[effect]}` : '',
    style: { ...animationSlots(slots), '--n-anim-state': run.state } as React.CSSProperties,
    props: {
      ...run.handlers,
      'data-neba-animation': effect ?? undefined,
      'data-state': run.state
    }
  };
}
