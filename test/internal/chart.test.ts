/**
 * The arithmetic every chart is built out of.
 *
 * `internal/chart.ts` knows nothing about React or SVG — it is scales, paths
 * and estimates — and that is exactly why it is tested here rather than through
 * a rendered chart. A flat series, an empty range, a `null` in the middle of a
 * line and a full-circle arc are all one call each; reaching the same cases
 * through a component means laying a chart out in a browser and reading the
 * answer back off a path string.
 *
 * The three rules asserted hardest are the ones CLAUDE.md calls load-bearing: a
 * `null` is a gap and never a zero, a series' colour follows its index in the
 * array it was passed, and the palette is handed out in order and never cycled
 * within its own length.
 */
import { describe, expect, it } from 'vitest';
import {
  arcPath,
  bandScale,
  bubbleRadius,
  categoryCount,
  chartPalette,
  extentOf,
  formatTimeValue,
  labelledPoints,
  linePath,
  markPath,
  rampStep,
  rampSteps,
  ringPath,
  seriesColor,
  tickStride,
  toValue,
  squarify,
  toValues,
  truncate,
  valueScale,
  toFullShares,
  timeScale
} from '../../src/internal/chart.js';

describe('timeScale', () => {
  // The ticks were walked from the pinned `min`, and a month after 31 January
  // is 3 March.
  it('ticks on the calendar when min is pinned off a boundary', () => {
    const min = new Date(2026, 0, 31).getTime();
    const max = new Date(2026, 5, 15).getTime();
    const scale = timeScale({ min, max }, { min, max });

    expect(scale.unit).toBe('month');
    expect(scale.min).toBe(min);
    expect(scale.ticks.map((tick) => new Date(tick).getDate())).toEqual(scale.ticks.map(() => 1));
    expect(scale.ticks.every((tick) => tick >= scale.min && tick <= scale.max)).toBe(true);
  });

  // One reading is not a range, and dividing by its own span would draw every
  // mark on one pixel.
  it('opens a day around a single instant', () => {
    const at = new Date(2026, 2, 2, 9, 30).getTime();
    const scale = timeScale({ min: at, max: at });

    expect(scale.max).toBeGreaterThan(scale.min);
    expect(scale.ticks.length).toBeGreaterThan(0);
  });

  // A day is a day on the wall clock, not 86,400,000 milliseconds from the
  // first reading — which is what walking the axis by arithmetic would give.
  it('ticks at midnight across a run of days', () => {
    const min = new Date(2026, 2, 2).getTime();
    const max = new Date(2026, 2, 12).getTime();
    const scale = timeScale({ min, max });

    expect(scale.unit).toBe('day');

    for (const tick of scale.ticks) {
      const at = new Date(tick);

      expect([at.getHours(), at.getMinutes(), at.getSeconds()]).toEqual([0, 0, 0]);
    }
  });

  // Above a year the calendar has no units left, so the step is 1-2-5 again.
  it('counts in whole years above a year', () => {
    const scale = timeScale({
      min: new Date(1996, 0, 1).getTime(),
      max: new Date(2026, 0, 1).getTime()
    });

    expect(scale.unit).toBe('year');
    expect([1, 2, 5, 10]).toContain(scale.step);
    expect(scale.ticks.map((tick) => new Date(tick).getMonth())).toEqual(scale.ticks.map(() => 0));
  });
});

describe('formatTimeValue', () => {
  // A tooltip and a hidden table read one instant out of its axis, so the year
  // is written whether or not the axis had room for it.
  it('writes a day with its year', () => {
    const text = formatTimeValue(new Date(2026, 2, 2).getTime(), 'day', 'en-US');

    expect(text).toContain('2026');
    expect(text).toContain('Mar');
    expect(text).toContain('2');
  });

  it('writes a time on the 24-hour clock', () => {
    expect(formatTimeValue(new Date(2026, 2, 2, 14, 5).getTime(), 'minute', 'en-US')).toBe('14:05');
  });

  it('adds the time of day to a date when it is asked for', () => {
    const text = formatTimeValue(new Date(2026, 2, 2, 14, 5).getTime(), 'day', 'en-GB', true);

    expect(text).toContain('2 Mar 2026');
    expect(text).toContain('14:05');
  });
});

