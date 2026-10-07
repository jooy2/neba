/**
 * One `ResizeObserver` and one `IntersectionObserver` per threshold, for the
 * whole page.
 *
 * Twenty-two components were building one each, and what this module adds over
 * a bare observer is the routing: a target back to the callbacks watching it,
 * and an `unobserve` when the last of them goes. Both halves fail quietly —
 * a watcher that stops being told is a chart that never resizes again, and a
 * target that is never unobserved is a detached node the browser keeps walking
 * — so they are worth pinning directly rather than through a component that
 * happens to measure itself.
 *
 * The delivery itself is asynchronous and belongs to the browser, so what is
 * asserted here is the routing around it.
 */
import { afterEach, describe, expect, it, vi } from 'vitest';
import { observeResize, observeVisibility } from '../../src/internal/observe.js';

let hosts: HTMLElement[] = [];

function host(width: number): HTMLElement {
  const element = document.createElement('div');

  element.style.cssText = `width:${width}px;height:20px`;
  document.body.append(element);
  hosts.push(element);

  return element;
}

afterEach(() => {
  for (const element of hosts) element.remove();
  hosts = [];
});

describe('observeResize', () => {
  it('tells a watcher about its own element', async () => {
    const element = host(100);
    const onResize = vi.fn();

    const stop = observeResize(element, onResize);

    await vi.waitFor(() => expect(onResize).toHaveBeenCalled());
    expect(onResize.mock.calls[0][0].target).toBe(element);

    stop();
  });

  // An element two components are measuring is observed once and reported to
  // both. This is the whole routing table the module exists for.
  it('tells every watcher of one element', async () => {
    const element = host(100);
    const first = vi.fn();
    const second = vi.fn();

    const stopFirst = observeResize(element, first);
    const stopSecond = observeResize(element, second);

    await vi.waitFor(() => {
      expect(first).toHaveBeenCalled();
      expect(second).toHaveBeenCalled();
    });

    stopFirst();
    stopSecond();
  });

  it('tells only the watchers of the element that changed', async () => {
    const watched = host(100);
    const other = host(100);
    const onWatched = vi.fn();
    const onOther = vi.fn();

    const stopWatched = observeResize(watched, onWatched);
    const stopOther = observeResize(other, onOther);

    await vi.waitFor(() => expect(onWatched).toHaveBeenCalled());
    onWatched.mockClear();
    onOther.mockClear();

    watched.style.width = '240px';

    await vi.waitFor(() => expect(onWatched).toHaveBeenCalled());
    expect(onOther).not.toHaveBeenCalled();

    stopWatched();
    stopOther();
  });

  it('stops telling a watcher that has stopped watching', async () => {
    const element = host(100);
    const onResize = vi.fn();

    const stop = observeResize(element, onResize);

    await vi.waitFor(() => expect(onResize).toHaveBeenCalled());
    stop();
    onResize.mockClear();

    element.style.width = '240px';
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));

    expect(onResize).not.toHaveBeenCalled();
  });

  // One of two watchers leaving must not take the observation with it, which is
  // the case a naive `unobserve` on every teardown gets wrong.
  it('keeps telling the watcher that stayed', async () => {
    const element = host(100);
    const leaving = vi.fn();
    const staying = vi.fn();

    const stopLeaving = observeResize(element, leaving);
    const stopStaying = observeResize(element, staying);

    await vi.waitFor(() => expect(staying).toHaveBeenCalled());
    stopLeaving();
    leaving.mockClear();
    staying.mockClear();

    element.style.width = '240px';

    await vi.waitFor(() => expect(staying).toHaveBeenCalled());
    expect(leaving).not.toHaveBeenCalled();

    stopStaying();
  });

  // A measurement is allowed to stop watching from inside its own delivery, and
  // a `Set` mutated mid-loop drops whatever came after it.
  it('survives a watcher that stops from inside its own callback', async () => {
    const element = host(100);
    const second = vi.fn();
    let stopFirst = () => {};

    const first = vi.fn(() => stopFirst());

    stopFirst = observeResize(element, first);
    const stopSecond = observeResize(element, second);

    await vi.waitFor(() => {
      expect(first).toHaveBeenCalled();
      expect(second).toHaveBeenCalled();
    });

    stopSecond();
  });

  it('costs nothing to stop twice', async () => {
    const element = host(100);
    const stop = observeResize(element, vi.fn());

    stop();

    expect(() => stop()).not.toThrow();
  });
});

