import { observeResize } from './observe.js';

/**
 * Keeps a sliding tile on the item it marks while the items change under it.
 *
 * A SegmentedButton and a FloatingBottomNavigation draw one tile behind the
 * current item and measure that item to place it. A value change is a render
 * of the component and is measured there. What is not is a change to the items
 * themselves: a label that grew, a font that arrived, the set reordered by its
 * caller. Both components used to catch those by measuring again whenever their
 * `children` changed identity, which is every render of whatever is above them,
 * and every one of those measurements laid the page out to read four offsets
 * that had not moved.
 *
 * So the items are watched instead, and nothing is measured unless something
 * happened to them:
 *
 * - **The root's size**, with no animation. That is the container moving under
 *   a tile that was already in the right place, and a tile that slides there
 *   lags behind a window being dragged.
 * - **Each item's size**, animated, as a label change always was.
 * - **The set itself**, through a `MutationObserver` on the root: an item added,
 *   removed or moved, and the attribute that marks the current one moving to
 *   another node, which is what a reorder of unkeyed items looks like.
 *
 * The root is observed before any item, and that order is load-bearing. One
 * `ResizeObserver` delivers its entries in the order its targets were added,
 * so when a resize of the root resizes the items with it, the instant
 * placement lands first and the animated ones that follow find the tile
 * already there. The other way round, the animated one starts a transition and
 * the instant one, asking for the same box, cannot stop it.
 *
 * `items` selects every item and `current` names the attribute on the current
 * one. Returns what stops all three.
 */
export function watchTile(
  root: HTMLElement,
  items: string,
  current: string,
  measure: (animate: boolean) => void
): () => void {
  const stopRoot = observeResize(root, () => measure(false));
  const watched = new Map<Element, () => void>();

  const sync = () => {
    const now = new Set(root.querySelectorAll(items));

    for (const [item, stop] of watched) {
      if (!now.has(item)) {
        stop();
        watched.delete(item);
      }
    }

    for (const item of now) {
      if (!watched.has(item)) {
        watched.set(
          item,
          observeResize(item, () => measure(true))
        );
      }
    }
  };

  sync();

  const changes = new MutationObserver(() => {
    sync();
    measure(true);
  });

  changes.observe(root, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: [current]
  });

  return () => {
    stopRoot();
    changes.disconnect();

    for (const stop of watched.values()) {
      stop();
    }

    watched.clear();
  };
}