describe('rampStep', () => {
  it('spreads a sequential range over the whole ladder', () => {
    expect(rampStep(0, 0, 100, 'sequential')).toBe(0);
    expect(rampStep(50, 0, 100, 'sequential')).toBe(2);
    expect(rampStep(100, 0, 100, 'sequential')).toBe(rampSteps - 1);
  });

  // A flat range took the top rung, so a week with no activity at all looked
  // like the busiest week there could be.
  it('reads a flat sequential range against zero', () => {
    expect(rampStep(0, 0, 0, 'sequential')).toBe(0);
    expect(rampStep(-3, -3, -3, 'sequential')).toBe(0);
    expect(rampStep(5, 5, 5, 'sequential')).toBe(rampSteps - 1);
  });

  it('holds a value outside the range to the ends of the ladder', () => {
    expect(rampStep(-40, 0, 100, 'sequential')).toBe(0);
    expect(rampStep(400, 0, 100, 'sequential')).toBe(rampSteps - 1);
  });

  // A diverging scale is read from its middle, and by the longer of its two
  // arms, so a set running from −2 to +40 does not paint every negative the
  // deepest colour there is.
  it('reads a diverging range from its midpoint, by its longer arm', () => {
    expect(rampStep(0, -2, 40, 'diverging')).toBe(2);
    expect(rampStep(40, -2, 40, 'diverging')).toBe(4);
    expect(rampStep(-2, -2, 40, 'diverging')).toBe(2);
    expect(rampStep(-40, -40, 40, 'diverging')).toBe(0);
  });

  // Flat, and flat on its own midpoint: there is no distance either side of the
  // neutral to scale, so every value is the neutral. A flat range away from the
  // midpoint still has reach, and reads at the end it is on.
  it('takes the middle rung when a diverging range has no reach at all', () => {
    expect(rampStep(7, 7, 7, 'diverging', 7)).toBe(2);
    expect(rampStep(7, 7, 7, 'diverging')).toBe(4);
  });
});

describe('squarify', () => {
  it('fills the box with tiles whose areas follow the values', () => {
    const values = [8, 4, 2, 2];
    const tiles = squarify(values, 200, 100);
    const total = values.reduce((sum, value) => sum + value, 0);

    expect(tiles).toHaveLength(values.length);

    for (const tile of tiles) {
      expect(tile.width * tile.height).toBeCloseTo((values[tile.index] / total) * 200 * 100, 4);
      expect(tile.x).toBeGreaterThanOrEqual(-0.000001);
      expect(tile.y).toBeGreaterThanOrEqual(-0.000001);
      expect(tile.x + tile.width).toBeLessThanOrEqual(200.000001);
      expect(tile.y + tile.height).toBeLessThanOrEqual(100.000001);
    }
  });

  // The layout sorts descending because the algorithm needs it to, and hands
  // the caller's own index back on every tile so a colour and a name still
  // belong to their value.
  it('hands back the index each value came in at', () => {
    const tiles = squarify([1, 9, 3], 100, 100);

    expect(tiles.map((tile) => tile.index).sort()).toEqual([0, 1, 2]);
    expect(tiles[0].index).toBe(1);
  });

  it('draws nothing for a box or a total with nothing in it', () => {
    expect(squarify([1, 2], 0, 100)).toEqual([]);
    expect(squarify([0, 0], 100, 100)).toEqual([]);
    expect(squarify([5, -3], 100, 100).map((tile) => tile.index)).toEqual([0]);
  });
});

