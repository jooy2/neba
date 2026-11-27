import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The lunch hour, whichever day the clock writes onto.
bool _isLunch(DateTime value, NebaTimeUnit unit) {
  return unit == NebaTimeUnit.hour && value.hour == 12;
}

class TimePickerBounds extends StatelessWidget {
  const TimePickerBounds({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime day = DateTime.now();

    DateTime at(int hours, [int minutes = 0]) {
      return DateTime(day.year, day.month, day.day, hours, minutes);
    }

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaTimePicker(
          label: const Text('Office hours'),
          placeholder: const Text('Pick a time'),
          minTime: at(9, 30),
          maxTime: at(17, 30),
          minuteStep: 15,
          description: const Text(
            '09:30 leaves the 9 available and greys out the minutes before it.',
          ),
        ),
        const NebaTimePicker(
          label: Text('No lunch hour'),
          placeholder: Text('Pick a time'),
          minuteStep: 30,
          shouldDisableTime: _isLunch,
        ),
      ],
    );
  }
}
