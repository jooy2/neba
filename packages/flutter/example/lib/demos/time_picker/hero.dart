import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TimePickerHero extends StatefulWidget {
  const TimePickerHero({super.key});

  @override
  State<TimePickerHero> createState() => _TimePickerHeroState();
}

class _TimePickerHeroState extends State<TimePickerHero> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaTimePicker(
          label: const Text('Starts at'),
          placeholder: const Text('Pick a time'),
          value: _value,
          onValueChange: (DateTime? next) => setState(() => _value = next),
          minuteStep: 15,
          clearable: true,
        ),
        const NebaTimePicker(
          label: Text('Ends at'),
          placeholder: Text('Pick a time'),
          minuteStep: 15,
        ),
      ],
    );
  }
}
