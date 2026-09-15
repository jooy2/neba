/**
 * The two browser observers the library uses, as one each rather than one per
 * component.
 *
 * Eleven components measure themselves and every one of them was building a
 * `ResizeObserver` of its own; eleven `Animate*` wrappers watch for their own
 * element scrolling into view and every one was building an
 * `IntersectionObserver`. Neither is free — each is a separate registration the
 * browser has to walk on every layout, and each delivers its own callback task
 * — and a dashboard of eight charts inside a PageLayout with a Panes and a
 * ScrollZone in it is a page with a dozen of them for no reason at all.
 *
 * An observer takes any number of targets, so one is enough. What each of these
 * adds is the routing: a target to the callbacks watching it, and an
 * `unobserve` when the last of them goes away.
 *
 * There is no cross-component behaviour here. A shared observer batches the
 * entries it delivers, which is if anything the better arrangement — two charts
 * on one row resize in one callback rather than two.
 */

/** What a watcher is told: the entry for its own element, and nothing else. */
type ResizeCallback = (entry: ResizeObserverEntry) => void;

const resizeWatchers = new Map<Element, Set<ResizeCallback>>();

let resizeObserver: ResizeObserver | null = null;

function resizeShared(): ResizeObserver | null {
  if (typeof ResizeObserver === 'undefined') {
    return null;
  }

  resizeObserver ??= new ResizeObserver((entries) => {
    for (const entry of entries) {
      // Copied before iterating: a measurement is allowed to stop watching,
      // and a `Set` mutated mid-loop drops whatever came after it.
      const watchers = resizeWatchers.get(entry.target);

      if (watchers) {
        for (const watcher of [...watchers]) {
          watcher(entry);
        }
      }
    }
  });

  return resizeObserver;
}

/**
 * Watches one element's size. Returns the function that stops watching.
 *
 * A no-op where there is no `ResizeObserver` — an old browser, or a server —
 * which is why every caller measures once itself before calling this rather
 * than waiting to be told.
 */
export function observeResize(element: Element, onResize: ResizeCallback): () => void {
  const observer = resizeShared();

  if (!observer) {
    return () => {};
  }

  let watchers = resizeWatchers.get(element);

  if (!watchers) {
    watchers = new Set();
    resizeWatchers.set(element, watchers);
    // Only for an element nobody was watching yet. `observe` on one that is
    // already registered re-delivers an entry for it, which would call every
    // watcher already attached to it for no change at all.
    observer.observe(element);
  }

  watchers.add(onResize);

  return () => {
    const set = resizeWatchers.get(element);

    if (!set) {
      return;
    }

    set.delete(onResize);

    if (set.size === 0) {
      resizeWatchers.delete(element);
      observer.unobserve(element);
    }
  };
}

/** What a watcher is told: whether its own element is on screen. */
type VisibilityCallback = (visible: boolean) => void;

/**
 * One observer per threshold, because the threshold is the one thing an
 * `IntersectionObserver` cannot vary per target. In practice that is one
 * observer for the whole page: `threshold` defaults to the same number on every
 * `Animate*`, and a page that mixes two of them gets two.
 *
 * A group lives exactly as long as something is watching through it. That is
 * not tidiness: `threshold` is a public prop on all seventeen `Animate*`
 * components, so a caller is free to compute one — and a group that outlived
 * its last watcher would mean a live `IntersectionObserver` per value ever
 * passed, each one a registration the browser still walks.
 */
interface VisibilityGroup {
  observer: IntersectionObserver;
  /** Keyed inside the group, so one element watched at two thresholds is two rows. */
  watchers: Map<Element, Set<VisibilityCallback>>;
}

const visibilityGroups = new Map<number, VisibilityGroup>();

function visibilityShared(threshold: number): VisibilityGroup | null {
  if (typeof IntersectionObserver === 'undefined') {
    return null;
  }

  let group = visibilityGroups.get(threshold);

  if (!group) {
    const watchers = new Map<Element, Set<VisibilityCallback>>();

    group = {
      watchers,
      observer: new IntersectionObserver(
        (entries) => {
          for (const entry of entries) {
            const listeners = watchers.get(entry.target);

            if (listeners) {
              // Copied before iterating: a watcher is allowed to stop watching
              // from inside its own callback, and a `Set` mutated mid-loop
              // drops whatever came after it.
              for (const listener of [...listeners]) {
                listener(entry.isIntersecting);
              }
            }
          }
        },
        { threshold }
      )
    };

    visibilityGroups.set(threshold, group);
  }

  return group;
}

/**
 * Watches whether one element is on screen. Returns the function that stops.
 *
 * `null` where there is no `IntersectionObserver`, rather than a no-op: a
 * caller cannot know the answer without one, and the right fallback is to show
 * the thing rather than to hide it forever — which is a decision only the
 * caller can make.
 */
export function observeVisibility(
  element: Element,
  threshold: number,
  onVisible: VisibilityCallback
): (() => void) | null {
  // `threshold` is a public prop on seventeen components and `useOnScreen`, and
  // `IntersectionObserver` throws a `RangeError` for anything outside 0–1 — from
  // an effect, which takes the whole tree down. Held to the range instead, and a
  // `NaN` is the default, since it is what a computed threshold that went wrong
  // looks like.
  const bounded = Number.isNaN(threshold) ? 0 : Math.min(1, Math.max(0, threshold));
  const group = visibilityShared(bounded);

  if (!group) {
    return null;
  }

  let watchers = group.watchers.get(element);

  if (!watchers) {
    watchers = new Set();
    group.watchers.set(element, watchers);
    group.observer.observe(element);
  }

  watchers.add(onVisible);

  return () => {
    const set = group.watchers.get(element);

    if (!set) {
      return;
    }

    set.delete(onVisible);

    if (set.size === 0) {
      group.watchers.delete(element);
      group.observer.unobserve(element);

      // And the group goes with the last element, since only that can empty it.
      // A teardown belonging to a group already dropped this way finds nothing
      // under its element and has returned above.
      if (group.watchers.size === 0) {
        group.observer.disconnect();
        visibilityGroups.delete(bounded);
      }
    }
  };
}

/**
 * A ref object that says when an element is put on it or taken off.
 *
 * An effect that reads a `useRef` once watches only the element that was there
 * at the first commit, so a hook whose caller draws a spinner first and the
 * element after it never watches anything. React writes an object ref's
 * `current` on every attach and detach, whichever component renders the
 * element, so a setter hears both.
 */
export function attachedRef<E>(onChange: (element: E | null) => void): { current: E | null } {
  let current: E | null = null;

  return {
    get current() {
      return current;
    },
    set current(element) {
      current = element;
      onChange(element);
    }
  };
}
