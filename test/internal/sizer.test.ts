/**
 * Which samples a `WidthSizer` lays out.
 *
 * The sizer pins a control to the width of the widest thing it could say, and
 * only the widest sample does any pinning. `widestSamples` drops the strings
 * too short to be that one. What can go wrong is dropping the one that was —
 * which nothing in a rendered component would show, since no stylesheet is
 * loaded there — so the ranking is checked here, where a length is a number.
 */
import { describe, expect, it } from 'vitest';
import { widestSamples } from '../../src/internal/sizer.js';

describe('widestSamples', () => {
  it('keeps the longest string, and drops one far shorter than it', () => {
    expect(widestSamples(['Chad', 'United Kingdom of Great Britain', 'Peru'])).toEqual([
      'United Kingdom of Great Britain'
    ]);
  });

  // A length is not a width: capitals are wider than lower case, so a string
  // somewhat shorter than the longest can still be the widest.
  it('keeps a string close enough in length to be the widest', () => {
    expect(widestSamples(['WASHINGTON DC', 'washington, d.c. area'])).toEqual([
      'WASHINGTON DC',
      'washington, d.c. area'
    ]);
  });

  // A character from these scripts is drawn about twice as wide as a Latin one.
  it('counts a character from a wide script as two', () => {
    expect(widestSamples(['서울특별시', 'Washington DC'])).toEqual(['서울특별시', 'Washington DC']);
    expect(widestSamples(['서울', 'Washington DC Metropolitan Area'])).toEqual([
      'Washington DC Metropolitan Area'
    ]);
  });

  it('keeps every sample that is not a string, whatever the strings beside it', () => {
    const node = { type: 'em' };

    expect(widestSamples([node as never, 'United Kingdom of Great Britain', 42])).toEqual([
      node,
      'United Kingdom of Great Britain',
      42
    ]);
  });

  it('keeps the order it was given', () => {
    expect(widestSamples(['Saint Lucia', 'Saint Kitts and Nevis', 'Saint Martin'])).toEqual([
      'Saint Lucia',
      'Saint Kitts and Nevis',
      'Saint Martin'
    ]);
  });

  it('answers an empty list with an empty one', () => {
    expect(widestSamples([])).toEqual([]);
  });
});
