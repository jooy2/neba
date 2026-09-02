'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, revealClip, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type {
  NebaAnimateMode,
  NebaAnimateProps,
  NebaSide,
  NebaStaggerProps,
  NebaTimelineProps
} from '../../types.js';

export interface AnimateRevealProps
  extends
    NebaAnimateProps,
    NebaStaggerProps,
    NebaTimelineProps,
    React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content is uncovered or covered again.
   * @default 'in'
   */
  mode?: NebaAnimateMode;
  /**
   * The edge the wipe travels **from**. `left` uncovers left to right.
   * @default 'left'
   */
  side?: NebaSide;
  /**
   * Fades as it wipes, from this opacity. `1` — the default — is a wipe and
   * nothing else, which is the point of reaching for one.
   * @default 1
   */
  from?: number;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content uncovered by an edge travelling across it.
 *
 * The one entrance in the set where the content never moves and never changes
 * colour: it is already in place, at full size and full strength, and what
 * changes is how much of it has been let through. That makes it the effect to
 * reach for on a heading, a rule, a chart's own plot area — anything whose
 * position is the information.
 *
 * It is `clip-path`, so there is no wrapper and no `overflow` box: the element
 * takes exactly the room it always took, and everything around it is laid out
 * against the finished size from the first frame.
 *
 * `mode="out"` runs the same edge backwards and holds it there, which covers
 * the content up.
 */
export const AnimateReveal = React.forwardRef<HTMLDivElement, AnimateRevealProps>(
  function AnimateReveal(
    {
      duration = 620,
      delay = 0,
      easing,
      repeat = 1,
      alternate,
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
      mode = 'in',
      side = 'left',
      from = 1,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const animate = useAnimateElement({
      effect: 'reveal',
      duration,
      delay,
      easing,
      repeat,
      alternate,
      mode,
      opacity: from,
      clip: revealClip(side),
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