describe('observeVisibility', () => {
  it('reports whether the element is on screen', async () => {
    const element = host(100);
    const onVisible = vi.fn();

    const stop = observeVisibility(element, 0, onVisible);

    await vi.waitFor(() => expect(onVisible).toHaveBeenCalledWith(true));

    stop?.();
  });

  it('tells every watcher of one element at one threshold', async () => {
    const element = host(100);
    const first = vi.fn();
    const second = vi.fn();

    const stopFirst = observeVisibility(element, 0, first);
    const stopSecond = observeVisibility(element, 0, second);

    await vi.waitFor(() => {
      expect(first).toHaveBeenCalled();
      expect(second).toHaveBeenCalled();
    });

    stopFirst?.();
    stopSecond?.();
  });

  // The threshold is the one thing an `IntersectionObserver` cannot vary per
  // target, which is why the groups are keyed by it. An element watched at two
  // thresholds is two rows, and neither may swallow the other.
  it('keeps the two thresholds of one element apart', async () => {
    const element = host(100);
    const loose = vi.fn();
    const tight = vi.fn();

    const stopLoose = observeVisibility(element, 0, loose);
    const stopTight = observeVisibility(element, 0.9, tight);

    await vi.waitFor(() => {
      expect(loose).toHaveBeenCalled();
      expect(tight).toHaveBeenCalled();
    });

    stopLoose?.();
    stopTight?.();

    expect(() => stopLoose?.()).not.toThrow();
  });

  // A computed threshold past either end threw from inside an effect and took
  // the tree with it.
  it('holds a threshold outside 0–1 to the range rather than throwing', async () => {
    const element = host(100);
    const over = vi.fn();
    const under = vi.fn();
    const broken = vi.fn();

    let stops: Array<(() => void) | null> = [];

    expect(() => {
      stops = [
        observeVisibility(element, 1.2, over),
        observeVisibility(element, -0.1, under),
        observeVisibility(element, Number.NaN, broken)
      ];
    }).not.toThrow();

    await vi.waitFor(() => {
      expect(over).toHaveBeenCalled();
      expect(under).toHaveBeenCalled();
      expect(broken).toHaveBeenCalled();
    });

    for (const stop of stops) stop?.();
  });

  /*
   * A group lives exactly as long as something is watching through it.
   * `threshold` is a public prop on every `Animate*`, so a caller is free to
   * compute one — and a group that outlived its last watcher would leave a live
   * observer behind for every value ever passed.
   */
  it('lets the observer go when its last watcher does', async () => {
    const element = host(100);
    const onVisible = vi.fn();
    const disconnect = vi.spyOn(IntersectionObserver.prototype, 'disconnect');

    const stop = observeVisibility(element, 0.37, onVisible);

    await vi.waitFor(() => expect(onVisible).toHaveBeenCalled());
    stop?.();

    expect(disconnect).toHaveBeenCalledTimes(1);
    disconnect.mockRestore();
  });

  it('keeps it while another element is still being watched', async () => {
    const leaving = host(100);
    const staying = host(100);
    const onStaying = vi.fn();
    const disconnect = vi.spyOn(IntersectionObserver.prototype, 'disconnect');

    const stopLeaving = observeVisibility(leaving, 0.39, vi.fn());
    const stopStaying = observeVisibility(staying, 0.39, onStaying);

    await vi.waitFor(() => expect(onStaying).toHaveBeenCalled());
    stopLeaving?.();

    expect(disconnect).not.toHaveBeenCalled();

    stopStaying?.();
    disconnect.mockRestore();
  });

  // The threshold is what an `Animate*` waits for, and a wrapper that caps it
  // for a tall element relies on the answer being measured against it rather
  // than against any overlap at all.
  it('answers false for an element showing less than its threshold', async () => {
    const element = host(100);
    const onVisible = vi.fn();

    element.style.cssText = 'position:fixed;left:0;top:calc(100vh - 10px);width:100px;height:100px';

    const stop = observeVisibility(element, 0.5, onVisible);

    await vi.waitFor(() => expect(onVisible).toHaveBeenCalled());
    expect(onVisible).toHaveBeenLastCalledWith(false);

    element.style.top = '0px';

    await vi.waitFor(() => expect(onVisible).toHaveBeenLastCalledWith(true));

    stop?.();
  });

  // The observer reports changes, and an element already reported has none to
  // report until it moves. A second watcher heard nothing at all.
  it('tells a watcher that arrives after the element was reported', async () => {
    const element = host(100);
    const first = vi.fn();
    const late = vi.fn();

    const stopFirst = observeVisibility(element, 0.43, first);

    await vi.waitFor(() => expect(first).toHaveBeenCalledWith(true));

    const stopLate = observeVisibility(element, 0.43, late);

    await vi.waitFor(() => expect(late).toHaveBeenCalledWith(true));
    expect(first).toHaveBeenCalledTimes(1);

    stopFirst?.();
    stopLate?.();
  });

  // Told in a microtask, so a watcher that stops from inside its first answer
  // has the function that stops it by then.
  it('lets a late watcher stop from inside the answer it is handed', async () => {
    const element = host(100);
    const first = vi.fn();

    const stopFirst = observeVisibility(element, 0.47, first);

    await vi.waitFor(() => expect(first).toHaveBeenCalled());

    let stop: (() => void) | null = null;
    let handed = false;
    const once = vi.fn(() => {
      handed = stop !== null;
      stop?.();
    });

    stop = observeVisibility(element, 0.47, once);

    await vi.waitFor(() => expect(once).toHaveBeenCalledTimes(1));
    expect(handed).toBe(true);

    // Off the screen: the watcher that stayed hears it, and the one that
    // stopped does not.
    element.style.cssText = 'position:fixed;top:200vh;width:100px;height:20px';

    await vi.waitFor(() => expect(first).toHaveBeenLastCalledWith(false));
    expect(once).toHaveBeenCalledTimes(1);

    stopFirst?.();
  });

  // Dropped and built again is the ordinary case on a page that mounts and
  // unmounts the same wrapper, so the second watcher has to be told as much as
  // the first was.
  it('watches again at a threshold everyone had left', async () => {
    const element = host(100);

    observeVisibility(element, 0.41, vi.fn())?.();

    const onVisible = vi.fn();
    const stop = observeVisibility(element, 0.41, onVisible);

    await vi.waitFor(() => expect(onVisible).toHaveBeenCalledWith(true));

    stop?.();
  });
});
