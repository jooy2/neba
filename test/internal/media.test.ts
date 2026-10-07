import { afterEach, describe, expect, it } from 'vitest';
import { widthAtLeast, widthBelow } from '../../src/internal/media.js';

const root = document.documentElement;

afterEach(() => {
  root.style.removeProperty('--neba-breakpoint-md');
});

describe('the breakpoint widths', () => {
  // No component test loads the stylesheet, so the first read here finds none
  // of the four tokens — which is what a page whose `<link>` has not finished
  // loading sees.
  it('falls back to the defaults while the stylesheet has not arrived', () => {
    expect(widthBelow('md')).toBe('(width < 48rem)');
    expect(widthAtLeast('lg')).toBe('(width >= 64rem)');
  });

  it('reads the stylesheet once it arrives, and keeps what it read', () => {
    root.style.setProperty('--neba-breakpoint-md', '50rem');

    expect(widthBelow('md')).toBe('(width < 50rem)');

    // A width cannot change without a new stylesheet, so the answer is kept.
    root.style.removeProperty('--neba-breakpoint-md');

    expect(widthBelow('md')).toBe('(width < 50rem)');
    expect(widthAtLeast('lg')).toBe('(width >= 64rem)');
  });
});
