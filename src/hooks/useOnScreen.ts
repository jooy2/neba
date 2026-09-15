'use client';

import * as React from 'react';
import { attachedRef, observeVisibility } from '../internal/observe.js';

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
 *
 * An element put on the ref after the first render, behind a loading state for
 * instance, is watched from when it arrives.
 */
export function useOnScreen<E extends Element = HTMLElement>(
  options: OnScreenOptions = {}
): [React.RefObject<E | null>, boolean] {
  const { threshold = 0, once = true } = options;

  const [element, setElement] = React.useState<E | null>(null);
  const [ref] = React.useState(() => attachedRef<E>(setElement));
  const [visible, setVisible] = React.useState(false);

  React.useEffect(() => {
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
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setVisible(true);
      return undefined;
    }

    return stop;
  }, [element, threshold, once]);

  return [ref, visible];
}
