'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { Calendar, usePickerLabels, type PickerLabels } from '../../internal/calendar.js';
import { CalendarIcon } from '../../internal/icons.js';
import { PickerFooter, PickerShell, type PickerShellProps } from '../../internal/picker.js';
import {
  displaySamples,
  formatDate,
  isUnitOutside,
  isValidDate,
  localeWeekStart,
  mergeDateAndTime,
  startOfMonth,
  startOfUnit,
  toISODate,
  toISOMonth,
  toISOYear,
  today,
  withPlaceholder
} from '../../internal/date.js';
import { cx } from '../../internal/styles.js';
import type { NebaDateGranularity, NebaWeekday } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * How the trigger writes a value the caller has not given a `format` for.
 *
 * Not one default with the coarser cases left to the caller: `dateStyle:
 * 'medium'` on a month picker prints `Mar 1, 2026`, and a control that reports
 * a whole month by naming a day inside it is lying in the one place a reader
 * actually looks. The day row is the historical default, unchanged.
 */
const defaultFormats: Record<NebaDateGranularity, Intl.DateTimeFormatOptions> = {
  day: { dateStyle: 'medium' },
  month: { year: 'numeric', month: 'long' },
  year: { year: 'numeric' }
};

/**
 * And how the hidden input spells it — the shapes `<input type="date">` and
 * `<input type="month">` submit. A year has no native input to copy, so it is
 * the bare `YYYY` those two already start with.
 */
const isoWriters: Record<NebaDateGranularity, (date: Date) => string> = {
  day: toISODate,
  month: toISOMonth,
  year: toISOYear
};

/**
 * What the four pickers agree on, so a caller who has learned one has learned
 * the others. Spelled out here rather than in `internal/` because these are the
 * props a reader of the docs is actually looking at.
 */
export interface DatePickerProps extends PickerShellProps {
  /** The chosen day. Use with `onValueChange` for a controlled picker. */
  value?: Date | null;
  /** The day the picker starts on, for an uncontrolled one. */
  defaultValue?: Date | null;
  onValueChange?: (value: Date | null) => void;
  /** Whether the calendar is open. Use with `onOpenChange` to control it. */
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Which unit the picker asks for: a day, a whole month, or a whole year.
   *
   * At `month` and `year` the calendar opens on that grid and stops there, and
   * the value is the first day of what was chosen — 1 March, 1 January. The
   * grid above is still reachable, so a year picker is one control and a month
   * picker is still two clicks from any month of any year.
   *
   * Everything else follows it: the trigger's default `format`, what the
   * footer's shortcut says, how `name` submits, and the unit `minDate`,
   * `maxDate` and `shouldDisableDate` are read at.
   * @default 'day'
   */
  granularity?: NebaDateGranularity;
  /** Which month the calendar opens on when there is no value. @default this one */
  defaultMonth?: Date;
  /**
   * The earliest date that may be chosen, compared at `granularity`. A minimum
   * of 15 March leaves the 14th out at `day` and leaves March in at `month`:
   * the cell stands for the whole month, and part of that month is allowed.
   */
  minDate?: Date | null;
  /** The latest date that may be chosen, read the same way. */
  maxDate?: Date | null;
  /**
   * Blocks individual cells that are inside the range but still not available —
   * weekends, holidays, a room that is already booked. Called with the value
   * that cell would produce, so at `month` it is handed the 1st.
   */
  shouldDisableDate?: (date: Date) => boolean;
  /**
   * BCP 47 tag deciding the month and weekday names, the order of the header's
   * two buttons, and how the trigger writes the date. Defaults to the browser's.
   */
  locale?: string;
  /** Which day the week starts on. Defaults to whatever the locale says. */
  weekStartsOn?: NebaWeekday;
  /**
   * How the trigger writes the chosen date. Passed straight to `Intl`, so
   * `{ dateStyle: 'full' }` and `{ year: '2-digit', month: 'narrow' }` both work.
   * Defaults to what `granularity` asked for — a medium date, a month and a
   * year, or a bare year.
   */
  format?: Intl.DateTimeFormatOptions;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /**
   * Offers the shortcut to the current unit in the footer — today, this month
   * or this year, whichever `granularity` is asking for. @default true
   */
  showTodayButton?: boolean;
  /** Closes the popup as soon as a day is chosen. @default true */
  closeOnSelect?: boolean;
  /** The strings a screen reader hears. Every one has an English default. */
  labels?: Partial<PickerLabels>;
  /**
   * Identifies the field when a form is submitted. The value is written at
   * `granularity` — `YYYY-MM-DD`, `YYYY-MM` or `YYYY` — so a month is never
   * submitted as a day nobody chose.
   */
  name?: string;
}

/**
 * One day, chosen from a calendar.
 *
 * The trigger is a TextField's shell wearing a calendar glyph, on purpose and
 * for the reason Select's is: a form where the date field is a different height,
 * radius or colour from the fields around it is a form that looks assembled.
 *
 * What the calendar is actually for is the header. A picker that only steps a
 * month at a time puts a birthday thirty years back a hundred and eighty clicks
 * away, so the month name and the year are each a button that opens a grid of
 * its own — twelve months, then twelve years at a time. Any month of the year on
 * screen is two clicks; any year at all is three.
 *
 * `granularity` turns that header into the answer. A month picker opens on the
 * grid of twelve months and stops there; a year picker opens on the years. The
 * value stays a `Date` — the 1st of what was chosen — because a second value
 * type would mean a second set of props to compare it with.
 *
 * There is no typing into the trigger. Parsing a date out of free text is
 * locale-dependent in a way that cannot be done honestly without a date library,
 * and a field that understands `27/7/26` in one browser and not in the next is
 * worse than one that never claimed to.
 */
