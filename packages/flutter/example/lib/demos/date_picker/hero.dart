import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DatePickerHero extends StatefulWidget {
  const DatePickerHero({super.key});

  @override
  State<DatePickerHero> createState() => _DatePickerHeroState();
}

class _DatePickerHeroState extends State<DatePickerHero> {
  DateTime? _value = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDatePicker(
          label: const Text('Ships on'),
          placeholder: const Text('Pick a day'),
          value: _value,
          onValueChange: (DateTime? next) => setState(() => _value = next),
          clearable: true,
        ),
        const NebaDatePicker(label: Text('Delivered'), placeholder: Text('Not yet')),
      ],
    );
  }
}
