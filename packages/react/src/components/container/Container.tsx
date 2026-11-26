'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses } from '../box/Box.js';
import { responsiveSlots } from '../../internal/responsive.js';
import { cx, measureValue } from '../../internal/styles.js';
import type { NebaDensity, NebaMeasure, NebaResponsive, NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface ContainerProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How wide the content is allowed to get.
   *
   * A step of the measure ladder — `xs` 30rem, `sm` 40rem, `md` 48rem, `lg`
   * 64rem, `xl` 80rem — or any length of your own: `'60ch'`, `'min(90vw,
   * 72rem)'`, or a number, which is pixels. The four upper steps are the
   * breakpoint floors; `xs` is not, because a measure of zero is not a thing.
   *
   * Responsive: `maxWidth={{ xs: 'none', lg: 'xl' }}` lets the content run to
   * the gutters until 64rem and holds it at 80rem from there on. Every entry
   * applies from its own breakpoint up.
   *
   * `none`, the default, is no limit: a Container's job is the gutter, and a
   * measure is a second decision that a page should have to ask for.
   * @default 'none'
   */
  maxWidth?: NebaResponsive<NebaMeasure>;
  /**
   * The gutter, on the `size`/`density` scale. Turn it off to keep the
   * centring and the measure without the padding.
   * @default true
   */
  padded?: boolean;
  /**
   * The gutter's scale. As on Box, `size` here is the size of the *sheet* — it
   * never touches a height or the type scale — and it is independent of
   * `maxWidth`, which is how wide the content gets rather than how far it sits
   * from the edge.
   * @default 'md'
   */
  size?: NebaSize;
  /** @default 'default' */
  density?: NebaDensity;
  /**
   * Centres the content once `maxWidth` is narrower than the page. No effect
   * while `maxWidth` is `none`, because there is nothing left over to centre in.
   * @default true
   */
  centered?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<main />}`,
   * `render={<section />}`. Base UI's own escape hatch.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Horizontal breathing room, and optionally a measure.
 *
 * Nothing to do with the grid — a Container holds a grid as happily as it holds
 * a single paragraph, and a `GridContainer` needs no Container around it. The
 * two are separate because the questions are separate: how far the content sits
 * from the edge of the window, and how the content divides itself up.
 *
 * It draws no surface for the same reason `GridContainer` does not. The
 * outermost element on a page is the one thing that must not decide what the
 * page looks like.
 */
export const Container = React.forwardRef<HTMLDivElement, ContainerProps>(
  function Container(rawProps, ref) {
    const {
      maxWidth,
      padded = true,
      size = 'md',
      density = 'default',
      centered = true,
      render,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density']);

    const classNames = cx(
      // The measure is read out of the slot by an ordinary utility, so a
      // caller's own `max-w-*` still fights it on equal terms.
      'neba-measure block w-full max-w-(--n-max-w)',
      centered ? 'mx-auto' : '',
      padded ? boxPaddingXClasses[density][size] : '',
      className ?? ''
    );

    return useRender({
      render,
      ref,
      props: {
        className: classNames,
        style: {
          ...responsiveSlots('max-w', maxWidth, measureValue),
          ...style
        },
        children,
        ...props
      }
    });
  }
);