export const DatePicker = React.forwardRef<HTMLButtonElement, DatePickerProps>(
  function DatePicker(rawProps, ref) {
    const {
      value: valueProp,
      defaultValue,
      onValueChange,
      open: openProp,
      defaultOpen,
      onOpenChange,
      granularity = 'day',
      defaultMonth,
      minDate,
      maxDate,
      shouldDisableDate,
      locale,
      weekStartsOn,
      format,
      placeholder,
      clearable = false,
      showTodayButton = true,
      closeOnSelect = true,
      labels: labelOverrides,
      name,
      size = 'md',
      color = 'primary',
      readOnly = false,
      disabled = false,
      startIcon,
      ...shell
    } = useStyleDefaults(rawProps, ['size', 'locale']);

    const labels = usePickerLabels(labelOverrides, locale);
    const firstDay = weekStartsOn ?? localeWeekStart(locale);
    const displayFormat = format ?? defaultFormats[granularity];

    const [uncontrolledValue, setUncontrolledValue] = React.useState<Date | null>(
      defaultValue ?? null
    );
    // `null` is a value a controlled picker legitimately holds — an emptied one —
    // so the test is against `undefined` and never against falsiness.
    const value = valueProp !== undefined ? valueProp : uncontrolledValue;

    const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
    const open = openProp ?? uncontrolledOpen;

    const [month, setMonth] = React.useState(() =>
      startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today()))
    );

    // Opening puts the calendar back on the chosen day. Without this, a picker
    // that was left on 2019 while browsing stays there the next time it is opened,
    // which reads as the control having forgotten its own value.
    React.useEffect(() => {
      if (open) {
        setMonth(startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today())));
      }
      // Only when the popup opens — following `value` here would drag the calendar
      // out from under someone typing into a form elsewhere on the page.
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [open]);

    const setOpen = (next: boolean) => {
      // A read-only picker does not open. What it holds is something to read, and
      // a calendar whose every cell was inert would be a menu of nothing.
      if (next && (readOnly || disabled)) {
        return;
      }
      if (openProp === undefined) {
        setUncontrolledOpen(next);
      }
      onOpenChange?.(next);
    };

    const commit = (next: Date | null) => {
      if (valueProp === undefined) {
        setUncontrolledValue(next);
      }
      onValueChange?.(next);
    };

    const select = (date: Date) => {
      // The unit is the answer, so the day inside it is not the caller's to read:
      // a month picker reports the 1st whichever cell was clicked, and the footer
      // shortcut lands on the same value the grid would have.
      const unit = startOfUnit(date, granularity);
      // The day changes; the time of day, if the value had one, does not. A
      // `DatePicker` bound to a field that also carries a time should not silently
      // reset it to midnight every time the day is corrected.
      const next = isValidDate(value) ? mergeDateAndTime(unit, value) : unit;
      commit(next);
      setMonth(startOfMonth(next));
      if (closeOnSelect) {
        setOpen(false);
      }
    };

    const now = today();
    // Read at the same unit the grid reads it at, and against the same value the
    // shortcut would commit — otherwise a "This month" button greys out because
    // the 1st is a Saturday, or stays lit for a month that has no day left in it.
    const shortcut = startOfUnit(now, granularity);
    const shortcutBlocked =
      isUnitOutside(now, granularity, minDate, maxDate) || (shouldDisableDate?.(shortcut) ?? false);
    const shortcutLabel =
      granularity === 'year'
        ? labels.thisYear
        : granularity === 'month'
          ? labels.thisMonth
          : labels.today;
    const hasFooter = showTodayButton || clearable;

    // Holds the trigger open at the width of the longest date it could show, so
    // choosing the 1st after the 28th does not shrink the field.
    const samples = React.useMemo(
      () => withPlaceholder(displaySamples(locale, displayFormat), placeholder),
      [locale, displayFormat, placeholder]
    );

    return (
      <PickerShell
        {...shell}
        size={size}
        color={color}
        readOnly={readOnly}
        disabled={disabled}
        triggerRef={ref}
        startIcon={startIcon ?? <CalendarIcon />}
        display={
          isValidDate(value) ? formatDate(value, locale, displayFormat) : (placeholder ?? '')
        }
        samples={samples}
        empty={!isValidDate(value)}
        clearable={clearable}
        onClear={() => commit(null)}
        open={open}
        onOpenChange={setOpen}
        clearLabel={labels.clear}
        hiddenValues={
          name
            ? [{ name, value: isValidDate(value) ? isoWriters[granularity](value) : '' }]
            : undefined
        }
      >
        <div className={cx('flex flex-col', hasFooter && 'gap-1.5')}>
          <Calendar
            size={size}
            color={color}
            locale={locale}
            weekStartsOn={firstDay}
            month={month}
            onMonthChange={setMonth}
            selected={[value]}
            onSelect={select}
            granularity={granularity}
            minDate={minDate}
            maxDate={maxDate}
            shouldDisableDate={shouldDisableDate}
            labels={labels}
            autoFocus
          />

          {hasFooter ? (
            <PickerFooter size={size}>
              {clearable ? (
                <Button
                  variant="text"
                  size={size}
                  color={color}
                  density="compact"
                  onClick={() => {
                    commit(null);
                    setOpen(false);
                  }}
                >
                  {labels.clear}
                </Button>
              ) : null}
              {showTodayButton ? (
                <Button
                  variant="text"
                  size={size}
                  color={color}
                  density="compact"
                  disabled={shortcutBlocked}
                  onClick={() => select(now)}
                >
                  {shortcutLabel}
                </Button>
              ) : null}
            </PickerFooter>
          ) : null}
        </div>
      </PickerShell>
    );
  }
);
