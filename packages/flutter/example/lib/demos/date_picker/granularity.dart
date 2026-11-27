import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DatePickerGranularity extends StatefulWidget {
  const DatePickerGranularity({super.key});

  @override
  State<DatePickerGranularity> createState() => _DatePickerGranularityState();
}

class _DatePickerGranularityState extends State<DatePickerGranularity> {
  DateTime? _period;

  @override
  Widget build(BuildContext context) {
    final DateTime? period = _period;

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 4,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            const NebaDatePicker(
              label: Text('Invoice date'),
              placeholder: Text('Pick a day'),
              clearable: true,
            ),
            NebaDatePicker(
              label: const Text('Billing period'),
              placeholder: const Text('Pick a month'),
              granularity: NebaDateGranularity.month,
              value: period,
              onValueChange: (DateTime? next) => setState(() => _period = next),
              clearable: true,
            ),
            const NebaDatePicker(
              label: Text('Tax year'),
              placeholder: Text('Pick a year'),
              granularity: NebaDateGranularity.year,
              clearable: true,
            ),
          ],
        ),
        NebaTypography(
          period == null ? 'No billing period yet.' : 'Billing period starts ${_written(period)}',
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
