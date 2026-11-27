import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DateTimePickerHero extends StatefulWidget {
  const DateTimePickerHero({super.key});

  @override
  State<DateTimePickerHero> createState() => _DateTimePickerHeroState();
}

class _DateTimePickerHeroState extends State<DateTimePickerHero> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDateTimePicker(
          label: const Text('Publish at'),
          placeholder: const Text('Pick a moment'),
          value: _value,
          onValueChange: (DateTime? next) => setState(() => _value = next),
          minuteStep: 15,
          clearable: true,
        ),
      ],
    );
  }
}
