/**
 * What a `visible` trigger watches for. The observer's answer belongs to the
 * browser, and a frame around the page clips a first frame drawn outside it
 * before any margin applies, so the arithmetic is checked here and the result
 * in `test/styles/animate-visible.test.tsx`.
 */
import { afterEach, describe, expect, it } from 'vitest';
import { visibilityWatch } from '../../src/internal/animate.js';

let hosts: HTMLElement[] = [];

function host(width: number, height: number): HTMLElement {
  const element = document.createElement('div');

  element.style.cssText = `width:${width}px;height:${height}px`;
  document.body.append(element);
  hosts.push(element);

  return element;
}

afterEach(() => {
  for (const element of hosts) element.remove();
  hosts = [];
});

const screenWidth = () => document.documentElement.clientWidth;
const screenHeight = () => document.documentElement.clientHeight;

describe('visibilityWatch', () => {
  it('leaves an element the screen can hold as it was asked', () => {
    expect(visibilityWatch(host(100, 40), 0.2, undefined)).toEqual({
      threshold: 0.2,
      rootMargin: '0px'
    });
  });

  // A fifth of the screen filled by it, whatever its height.
  it('scales the threshold for an element taller than the screen', () => {
    const watch = visibilityWatch(host(100, screenHeight() * 5), 0.2, undefined);

    expect(watch.threshold).toBe(0.04);
  });

  it('rounds the scaled threshold down to a hundredth', () => {
    const watch = visibilityWatch(host(100, screenHeight() * 3), 0.2, undefined);

    expect(watch.threshold).toBe(0.06);
  });

  // The root moves with the element: grown on the side it moved towards and
  // shrunk on the other, top, right, bottom, left.
  it('moves the root as far as the first frame moves the element', () => {
    const wide = host(screenWidth(), 40);

    expect(visibilityWatch(wide, 0.2, { x: 'calc(-1 * 100%)', y: '0px' }).rootMargin).toBe(
      '0% -100% 0% 100%'
    );
    expect(visibilityWatch(wide, 0.2, { x: '100%', y: '0px' }).rootMargin).toBe('0% 100% 0% -100%');
    expect(visibilityWatch(wide, 0.2, { x: '0px', y: `${screenHeight() / 2}px` }).rootMargin).toBe(
      '-50% 0% 50% 0%'
    );
  });

  it('leaves the root alone for a first frame it cannot read', () => {
    expect(
      visibilityWatch(host(100, 40), 0.2, { x: 'calc(100% + 1rem)', y: '0px' }).rootMargin
    ).toBe('0px');
  });
});
