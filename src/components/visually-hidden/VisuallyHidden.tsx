'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { cx, srOnlyClasses } from '../../internal/styles.js';

export interface VisuallyHiddenProps extends React.ComponentPropsWithoutRef<'span'> {
  /**
   * Take the hiding off, so the content is drawn like anything else.
   *
   * This is what a skip link needs: hidden until it has the focus, and then a
   * real control the reader can see themselves press. `focus-visible:` cannot
   * express it, because the element has to *leave* the 1px box entirely.
   * @default false
   */
  visible?: boolean;
  /** Render as something else — a `<div>`, a `<label>`, an element of your own. */
  render?: useRender.RenderProp;
}

/**
 * Content that is in the accessibility tree and not on the screen.
 *
 * The library has needed this everywhere from the beginning and kept it to
 * itself: the word "Remove" behind a Chip's ×, the count behind a Badge's dot,
 * the page number under a Pagination chevron, the table a chart draws for a
 * screen reader instead of a picture. This is the same 1px clipped box, offered
 * so an application's own markup can say the same things.
 *
 * The form matters and there is only one that works. `hidden` and
 * `display: none` take the text off the accessibility tree along with the
 * screen, which is the opposite of the job. `opacity: 0` leaves a clickable
 * ghost the size of the words, and a pointer finds it. `text-indent: -9999px`
 * makes a box that wide and a horizontal scrollbar with it. A 1px box with its
 * contents clipped is invisible to a sighted reader and present to every other
 * kind, and it is what every serious implementation converged on.
 *
 * There is no `aria-hidden` here, deliberately: that is the *other* half of the
 * pair — visible and not announced — and it is an attribute rather than a
 * component because it belongs on the element that is already being drawn.
 */
export const VisuallyHidden = React.forwardRef<HTMLSpanElement, VisuallyHiddenProps>(
  function VisuallyHidden({ visible = false, render, className, ...props }, ref) {
    return useRender({
      render: render ?? <span />,
      ref,
      props: {
        ...props,
        className: cx(visible ? undefined : srOnlyClasses, className)
      }
    });
  }
);
