import * as React from 'react';

/**
 * Handing a node to a ref a caller forwarded, beside the component's own.
 *
 * React 19 lets a callback ref return a cleanup function, and when the node
 * goes it calls that cleanup *instead of* calling the ref with `null`. A
 * component that hands its node to a caller's ref by hand has to keep that
 * promise too, or a caller who writes `ref={(node) => { …; return () => … }}`
 * never has the cleanup run and is handed a `null` it was told it would not
 * see. React 18 has no cleanups: it ignores what a ref returns and always calls
 * it with `null`, so a caller writing for 18 is unaffected either way.
 *
 * No directive: `useMemo` is in React's `react-server` build, and nothing here
 * holds a context, an effect or a store.
 */

const nothing = () => {};

/**
 * Hands `node` to a ref of either kind, and returns what takes it back.
 *
 * For a callback ref that is the cleanup it returned, or a call with `null`
 * when it returned none. An object ref is cleared only while it still holds
 * this node, so one that has since been handed another node keeps that one.
 */
export function attachRef<T>(ref: React.Ref<T> | undefined, node: T): () => void {
  if (typeof ref === 'function') {
    const cleanup: unknown = ref(node);

    if (typeof cleanup === 'function') {
      return cleanup as () => void;
    }

    return () => {
      ref(null);
    };
  }

  if (!ref) {
    return nothing;
  }

  ref.current = node;

  return () => {
    if (ref.current === node) {
      ref.current = null;
    }
  };
}

/**
 * One callback ref that hands the node to `own` and then to `ref`.
 *
 * It returns nothing on purpose. React then calls it with `null` when the node
 * goes, on 18 and on 19 alike, and that is when each of the two is taken back
 * the way `attachRef` says: the component's own sees `null` whichever React is
 * running, and the caller's gets its cleanup, or `null` if it returned none.
 * Returning a cleanup instead would not do: React 18 ignores it, calls this
 * with `null` all the same, and in a development build says "A callback ref
 * should not return a function" for every component that hands one over.
 */
function mergeRefs<T>(
  own: React.Ref<T> | undefined,
  ref: React.Ref<T> | undefined
): (node: T | null) => void {
  let releaseOwn = nothing;
  let releaseRef = nothing;

  return (node) => {
    releaseOwn();
    releaseRef();
    releaseOwn = nothing;
    releaseRef = nothing;

    if (node !== null) {
      releaseOwn = attachRef(own, node);
      releaseRef = attachRef(ref, node);
    }
  };
}

/**
 * The ref a component puts on its element when a caller may have forwarded one:
 * `mergeRefs` over the component's own and the caller's.
 *
 * Its identity changes only when one of the two refs does, as a `useCallback`
 * listing both would. An `own` written inline is a new ref on every render, and
 * React then lets go of the node and takes it again each time.
 */
export function useMergedRef<T>(
  own: React.Ref<T> | undefined,
  ref: React.Ref<T> | undefined
): (node: T | null) => void {
  return React.useMemo(() => mergeRefs(own, ref), [own, ref]);
}
