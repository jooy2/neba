'use client';

import * as React from 'react';
import { attachedRef, observeResize } from '../internal/observe.js';

/**
 * A box, in CSS pixels: the element's own layout box, in whole pixels, before any
 * transform on it or above it. `0` × `0` before the first measurement and on a
 * server.
 */
export interface ElementSize {
  width: number;
  height: number;
}

/**
 * The element's own box, before any transform on it or above it.
 *
 * `getBoundingClientRect()` is the box as drawn, so inside a scaled ancestor —
 * a Mockup's screen, a zoom entrance part way through — it reported a fraction
 * of the room the element really has, and a transform does not resize anything,
 * so no observer said so afterwards either. The offset box is the layout one.
 * An element without one, an SVG element for instance, is read as drawn.
 */
function layoutBox(element: Element): ElementSize {
  if (element instanceof HTMLElement) {
    return { width: element.offsetWidth, height: element.offsetHeight };
  }

  return element.getBoundingClientRect();
}

/**
 * One element's size, kept up to date.
 *
 * The same shared `ResizeObserver` the library's own components measure
 * themselves with — one observer for the whole page rather than one per
 * subscriber, because a dashboard of eight charts inside a PageLayout with a
 * Panes in it was a dozen registrations the browser walked on every layout.
 *
 * The ref goes on the element to watch. It measures once as soon as that
 * element is there rather than waiting to be told, because a `ResizeObserver`
 * that is missing — an old browser, a server — never says anything at all, and
 * a component sized `0 × 0` forever is worse than one measured once. An element
 * put on the ref after the first render, behind a loading state for instance, is
 * measured when it arrives.
 */
export function useElementSize<E extends Element = HTMLElement>(): [
  React.RefObject<E | null>,
  ElementSize
] {
  const [element, setElement] = React.useState<E | null>(null);
  const [ref] = React.useState(() => attachedRef<E>(setElement));
  const [size, setSize] = React.useState<ElementSize>({ width: 0, height: 0 });

  React.useLayoutEffect(() => {
    if (!element) {
      return undefined;
    }

    const measure = () => {
      const box = layoutBox(element);
      // Only on a real change: a `ResizeObserver` fires for a resize that
      // rounds to the same box, and setting state there is a render loop with
      // a layout in it.
      setSize((current) =>
        current.width === box.width && current.height === box.height
          ? current
          : { width: box.width, height: box.height }
      );
    };

    measure();

    return observeResize(element, measure);
  }, [element]);

  return [ref, size];
}
