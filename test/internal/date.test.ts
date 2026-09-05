/**
 * The calendar arithmetic the three pickers share.
 *
 * Every comparison in `internal/date.ts` is on the local year/month/day triple
 * rather than on `getTime()`, and the reason is the case a rendered picker
 * almost never shows you: two `Date`s that are the same calendar day differ by
 * milliseconds far more often than not — a value carrying a time of day, a
 * `min` built at noon — and every one of those comparisons has to come out
 * true.
 *
 * The other cases here are the ones a month grid gets wrong: the 31st stepped
 * into a month that has no 31st, a leap February, and a range whose ends have
 * not both been chosen yet.
 */
import { describe, expect, it } from 'vitest';
import {
  addDays,
  addMonths,
  addYears,
  calendarWeeks,
  clampDate,
  compareDay,
  daysInMonth,
  isDayInRange,
  isDayOutside,
  isSameDay,
  isSameMonth,
  isUnitOutside,
  isValidDate,
  localeWeekStart,
  makeDate,
  minutesOfDay,
  startOfDay,
  startOfMonth,
  startOfUnit,
  endOfUnit,
  toISODate,
  toISOMonth,
  toISOYear,
  yearPageStart
} from '../../src/internal/date.js';

describe('makeDate and isValidDate', () => {
  it('builds a local date at midnight', () => {
    const date = makeDate(2026, 1, 15);

    expect(date.getFullYear()).toBe(2026);
    expect(date.getMonth()).toBe(1);
    expect(date.getDate()).toBe(15);
    expect(date.getHours()).toBe(0);
  });

  it('knows a date from something that only looks like one', () => {
    expect(isValidDate(makeDate(2026, 0, 1))).toBe(true);
    expect(isValidDate(new Date('nonsense'))).toBe(false);
    expect(isValidDate(null)).toBe(false);
    expect(isValidDate('2026-01-01')).toBe(false);
  });

  it('builds a year under a hundred as that year, not as nineteen-hundred-and-it', () => {
    // `new Date(26, 0, 1)` is 1926. A calendar that can be walked back that far
    // has to be able to say so.
    expect(makeDate(26, 0, 1).getFullYear()).toBe(26);
  });
});

describe('daysInMonth', () => {
  it('counts the ordinary months', () => {
    expect(daysInMonth(2026, 0)).toBe(31);
    expect(daysInMonth(2026, 3)).toBe(30);
  });

  it('counts February in a leap year and out of one', () => {
    expect(daysInMonth(2026, 1)).toBe(28);
    expect(daysInMonth(2024, 1)).toBe(29);
    expect(daysInMonth(2000, 1)).toBe(29);
    expect(daysInMonth(1900, 1)).toBe(28);
  });
});

describe('stepping', () => {
  it('adds days across a month boundary', () => {
    expect(toISODate(addDays(makeDate(2026, 0, 30), 3))).toBe('2026-02-02');
  });

  it('does not let the 31st overflow into the month after next', () => {
    // The bug every hand-rolled month step has: `setMonth` on the 31st of
    // January lands in March.
    expect(toISODate(addMonths(makeDate(2026, 0, 31), 1))).toBe('2026-02-28');
    expect(toISODate(addMonths(makeDate(2024, 0, 31), 1))).toBe('2024-02-29');
  });

  it('steps backwards the same way', () => {
    expect(toISODate(addMonths(makeDate(2026, 2, 31), -1))).toBe('2026-02-28');
  });

  it('steps a leap day into a year that has none', () => {
    expect(toISODate(addYears(makeDate(2024, 1, 29), 1))).toBe('2025-02-28');
  });

  it('keeps the time of day it was given', () => {
    const noon = new Date(2026, 0, 31, 12, 30);

    expect(addMonths(noon, 1).getHours()).toBe(12);
    expect(addMonths(noon, 1).getMinutes()).toBe(30);
  });
});

