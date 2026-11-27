import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final DateTime _day = DateTime(2026, 7, 27);

class DatePickerStates extends StatelessWidget {
  const DatePickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaDatePicker(label: const Text('Read-only'), readOnly: true, defaultValue: _day),
        NebaDatePicker(label: const Text('Disabled'), disabled: true, defaultValue: _day),
        const NebaDatePicker(
          label: Text('Invalid'),
          placeholder: Text('Pick a day'),
          error: Text('A date is required.'),
        ),
        NebaDatePicker(
          label: const Text('With help'),
          description: const Text('Local time.'),
          defaultValue: _day,
        ),
      ],
    );
  }
}
