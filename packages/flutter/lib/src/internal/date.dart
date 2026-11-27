/// The arithmetic the calendar and the pickers share: the React package's
/// `internal/date.ts`, without its half that asks `Intl` for names, which is
/// `NebaDateNames` here.
///
/// Two rules hold everywhere below, as they do there:
///
/// - **Local time, always.** A calendar day is something a person reads off a
///   wall, not an instant on a line, so every comparison is made on the local
///   year, month and day, and a picker in Seoul and one in São Paulo light up
///   the same cell.
/// - **Calendar steps, never durations.** Adding a day is adding one to the
///   day of the month and letting [DateTime] carry the overflow, which keeps
///   the clock where it was across a change to summer time. Adding
///   `Duration(days: 1)` is twenty-four hours, which lands an hour off on the
///   two days a year that are not twenty-four hours long.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// Which of its three grids a calendar is showing.
enum NebaCalendarView {
  /// The days of a month.
  day,

  /// The twelve months of a year.
  month,

  /// Twelve years at a time.
  year,
}

/// How many years one page of the year grid holds: four columns of three.
const int nebaYearPageSize = 12;

/// Date arithmetic on the local calendar.
abstract final class NebaDate {
  /// Midnight on [year], [month] and [day], with a part out of range carried
  /// into the next: month 13 is January of the year after, day 0 the last day
  /// of the month before. [month] counts from 1, as [DateTime.month] does.
  static DateTime make(int year, int month, int day) => DateTime(year, month, day);

  /// The same day at midnight.
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  /// The first day of the month [date] is in, at midnight.
  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

  /// The first day of the year [date] is in, at midnight.
  static DateTime startOfYear(DateTime date) => DateTime(date.year);

  /// The first instant of the unit [date] falls in, which is what a picker
  /// of that [granularity] reports. The cell that was pressed, the footer's
  /// shortcut, the bounds and a caller's own check all have to agree on what
  /// "the value stands for a whole month" means.
  static DateTime startOfUnit(DateTime date, NebaDateGranularity granularity) {
    return switch (granularity) {
      NebaDateGranularity.year => startOfYear(date),
      NebaDateGranularity.month => startOfMonth(date),
      NebaDateGranularity.day => startOfDay(date),
    };
  }

  /// The last day of that same unit.
  static DateTime endOfUnit(DateTime date, NebaDateGranularity granularity) {
    return switch (granularity) {
      NebaDateGranularity.year => DateTime(date.year, 12, 31),
      NebaDateGranularity.month => DateTime(date.year, date.month + 1, 0),
      NebaDateGranularity.day => startOfDay(date),
    };
  }

  /// How many days [month] of [year] has, leap years included.
  static int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  /// Today, at midnight: the one place the pickers read the clock for a day.
  static DateTime today() => startOfDay(DateTime.now());

