/**
 * The wheel, turned onto the axis a strip runs along.
 *
 * A mouse has one wheel and it points down the page, which is the one axis a
 * horizontal strip does not run along — so a shelf of cards, or a tab bar with
 * more tabs than room, is the one thing on a page a mouse cannot reach into.
 * The scrollbar is hidden on both, and a Tabs bar has no buttons either, so
 * without this the far tabs are reachable only by keyboard.
 *
 * What it does is one gesture: while the pointer is over a strip that has
 * somewhere to go along its own axis, the wheel is the strip's and nothing
 * else's. It is held at the ends too, and that is the part worth stating —
 * handing the wheel back the moment the strip runs out is what makes the page
 * lurch mid-flick, because the reader was still pushing the strip and what
 * answered was the article behind it. Moving the pointer off the strip is how
 * the page is scrolled past.
 *
 * Held only where there is a strip to hold it. A bar that fits in its box takes
 * nothing at all, which is what makes it safe to leave on: three tabs in a row
 * are not a scroll container as far as the reader is concerned, and must not
 * behave like one. And it takes no listener either, which is what
 * `bindAxisWheelWhileOverflowing` is for: a wheel listener that can cancel the
 * scroll makes the browser ask the page's main thread before it scrolls
 * anything under it, so every tab bar on a page held up the page's own scroll
 * while the pointer crossed it, whether the bar could scroll or not.
 *
 * Two gestures are deliberately left alone. A wheel held with Ctrl is a zoom. A
 * trackpad swiping sideways is already travel along the strip, and the browser
 * scrolls it better than a handler can — momentum and rubber-banding come with
 * it — so `overscroll-behavior` is what holds that one at the ends instead,
 * which is why every caller sets it.
 */

/**
 * What a wheel notch is worth when it is counted in lines rather than pixels.
 *
 * Firefox reports a mouse wheel that way — three lines a notch — and a line is
 * whatever the reader's text is; sixteen pixels is the browser's own default
 * and near enough for a gesture that is repeated until it looks right.
 */
const WHEEL_LINE = 16;

/** Under this much room left over, the strip is not scrolled and does not hold. */
const SLACK = 1;

/**
 * Turns a wheel rolled over `el` into travel along `el`'s horizontal scroll,
 * and holds it there. Returns the teardown.
 *
 * Registered as a native listener rather than as React's `onWheel`, because
 * React attaches its wheel listener passively and a passive listener cannot
 * `preventDefault` — which is the whole gesture: taking the wheel is only right
 * if the page does not answer it as well.
 */
export function bindAxisWheel(el: HTMLElement): () => void {
  const onWheel = (event: WheelEvent) => {
    // Something nearer the pointer has already answered this notch — a strip
    // inside a strip, or a NumberField being scrubbed on one. The event still
    // bubbles out here, and acting on it again would move twice as far as the
    // hand asked for.
    if (event.defaultPrevented) {
      return;
    }

    if (event.ctrlKey || Math.abs(event.deltaX) > Math.abs(event.deltaY)) {
      return;
    }

    // Measured now rather than read off the last render: whether a strip
    // overflows depends on the room it was given, and children arriving change
    // that without resizing anything an observer is watching.
    if (el.scrollWidth - el.clientWidth <= SLACK) {
      return;
    }

    const unit = event.deltaMode === 1 ? WHEEL_LINE : event.deltaMode === 2 ? el.clientWidth : 1;
    const distance = event.deltaY * unit;
    if (!distance) {
      return;
    }

    event.preventDefault();
    // Instantly: a wheel is already a stream of small movements, and smoothing
    // each one would leave the strip still arriving after the hand stopped.
    // Signed against the writing direction, because a right-to-left container
    // counts its scroll backwards from zero while ahead is still ahead.
    const rtl = getComputedStyle(el).direction === 'rtl';
    el.scrollBy({ left: rtl ? -distance : distance, behavior: 'auto' });
  };

  el.addEventListener('wheel', onWheel, { passive: false });

  return () => el.removeEventListener('wheel', onWheel);
}

/** What `bindAxisWheelWhileOverflowing` hands back. */
export interface AxisWheelBinding {
  /** Measures the strip again, and takes or drops the wheel to match. */
  check: () => void;
  /** The teardown. */
  stop: () => void;
}

/**
 * `bindAxisWheel`, attached only while the strip overflows along its width —
 * the one case its handler acts on, measured the same way.
 *
 * `check` is for the caller to run whenever it measures the strip anyway: on a
 * scroll, a resize, a change in what it holds. The strip also checks when a
 * pointer arrives over it, because a label can grow without resizing anything
 * an observer is watching, and a wheel can only reach the strip through a
 * pointer that is over it. The reads come first and nothing is written, so a
 * caller can run it ahead of its own writes without forcing a layout.
 */
export function bindAxisWheelWhileOverflowing(el: HTMLElement): AxisWheelBinding {
  let unbind: (() => void) | null = null;

  const check = () => {
    const overflows = el.scrollWidth - el.clientWidth > SLACK;

    if (overflows && !unbind) {
      unbind = bindAxisWheel(el);
    } else if (!overflows && unbind) {
      unbind();
      unbind = null;
    }
  };

  el.addEventListener('pointerenter', check);
  check();

  return {
    check,
    stop() {
      el.removeEventListener('pointerenter', check);
      unbind?.();
      unbind = null;
    }
  };
}
