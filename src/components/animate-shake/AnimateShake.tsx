'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, lengthValue, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type { NebaAnimateProps, NebaStaggerProps, NebaTimelineProps } from '../../types.js';

export interface AnimateShakeProps
  extends
    NebaAnimateProps,
    NebaStaggerProps,
    NebaTimelineProps,
    React.ComponentPropsWithoutRef<'div'> {
  /**
   * How far it travels at the widest point — a CSS length, or a number in
   * pixels. Short: this is a head shaken, not a thing thrown.
   * @default 6
   */
  distance?: number | string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * The one effect in the set that says *no*.
 *
 * A password that was wrong, a form that would not send, a row that could not
 * be dropped where it was let go. Every other animation here is about content
 * arriving; this one is an **answer**, and it is the only reason to reach for
 * it — a shake that runs on mount is decoration, and decoration that moves is
 * what a reader learns to ignore.
 *
 * It is therefore almost always `trigger="manual"` with `play` bound to the
 * thing that failed, and it starts and ends exactly where the element sits, so
 * a run that is interrupted leaves nothing off its mark.
 *
 * ## Why this one is allowed to move
 *
 * The house rule is that a control is never transformed: scaling resamples the
 * label, and text that shifts under the cursor is what reads as cheap. That
 * rule is about a control's **resting states** — hover, press, on, off — where
 * the movement is a side effect of saying something colour could say better.
 * A shake is not a state. It is a one-off reply to something the reader just
 * did, it is over in four hundred milliseconds, and there is no colour that
 * says "that did not work" as unmistakably. It is an exception, it is the only
 * one, and it should never be given `repeat`.
 */
export const AnimateShake = React.forwardRef<HTMLDivElement, AnimateShakeProps>(
  function AnimateShake(
    {
      duration = 420,
      delay = 0,
      easing = 'ease-in-out',
      repeat = 1,
      alternate,
      paused,
      trigger = 'manual',
      play,
      once = true,
      threshold = 0.2,
      stagger = 0,
      durationStep = 0,
      reverse = false,
      timeline,
      range,
      distance = 6,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const animate = useAnimateElement({
      // Its own keyframe rather than one out of the shared table: this is not
      // an entrance, so putting it in the `transition` vocabulary would make
      // every component that offers one pay for a row it can never use.
      effect: null,
      effectClass: 'neba-anim-shake',
      name: 'shake',
      duration,
      delay,
      easing,
      repeat,
      alternate,
      x: lengthValue(distance),
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: isInfinite(repeat),
      timeline,
      range,
      children,
      stagger,
      durationStep,
      reverse
    });

    return useRender({
      render,
      ref: [ref, animate.ref],
      props: {
        ...props,
        className: cx(animate.className, className),
        style: { ...animate.style, ...style },
        ...animate.props,
        children: animate.children
      }
    });
  }
);