describe('markPath', () => {
  const shapes = ['circle', 'square', 'triangle', 'diamond', 'cross'] as const;

  it('draws every shape as a path of its own', () => {
    const paths = shapes.map((shape) => markPath(shape, 20, 20, 6));

    expect(paths.every((path) => path.startsWith('M'))).toBe(true);
    expect(new Set(paths).size).toBe(shapes.length);
  });

  it('draws nothing at all at no radius', () => {
    expect(shapes.every((shape) => markPath(shape, 20, 20, 0) === '')).toBe(true);
    expect(markPath('square', 20, 20, -4)).toBe('');
  });

  /*
   * Equal area rather than equal radius, which is the whole reason the shapes
   * are scaled at all: on a bubble chart the area is carrying a magnitude, so a
   * square that covers a third more ink than the circle beside it is reporting
   * a value it was not given.
   */
  it('covers the area of a circle of the same radius, whatever the shape', () => {
    const radius = 10;
    const area = Math.PI * radius * radius;
    const side = Number(/h([\d.]+)/.exec(markPath('square', 0, 0, radius))![1]);
    const half = Number(/^M0 -([\d.]+)/.exec(markPath('diamond', 0, 0, radius))![1]);

    expect(side ** 2).toBeCloseTo(area, 0);
    expect(2 * half ** 2).toBeCloseTo(area, 0);
  });
});

describe('valueScale', () => {
  it('rounds the top outward to a tick, so the tallest mark stops short of the frame', () => {
    const scale = valueScale({ min: 0, max: 4830 });

    expect(scale.max).toBeGreaterThan(4830);
    expect(scale.ticks[scale.ticks.length - 1]).toBe(scale.max);
  });

  it('opens a band around a flat series rather than dividing by zero', () => {
    // Every value the same. Without this the extent is zero and every point
    // lands on one line — or on `NaN`. Keeping zero in range hides the case, so
    // it is turned off here, which is what a LineChart told a `min` does.
    const scale = valueScale({ min: 40, max: 40 }, { includeZero: false });

    expect(scale.min).toBeLessThan(40);
    expect(scale.max).toBeGreaterThan(40);
    expect(Number.isFinite(scale.fraction(40))).toBe(true);
  });

  it('opens a band around a flat series at zero', () => {
    const scale = valueScale({ min: 0, max: 0 });

    expect(scale.max).toBeGreaterThan(scale.min);
    expect(Number.isFinite(scale.fraction(0))).toBe(true);
  });

  it('answers a scale with no data at all', () => {
    const scale = valueScale(null);

    expect(scale.max).toBeGreaterThan(scale.min);
    expect(scale.ticks.length).toBeGreaterThan(1);
  });

  it('keeps zero in range unless an end was pinned', () => {
    expect(valueScale({ min: 20, max: 90 }).min).toBe(0);
    expect(valueScale({ min: 20, max: 90 }, { min: 20 }).min).toBe(20);
  });

  it('prints no tick as a floating-point smear', () => {
    // `0.1 * 3` is 0.30000000000000004. A tick printed that way is worse than
    // a missing one, and the guard against it is what keeps the last tick on.
    const scale = valueScale({ min: 0, max: 0.5 });

    for (const tick of scale.ticks) {
      expect(String(tick).length).toBeLessThan(8);
    }
  });

  it('runs the fraction from 0 at the bottom to 1 at the top', () => {
    const scale = valueScale({ min: 0, max: 100 }, { min: 0, max: 100 });

    expect(scale.fraction(0)).toBe(0);
    expect(scale.fraction(100)).toBe(1);
    expect(scale.fraction(50)).toBeCloseTo(0.5, 10);
  });

  it('handles a range entirely below zero', () => {
    const scale = valueScale({ min: -900, max: -100 });

    expect(scale.min).toBeLessThanOrEqual(-900);
    expect(scale.max).toBe(0);
  });

  it('keeps a pinned end when every value lies past it', () => {
    // A LineChart told `min: 0` over a series that is all below zero. The data
    // gives a top of -10 under a bottom of 0, and a negative range had no step.
    const below = valueScale({ min: -50, max: -10 }, { min: 0, includeZero: false });

    expect(below.min).toBe(0);
    expect(below.max).toBeGreaterThan(0);
    expect(below.ticks.length).toBeGreaterThan(1);
    expect(below.ticks.every(Number.isFinite)).toBe(true);

    const above = valueScale({ min: 10, max: 50 }, { max: 0, includeZero: false });

    expect(above.max).toBe(0);
    expect(above.min).toBeLessThan(0);
    expect(above.ticks.length).toBeGreaterThan(1);

    // A bar chart keeps zero in range, and a pinned `min` above the data still
    // inverts it.
    const bars = valueScale({ min: 2, max: 5 }, { min: 10 });

    expect(bars.min).toBe(10);
    expect(bars.max).toBeGreaterThan(10);
    expect(Number.isFinite(bars.fraction(5))).toBe(true);
  });

  it('keeps a pinned end under a flat series', () => {
    const scale = valueScale({ min: 40, max: 40 }, { min: 40, includeZero: false });

    expect(scale.min).toBe(40);
    expect(scale.max).toBeGreaterThan(40);
  });
});