describe('comparison', () => {
  const morning = new Date(2026, 5, 10, 9, 0);
  const evening = new Date(2026, 5, 10, 21, 45);

  it('calls two times on one day the same day', () => {
    // The whole reason the comparisons are on the triple and not on `getTime`.
    expect(isSameDay(morning, evening)).toBe(true);
    expect(compareDay(morning, evening)).toBe(0);
  });

  it('answers false rather than throwing for a date that is not one', () => {
    expect(isSameDay(morning, null)).toBe(false);
    expect(isSameDay(undefined, undefined)).toBe(false);
    expect(isSameMonth(morning, null)).toBe(false);
  });

  it('compares months without regard to the day', () => {
    expect(isSameMonth(makeDate(2026, 5, 1), makeDate(2026, 5, 30))).toBe(true);
    expect(isSameMonth(makeDate(2026, 5, 1), makeDate(2025, 5, 1))).toBe(false);
  });

  it('takes the start of a day and a month back to midnight and the first', () => {
    expect(startOfDay(evening).getHours()).toBe(0);
    expect(startOfMonth(evening).getDate()).toBe(1);
    expect(startOfMonth(evening).getHours()).toBe(0);
  });
});

describe('bounds', () => {
  const min = new Date(2026, 5, 10, 12, 0);
  const max = new Date(2026, 5, 20, 12, 0);

  it('holds a date inside the two ends', () => {
    expect(toISODate(clampDate(makeDate(2026, 5, 1), min, max))).toBe('2026-06-10');
    expect(toISODate(clampDate(makeDate(2026, 5, 25), min, max))).toBe('2026-06-20');
    expect(toISODate(clampDate(makeDate(2026, 5, 15), min, max))).toBe('2026-06-15');
  });

  it('leaves a date alone when there are no ends', () => {
    const date = makeDate(2026, 5, 15);

    expect(clampDate(date).getTime()).toBe(date.getTime());
    expect(clampDate(date, null, null).getTime()).toBe(date.getTime());
  });

  it('leaves the boundary day pickable, whatever time of day the bound carries', () => {
    // A `maxDate` of the 20th at noon still leaves the 20th selectable: the
    // bound is about which days exist, and the time is the time picker's.
    expect(isDayOutside(makeDate(2026, 5, 20), min, max)).toBe(false);
    expect(isDayOutside(makeDate(2026, 5, 10), min, max)).toBe(false);
    expect(isDayOutside(makeDate(2026, 5, 21), min, max)).toBe(true);
    expect(isDayOutside(makeDate(2026, 5, 9), min, max)).toBe(true);
  });

  it('holds nothing inside a range that has only one end', () => {
    // A range half-chosen is not a range, and shading everything after the
    // first click is the thing that reads as broken.
    expect(isDayInRange(makeDate(2026, 5, 15), min, null)).toBe(false);
    expect(isDayInRange(makeDate(2026, 5, 15), null, max)).toBe(false);
  });

  it('leaves the two ends outside the run between them', () => {
    expect(isDayInRange(makeDate(2026, 5, 10), min, max)).toBe(false);
    expect(isDayInRange(makeDate(2026, 5, 15), min, max)).toBe(true);
  });
});

/**
 * The same comparisons one unit up. A picker whose granularity is `month` reports
 * March for the March cell, so a bound has to be checked against the span that
 * cell stands for rather than against one instant inside it — otherwise a
 * minimum of 15 March takes March away and the value it names becomes
 * unreachable.
 */
describe('units', () => {
  // The same two bounds the day-granular block uses, both carrying a time of
  // day: what changes below is only the unit they are read at.
  const min = new Date(2026, 5, 10, 12, 0);
  const max = new Date(2026, 5, 20, 12, 0);

  it('takes the first and last instant of the unit', () => {
    const date = new Date(2026, 1, 15, 13, 45);

    expect(toISODate(startOfUnit(date, 'day'))).toBe('2026-02-15');
    expect(toISODate(startOfUnit(date, 'month'))).toBe('2026-02-01');
    expect(toISODate(startOfUnit(date, 'year'))).toBe('2026-01-01');

    expect(toISODate(endOfUnit(date, 'day'))).toBe('2026-02-15');
    expect(toISODate(endOfUnit(date, 'year'))).toBe('2026-12-31');
  });

  it('ends a month on its own last day, February included', () => {
    expect(toISODate(endOfUnit(makeDate(2026, 1, 5), 'month'))).toBe('2026-02-28');
    expect(toISODate(endOfUnit(makeDate(2024, 1, 5), 'month'))).toBe('2024-02-29');
  });

  it('drops the clock the way startOfDay does', () => {
    expect(startOfUnit(new Date(2026, 1, 15, 13, 45), 'day').getHours()).toBe(0);
    expect(endOfUnit(new Date(2026, 1, 15, 13, 45), 'month').getHours()).toBe(0);
  });

  it('is isDayOutside exactly, at day granularity', () => {
    for (const day of [9, 10, 15, 20, 21]) {
      const date = makeDate(2026, 5, day);
      expect(isUnitOutside(date, 'day', min, max)).toBe(isDayOutside(date, min, max));
    }
  });

  it('keeps a unit the bound falls inside', () => {
    // June is where both bounds are, so June is reachable at either coarser
    // unit — it just starts late and ends early.
    expect(isUnitOutside(makeDate(2026, 5, 1), 'month', min, max)).toBe(false);
    expect(isUnitOutside(makeDate(2026, 5, 30), 'month', min, max)).toBe(false);
    expect(isUnitOutside(makeDate(2026, 0, 1), 'year', min, max)).toBe(false);
  });

  it('drops a unit with no allowed day left in it', () => {
    expect(isUnitOutside(makeDate(2026, 4, 31), 'month', min, max)).toBe(true);
    expect(isUnitOutside(makeDate(2026, 6, 1), 'month', min, max)).toBe(true);
    expect(isUnitOutside(makeDate(2025, 11, 31), 'year', min, max)).toBe(true);
    expect(isUnitOutside(makeDate(2027, 0, 1), 'year', min, max)).toBe(true);
  });

  it('writes the unit rather than inventing the parts below it', () => {
    const date = new Date(2026, 6, 27, 13, 45);

    expect(toISOMonth(date)).toBe('2026-07');
    expect(toISOYear(date)).toBe('2026');
    expect(toISOMonth(makeDate(2026, 0, 5))).toBe('2026-01');
  });
});

