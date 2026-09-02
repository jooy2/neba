'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import type {
  NebaAnimateMode,
  NebaAnimateProps,
  NebaStaggerProps,
  NebaTimelineProps
} from '../../types.js';

export interface AnimateFadeProps
  extends
    NebaAnimateProps,
    NebaStaggerProps,
    NebaTimelineProps,
    React.ComponentPropsWithoutRef<'div'> {
  /**
   * Whether the content arrives or leaves.
   * @default 'in'
   */
  mode?: NebaAnimateMode;
  /**
   * The opacity it starts from, between `0` and `1`. Raise it for content that
   * should never be completely gone.
   * @default 0
   */
  from?: number;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Content arriving or leaving on opacity alone.
 *
 * The plainest effect in the set, and the one to reach for first: nothing
 * moves, so nothing reflows and nothing is resampled. A fade is the only
 * entrance that is safe on a block of text at any size.
 *
 * `mode="out"` is the same animation run backwards, and it is held at the end —
 * a faded-out element stays faded out rather than snapping back into view when
 * the animation finishes.
 */
export const AnimateFade = React.forwardRef<HTMLDivElement, AnimateFadeProps>(function AnimateFade(
  {
    duration = 320,
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
    from = 0,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const animate = useAnimateElement({
    effect: 'fade',
    duration,
    delay,
    easing,
    repeat,
    alternate,
    mode,
    opacity: from,
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
});
