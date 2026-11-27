/// `NebaDateNames` and `NebaPickerLabels`, the words the calendar and the
/// pickers draw: the names of the months and the weekdays, how a date is
/// written, and what their buttons say.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/theme.dart';

/// How dates are named and written in one language: what the calendar's
/// header, its column heads, its cells and a picker's trigger say.
///
/// The React package asks `Intl` for all of this. Flutter's widgets layer has
/// no date names to ask (`WidgetsLocalizations` holds a text direction and a
/// few editing labels, and `dart:ui` none), and the package takes no
/// dependency on `intl`, so the names are a table. English is built in; any
/// other language is registered once with [registerNebaDateNames] and found
/// by the locale the widget is in, as the widgets' own words are.
///
/// A pattern is text with placeholders: `{year}`, `{month}` (the long name),
/// `{shortMonth}`, `{monthNumber}`, `{day}`, `{weekday}` (the long name) and
/// `{shortWeekday}` for the day; `{hour}` (0 to 23), `{paddedHour}` (00 to
/// 23), `{dialHour}` (12, 1 to 11), `{minute}`, `{second}` (each two digits)
/// and `{dayPeriod}` ([am] or [pm]) for the time of day; and, in [dateTime],
/// `{mediumDate}` and `{time}` for those two patterns whole.
///
/// ```dart
/// registerNebaDateNames(
///   'ko',
///   const NebaDateNames(
///     months: <String>['1월', '2월', '3월', '4월', '5월', '6월',
///         '7월', '8월', '9월', '10월', '11월', '12월'],
///     shortMonths: <String>['1월', '2월', '3월', '4월', '5월', '6월',
///         '7월', '8월', '9월', '10월', '11월', '12월'],
///     weekdays: <String>['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
///     shortWeekdays: <String>['월', '화', '수', '목', '금', '토', '일'],
///     monthYear: '{year}년 {month}',
///     fullDate: '{year}년 {month} {day}일 {weekday}',
///     mediumDate: '{year}. {monthNumber}. {day}.',
///     am: '오전',
///     pm: '오후',
///     time: '{dayPeriod} {dialHour}:{minute}',
///     timeWithSeconds: '{dayPeriod} {dialHour}:{minute}:{second}',
///     dateTime: '{mediumDate} {time}',
///   ),
/// );
/// ```
@immutable
class NebaDateNames {
  /// The names of one language.
  const NebaDateNames({
    required this.months,
    required this.shortMonths,
    required this.weekdays,
    required this.shortWeekdays,
    this.monthYear = '{month} {year}',
    this.fullDate = '{weekday}, {month} {day}, {year}',
    this.mediumDate = '{shortMonth} {day}, {year}',
    this.am = 'AM',
    this.pm = 'PM',
    this.hour12 = true,
    this.time = '{dialHour}:{minute} {dayPeriod}',
    this.timeWithSeconds = '{dialHour}:{minute}:{second} {dayPeriod}',
    this.dateTime = '{mediumDate}, {time}',
  });

  /// The twelve months' names, January first: the header's month button, a
  /// month cell's name and `{month}`.
  final List<String> months;

  /// The twelve months' short names, January first: what a month cell shows
  /// and `{shortMonth}`.
  final List<String> shortMonths;

  /// The seven weekdays' names, Monday first, as [DateTime.weekday] counts
  /// them: what a column head is read as and `{weekday}`.
  final List<String> weekdays;

  /// The seven weekdays' short names, Monday first: what a column head shows
  /// and `{shortWeekday}`. Short rather than a single letter, which leaves two
  /// pairs of columns that cannot be told apart in English.
  final List<String> shortWeekdays;

  /// A month of a year: the name a screen reader hears for the grid on
  /// screen and for a month cell, and the default format of a month picker.
  /// Whether `{month}` comes before `{year}` in it decides the order of the
  /// header's two buttons.
  final String monthYear;

  /// A whole date, with its weekday: the name a screen reader hears for a day
  /// cell.
  final String fullDate;

  /// A date written short: the default format of a date picker.
  final String mediumDate;

  /// What the first half of the day is called: a time picker's meridiem
  /// column and `{dayPeriod}` before noon.
  final String am;

  /// What the second half of the day is called.
  final String pm;

  /// Whether a clock is read on a 12-hour dial here, which is what a time
  /// picker's columns default to: hours 12, 1 to 11 and a column of [am] and
  /// [pm], or hours 00 to 23.
  final bool hour12;

  /// An hour and its minutes: the default format of a time picker, and what
  /// a screen reader hears its clock say.
  final String time;

  /// The same with the seconds, for a time picker that shows them.
  final String timeWithSeconds;

  /// A day and a time in one string: the default format of a date and time
  /// picker. `{mediumDate}` and `{time}` stand for those two patterns.
  final String dateTime;