describe('extentOf', () => {
  const rows = (...numbers: (number | null)[][]) =>
    numbers.map((one) => one.map((value) => ({ value })));

  it('ignores a gap rather than counting it as zero', () => {
    // The rule the whole file turns on: a chart that renders missing data as
    // zero reports an outage as a collapse.
    expect(extentOf(rows([50, null, 70]), false)).toEqual({ min: 50, max: 70 });
  });

  it('answers null when there is nothing to measure', () => {
    expect(extentOf(rows([null, null]), false)).toBeNull();
    expect(extentOf([], false)).toBeNull();
  });

  it('sums a stack, and sums the two signs apart', () => {
    expect(extentOf(rows([10, -5], [20, -5]), true)).toEqual({ min: -10, max: 30 });
  });

  it('leaves a gap out of a stack without shortening the column', () => {
    expect(extentOf(rows([10, 10], [null, 10]), true)).toEqual({ min: 0, max: 20 });
  });
});

describe('toValue', () => {
  it('reads the three ways a datum can be written', () => {
    expect(toValue(12)).toEqual({ value: 12 });
    expect(toValue(null)).toEqual({ value: null });
    expect(toValue({ y: 3, x: 'Jan' })).toMatchObject({ value: 3, x: 'Jan' });
  });

  it('treats a number that is not one as a gap', () => {
    // `NaN` and `Infinity` reach a chart from arithmetic a caller did — a rate
    // over a zero denominator — and drawing them puts a mark nowhere.
    expect(toValue(Number.NaN)).toEqual({ value: null });
    expect(toValue(Number.POSITIVE_INFINITY)).toEqual({ value: null });
    expect(toValue({ y: Number.NaN })).toMatchObject({ value: null });
  });

  it('keeps a point’s own label and category beside a null value', () => {
    expect(toValue({ y: null, x: 'Feb', label: 'no reading' })).toMatchObject({
      value: null,
      x: 'Feb',
      label: 'no reading'
    });
  });
});

describe('toValues and categoryCount', () => {
  it('counts the widest series rather than the first', () => {
    expect(categoryCount([{ data: [1, 2, 3] }, { data: [1] }])).toBe(3);
    expect(categoryCount([])).toBe(0);
  });

  it('unpacks every series in the order it was given', () => {
    expect(toValues([{ data: [1, null] }, { data: [{ y: 2 }] }])).toEqual([
      [{ value: 1 }, { value: null }],
      [{ value: 2, x: undefined, z: undefined, color: undefined, label: undefined }]
    ]);
  });
});

describe('seriesColor', () => {
  it('follows the index in the array it was passed, not a position among the visible', () => {
    // Which is what stops filtering a legend repainting the survivors.
    expect(seriesColor(undefined, 0)).toBe(seriesColor(undefined, 0));
    expect(seriesColor(undefined, 1)).not.toBe(seriesColor(undefined, 0));
  });

  it('hands the eight slots out in order', () => {
    // The order is what makes the *adjacent* pairs the ones checked for
    // colour-vision separation, so it is not an implementation detail.
    const first = chartPalette.map((_, index) => seriesColor(undefined, index));

    expect(new Set(first).size).toBe(chartPalette.length);
  });

  it('lets a series name its own colour', () => {
    expect(seriesColor({ color: 'rebeccapurple' }, 3)).toBe('rebeccapurple');
  });
});

