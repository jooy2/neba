'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { hiddenBelowClasses, hiddenFromClasses } from '../../internal/responsive.js';
import { cx } from '../../internal/styles.js';
import type { NebaBreakpoint } from '../../types.js';

export interface ShowProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * The narrowest width the children are drawn at, inclusive. Below it they
   * are not drawn.
   *
   * `above="md"` is the desktop half of a pair; `xs` is a floor of zero and so
   * means "always", which is what makes it safe to pass a value straight
   * through from a variable.
   */
  above?: NebaBreakpoint;
  /**
   * The width at which the children stop being drawn, exclusive — so
   * `below="md"` is drawn under 48rem and not at it, and pairs exactly with
   * `above="md"` to cover every width once.
   *
   * `below="xs"` draws nothing at all: there is no width under a floor of zero.
   */
  below?: NebaBreakpoint;
  /**
   * Renders something other than a `<div>`: `render={<li />}`,
   * `render={<td />}`. Base UI's own escape hatch, and the way to put this
   * somewhere a `<div>` is not allowed.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Its children at some widths and not at others.
 *
 * `above` and `below` are a floor and a ceiling on the same ladder every other
 * breakpoint in the library uses, and they compose: `above="sm" below="lg"` is
 * drawn from 40rem up to but not including 64rem. Either alone is the common
 * case — a pair of them, with the same breakpoint in both, is the two halves of
 * one decision and covers every width exactly once.
 *
 * **The children are always rendered.** What changes is `display`, which is
 * deliberate on both sides of it: the answer is right in the first frame the
 * browser paints, so nothing flashes and nothing has to wait for JavaScript to
 * find out how wide the window is, and it is the same answer on a server, where
 * there is no window to ask. It also costs nothing to change — a resize repaints
 * rather than re-rendering React.
 *
 * That is also its limit. A component that must not *run* below a width — one
 * that fetches, or that mounts a map — is a decision CSS cannot make, and
 * `useBreakpoint` is what makes it:
 *
 * ```tsx
 * {useBreakpoint('md') && <Map />}
 * ```
 *
 * The wrapper is `display: contents`, so it adds no box: a `Show` inside a
 * `GridContainer` leaves its children as grid items, and one inside a flex row
 * leaves them as flex items. Nothing it is given to style — padding, a
 * background — would have anywhere to land, so put those on an element inside
 * it or name the element with `render`.
 */
export const Show = React.forwardRef<HTMLDivElement, ShowProps>(function Show(
  { above, below, render, className, children, ...props },
  ref
) {
  const classNames = cx(
    'contents',
    above ? hiddenBelowClasses[above] : '',
    below ? hiddenFromClasses[below] : '',
    className ?? ''
  );

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