  /// The names English is written with, which every language falls back to.
  static const NebaDateNames english = NebaDateNames(
    months: <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    shortMonths: <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
    weekdays: <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ],
    shortWeekdays: <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  );

  /// The names for a widget in [context]: those registered for its [locale],
  /// then `NebaProvider`'s, then the app's, and English when none of them has
  /// any.
  static NebaDateNames of(BuildContext context, {Locale? locale}) {
    return resolve(
      locale ?? NebaTheme.defaultsOf(context).locale ?? Localizations.maybeLocaleOf(context),
    );
  }

  /// The names registered for [locale], matched by script, then region, then
  /// language, or English.
  static NebaDateNames resolve(Locale? locale) {
    if (locale == null) {
      return english;
    }

    for (final String candidate in nebaLocaleCandidates(locale.toLanguageTag())) {
      final NebaDateNames? names = nebaRegisteredDateNames[candidate];

      if (names != null) {
        return names;
      }
    }

    return english;
  }

  /// Whether a month is written before its year here: `July 2026`, against
  /// `2026년 7월`.
  bool get monthBeforeYear {
    final int month = monthYear.indexOf('{month}');
    final int year = monthYear.indexOf('{year}');

    return month < 0 || year < 0 || month < year;
  }

  /// [pattern] with its placeholders filled from [date].
  String write(String pattern, DateTime date) => _fill(pattern, date, whole: true);

  // `{mediumDate}` and `{time}` are filled only one level down, so a pattern
  // that names itself is written once rather than without end.
  String _fill(String pattern, DateTime date, {required bool whole}) {
    String two(int value) => value.toString().padLeft(2, '0');

    return pattern.replaceAllMapped(RegExp(r'\{(\w+)\}'), (Match match) {
      return switch (match.group(1)) {
        'year' => '${date.year}',
        'month' => months[date.month - 1],
        'shortMonth' => shortMonths[date.month - 1],
        'monthNumber' => '${date.month}',
        'day' => '${date.day}',
        'weekday' => weekdays[date.weekday - 1],
        'shortWeekday' => shortWeekdays[date.weekday - 1],
        'hour' => '${date.hour}',
        'paddedHour' => two(date.hour),
        'dialHour' => '${date.hour % 12 == 0 ? 12 : date.hour % 12}',
        'minute' => two(date.minute),
        'second' => two(date.second),
        'dayPeriod' => date.hour < 12 ? am : pm,
        'mediumDate' when whole => _fill(mediumDate, date, whole: false),
        'time' when whole => _fill(time, date, whole: false),
        _ => match.group(0)!,
      };
    });
  }

  @override
  bool operator ==(Object other) {
    return other is NebaDateNames &&
        listEquals(other.months, months) &&
        listEquals(other.shortMonths, shortMonths) &&
        listEquals(other.weekdays, weekdays) &&
        listEquals(other.shortWeekdays, shortWeekdays) &&
        other.monthYear == monthYear &&
        other.fullDate == fullDate &&
        other.mediumDate == mediumDate &&
        other.am == am &&
        other.pm == pm &&
        other.hour12 == hour12 &&
        other.time == time &&
        other.timeWithSeconds == timeWithSeconds &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(months),
    Object.hashAll(shortMonths),
    Object.hashAll(weekdays),
    Object.hashAll(shortWeekdays),
    monthYear,
    fullDate,
    mediumDate,
    am,
    pm,
    hour12,
    time,
    timeWithSeconds,
    dateTime,
  );
}

/// Makes [names] the way dates are named for [tag], matched as the widgets'
/// own words are: by script, then by region, then by language, so
/// registering `pt` answers `pt-BR`. A second call for a tag replaces the
/// first. Register before the widgets that need it are built.
void registerNebaDateNames(String tag, NebaDateNames names) {
  nebaRegisteredDateNames[tag.trim().toLowerCase()] = names;
}

/// What the calendar and the pickers say on their own behalf, in place of
/// the [locale]'s words: the steppers' names, the footers' buttons and the
/// clock's columns. Each one left `null` keeps the locale's.
///
/// The React package's `labels`, a partial set of its `picker` messages.
@immutable
class NebaPickerLabels {
  /// The words to use instead of the locale's.
  const NebaPickerLabels({
    this.previousMonth,
    this.nextMonth,
    this.previousYear,
    this.nextYear,
    this.previousYears,
    this.nextYears,
    this.chooseMonth,
    this.chooseYear,
    this.today,
    this.thisMonth,
    this.thisYear,
    this.now,
    this.clear,
    this.done,
    this.hour,
    this.minute,
    this.second,
    this.meridiem,
    this.start,
    this.end,
  });

  /// The stepper back a month.
  final String? previousMonth;

  /// The stepper on a month.
  final String? nextMonth;

  /// The stepper back a year, in the grid of months.
  final String? previousYear;

  /// The stepper on a year, in the grid of months.
  final String? nextYear;

  /// The stepper back a page, in the grid of years.
  final String? previousYears;

  /// The stepper on a page, in the grid of years.
  final String? nextYears;

  /// What pressing the header's month button does.
  final String? chooseMonth;

  /// What pressing the header's year button does.
  final String? chooseYear;

  /// The footer's shortcut to today.
  final String? today;

  /// The footer's shortcut to this month, on a month picker.
  final String? thisMonth;

  /// The footer's shortcut to this year, on a year picker.
  final String? thisYear;

  /// The footer's shortcut to the time now.
  final String? now;

  /// The button that empties the picker.
  final String? clear;

  /// The button that closes a picker that stays open.
  final String? done;

  /// The column of hours.
  final String? hour;

  /// The column of minutes.
  final String? minute;

  /// The column of seconds.
  final String? second;

  /// The column of AM and PM.
  final String? meridiem;

  /// The start of a range.
  final String? start;

  /// The end of a range.
  final String? end;

  /// The words that were given, by their key in the `picker` messages.
  Map<String, String> get given {
    return <String, String>{
      'previousMonth': ?previousMonth,
      'nextMonth': ?nextMonth,
      'previousYear': ?previousYear,
      'nextYear': ?nextYear,
      'previousYears': ?previousYears,
      'nextYears': ?nextYears,
      'chooseMonth': ?chooseMonth,
      'chooseYear': ?chooseYear,
      'today': ?today,
      'thisMonth': ?thisMonth,
      'thisYear': ?thisYear,
      'now': ?now,
      'clear': ?clear,
      'done': ?done,
      'hour': ?hour,
      'minute': ?minute,
      'second': ?second,
      'meridiem': ?meridiem,
      'start': ?start,
      'end': ?end,
    };
  }
}