  /// [amount] days on, with the clock kept where it was.
  static DateTime addDays(DateTime date, int amount) {
    return DateTime(
      date.year,
      date.month,
      date.day + amount,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  /// [amount] months on, with the day held to the last one the month has:
  /// 31 January and a month is 28 February, not 3 March, which is why a
  /// calendar stepped forward from a 31st with the naive sum skips February.
  static DateTime addMonths(DateTime date, int amount) {
    final DateTime target = DateTime(date.year, date.month + amount);

    return DateTime(
      target.year,
      target.month,
      math.min(date.day, daysInMonth(target.year, target.month)),
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  /// [amount] years on, a 29 February held to the 28th.
  static DateTime addYears(DateTime date, int amount) => addMonths(date, amount * 12);

  /// Negative, zero or positive, as a sort wants it, on the local day alone:
  /// two values on the same day differ by a time of day far more often than
  /// not, and every one of those comparisons has to come out equal.
  static int compareDay(DateTime a, DateTime b) {
    if (a.year != b.year) {
      return a.year - b.year;
    }

    if (a.month != b.month) {
      return a.month - b.month;
    }

    return a.day - b.day;
  }

  /// Whether [a] and [b] are the same local day; `false` when either is
  /// missing.
  static bool isSameDay(DateTime? a, DateTime? b) {
    return a != null && b != null && compareDay(a, b) == 0;
  }

  /// Whether [a] and [b] are in the same local month.
  static bool isSameMonth(DateTime? a, DateTime? b) {
    return a != null && b != null && a.year == b.year && a.month == b.month;
  }

  /// Whether the day [date] is outside [min] and [max]. Day by day on
  /// purpose: a maximum of the 27th at nine in the morning leaves the 27th
  /// open, because the bounds are about which days exist.
  static bool isDayOutside(DateTime date, DateTime? min, DateTime? max) {
    if (min != null && compareDay(date, min) < 0) {
      return true;
    }

    return max != null && compareDay(date, max) > 0;
  }

  /// Whether the whole unit [date] falls in is outside [min] and [max]. A
  /// minimum of 15 March leaves March open at month granularity: the cell
  /// stands for the whole month, and part of it is allowed.
  static bool isUnitOutside(
    DateTime date,
    NebaDateGranularity granularity,
    DateTime? min,
    DateTime? max,
  ) {
    if (min != null && compareDay(endOfUnit(date, granularity), min) < 0) {
      return true;
    }

    return max != null && compareDay(startOfUnit(date, granularity), max) > 0;
  }

  /// [date]'s day with [time]'s clock.
  static DateTime mergeDateAndTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute, time.second);
  }

  /// [date] with the clock fields given replaced, and the rest of a second
  /// dropped. The fields are set on the wall clock, so the hour a row is
  /// labelled with is the hour it lands on, a day the clocks change included.
  static DateTime withTime(DateTime date, {int? hours, int? minutes, int? seconds}) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      hours ?? date.hour,
      minutes ?? date.minute,
      seconds ?? date.second,
    );
  }

  /// [date] held inside [min] and [max], at whatever precision they carry.
  static DateTime clamp(DateTime date, DateTime? min, DateTime? max) {
    if (min != null && date.isBefore(min)) {
      return min;
    }

    if (max != null && date.isAfter(max)) {
      return max;
    }

    return date;
  }

  /// Seconds since local midnight, on the wall clock.
  static int secondsOfDay(DateTime date) => date.hour * 3600 + date.minute * 60 + date.second;

  /// The span of the day one row of one column of a clock stands for, in
  /// seconds since midnight, both ends included.
  ///
  /// A bound is checked against the span and never against one instant in
  /// it: with a minimum of 09:30, the hour `9` covers 09:00:00 to 09:59:59,
  /// which reaches what is allowed, so it stays open and the minute column
  /// is where `00` to `29` grey out. Comparing the instant instead hides the
  /// `9` and makes half past nine unreachable.
  static (int, int) timeUnitSpan(NebaTimeUnit unit, DateTime at) {
    final int seconds = secondsOfDay(at);

    switch (unit) {
      case NebaTimeUnit.hour:
        final int start = seconds ~/ 3600 * 3600;

        return (start, start + 3599);
      case NebaTimeUnit.minute:
        final int start = seconds ~/ 60 * 60;

        return (start, start + 59);
      case NebaTimeUnit.second:
        return (seconds, seconds);
      case NebaTimeUnit.meridiem:
        final int start = at.hour < 12 ? 0 : 12 * 3600;

        return (start, start + 12 * 3600 - 1);
    }
  }

  /// [date]'s weekday as the calendar counts columns: [DateTime.weekday]
  /// with Sunday taken round to sit before Monday, so a week starting on any
  /// day is a subtraction away.
  static int column(DateTime date, NebaWeekday weekStartsOn) {
    return (date.weekday - weekStartsOn + 7) % 7;
  }

  /// Six weeks of seven days, always, the days of the neighbouring months
  /// included. Six rows whatever the month: a grid that drew only the rows a
  /// month needs would change height when stepped, and move every cell out
  /// from under the pointer that had just pressed one.
  static List<List<DateTime>> weeks(DateTime month, NebaWeekday weekStartsOn) {
    final DateTime first = startOfMonth(month);
    final DateTime origin = addDays(first, -column(first, weekStartsOn));

    return <List<DateTime>>[
      for (int week = 0; week < 6; week++)
        <DateTime>[for (int day = 0; day < 7; day++) addDays(origin, week * 7 + day)],
    ];
  }

  /// The first year of the page of the year grid [year] falls on: 2026 is
  /// on the page that starts at 2016.
  static int yearPageStart(int year) => year - year % nebaYearPageSize;
}