describe('linePath', () => {
  const points = [
    { x: 0, y: 10 },
    { x: 10, y: 20 },
    { x: 20, y: 30 }
  ];

  it('draws one run through every point', () => {
    expect(linePath(points, 'linear')).toBe('M0 10L10 20L20 30');
  });

  it('breaks at a gap instead of drawing through it', () => {
    const path = linePath([points[0], null, points[2]], 'linear');

    // Two `M`s means two runs, which is what a break is.
    expect(path.match(/M/g)).toHaveLength(2);
  });

  it('draws a lone point between two gaps as a zero-length stroke', () => {
    // A round cap renders that as the dot it is. Nothing at all would lose the
    // reading entirely.
    expect(linePath([null, points[1], null], 'linear')).toBe('M10 20h0');
  });

  it('draws nothing at all when every point is a gap', () => {
    expect(linePath([null, null], 'linear')).toBe('');
    expect(linePath([], 'linear')).toBe('');
  });

  it('steps between points rather than sloping', () => {
    expect(linePath(points.slice(0, 2), 'step')).toBe('M0 10H5V20H10');
  });

  it('smooths without leaving the points it was given', () => {
    const path = linePath(points, 'smooth');

    expect(path.startsWith('M0 10')).toBe(true);
    expect(path).toContain('C');
  });
});

describe('bandScale', () => {
  it('centres a category in its own slot', () => {
    const band = bandScale(4, 400, 1);

    expect(band.step).toBe(100);
    expect(band.centre(0)).toBe(50);
    expect(band.centre(3)).toBe(350);
  });

  it('survives being asked for no categories', () => {
    expect(Number.isFinite(bandScale(0, 400, 1).step)).toBe(true);
  });

  it('narrows the marks against the slot by the ratio', () => {
    expect(bandScale(4, 400, 0.5).band).toBeLessThan(bandScale(4, 400, 1).band);
  });
});

describe('tickStride', () => {
  it('labels every category when they all fit', () => {
    expect(tickStride(4, 400, 40)).toBe(1);
  });

  it('skips enough of them to fit the rest', () => {
    expect(tickStride(40, 400, 40)).toBeGreaterThan(1);
  });

  it('never returns a stride of zero, whatever it is asked', () => {
    // A stride of zero is an infinite loop in whichever caller walks it.
    expect(tickStride(0, 0, 0)).toBe(1);
    expect(tickStride(100, -10, 0)).toBe(1);
  });
});

describe('truncate', () => {
  it('leaves a label that fits alone', () => {
    expect(truncate('Jan', 200, 12)).toBe('Jan');
  });

  it('cuts a label that does not, and marks the cut', () => {
    const cut = truncate('September 2026', 30, 12);

    expect(cut.endsWith('…')).toBe(true);
    expect(cut.length).toBeLessThan('September 2026'.length);
  });

  it('answers with the mark alone rather than nothing when there is no room', () => {
    expect(truncate('September', 1, 12)).toBe('…');
  });

  it('leaves the label alone when there is no width to fit it to', () => {
    expect(truncate('September', 0, 12)).toBe('September');
  });
});

describe('bubbleRadius', () => {
  it('scales by area rather than by radius', () => {
    // Four times the value is twice the radius, which is what makes two bubbles
    // read as the ratio they are.
    expect(bubbleRadius(100, 100, 20, 2)).toBeCloseTo(20, 10);
    expect(bubbleRadius(25, 100, 20, 2)).toBeCloseTo(10, 10);
  });

  it('keeps a small-but-real value findable, and lets a zero disappear', () => {
    expect(bubbleRadius(0.0001, 100, 20, 2)).toBe(2);
    expect(bubbleRadius(0, 100, 20, 2)).toBe(0);
  });

  it('answers a number when there is no largest value to scale against', () => {
    expect(bubbleRadius(5, 0, 20, 2)).toBe(2);
    expect(Number.isNaN(bubbleRadius(5, 0, 20, 2))).toBe(false);
  });
});

