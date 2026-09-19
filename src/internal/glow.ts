/**
 * The pointer's place on a surface that is lit by it.
 *
 * `.neba-glow` in `styles.css` draws two layers off `--n-mx`/`--n-my` — a
 * spotlight that follows the pointer and an afterglow that lands on a press —
 * and neither of them can find the pointer on its own: CSS has no way to ask
 * where it is. This is the two lines that tell it, and they are here because
 * the number of components that want them is no longer two.
 *
 * **The rect, rather than `offsetX`.** `offsetX` is measured from the *target*,
 * which is the innermost element under the pointer — so it is only the surface's
 * own offset while every descendant is `pointer-events: none`. That holds for a
 * Button's icons and stops holding the moment a caller wraps the label in a
 * `<span>`, and it never held for a field, whose `<input>` is exactly the thing
 * the pointer is over. One `getBoundingClientRect` per frame on the one element
 * a pointer can be over is the price of being right about all of them.
 *
 * Nothing else costs anything. `pointermove` is already coalesced to one per
 * frame; the two properties are written straight to the element rather than
 * held in state, so React never re-renders; and what changes is where a
 * gradient is centred, which is a repaint of one box and not a layout. Only the
 * hovered element paints at all, `@media (hover: hover)` keeps it off a touch
 * screen entirely, and a reduced-motion preference drops both layers.
 *
 * The one thing to watch is **whose subtree it is**. A custom property written
 * on an element invalidates the style of everything under it, so the slots go
 * on the surface that paints the light and never on a container holding rows of
 * other things: a Menu lights its own rows, one at a time, and not the popup
 * around them.
 */

import type * as React from 'react';

/** Carries the two layers. Useless without the slots below and the handler. */
export const glowClasses = 'neba-glow';

/**
 * The spotlight without the press flash, for a surface that is **entered**
 * rather than pressed and held.
 *
 * `--n-flash` is left unset and the afterglow falls back to `transparent`,
 * which is the whole distinction. A press is answered by a flash that lands on
 * the frame of the click and drains for the best part of a second: clicking
 * into a field is not that, and neither is choosing a menu row, which is gone
 * before the flash is a third of the way out.
 *
 * It reads `--n-soft` rather than a family, so it follows whatever the
 * component's own slots resolved to — including a field turning `danger` the
 * moment it is invalid.
 */
export const spotlightSlot = { '--n-glow': 'var(--n-soft)' } as React.CSSProperties;

/**
 * Writes the pointer's place onto the element, in front of whatever handler the
 * caller passed.
 *
 * `lit` is what stops a disabled, read-only or otherwise unlit surface paying
 * for a light nobody is painting: without the class there are no layers to
 * feed, and writing the slots anyway would invalidate that element's style on
 * every pointer event for nothing.
 */
export function trackPointer<E extends HTMLElement>(
  handler: React.PointerEventHandler<E> | undefined,
  lit: boolean
): React.PointerEventHandler<E> | undefined {
  if (!lit) {
    return handler;
  }

  return (event) => {
    const element = event.currentTarget;
    const box = element.getBoundingClientRect();

    element.style.setProperty('--n-mx', `${event.clientX - box.left}px`);
    element.style.setProperty('--n-my', `${event.clientY - box.top}px`);

    handler?.(event);
  };
}
