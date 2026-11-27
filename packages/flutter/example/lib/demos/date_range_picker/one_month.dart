import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DateRangePickerOneMonth extends StatelessWidget {
  const DateRangePickerOneMonth({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime inThirtyDays = DateTime(today.year, today.month, today.day + 30);

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        const NebaDateRangePicker(
          label: Text('One panel'),
          monthCount: 1,
          startPlaceholder: Text('From'),
          endPlaceholder: Text('To'),
        ),
        NebaDateRangePicker(
          label: const Text('Next thirty days'),
          minDate: today,
          maxDate: inThirtyDays,
          startPlaceholder: const Text('From'),
          endPlaceholder: const Text('To'),
        ),
      ],
    );
  }
}
