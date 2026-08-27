import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { isInfinite, useAnimateElement } from '../../internal/animate.js';
import { cx, radiusClasses } from '../../internal/styles.js';
import type { NebaAnimateProps, NebaColor, NebaSize } from '../../types.js';

export interface AnimateLightingProps
  extends NebaAnimateProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which family the light is drawn in.
   * @default 'primary'
   */
  color?: NebaColor;
  /**
   * A CSS colour, when a semantic family is not what is wanted. Overrides
   * `color`.
   */
  glow?: string;
  /**
   * The radius the light follows, on the shared ladder. It has to match what is
   * inside, or the glow will cut a corner the content has rounded off.
   * @default 'md'
   */
  size?: NebaSize;
  /**
   * How far past the content the light reaches, in pixels.
   * @default 3
   */
  spread?: number;
  /**
   * How much of the outline is lit at once, in degrees. Small is a travelling
   * spark; large is a sweep.
   * @default 50
   */
  arc?: number;
  /**
   * How soft the light is, in pixels. At `0` it is a hard-edged wedge, which
   * reads as a graphic rather than as light.
   * @default 4
   */
  blur?: number;
  /** Runs the light the other way round. @default false */
  reverse?: boolean;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * A light travelling around the outside of something.
 *
 * The light is behind the content rather than on it, so what a reader sees is a
 * glow escaping from under the edges — which is why it works on a Card or a
 * Button without touching anything about how they are drawn. Nothing inside is
 * altered, nothing is overlaid, and the content stays exactly as legible as it
 * was.
 *
 * Use it to mark the one thing on a screen that is currently live: the row that
 * is processing, the field that is being checked, the plan being recommended.
 * It draws attention with light rather than by moving anything, which is the
 * only way this library has of saying "here" without also saying "and it moved".
 *
 * `size` has to agree with the radius of what is inside it. The glow follows
 * the wrapper's own corners, so a `lg` card in an `xs` Lighting will show light
 * poking out of four corners the card has already rounded away.
 */
export const AnimateLighting = React.forwardRef<HTMLDivElement, AnimateLightingProps>(
  function AnimateLighting(
    {
      duration = 3000,
      delay = 0,
      easing,
      repeat = 'infinite',
      alternate,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      color = 'primary',
      glow,
      size = 'md',
      spread = 3,
      arc = 50,
      blur = 4,
      reverse = false,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const animate = useAnimateElement({
      // The keyframe runs on a pseudo-element rather than on the root, so there
      // is no effect class to apply here — only the slots it reads.
      effect: null,
      duration,
      delay,
      easing,
      repeat,
      alternate,
      mode: reverse ? 'out' : 'in',
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: isInfinite(repeat)
    });

    return useRender({
      render,
      ref: [ref, animate.ref],
      props: {
        ...props,
        className: cx('neba-anim-lighting', radiusClasses[size], className),
        style: {
          ...animate.style,
          '--n-anim-glow': glow ?? `var(--neba-${color}-accent)`,
          '--n-anim-glow-width': `${spread}px`,
          '--n-anim-glow-arc': `${arc}deg`,
          '--n-anim-glow-blur': `${blur}px`,
          ...style
        } as React.CSSProperties,
        ...animate.props,
        'data-neba-animation': 'lighting',
        children
      }
    });
  }
);
