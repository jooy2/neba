import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final DateTime _day = DateTime(2026, 7, 27);

class DatePickerSizes extends StatelessWidget {
  const DatePickerSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaDatePicker(size: size, label: Text(size.name), defaultValue: _day),
      ],
    );
  }
}
