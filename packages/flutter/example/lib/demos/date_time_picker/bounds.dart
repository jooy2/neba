import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DateTimePickerBounds extends StatelessWidget {
  const DateTimePickerBounds({super.key});

  @override
  Widget build(BuildContext context) {
    // Now, to the minute: the ordinary "you cannot schedule into the past"
    // rule.
    final DateTime now = DateTime.now();

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDateTimePicker(
          label: const Text('Not before now'),
          placeholder: const Text('Pick a moment'),
          minDate: now,
          minuteStep: 5,
          description: const Text('Today stays selectable; the hours already gone do not.'),
        ),
        const NebaDateTimePicker(
          label: Text('24-hour, with seconds'),
          placeholder: Text('Pick a moment'),
          hour12: false,
          showSeconds: true,
          secondStep: 10,
        ),
      ],
    );
  }
}
