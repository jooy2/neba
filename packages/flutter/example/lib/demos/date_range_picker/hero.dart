import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DateRangePickerHero extends StatefulWidget {
  const DateRangePickerHero({super.key});

  @override
  State<DateRangePickerHero> createState() => _DateRangePickerHeroState();
}

class _DateRangePickerHeroState extends State<DateRangePickerHero> {
  NebaDateRange _value = const NebaDateRange();

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDateRangePicker(
          label: const Text('Stay'),
          startPlaceholder: const Text('Check in'),
          endPlaceholder: const Text('Check out'),
          value: _value,
          onValueChange: (NebaDateRange next) => setState(() => _value = next),
          clearable: true,
        ),
      ],
    );
  }
}
