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
});
