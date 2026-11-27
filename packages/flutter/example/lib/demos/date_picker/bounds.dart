import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Saturday and Sunday.
bool _isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

class DatePickerBounds extends StatelessWidget {
  const DatePickerBounds({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime inTwoWeeks = DateTime(today.year, today.month, today.day + 14);

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDatePicker(
          label: const Text('Within a fortnight'),
          placeholder: const Text('Pick a day'),
          minDate: today,
          maxDate: inTwoWeeks,
        ),
        const NebaDatePicker(
          label: Text('Weekdays only'),
          placeholder: Text('Pick a day'),
          shouldDisableDate: _isWeekend,
          description: Text('Weekends stay in the grid, greyed out.'),
        ),
      ],
    );
  }
}
