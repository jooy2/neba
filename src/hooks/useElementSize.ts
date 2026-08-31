'use client';

import * as React from 'react';
import { observeResize } from '../internal/observe.js';

/** A box, in CSS pixels. `0` × `0` before the first measurement and on a server. */
export interface ElementSize {
  width: number;
  height: number;
}

/**
 * One element's size, kept up to date.
 *
 * The same shared `ResizeObserver` eleven components in the library measure
 * themselves with — one observer for the whole page rather than one per
 * subscriber, because a dashboard of eight charts inside a PageLayout with a
 * Panes in it was a dozen registrations the browser walked on every layout.
 *
 * The ref goes on the element to watch. It measures once as soon as that
 * element is there rather than waiting to be told, because a `ResizeObserver`
 * that is missing — an old browser, a server — never says anything at all, and
 * a component sized `0 × 0` forever is worse than one measured once.
 */
export function useElementSize<E extends Element = HTMLElement>(): [
  React.RefObject<E | null>,
  ElementSize
] {
  const ref = React.useRef<E | null>(null);
  const [size, setSize] = React.useState<ElementSize>({ width: 0, height: 0 });

  React.useLayoutEffect(() => {
    const element = ref.current;

    if (!element) {
      return undefined;
    }

    const measure = () => {
      const box = element.getBoundingClientRect();
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
  }, []);

  return [ref, size];
}
