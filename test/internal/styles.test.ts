/**
 * The two length helpers in `internal/styles.ts`.
 *
 * They are the one part of that file that is a *function* rather than a class
 * string, and the only part with a wrong answer available to it. Both were
 * written more than once before they lived here — `toLength` three times and
 * `toPixels` twice — and the copies disagreed, which is exactly what a test on
 * the shared version is for.
 *
 * Nothing here renders a component. The rest of `test/` drives a browser
 * because the components need one; these are arithmetic, and arithmetic is
 * cheaper and sharper to check directly.
 */
import { describe, expect, it } from 'vitest';
import { toLength, toPixels } from '../../src/internal/styles.js';

describe('toLength', () => {
  it('reads a number as pixels', () => {
    expect(toLength(240)).toBe('240px');
  });

  it('keeps zero, which is falsy and is a length', () => {
    // The reason the helper lives in one place: a second copy written with a
    // truthiness check turns `0` into nothing at all.
    expect(toLength(0)).toBe('0px');
  });

  it('leaves a string alone', () => {
    expect(toLength('15rem')).toBe('15rem');
    expect(toLength('clamp(12rem, 30%, 30rem)')).toBe('clamp(12rem, 30%, 30rem)');
  });

  it('turns nothing into nothing', () => {
    expect(toLength(undefined)).toBeUndefined();
  });
});

describe('toPixels', () => {
  it('reads a pixel length', () => {
    expect(toPixels('240px', { percentOf: 1000 })).toBe(240);
  });

  it('reads a percentage against what it was told to', () => {
    // Which is the whole reason `percentOf` is a parameter: a Sidebar is
    // bounded against the window and a pane against the split it sits in.
    expect(toPixels('25%', { percentOf: 800 })).toBe(200);
    expect(toPixels('25%', { percentOf: 400 })).toBe(100);
  });

  it('reads rem against the document root', () => {
    const root = document.documentElement.style.fontSize;

    document.documentElement.style.fontSize = '20px';

    try {
      expect(toPixels('2rem', { percentOf: 0 })).toBe(40);
    } finally {
      document.documentElement.style.fontSize = root;
    }
  });

  it('reads em against the element it was given, not the document root', () => {
    // The bug this replaced: one of the two copies resolved `em` against the
    // document root, which is what `rem` means — so a `minWidth="2em"` on a
    // sidebar with type of its own came out at the wrong width.
    const element = document.createElement('div');

    element.style.fontSize = '32px';
    document.body.append(element);

    try {
      expect(toPixels('2em', { percentOf: 0, relativeTo: element })).toBe(64);
      expect(toPixels('2em', { percentOf: 0 })).not.toBe(64);
    } finally {
      element.remove();
    }
  });

  it('leaves a length it cannot read to the caller', () => {
    // `undefined` rather than a guess, so every caller decides its own fallback
    // — a Sidebar has a default width to fall back to and a pane does not.
    expect(toPixels('calc(100% - 2rem)', { percentOf: 100 })).toBeUndefined();
    expect(toPixels('auto', { percentOf: 100 })).toBeUndefined();
    expect(toPixels('12', { percentOf: 100 })).toBeUndefined();
  });

  it('does not read a bare number, which means two different things', () => {
    // Pixels on a Sidebar and a percentage on a Panes. That is a question about
    // the prop, and it is answered at the two call sites rather than here.
    expect(toPixels('30', { percentOf: 100 })).toBeUndefined();
  });
});
