/**
 * The threshold a `visible` trigger watches with. The observer's answer
 * belongs to the browser, so the arithmetic is checked here and the result in
 * `test/styles/animate-visible.test.tsx`.
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

const screenHeight = () => document.documentElement.clientHeight;

describe('visibilityWatch', () => {
  it('leaves an element the screen can hold as it was asked', () => {
    expect(visibilityWatch(host(100, 40), 0.2)).toBe(0.2);
  });

  // A fifth of the screen filled by it, whatever its height.
  it('scales the threshold for an element taller than the screen', () => {
    expect(visibilityWatch(host(100, screenHeight() * 5), 0.2)).toBe(0.04);
  });

  it('rounds the scaled threshold down to a hundredth', () => {
    expect(visibilityWatch(host(100, screenHeight() * 3), 0.2)).toBe(0.06);
  });
});
