import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TimePickerColumns extends StatelessWidget {
  const TimePickerColumns({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime nineThirty = DateTime(2026, 7, 27, 9, 30);

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaTimePicker(
          label: const Text('Every five minutes'),
          minuteStep: 5,
          defaultValue: nineThirty,
        ),
        NebaTimePicker(
          label: const Text('With seconds'),
          showSeconds: true,
          defaultValue: nineThirty,
        ),
        NebaTimePicker(label: const Text('24-hour'), hour12: false, defaultValue: nineThirty),
      ],
    );
  }
}
