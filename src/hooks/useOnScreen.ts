'use client';

import * as React from 'react';
import { observeVisibility } from '../internal/observe.js';

export interface OnScreenOptions {
  /** How much of the element has to be showing. @default 0 */
  threshold?: number;
  /**
   * Stop watching once it has been seen. The right default for the thing this
   * is usually for — mounting something, starting something, loading
   * something — where the answer only has to arrive once.
   * @default true
   */
  once?: boolean;
}

/**
 * Whether an element is on screen.
 *
 * The same shared `IntersectionObserver` the eleven `Animate*` wrappers watch
 * for their own element with — one per threshold for the whole page, because a
 * page of them was one registration each.
 *
 * It answers `true` where there is no `IntersectionObserver` rather than
 * `false`, and that is the load-bearing part: a caller cannot know without one,
 * and the right fallback is to show the thing rather than to hide it forever.
 */
export function useOnScreen<E extends Element = HTMLElement>(
  options: OnScreenOptions = {}
): [React.RefObject<E | null>, boolean] {
  const { threshold = 0, once = true } = options;

  const ref = React.useRef<E | null>(null);
  const [visible, setVisible] = React.useState(false);

  React.useEffect(() => {
    const element = ref.current;

    if (!element) {
      return undefined;
    }

    const stop = observeVisibility(element, threshold, (showing) => {
      setVisible(showing);
      if (showing && once) {
        stop?.();
      }
    });

    if (!stop) {
      // No observer in this browser. Showing it is the only answer that cannot
      // hide something forever.
      setVisible(true);
      return undefined;
    }

    return stop;
  }, [threshold, once]);

  return [ref, visible];
}