describe('arcPath', () => {
  it('draws a full circle as two arcs rather than one', () => {
    // Start and end are the same point on a single arc, and a renderer draws
    // nothing at all for it.
    const path = arcPath(50, 50, 40, 0, 0, 360);

    expect(path.match(/A/g)?.length).toBeGreaterThanOrEqual(2);
    expect(path).not.toContain('NaN');
  });

  it('draws a ring as two rings when there is a hole in it', () => {
    const ring = arcPath(50, 50, 40, 20, 0, 360);

    expect(ring.match(/M/g)).toHaveLength(2);
  });

  it('draws an ordinary slice without a NaN in it', () => {
    expect(arcPath(50, 50, 40, 0, 0, 90)).not.toContain('NaN');
    expect(arcPath(50, 50, 40, 20, 90, 200)).not.toContain('NaN');
  });
});

describe('ringPath', () => {
  /**
   * The open half of the pair, and the reason it exists: a stroked line has a
   * `stroke-dashoffset`, which is a number CSS can travel along, where a closed
   * wedge only has a `d`, which is not.
   */
  it('leaves the path open, so it can be stroked rather than filled', () => {
    const path = ringPath(50, 50, 30, -90, 90);

    expect(path).not.toContain('Z');
    expect(path.match(/M/g)).toHaveLength(1);
    expect(path).not.toContain('NaN');
  });

  it('draws a full circle as two arcs rather than one', () => {
    const path = ringPath(50, 50, 30, 0, 360);

    expect(path.match(/A/g)).toHaveLength(2);
    expect(path).not.toContain('NaN');
  });

  it('flags a span over a half turn as the long way round', () => {
    expect(ringPath(50, 50, 30, -135, 135)).toContain('0 1 1');
    expect(ringPath(50, 50, 30, -45, 45)).toContain('0 0 1');
  });

  it('starts at twelve o\u2019clock, not at three', () => {
    // A zero-degree point sits directly above the centre.
    expect(ringPath(50, 50, 30, 0, 90).startsWith('M50 20')).toBe(true);
  });
});

describe('labelledPoints', () => {
  const series = (...values: (number | null)[]) => values.map((value) => ({ value }));
  const chosen = (test: (index: number) => boolean, length: number) =>
    Array.from({ length }, (_, index) => index).filter(test);

  it('names the high and the low, every time either value appears', () => {
    const one = series(3, 9, 1, 9, null, 1);

    expect(chosen(labelledPoints(one, 'extremes'), one.length)).toEqual([1, 2, 3, 5]);
  });

  it('names nothing in a series that is all gaps', () => {
    const one = series(null, null);

    expect(chosen(labelledPoints(one, 'extremes'), one.length)).toEqual([]);
  });

  it('takes the last value that exists rather than the last slot', () => {
    const one = series(4, 7, null);

    expect(chosen(labelledPoints(one, 'last'), one.length)).toEqual([1]);
  });

  it('names every point with all', () => {
    expect(chosen(labelledPoints(series(1, null, 3), 'all'), 3)).toEqual([0, 1, 2]);
  });
});

describe('toFullShares', () => {
  const format = (value: number) => value.toFixed(1);

  it('shares each category out of a hundred and keeps the original as the label', () => {
    const [a, b] = toFullShares([[{ value: 1 }], [{ value: 3 }]], [true, true], format);

    expect(a[0]).toEqual({ value: 25, label: '1.0' });
    expect(b[0]).toEqual({ value: 75, label: '3.0' });
  });

  // A hidden series counted towards the total, so what was left stopped short.
  it('leaves a hidden series out of the total', () => {
    const [a] = toFullShares([[{ value: 1 }], [{ value: 3 }]], [true, false], format);

    expect(a[0].value).toBe(100);
  });

  it('keeps a gap a gap and a label the caller wrote', () => {
    const [a, b] = toFullShares(
      [[{ value: null }], [{ value: 2, label: 'two' }]],
      [true, true],
      format
    );

    expect(a[0].value).toBeNull();
    expect(b[0]).toEqual({ value: 100, label: 'two' });
  });
});
