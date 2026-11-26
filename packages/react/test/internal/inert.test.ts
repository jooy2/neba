import { describe, expect, it } from 'vitest';
import { inertValue } from '../../src/internal/inert.js';

describe('inertValue', () => {
  // React 19 writes a boolean attribute it knows; React 18 knows nothing about
  // `inert` and writes only a string.
  it('spells `inert` the way the running React writes it', () => {
    expect(inertValue(true, '19.1.0')).toBe(true);
    expect(inertValue(true, '18.3.1')).toBe('');
  });

  it('leaves the attribute off when the element is reachable', () => {
    expect(inertValue(false, '19.1.0')).toBeUndefined();
    expect(inertValue(false, '18.3.1')).toBeUndefined();
  });
});
