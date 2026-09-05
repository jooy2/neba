/**
 * The arithmetic the progress indicators, the Meter and the GaugeChart share.
 *
 * Both functions here have the same shape of edge case, and it is the one a
 * rendered component answers vaguely: a range that is empty or inverted, a
 * reading outside its own scale, a band list that starts above the value or
 * that was written in the wrong order. Each is a line of arithmetic and each is
 * read by four components, so getting one wrong is wrong in four places at once.
 */
import { describe, expect, it } from 'vitest';
import { progressFraction, thresholdColor } from '../../src/internal/progress.js';

describe('progressFraction', () => {
  it('places a value inside its range', () => {
    expect(progressFraction(25, 0, 100)).toBe(0.25);
    expect(progressFraction(5, 0, 10)).toBe(0.5);
  });

  it('works against a range that does not start at zero', () => {
    expect(progressFraction(15, 10, 20)).toBe(0.5);
  });

  // A reading past either end is clamped rather than allowed to draw a bar
  // longer than its own groove.
  it('clamps a value outside the range', () => {
    expect(progressFraction(200, 0, 100)).toBe(1);
    expect(progressFraction(-40, 0, 100)).toBe(0);
  });

  /*
   * `null` is the indeterminate case — something is happening and nobody knows
   * how much is left — and it has to stay distinguishable from zero all the way
   * through. An indicator told `null` says so; one told `0` draws an empty bar,
   * which is the claim that no progress has been made.
   */
  it('keeps an absent value apart from a zero one', () => {
    expect(progressFraction(null, 0, 100)).toBeNull();
    expect(progressFraction(undefined, 0, 100)).toBeNull();
    expect(progressFraction(0, 0, 100)).toBe(0);
  });

  it('has no answer for a value that is not a number', () => {
    expect(progressFraction(Number.NaN, 0, 100)).toBeNull();
  });

  // A range of no width has no fraction to give. Answering `0` or `1` would be
  // a reading invented out of a caller's mistake.
  it('has no answer for an empty or inverted range', () => {
    expect(progressFraction(50, 100, 100)).toBeNull();
    expect(progressFraction(50, 100, 0)).toBeNull();
  });
});

describe('thresholdColor', () => {
  const bands = [
    { from: 60, color: 'warning' },
    { from: 85, color: 'danger' }
  ] as const;

  it('keeps the base family when there are no bands', () => {
    expect(thresholdColor(90, 'primary', undefined)).toBe('primary');
    expect(thresholdColor(90, 'primary', [])).toBe('primary');
  });

  it('keeps the base family below the first band', () => {
    expect(thresholdColor(10, 'primary', bands)).toBe('primary');
  });

  it('takes the highest band the value has reached', () => {
    expect(thresholdColor(70, 'primary', bands)).toBe('warning');
    expect(thresholdColor(90, 'primary', bands)).toBe('danger');
  });

  // `from` is the value the band applies *from*, so the boundary belongs to the
  // band above rather than the one below it.
  it('gives the boundary itself to the band it opens', () => {
    expect(thresholdColor(60, 'primary', bands)).toBe('warning');
    expect(thresholdColor(59.9, 'primary', bands)).toBe('primary');
  });

  /*
   * A scan in the order the array was written, not a sort. Bands are meant to
   * be listed ascending, and reordering them here would hide the one call site
   * that did not — so a list out of order gives the last band that matched,
   * which is visibly wrong at the call site rather than quietly right.
   */
  it('reads the list in the order it was given', () => {
    const wrongWayRound = [
      { from: 85, color: 'danger' },
      { from: 60, color: 'warning' }
    ] as const;

    expect(thresholdColor(90, 'primary', wrongWayRound)).toBe('warning');
  });
});