/// Every month against every weekday, each on a two-digit day and each at a
/// different hour, with two-digit minutes and seconds: the dates a picker's
/// trigger is measured against.
///
/// A trigger is as wide as what it says, so `Jul 1, 2026` and `Sep 28, 2026`
/// are different widths and the field would move each time a day was chosen.
/// Measuring all of these holds it at the widest thing it could ever say. The
/// React package has a shorter list for a format that writes no weekday;
/// here a format is a function nothing can ask, so the longer list is the one
/// that is always right.
final List<DateTime> nebaDateSamples = List<DateTime>.unmodifiable(<DateTime>[
  for (int index = 0; index < 84; index++)
    () {
      final int month = index ~/ 7 + 1;
      final int first = DateTime(2027, month, 21).weekday % 7;

      return DateTime(2027, month, 21 + (index - first + 7) % 7, index % 24, 58, 58);
    }(),
]);

/// What [format] writes for every one of [nebaDateSamples], each once.
List<String> nebaDisplaySamples(String Function(DateTime date) format) {
  return <String>{for (final DateTime date in nebaDateSamples) format(date)}.toList();
}

// Which day a week starts on, by region, from CLDR's week data as the ICU in
// Node 26 holds it (ICU 78.3, CLDR 48): what the React package reads at run
// time through `Intl.Locale`'s week info. A region that is not here starts on
// Monday, as CLDR's world default does.
const Map<String, NebaWeekday> _weekStartByRegion = <String, NebaWeekday>{
  // Sunday.
  'AG': DateTime.sunday, 'AS': DateTime.sunday, 'BD': DateTime.sunday,
  'BR': DateTime.sunday, 'BS': DateTime.sunday, 'BT': DateTime.sunday,
  'BW': DateTime.sunday, 'BZ': DateTime.sunday, 'CA': DateTime.sunday,
  'CO': DateTime.sunday, 'DM': DateTime.sunday, 'DO': DateTime.sunday,
  'ET': DateTime.sunday, 'GT': DateTime.sunday, 'GU': DateTime.sunday,
  'HK': DateTime.sunday, 'HN': DateTime.sunday, 'ID': DateTime.sunday,
  'IL': DateTime.sunday, 'IN': DateTime.sunday, 'IS': DateTime.sunday,
  'JM': DateTime.sunday, 'JP': DateTime.sunday, 'KE': DateTime.sunday,
  'KH': DateTime.sunday, 'KR': DateTime.sunday, 'LA': DateTime.sunday,
  'MH': DateTime.sunday, 'MM': DateTime.sunday, 'MO': DateTime.sunday,
  'MT': DateTime.sunday, 'MX': DateTime.sunday, 'MZ': DateTime.sunday,
  'NI': DateTime.sunday, 'NP': DateTime.sunday, 'PA': DateTime.sunday,
  'PE': DateTime.sunday, 'PH': DateTime.sunday, 'PK': DateTime.sunday,
  'PR': DateTime.sunday, 'PT': DateTime.sunday, 'PY': DateTime.sunday,
  'SA': DateTime.sunday, 'SG': DateTime.sunday, 'SV': DateTime.sunday,
  'TH': DateTime.sunday, 'TT': DateTime.sunday, 'TW': DateTime.sunday,
  'UM': DateTime.sunday, 'US': DateTime.sunday, 'VE': DateTime.sunday,
  'VI': DateTime.sunday, 'WS': DateTime.sunday, 'YE': DateTime.sunday,
  'ZA': DateTime.sunday, 'ZW': DateTime.sunday,
  // Saturday.
  'AF': DateTime.saturday, 'BH': DateTime.saturday, 'DJ': DateTime.saturday,
  'DZ': DateTime.saturday, 'EG': DateTime.saturday, 'IQ': DateTime.saturday,
  'IR': DateTime.saturday, 'JO': DateTime.saturday, 'KW': DateTime.saturday,
  'LY': DateTime.saturday, 'OM': DateTime.saturday, 'QA': DateTime.saturday,
  'SD': DateTime.saturday, 'SY': DateTime.saturday,
  // Friday.
  'MV': DateTime.friday,
};

