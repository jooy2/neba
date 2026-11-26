'use client';

import * as React from 'react';
import { createPortal } from 'react-dom';
import { cx } from '../../internal/styles.js';

export interface PortalProps extends React.ComponentPropsWithoutRef<'div'> {
  children?: React.ReactNode;
  /**
   * Where the children go. Defaults to `document.body`.
   *
   * A function is called after mount, which is how a portal targets something
   * that is itself rendered by React — `() => document.getElementById('drawer')`
   * finds an element that did not exist when this component's props were built.
   */
  container?: Element | DocumentFragment | null | (() => Element | DocumentFragment | null);
  /**
   * Render in place instead of portalling.
   *
   * **Decide this once, at mount.** A portalled subtree and an inline one are
   * different children as far as React is concerned, so flipping this remounts
   * everything inside and throws away what was in it — a half-filled form, a
   * scroll position, a video that was playing. That is React's reconciliation
   * rather than a shortcoming here, and no portal implementation escapes it.
   *
   * It is a prop rather than an absence so a caller can decide from something
   * they only know at runtime: a subtree that is already inside a portal, a
   * test that wants the markup where it was written, an embed with no
   * `document.body` worth reaching.
   * @default false
   */
  disabled?: boolean;
}

/**
 * Children, rendered somewhere else in the DOM.
 *
 * `createPortal` with the two things a library has to add. The first is the
 * class: the wrapper carries `neba-portal`, which is the hook this library's
 * own popups already use and which a scoped stylesheet hangs its reset off — a
 * portalled subtree leaves whatever element the page had scoped its styling to,
 * and the class is how it is found again. That is the reason to reach for this
 * over `createPortal` directly.
 *
 * The second is the server. There is no `document` there, so a portal renders
 * nothing at all until it has mounted, and the markup that ships never contains
 * the portalled subtree. That is not a limitation to work around — it is what a
 * portal *is* — so anything that must be in the server's HTML does not belong
 * in one.
 *
 * The wrapper is a real element rather than a fragment on purpose: it is what
 * carries the class, and it is what a caller styles to place the subtree.
 */
export const Portal = React.forwardRef<HTMLDivElement, PortalProps>(function Portal(
  { children, container, disabled = false, className, ...props },
  ref
) {
  // `document` is a browser fact, so the first render on a server — and the
  // hydration that has to match it — is deliberately nothing.
  const [target, setTarget] = React.useState<Element | DocumentFragment | null>(null);

  React.useEffect(() => {
    if (disabled) {
      return;
    }
    const resolved = typeof container === 'function' ? container() : container;

    setTarget(resolved ?? document.body);
  }, [container, disabled]);

  const content = (
    <div ref={ref} className={cx('neba-portal', className)} {...props}>
      {children}
    </div>
  );

  if (disabled) {
    return content;
  }

  return target ? createPortal(content, target) : null;
});