describe('calendarWeeks', () => {
  it('lays a month out in whole weeks, starting where it was told', () => {
    const weeks = calendarWeeks(makeDate(2026, 1, 1), 1);

    expect(weeks.every((week) => week.length === 7)).toBe(true);
    expect(weeks[0][0].getDay()).toBe(1);
  });

  it('starts on Sunday when asked to', () => {
    expect(calendarWeeks(makeDate(2026, 1, 1), 0)[0][0].getDay()).toBe(0);
  });

  it('holds every day of the month somewhere in the grid', () => {
    const days = calendarWeeks(makeDate(2026, 0, 1), 1)
      .flat()
      .filter((day) => day.getMonth() === 0)
      .map((day) => day.getDate());

    expect(days).toEqual(Array.from({ length: 31 }, (_, index) => index + 1));
  });
});

describe('minutesOfDay and yearPageStart', () => {
  it('counts minutes from local midnight', () => {
    expect(minutesOfDay(new Date(2026, 0, 1, 9, 30))).toBe(570);
    expect(minutesOfDay(new Date(2026, 0, 1, 0, 0))).toBe(0);
  });

  it('puts a year on a page that always starts in the same place', () => {
    // A page of years is a grid, and a grid whose first cell moved with
    // whichever year you arrived from would shuffle under every step. So the
    // start is a fixed multiple of the page, and the year is always on it.
    const size = yearPageStart(2026 + 1) - yearPageStart(2026) || 12;

    expect(yearPageStart(2026) % size).toBe(0);
    expect(yearPageStart(2026)).toBeLessThanOrEqual(2026);
    expect(yearPageStart(2026) + size).toBeGreaterThan(2026);
    // Two years on one page answer with the same first cell.
    expect(yearPageStart(2026)).toBe(yearPageStart(yearPageStart(2026)));
  });

  it('walks back through the pages without a gap or an overlap', () => {
    const here = yearPageStart(2026);
    const size = 12;

    expect(yearPageStart(here - 1)).toBe(here - size);
    expect(yearPageStart(here + size)).toBe(here + size);
  });
});

/**
 * The answer is a property of the tag and is memoised on it, so the second call
 * has to agree with the first — and an unparseable tag has to come back as
 * Sunday rather than throw, because a calendar that renders on the wrong day is
 * a small annoyance and one that renders nothing is not.
 */
describe('localeWeekStart', () => {
  it('reads the first day out of the tag', () => {
    expect(localeWeekStart('en-US')).toBe(0);
    expect(localeWeekStart('de-DE')).toBe(1);
  });

  it('gives the same answer the second time', () => {
    expect(localeWeekStart('fr-FR')).toBe(localeWeekStart('fr-FR'));
    expect(localeWeekStart(undefined)).toBe(localeWeekStart(undefined));
  });

  it('falls back to Sunday on a tag it cannot parse', () => {
    expect(localeWeekStart('not a locale')).toBe(0);
  });
});
