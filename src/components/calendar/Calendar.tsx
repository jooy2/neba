'use client';

import * as React from 'react';
import {
  Calendar as CalendarGrid,
  usePickerLabels,
  type PickerLabels
} from '../../internal/calendar.js';
import {
  compareDay,
  isSameDay,
  isValidDate,
  localeWeekStart,
  makeDate,
  startOfMonth,
  startOfUnit,
  toISOMonth,
  toMonthOf,
  today
} from '../../internal/date.js';
import { popupPaddingClasses } from '../../internal/picker.js';
import { cx, radiusClasses, surfaceClasses, surfaceSlots } from '../../internal/styles.js';
import type {
  NebaColor,
  NebaDateGranularity,
  NebaElevation,
  NebaSize,
  NebaWeekday
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { useHydrated, useIntlLocale } from '../../internal/media.js';

/** Both ends of a span. Either may be missing while one is being chosen. */
export interface CalendarRange {
  start: Date | null;
  end: Date | null;
}

/** How many days the reader may be holding at once. */
export type CalendarMode = 'single' | 'multiple' | 'range';

/** What the value is, for each of the three. */
export interface CalendarValueByMode {
  single: Date | null;
  multiple: Date[];
  range: CalendarRange;
}

interface CalendarBaseProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'defaultValue' | 'onSelect'
> {
  size?: NebaSize;
  color?: NebaColor;
  /** Drop shadow depth. `0` is flat — a calendar in a page is not floating. */
  elevation?: NebaElevation;
  /** Draws the sheet the picker's popup draws. `false` for the bare grid. */
  bordered?: boolean;
  /** The month on screen. Use with `onMonthChange` to control it. */
  month?: Date;
  /** Which month it opens on. @default the month of the value, or this one */
  defaultMonth?: Date;
  onMonthChange?: (month: Date) => void;
  /** Which unit a click chooses: a day, a whole month, a whole year. */
  granularity?: NebaDateGranularity;
  minDate?: Date | null;
  maxDate?: Date | null;
  /** Blocks cells inside the range. Handed the value that cell would produce. */
  shouldDisableDate?: (date: Date) => boolean;
  /** BCP 47 tag deciding the month and weekday names and the header's order. */
  locale?: string;
  weekStartsOn?: NebaWeekday;
  /** Draws the leading and trailing days of the neighbouring months. */
  showOutsideDays?: boolean;
  /** What a day cell draws under its number — a dot, a count, a bar. */
  renderDay?: (date: Date) => React.ReactNode;
  /** The strings a screen reader hears. Every one has an English default. */
  labels?: Partial<PickerLabels>;
}

interface ModeProps<Mode extends CalendarMode> {
  mode?: Mode;
  value?: CalendarValueByMode[Mode] | null;
  defaultValue?: CalendarValueByMode[Mode] | null;
  onValueChange?: (value: CalendarValueByMode[Mode]) => void;
}

export type CalendarProps = CalendarBaseProps &
  (ModeProps<'single'> | ModeProps<'multiple'> | ModeProps<'range'>);

/** Nothing chosen, per mode — so an uncontrolled calendar starts somewhere real. */
const EMPTY: { [Mode in CalendarMode]: CalendarValueByMode[Mode] } = {
  single: null,
  multiple: [],
  range: { start: null, end: null }
};

/** The days a mode's value lights up, flattened for the grid. */
function chosenDays(mode: CalendarMode, value: unknown): Array<Date | null | undefined> {
  if (mode === 'multiple') {
    return (value as Date[] | null) ?? [];
  }
  if (mode === 'range') {
    const range = (value as CalendarRange | null) ?? EMPTY.range;
    return [range.start, range.end];
  }
  return [value as Date | null];
}

/**
 * The month a server drew into the calendar `id` names, read back out of the
 * page while that HTML is being hydrated. `null` where there is no page or no
 * such calendar in it.
 */
function drawnMonth(id: string): Date | null {
  if (typeof document === 'undefined') {
    return null;
  }

  const written = document
    .querySelector(`[data-neba-calendar="${CSS.escape(id)}"]`)
    ?.getAttribute('data-month');
  const parts = written ? /^(\d{4,})-(\d{2})$/.exec(written) : null;

  return parts ? makeDate(Number(parts[1]), Number(parts[2]) - 1, 1) : null;
}

/**
 * A month, inline, with the days it is holding lit up.
 *
 * The same grid the four pickers open, without a popup around it. It has been
 * in `internal/` since the first picker shipped, and keeping it there meant a
 * page that wanted a month on it — a booking sheet, a schedule, a filter that
 * is always visible — had to open a DatePicker and never close it.
 *
 * What it is *not* is a scheduler. The cells are the control ladder's heights,
 * so `renderDay` is room for a dot, a count or a bar under the number, and not
 * for a day's worth of entries. A component that drew those would be a
 * different component with a different grid, and calling this one that would be
 * a promise the sizes cannot keep.
 *
 * `mode` decides what the value is: one day, an array of them, or a
 * `{ start, end }` span. Range mode fills the near end first and then the far
 * one, and a click below the start begins again rather than inverting the span
 * — inverting is the behaviour that makes a reader believe they mis-clicked.
 */
export const Calendar = React.forwardRef<HTMLDivElement, CalendarProps>(
  function Calendar(rawProps, ref) {
    const {
      mode = 'single',
      value: valueProp,
      defaultValue,
      onValueChange,
      size = 'md',
      color = 'primary',
      elevation = 0,
      bordered = true,
      month: monthProp,
      defaultMonth,
      onMonthChange,
      granularity = 'day',
      minDate,
      maxDate,
      shouldDisableDate,
      locale,
      weekStartsOn,
      showOutsideDays = true,
      renderDay,
      labels: labelOverrides,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'locale']);

    const pickerLabels = usePickerLabels(labelOverrides, locale);
    const intlLocale = useIntlLocale(locale);
    const firstDay = weekStartsOn ?? localeWeekStart(intlLocale);

    const [uncontrolledValue, setUncontrolledValue] = React.useState(
      () => defaultValue ?? EMPTY[mode]
    );
    // `null` is a value a controlled calendar legitimately holds — an emptied
    // one — so the test is against `undefined` and never against falsiness.
    const value = valueProp !== undefined ? valueProp : uncontrolledValue;

    const firstChosen = chosenDays(mode, value).find(isValidDate);

    /*
     * The month a calendar opens on when nothing says which: this one, by the
     * clock of whatever is rendering it.
     *
     * A server's clock and a reader's are not in the same month for long: a
     * page built at the end of one month and served into the next drew last
     * month's grid, the browser hydrated this month's, and React threw the
     * server's HTML away for every visitor. So the root carries the month it
     * drew, under an id `useId` gives the server and the hydrating render
     * alike, and the hydrating render reads it back out of the page instead of
     * asking its own clock. Once hydration is over, the effect below moves a
     * calendar nobody has touched on to the reader's month, which is what the
     * today marks in the grid wait for too. A calendar mounted in the browser
     * reads the clock straight away, as it always did.
     */
    const hydrated = useHydrated();
    const calendarId = React.useId();

    const [uncontrolledMonth, setUncontrolledMonth] = React.useState(() =>
      startOfMonth(
        firstChosen ?? defaultMonth ?? (hydrated ? null : drawnMonth(calendarId)) ?? today()
      )
    );
    const month = monthProp ?? uncontrolledMonth;

    // Whether the month came from the clock during hydration, and whether the
    // reader has moved it since. A value, `defaultMonth` or `month` is a month
    // the caller chose, and it is the same on both sides.
    const waitingForClock = React.useRef(
      !hydrated &&
        firstChosen === undefined &&
        defaultMonth === undefined &&
        monthProp === undefined
    );
    const moved = React.useRef(false);

    React.useEffect(() => {
      if (!hydrated || !waitingForClock.current) {
        return;
      }
      waitingForClock.current = false;

      if (!moved.current) {
        // Not reported through `onMonthChange`. The reader moved nothing, and
        // this is the month the calendar opens on in their browser.
        setUncontrolledMonth(toMonthOf(today()));
      }
      // Once, on the render hydration ends.
    }, [hydrated]);

    const setMonth = (next: Date) => {
      moved.current = true;
      if (monthProp === undefined) {
        setUncontrolledMonth(next);
      }
      onMonthChange?.(next);
    };

    const commit = (next: unknown) => {
      if (valueProp === undefined) {
        setUncontrolledValue(next as never);
      }
      (onValueChange as ((value: unknown) => void) | undefined)?.(next);
    };

    const select = (date: Date) => {
      const unit = startOfUnit(date, granularity);

      if (mode === 'multiple') {
        const held = (value as Date[] | null) ?? [];
        const without = held.filter((entry) => !isSameDay(entry, unit));

        // Clicking a day that is already held takes it back out, which is the
        // only way a multiple calendar can be undone with the pointer.
        commit(without.length === held.length ? [...held, unit] : without);
        return;
      }

      if (mode === 'range') {
        const range = (value as CalendarRange | null) ?? EMPTY.range;

        // A span in progress is one with a start and no end. Anything else — a
        // finished span, an empty one — starts a new one.
        if (!isValidDate(range.start) || isValidDate(range.end)) {
          commit({ start: unit, end: null });
          return;
        }
        // Below the start is a new start rather than an inverted span: inverting
        // is what makes a reader think they mis-clicked.
        commit(
          compareDay(unit, range.start) < 0
            ? { start: unit, end: null }
            : { start: range.start, end: unit }
        );
        return;
      }

      commit(unit);
    };

    const range = mode === 'range' ? ((value as CalendarRange | null) ?? EMPTY.range) : EMPTY.range;

    return (
      <div
        ref={ref}
        className={cx(
          'inline-block',
          // The popup's own sheet — its glass edge and its padding per size — so
          // a calendar on a page and one in a picker are the same object. The
          // shadow is `elevation`'s, read from the slot every surface writes;
          // nothing read it before, so the prop drew nothing.
          bordered
            ? cx(
                surfaceClasses,
                'border bg-(--n-panel-press) [border-color:var(--n-line)]',
                '[box-shadow:var(--n-elev),var(--neba-plate-glass)]',
                radiusClasses[size],
                popupPaddingClasses[size]
              )
            : '[box-shadow:var(--n-elev)]',
          className
        )}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        data-neba-calendar={calendarId}
        data-month={toISOMonth(month)}
        {...props}
      >
        <CalendarGrid
          size={size}
          color={color}
          locale={locale}
          weekStartsOn={firstDay}
          month={month}
          onMonthChange={setMonth}
          selected={chosenDays(mode, value)}
          rangeStart={range.start}
          rangeEnd={range.end}
          onSelect={select}
          granularity={granularity}
          minDate={minDate}
          maxDate={maxDate}
          shouldDisableDate={shouldDisableDate}
          showOutsideDays={showOutsideDays}
          renderDay={renderDay}
          multiselectable={mode !== 'single'}
          labels={pickerLabels}
        />
      </div>
    );
  }
);
