// The calendar's arithmetic, checked directly: the React package's
// `test/internal/date.test.ts`, on Dart's own `DateTime`.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/date.dart';

void main() {
  group('NebaDate', () {
    test('holds the day of the month to the last one a month has', () {
      expect(NebaDate.addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
      expect(NebaDate.addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
      expect(NebaDate.addMonths(DateTime(2026, 3, 31), -1), DateTime(2026, 2, 28));
      expect(NebaDate.addYears(DateTime(2024, 2, 29), 1), DateTime(2025, 2, 28));
      expect(NebaDate.addMonths(DateTime(2026, 12, 15), 1), DateTime(2027, 1, 15));
    });

    test('adds calendar days, keeping the clock where it was', () {
      expect(NebaDate.addDays(DateTime(2026, 7, 31, 9, 30), 1), DateTime(2026, 8, 1, 9, 30));
      expect(NebaDate.addDays(DateTime(2026, 1, 1), -1), DateTime(2025, 12, 31));
    });

    test('compares days and months on the local calendar, whatever the time', () {
      expect(NebaDate.isSameDay(DateTime(2026, 7, 27, 23, 59), DateTime(2026, 7, 27)), isTrue);
      expect(NebaDate.isSameDay(DateTime(2026, 7, 27), null), isFalse);
      expect(NebaDate.isSameMonth(DateTime(2026, 7, 1), DateTime(2026, 7, 31)), isTrue);
      expect(NebaDate.compareDay(DateTime(2026, 7, 26), DateTime(2026, 7, 27)), isNegative);
    });

    test('reads a bound at the unit a cell stands for', () {
      final DateTime min = DateTime(2026, 3, 15);

      expect(
        NebaDate.isUnitOutside(DateTime(2026, 3, 14), NebaDateGranularity.day, min, null),
        isTrue,
      );
      expect(
        NebaDate.isUnitOutside(DateTime(2026, 3), NebaDateGranularity.month, min, null),
        isFalse,
      );
      expect(
        NebaDate.isUnitOutside(DateTime(2026, 2), NebaDateGranularity.month, min, null),
        isTrue,
      );
      // A maximum at nine in the morning leaves its day open.
      expect(
        NebaDate.isDayOutside(DateTime(2026, 7, 27, 18), null, DateTime(2026, 7, 27, 9)),
        isFalse,
      );
    });

    test('lays out six weeks from the week start, whatever the month', () {
      final List<List<DateTime>> sundays = NebaDate.weeks(DateTime(2026, 7), DateTime.sunday);
      final List<List<DateTime>> mondays = NebaDate.weeks(DateTime(2026, 7), DateTime.monday);

      expect(sundays, hasLength(6));
      expect(sundays.every((List<DateTime> week) => week.length == 7), isTrue);
      // 1 July 2026 is a Wednesday.
      expect(sundays.first.first, DateTime(2026, 6, 28));
      expect(mondays.first.first, DateTime(2026, 6, 29));
      expect(sundays.last.last, DateTime(2026, 8, 8));
      // A February that starts on a Sunday still takes six rows.
      expect(NebaDate.weeks(DateTime(2026, 2), DateTime.sunday).first.first, DateTime(2026, 2));
    });

    test('pages the years twelve at a time', () {
      expect(NebaDate.yearPageStart(2026), 2016);
      expect(NebaDate.yearPageStart(2028), 2028);
      expect(NebaDate.yearPageStart(2027), 2016);
    });

    test('starts a unit at its first day and ends it at its last', () {
      final DateTime date = DateTime(2026, 7, 27, 15);

      expect(NebaDate.startOfUnit(date, NebaDateGranularity.day), DateTime(2026, 7, 27));
      expect(NebaDate.startOfUnit(date, NebaDateGranularity.month), DateTime(2026, 7));
      expect(NebaDate.startOfUnit(date, NebaDateGranularity.year), DateTime(2026));
      expect(NebaDate.endOfUnit(date, NebaDateGranularity.month), DateTime(2026, 7, 31));
      expect(NebaDate.endOfUnit(date, NebaDateGranularity.year), DateTime(2026, 12, 31));
    });

    test('reads a row of the clock as the span of the day it stands for', () {
      final DateTime at = DateTime(2026, 7, 27, 9, 45, 12);

      expect(NebaDate.secondsOfDay(at), 9 * 3600 + 45 * 60 + 12);
      expect(NebaDate.timeUnitSpan(NebaTimeUnit.hour, at), (9 * 3600, 9 * 3600 + 3599));
      expect(NebaDate.timeUnitSpan(NebaTimeUnit.minute, at), (
        9 * 3600 + 45 * 60,
        9 * 3600 + 45 * 60 + 59,
      ));
      expect(NebaDate.timeUnitSpan(NebaTimeUnit.second, at), (35112, 35112));
      expect(NebaDate.timeUnitSpan(NebaTimeUnit.meridiem, at), (0, 12 * 3600 - 1));
      expect(NebaDate.timeUnitSpan(NebaTimeUnit.meridiem, DateTime(2026, 7, 27, 12)), (
        12 * 3600,
        24 * 3600 - 1,
      ));
    });

    test('puts the span of a row on the day of the moment it is read at', () {
      final DateTime at = DateTime(2026, 11, 1, 9, 45, 12);

      expect(NebaDate.timeUnitRange(NebaTimeUnit.hour, at), (
        DateTime(2026, 11, 1, 9),
        DateTime(2026, 11, 1, 9, 59, 59),
      ));
      expect(NebaDate.timeUnitRange(NebaTimeUnit.meridiem, at), (
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 1, 11, 59, 59),
      ));
    });

    test('replaces the fields of the clock it is given and holds a moment to its bounds', () {
      final DateTime at = DateTime(2026, 7, 27, 9, 45, 12, 500);

      expect(NebaDate.withTime(at, minutes: 0), DateTime(2026, 7, 27, 9, 0, 12));
      expect(NebaDate.withTime(at, hours: 17, seconds: 0), DateTime(2026, 7, 27, 17, 45));

      final DateTime min = DateTime(2026, 7, 27, 9, 30);
      final DateTime max = DateTime(2026, 7, 27, 17, 30);

      expect(NebaDate.clamp(DateTime(2026, 7, 27, 9, 15), min, max), min);
      expect(NebaDate.clamp(DateTime(2026, 7, 27, 18), min, max), max);
      expect(NebaDate.clamp(at, min, max), at);
      expect(NebaDate.clamp(at, null, null), at);
    });
  });

  group('nebaWeekStart', () {
    test('follows the region, then the language, as CLDR does', () {
      expect(nebaWeekStart(null), DateTime.sunday);
      expect(nebaWeekStart(const Locale('en')), DateTime.sunday);
      expect(nebaWeekStart(const Locale('en', 'GB')), DateTime.monday);
      expect(nebaWeekStart(const Locale('ko')), DateTime.sunday);
      expect(nebaWeekStart(const Locale('de')), DateTime.monday);
      expect(nebaWeekStart(const Locale('ar')), DateTime.saturday);
      expect(nebaWeekStart(const Locale('pt', 'PT')), DateTime.sunday);
      expect(nebaWeekStart(const Locale('fr', 'CA')), DateTime.sunday);
      expect(nebaWeekStart(const Locale('zh')), DateTime.monday);
      expect(
        nebaWeekStart(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
        DateTime.sunday,
      );
      expect(nebaWeekStart(const Locale('dv')), DateTime.friday);
    });
  });

  group('nebaDisplaySamples', () {
    test('reaches every month and every weekday, each written once', () {
      final List<String> months = nebaDisplaySamples(
        (DateTime date) => NebaDateNames.english.months[date.month - 1],
      );
      final List<String> weekdays = nebaDisplaySamples(
        (DateTime date) => NebaDateNames.english.weekdays[date.weekday - 1],
      );

      expect(months, hasLength(12));
      expect(weekdays, hasLength(7));
      expect(nebaDateSamples.every((DateTime date) => date.day >= 21 && date.day <= 27), isTrue);
    });
  });

  group('NebaDateNames', () {
    tearDown(resetNebaDateNames);

    test('writes a pattern and says which comes first, the month or the year', () {
      const NebaDateNames english = NebaDateNames.english;
      final DateTime date = DateTime(2026, 7, 27);

      expect(english.write(english.fullDate, date), 'Monday, July 27, 2026');
      expect(english.write(english.mediumDate, date), 'Jul 27, 2026');
      expect(english.write(english.monthYear, date), 'July 2026');
      expect(english.monthBeforeYear, isTrue);
      expect(english.write(english.time, DateTime(2026, 7, 27, 14, 5)), '2:05 PM');
      expect(english.write(english.time, DateTime(2026, 7, 27, 0, 30)), '12:30 AM');
      expect(english.write(english.timeWithSeconds, DateTime(2026, 7, 27, 9, 5, 7)), '9:05:07 AM');
      expect(english.write('{paddedHour}:{minute} {hour}', DateTime(2026, 7, 27, 9, 5)), '09:05 9');
      expect(english.hour12, isTrue);
      expect(
        english.write(english.dateTime, DateTime(2026, 7, 27, 14, 30)),
        'Jul 27, 2026, 2:30 PM',
      );
      // A pattern that names itself is written once, not without end.
      expect(
        const NebaDateNames(
          months: <String>[],
          shortMonths: <String>[],
          weekdays: <String>[],
          shortWeekdays: <String>[],
          time: '{time}',
        ).write('{time}', DateTime(2026)),
        '{time}',
      );
      expect(
        const NebaDateNames(
          months: <String>[],
          shortMonths: <String>[],
          weekdays: <String>[],
          shortWeekdays: <String>[],
          monthYear: '{year}년 {month}',
        ).monthBeforeYear,
        isFalse,
      );
    });

    test('finds a registered language by script, then region, then language', () {
      const NebaDateNames portuguese = NebaDateNames(
        months: <String>[
          'janeiro',
          'fevereiro',
          'março',
          'abril',
          'maio',
          'junho',
          'julho',
          'agosto',
          'setembro',
          'outubro',
          'novembro',
          'dezembro',
        ],
        shortMonths: <String>[
          'jan.',
          'fev.',
          'mar.',
          'abr.',
          'mai.',
          'jun.',
          'jul.',
          'ago.',
          'set.',
          'out.',
          'nov.',
          'dez.',
        ],
        weekdays: <String>[
          'segunda-feira',
          'terça-feira',
          'quarta-feira',
          'quinta-feira',
          'sexta-feira',
          'sábado',
          'domingo',
        ],
        shortWeekdays: <String>['seg.', 'ter.', 'qua.', 'qui.', 'sex.', 'sáb.', 'dom.'],
        monthYear: '{month} de {year}',
      );

      registerNebaDateNames('pt', portuguese);

      expect(NebaDateNames.resolve(const Locale('pt', 'BR')), portuguese);
      expect(NebaDateNames.resolve(const Locale('en')), NebaDateNames.english);
      expect(NebaDateNames.resolve(null), NebaDateNames.english);
    });
  });
}
