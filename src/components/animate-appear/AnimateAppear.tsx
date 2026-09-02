'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  animBaseClass,
  animationClasses,
  isInfinite,
  slideOffsets,
  staggerChildren,
  useAnimationRun
} from '../../internal/animate.js';
import type {
  NebaAnimateProps,
  NebaSide,
  NebaStaggerProps,
  NebaTimelineProps
} from '../../types.js';

export interface AnimateAppearProps
  extends
    NebaAnimateProps,
    NebaStaggerProps,
    NebaTimelineProps,
    React.ComponentPropsWithoutRef<'div'> {
  /**
   * Which edge each child drifts in from.
   * @default 'bottom'
   */
  from?: NebaSide;
  /**
   * How far each child travels. Short on purpose: this is a settling, not an
   * entrance from off screen, and a long travel on a list of eight turns the
   * whole block into something moving.
   * @default '0.75rem'
   */
  distance?: number | string;
  /**
   * Fades each child in as it settles.
   * @default true
   */
  fade?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  /** The things that appear, one after another. */
  children?: React.ReactNode;
}

/**
 * A list of things settling into place one after another.
 *
 * Each child gets the same short fade and drift, held back by its position — so
 * the effect belongs to the *set* rather than to any one item, and a reader's
 * eye is walked down the list in the order it should be read.
 *
 * The animation is written onto the children themselves rather than onto
 * wrappers around them. A row of `<li>`s stays a row of `<li>`s, a grid's cells
 * stay its direct children, and nothing about the layout changes because the
 * list is being animated. Only a bare string has no element to write onto, so
 * that one is wrapped in a `<span>`.
 *
 * The stagger is per *child*, which means what you pass matters: eight children
 * are eight steps, and one child holding eight things is one step. That is also
 * how to opt part of a list out — group it.
 */
export const AnimateAppear = React.forwardRef<HTMLDivElement, AnimateAppearProps>(
  function AnimateAppear(
    {
      duration = 420,
      delay = 0,
      easing,
      repeat = 1,
      alternate,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      // The one component whose step is not zero by default: on the other six a
      // step is something a caller turns on, and here it *is* the component.
      stagger = 80,
      durationStep = 0,
      reverse = false,
      timeline,
      range,
      from = 'bottom',
      distance = '0.75rem',
      fade = true,
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

    const { x, y } = slideOffsets(from, distance);

    // The same helper the other six reach for once they are given a step. Appear
    // is the one that cannot be turned off — a slide with no order to it is an
    // `AnimateSlide`.
    const animated = staggerChildren(
      children,
      `${animBaseClass} ${animationClasses.slide}`,
      { duration, delay, easing, repeat, alternate, x, y, opacity: fade ? 0 : 1, timeline, range },
      { stagger, durationStep, reverse }
    );

    return useRender({
      render,
      ref: [ref, run.ref],
      props: {
        ...props,
        className,
        // Only the play state lives on the root. Every other slot is per child,
        // because the delay is what the whole effect is made of.
        style: { '--n-anim-state': run.state, ...style } as React.CSSProperties,
        ...run.handlers,
        'data-neba-animation': 'appear',
        'data-state': run.state,
        children: animated
      }
    });
  }
);
