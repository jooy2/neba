import * as React from 'react';

/**
 * The key a wrapper drawn around one of a component's children should take.
 *
 * `Children.toArray` has already given every element a key — the caller's own
 * where there was one, its position where there was not — so that is the key
 * the wrapper takes too. Keying the wrapper by position instead throws the
 * caller's key away: put a new child at the front and every wrapper after it is
 * handed a different child, which React answers by mounting all of them again,
 * with their state, their loaded images and their entrance animation.
 *
 * A string or a number has no key and keeps its position, which is all there
 * is to go on.
 */
export function childKey(child: React.ReactNode, index: number): React.Key {
  return React.isValidElement(child) && child.key !== null ? child.key : index;
}
