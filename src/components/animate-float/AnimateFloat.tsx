'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, slideOffsets, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type {
  NebaAnimateProps,
  NebaAnimateRepeat,
  NebaSide,
  NebaStaggerProps,
  NebaTimelineProps
} from '../../types.js';

export interface AnimateFloatProps
  extends
    NebaAnimateProps,
    NebaStaggerProps,
    NebaTimelineProps,
    React.ComponentPropsWithoutRef<'div'> {
  /**
   * Which way it drifts.
   * @default 'top'
   */
  from?: NebaSide;
  /**
   * How far, at the top of the drift — a CSS length, or a number in pixels.
   * Small on purpose: this is something resting rather than something moving,
   * and past about a centimetre it stops reading as either.
   * @default '0.5rem'
   */
  distance?: number | string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * A slow drift with nowhere to get to.
 *
 * The only effect in the set that is neither an arrival nor a state: it says
 * *this is not fixed to the page*, which is what an illustration, a floating
 * card or a mark above a hero wants and what nothing else in the library says.
 * It runs for as long as the page is open and turns round at both ends, so
 * there is never a frame where it jumps back.
 *
 * It is `translate` rather than a `transform`, so it composes with anything the
 * element is already scaled or rotated by — and it is deliberately not offered
 * on a control: a button that is never quite where it was is a button that is
 * harder to press.
 */
export const AnimateFloat = React.forwardRef<HTMLDivElement, AnimateFloatProps>(
  function AnimateFloat(
    {
      duration = 3200,
      delay = 0,
      easing = 'ease-in-out',
      repeat = 'infinite' as NebaAnimateRepeat,
      alternate = true,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      stagger = 0,
      durationStep = 0,
      reverse = false,
      timeline,
      range,
      from = 'top',
      distance = '0.5rem',
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const { x, y } = slideOffsets(from, distance);

    const animate = useAnimateElement({
      // Its own keyframe rather than one out of the shared table: this is not
      // an entrance, so putting it in the `transition` vocabulary would make
      // every component that offers one pay for a row it can never use.
      effect: null,
      effectClass: 'neba-anim-float',
      name: 'float',
      duration,
      delay,
      easing,
      repeat,
      alternate,
      x,
      y,
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
