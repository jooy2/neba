/**
 * The scaffold around a pointer drag.
 *
 * Six components drag something and the arithmetic differs in every one of
 * them; what is shared is what the gesture takes from outside itself and has to
 * give back — three listeners, a `data-dragging` mark, and the document's text
 * selection. Each of those was written more than once before this module
 * existed, and each copy that got one of them wrong got it wrong invisibly: a
 * selection never restored looks like nothing until the reader next tries to
 * select a word.
 *
 * The split between `release` and `onEnd` is the other thing worth pinning. An
 * unmount has to run the first and must not run the second, because a component
 * that disappeared did not finish resizing — telling its caller it did would set
 * state on the way out of the tree.
 */
import { afterEach, describe, expect, it, vi } from 'vitest';
import { beginPointerDrag } from '../../src/internal/drag.js';

const SELECT = '-webkit-user-select';

let hosts: HTMLElement[] = [];

/** A target in the document, since capture and listeners both need one. */
function host(): HTMLElement {
  const element = document.createElement('div');

  document.body.append(element);
  hosts.push(element);

  return element;
}

function send(target: HTMLElement, type: string, init: PointerEventInit = {}) {
  target.dispatchEvent(new PointerEvent(type, { bubbles: true, pointerId: 1, ...init }));
}

afterEach(() => {
  for (const element of hosts) element.remove();
  hosts = [];
  document.body.style.removeProperty(SELECT);
});

describe('beginPointerDrag', () => {
  it('reports every move until the gesture ends', () => {
    const target = host();
    const onMove = vi.fn();

    beginPointerDrag({ target, pointerId: 1, onMove });

    send(target, 'pointermove', { clientX: 10 });
    send(target, 'pointermove', { clientX: 20 });

    expect(onMove).toHaveBeenCalledTimes(2);
  });

  it('stops reporting once the pointer is released', () => {
    const target = host();
    const onMove = vi.fn();

    beginPointerDrag({ target, pointerId: 1, onMove });

    send(target, 'pointerup');
    send(target, 'pointermove');

    expect(onMove).not.toHaveBeenCalled();
  });

  // A `pointercancel` is the gesture ending the way it was meant to as far as a
  // caller is concerned: it is over, and where it settled is the answer.
  it('counts a cancel as the end', () => {
    const target = host();
    const onEnd = vi.fn();

    beginPointerDrag({ target, pointerId: 1, onMove: () => {}, onEnd });

    send(target, 'pointercancel');

    expect(onEnd).toHaveBeenCalledTimes(1);
  });

  describe('the mark', () => {
    it('is on for the length of the gesture and off after it', () => {
      const target = host();

      beginPointerDrag({ target, pointerId: 1, onMove: () => {} });
      expect(target.dataset.dragging).toBe('true');

      send(target, 'pointerup');
      expect(target.dataset.dragging).toBeUndefined();
    });

    it('is not drawn when it was not asked for', () => {
      const target = host();

      beginPointerDrag({ target, pointerId: 1, onMove: () => {}, mark: false });

      expect(target.dataset.dragging).toBeUndefined();
    });
  });

  describe('the selection', () => {
    /*
     * Written prefixed and through `setProperty` because WebKit implements only
     * `-webkit-user-select`: `style.userSelect = 'none'` hangs a plain
     * JavaScript property off the object and Safari goes on selecting text
     * through the whole drag.
     */
    it('is taken for the length of the gesture', () => {
      const target = host();

      beginPointerDrag({ target, pointerId: 1, onMove: () => {} });

      expect(document.body.style.getPropertyValue(SELECT)).toBe('none');
    });

    // Removed rather than blanked, so a page that never wrote the property
    // inline is left with the declaration it actually had.
    it('is removed again rather than blanked', () => {
      const target = host();

      beginPointerDrag({ target, pointerId: 1, onMove: () => {} });
      send(target, 'pointerup');

      expect(document.body.style.getPropertyValue(SELECT)).toBe('');
    });

    it('gives back the value the page had written itself', () => {
      const target = host();

      document.body.style.setProperty(SELECT, 'text');
      beginPointerDrag({ target, pointerId: 1, onMove: () => {} });
      send(target, 'pointerup');

      expect(document.body.style.getPropertyValue(SELECT)).toBe('text');
    });

    it('is left alone when it was not asked for', () => {
      const target = host();

      beginPointerDrag({ target, pointerId: 1, onMove: () => {}, selectable: false });

      expect(document.body.style.getPropertyValue(SELECT)).toBe('');
    });
  });

  describe('release', () => {
    /*
     * The split this module exists for. An unmount calls `release`, and a
     * component that disappeared did not finish resizing — telling its caller it
     * did would set state on the way out of the tree.
     */
    it('gives everything back without telling the caller the gesture finished', () => {
      const target = host();
      const onMove = vi.fn();
      const onEnd = vi.fn();

      const release = beginPointerDrag({ target, pointerId: 1, onMove, onEnd });

      release();

      expect(onEnd).not.toHaveBeenCalled();
      expect(target.dataset.dragging).toBeUndefined();
      expect(document.body.style.getPropertyValue(SELECT)).toBe('');

      send(target, 'pointermove');
      expect(onMove).not.toHaveBeenCalled();
    });

    // The pointer's own `pointerup` calls it first in the ordinary case, so a
    // teardown running afterwards has to cost nothing.
    it('costs nothing the second time', () => {
      const target = host();
      const onEnd = vi.fn();

      const release = beginPointerDrag({ target, pointerId: 1, onMove: () => {}, onEnd });

      send(target, 'pointerup');
      document.body.style.setProperty(SELECT, 'text');
      release();

      expect(onEnd).toHaveBeenCalledTimes(1);
      expect(document.body.style.getPropertyValue(SELECT)).toBe('text');
    });
  });

  /*
   * Capture is an optimisation and not a requirement — the listeners are on the
   * target either way — so a pointer that is no longer active must not take the
   * gesture down with it. `setPointerCapture` throws `NotFoundError` for one,
   * and an exception escaping a React event handler takes the page down.
   */
  it('starts even when the pointer cannot be captured', () => {
    const target = host();
    const onMove = vi.fn();

    expect(() => beginPointerDrag({ target, pointerId: 9999, onMove })).not.toThrow();

    send(target, 'pointermove', { pointerId: 9999 });
    expect(onMove).toHaveBeenCalledTimes(1);
  });
});
