import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CalendarModes extends StatefulWidget {
  const CalendarModes({super.key});

  @override
  State<CalendarModes> createState() => _CalendarModesState();
}

class _CalendarModesState extends State<CalendarModes> {
  List<DateTime> _days = <DateTime>[];
  NebaCalendarRange _span = const NebaCalendarRange();

  @override
  Widget build(BuildContext context) {
    final DateTime? start = _span.start;
    final DateTime? end = _span.end;

    return NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 2,
          alignItems: NebaAlignItems.start,
          children: <Widget>[
            NebaCalendar.multiple(
              value: _days,
              onValueChange: (List<DateTime> next) => setState(() => _days = next),
            ),
            NebaTypography(
              _days.isEmpty ? 'No days held.' : '${_days.length} days held',
              level: NebaTypographyLevel.caption,
            ),
          ],
        ),
        NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 2,
          alignItems: NebaAlignItems.start,
          children: <Widget>[
            NebaCalendar.range(
              value: _span,
              onValueChange: (NebaCalendarRange next) => setState(() => _span = next),
            ),
            NebaTypography(
              start == null
                  ? 'No span yet.'
                  : '${_written(start)} → ${end == null ? '…' : _written(end)}',
              level: NebaTypographyLevel.caption,
            ),
          ],
        ),
      ],
    );
  }
}

/// A day as JavaScript's `toDateString` writes it: `Fri Nov 27 2026`.
String _written(DateTime date) {
  final NebaDateNames names = NebaDateNames.english;
  final String day = '${date.day}'.padLeft(2, '0');

  return '${names.shortWeekdays[date.weekday - 1]} ${names.shortMonths[date.month - 1]} $day ${date.year}';
}