// The same for a tag that names no region, by the region CLDR's likely
// subtags give the language (and the script, for Chinese): `en` is the
// United States, `ar` Egypt, `zh-Hant` Taiwan. A language that is not here
// starts on Monday.
const Map<String, NebaWeekday> _weekStartByLanguage = <String, NebaWeekday>{
  // Sunday.
  'aa': DateTime.sunday, 'af': DateTime.sunday, 'am': DateTime.sunday,
  'as': DateTime.sunday, 'bn': DateTime.sunday, 'ch': DateTime.sunday,
  'cr': DateTime.sunday, 'dz': DateTime.sunday, 'en': DateTime.sunday,
  'gn': DateTime.sunday, 'gu': DateTime.sunday, 'he': DateTime.sunday,
  'hi': DateTime.sunday, 'id': DateTime.sunday, 'ik': DateTime.sunday,
  'is': DateTime.sunday, 'iu': DateTime.sunday, 'ja': DateTime.sunday,
  'jv': DateTime.sunday, 'ki': DateTime.sunday, 'km': DateTime.sunday,
  'kn': DateTime.sunday, 'ko': DateTime.sunday, 'ks': DateTime.sunday,
  'lo': DateTime.sunday, 'mh': DateTime.sunday, 'ml': DateTime.sunday,
  'mr': DateTime.sunday, 'mt': DateTime.sunday, 'my': DateTime.sunday,
  'nd': DateTime.sunday, 'ne': DateTime.sunday, 'nr': DateTime.sunday,
  'nv': DateTime.sunday, 'oj': DateTime.sunday, 'om': DateTime.sunday,
  'or': DateTime.sunday, 'pa': DateTime.sunday, 'pt': DateTime.sunday,
  'qu': DateTime.sunday, 'sa': DateTime.sunday, 'sd': DateTime.sunday,
  'sm': DateTime.sunday, 'sn': DateTime.sunday, 'ss': DateTime.sunday,
  'st': DateTime.sunday, 'su': DateTime.sunday, 'ta': DateTime.sunday,
  'te': DateTime.sunday, 'th': DateTime.sunday, 'ti': DateTime.sunday,
  'tl': DateTime.sunday, 'tn': DateTime.sunday, 'ts': DateTime.sunday,
  'ur': DateTime.sunday, 've': DateTime.sunday, 'xh': DateTime.sunday,
  'zh-hant': DateTime.sunday, 'zu': DateTime.sunday,
  // Saturday.
  'ar': DateTime.saturday, 'fa': DateTime.saturday, 'ps': DateTime.saturday,
  // Friday.
  'dv': DateTime.friday,
};

/// Which day the week starts on for [locale]: Sunday in the United States
/// and Korea, Monday across most of Europe, Saturday across much of the
/// Middle East. A region decides it when the tag names one, and the
/// language's likely region when it does not. No locale is English, as the
/// widgets' own words are.
NebaWeekday nebaWeekStart(Locale? locale) {
  if (locale == null) {
    return DateTime.sunday;
  }

  final String? region = locale.countryCode;

  if (region != null && region.isNotEmpty) {
    return _weekStartByRegion[region.toUpperCase()] ?? DateTime.monday;
  }

  for (final String candidate in nebaLocaleCandidates(locale.toLanguageTag())) {
    final NebaWeekday? day = _weekStartByLanguage[candidate];

    if (day != null) {
      return day;
    }
  }

  return DateTime.monday;
}

/// The languages `registerNebaDateNames` was given, by lower-case tag.
final Map<String, NebaDateNames> nebaRegisteredDateNames = <String, NebaDateNames>{};

/// Forgets every registered language. For tests.
@visibleForTesting
void resetNebaDateNames() => nebaRegisteredDateNames.clear();

/// The locale a widget in [context] names its dates and starts its weeks in:
/// its own [locale], then `NebaProvider`'s, then the app's.
Locale? nebaDateLocale(BuildContext context, {Locale? locale}) {
  return locale ?? NebaTheme.defaultsOf(context).locale ?? Localizations.maybeLocaleOf(context);
}

/// The `picker` messages for a widget in [context] in its [locale], with
/// [labels] laid over them.
Map<String, String> nebaPickerWords(
  BuildContext context, {
  Locale? locale,
  NebaPickerLabels? labels,
}) {
  final Map<String, String> messages = nebaMessages(context, 'picker', locale: locale);

  return labels == null ? messages : <String, String>{...messages, ...labels.given};
}
