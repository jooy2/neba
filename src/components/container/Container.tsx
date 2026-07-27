import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses } from '../box/Box';
import type { NebaDensity, NebaSize } from '../../types';

export interface ContainerProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * How wide the content is allowed to get, on the same ladder the breakpoints
   * use — `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem, `xs` 30rem.
   *
   * `none`, the default, is no limit: a Container's job is the gutter, and a
   * measure is a second decision that a page should have to ask for.
   * @default 'none'
   */
  maxWidth?: NebaSize | 'none';
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
 * The measure ladder, in `rem` rather than in Tailwind's named `max-w-*` steps
 * so that a Container's `lg` and a `lg:` utility are the same 64rem. Tailwind's
 * own container scale is a different set of numbers, and having two ladders
 * called `lg` on one page is how a layout drifts by a few pixels for no reason
 * anybody can find later.
 */
const maxWidthClasses: Record<NebaSize, string> = {
  xs: 'max-w-[30rem]',
  sm: 'max-w-[40rem]',
  md: 'max-w-[48rem]',
  lg: 'max-w-[64rem]',
  xl: 'max-w-[80rem]'
};

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
export const Container = React.forwardRef<HTMLDivElement, ContainerProps>(function Container(
  {
    maxWidth = 'none',
    padded = true,
    size = 'md',
    density = 'default',
    centered = true,
    render,
    className,
    children,
    ...props
  },
  ref
) {
  const classNames = [
    'block w-full',
    maxWidth === 'none' ? '' : maxWidthClasses[maxWidth],
    centered ? 'mx-auto' : '',
    padded ? boxPaddingXClasses[density][size] : '',
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      children,
      ...props
    }
  });
});
