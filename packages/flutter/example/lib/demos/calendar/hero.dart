import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CalendarHero extends StatefulWidget {
  const CalendarHero({super.key});

  @override
  State<CalendarHero> createState() => _CalendarHeroState();
}

class _CalendarHeroState extends State<CalendarHero> {
  DateTime? _value = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final DateTime? value = _value;

    return NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaCalendar(
          value: value,
          onValueChange: (DateTime? next) => setState(() => _value = next),
        ),
        NebaTypography(
          value == null ? 'Nothing chosen.' : _written(value),
          level: NebaTypographyLevel.caption,
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
