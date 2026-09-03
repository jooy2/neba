/**
 * The fold behind every prop that changes at a breakpoint.
 *
 * These are the cases a rendered component makes expensive and vague to check
 * and a direct call makes cheap and sharp: a map that names one breakpoint and
 * nothing else, two maps laid over each other, a value asked for at a width
 * below anything the caller said. Reach for a component test when the question
 * is what the component does with the answer; this is where the answer is.
 */
import { describe, expect, it } from 'vitest';
import {
  breakpointMap,
  lengthOf,
  overlayResponsive,
  responsiveSlots,
  valueAt,
  withBaseline
} from '../../src/internal/responsive.js';

describe('breakpointMap', () => {
  it('reads a bare value as "from xs up"', () => {
    expect(breakpointMap(6)).toEqual({ xs: 6 });
  });

  it('leaves a map alone, and reads nothing as nothing', () => {
    expect(breakpointMap({ md: 6 })).toEqual({ md: 6 });
    expect(breakpointMap(undefined)).toEqual({});
  });

  it('treats false and zero as values rather than as absence', () => {
    expect(breakpointMap(0)).toEqual({ xs: 0 });
    expect(breakpointMap(false)).toEqual({ xs: false });
  });
});

describe('responsiveSlots', () => {
  it('writes only the breakpoints the caller named', () => {
    expect(responsiveSlots('span', { md: 6 }, String)).toEqual({ '--n-span-md': '6' });
  });

  it('writes nothing at all for a value nobody gave', () => {
    expect(responsiveSlots('span', undefined, String)).toEqual({});
  });

  it('keeps the slots in ladder order, smallest first', () => {
    const slots = responsiveSlots('span', { xl: 3, xs: 12, md: 6 }, String);

    expect(Object.keys(slots)).toEqual(['--n-span-xs', '--n-span-md', '--n-span-xl']);
  });
});

describe('withBaseline', () => {
  it('fills in xs so a partial map does not lose the default below it', () => {
    // The failure it exists for: `spacing={{ md: 4 }}` with no baseline is a
    // grid with no gutter at all under 48rem.
    expect(withBaseline({ md: 4 }, 2)).toEqual({ xs: 2, md: 4 });
  });

  it('leaves an xs the caller wrote alone', () => {
    expect(withBaseline({ xs: 0, md: 4 }, 2)).toEqual({ xs: 0, md: 4 });
  });

  it('passes a bare value and an absent one straight through', () => {
    expect(withBaseline(4, 2)).toBe(4);
    expect(withBaseline(undefined, 2)).toBe(2);
  });
});

describe('overlayResponsive', () => {
  it('keeps the base where the override has said nothing yet', () => {
    expect(overlayResponsive(2, { md: 6 })).toEqual({ xs: 2, md: 6 });
  });

  it('keeps the override above where it was set, being the more specific', () => {
    expect(overlayResponsive({ xs: 2, lg: 4 }, { md: 6 })).toEqual({ xs: 2, md: 6 });
  });

  it('emits only the steps where the answer actually changes', () => {
    expect(overlayResponsive({ xs: 2, md: 2 }, undefined)).toEqual({ xs: 2, md: 2 });
    expect(overlayResponsive({ xs: 2 }, { md: 2 })).toEqual({ xs: 2 });
  });

  it('returns the base untouched when there is no override', () => {
    expect(overlayResponsive(2, undefined)).toBe(2);
  });
});

describe('valueAt', () => {
  it('reads the nearest entry at or below, every entry being a floor', () => {
    const span = { xs: 12, md: 6 };

    expect(valueAt(span, 'xs')).toBe(12);
    expect(valueAt(span, 'sm')).toBe(12);
    expect(valueAt(span, 'md')).toBe(6);
    expect(valueAt(span, 'lg')).toBe(6);
  });

  it('says nothing where the caller has said nothing', () => {
    // Not a failure: `{ lg: 4 }` on a phone is an opinion the caller declined
    // to have, which is what the CSS fallback answers there too.
    expect(valueAt({ lg: 4 }, 'sm')).toBeUndefined();
    expect(valueAt(undefined, 'xl')).toBeUndefined();
  });

  it('answers a bare value at every width', () => {
    expect(valueAt(6, 'xs')).toBe(6);
    expect(valueAt(6, 'xl')).toBe(6);
  });

  it('gives the same answer the cascade would', () => {
    // The two halves have to agree, or a component's responsive prop and the
    // number a caller worked out for themselves describe different layouts.
    expect(valueAt(withBaseline({ md: 4 }, 2), 'sm')).toBe(2);
    expect(valueAt(withBaseline({ md: 4 }, 2), 'md')).toBe(4);
  });
});

describe('lengthOf', () => {
  it('reads a number as pixels and a string as itself', () => {
    expect(lengthOf(640)).toBe('640px');
    expect(lengthOf('60ch')).toBe('60ch');
  });
});
