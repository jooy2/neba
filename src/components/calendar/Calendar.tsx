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
  startOfMonth,
  startOfUnit,
  today
} from '../../internal/date.js';
import { cx, radiusClasses, surfaceSlots } from '../../internal/styles.js';
import type {
  NebaColor,
  NebaDateGranularity,
  NebaElevation,
  NebaSize,
  NebaWeekday
} from '../../types.js';

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
export const Calendar = React.forwardRef<HTMLDivElement, CalendarProps>(function Calendar(
  {
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
  }: CalendarProps,
  ref
) {
  const pickerLabels = usePickerLabels(labelOverrides);
  const firstDay = weekStartsOn ?? localeWeekStart(locale);

  const [uncontrolledValue, setUncontrolledValue] = React.useState(
    () => defaultValue ?? EMPTY[mode]
  );
  // `null` is a value a controlled calendar legitimately holds — an emptied
  // one — so the test is against `undefined` and never against falsiness.
  const value = valueProp !== undefined ? valueProp : uncontrolledValue;

  const firstChosen = chosenDays(mode, value).find(isValidDate);

  const [uncontrolledMonth, setUncontrolledMonth] = React.useState(() =>
    startOfMonth(firstChosen ?? defaultMonth ?? today())
  );
  const month = monthProp ?? uncontrolledMonth;

  const setMonth = (next: Date) => {
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
        bordered && 'border p-3 [border-color:var(--n-line)] bg-(--n-panel-press)',
        bordered && radiusClasses[size],
        className
      )}
      style={{ ...surfaceSlots(color, elevation), ...style }}
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
        labels={pickerLabels}
      />
    </div>
  );
});
