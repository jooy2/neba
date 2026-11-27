import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final DateTime _day = DateTime(2026, 7, 27);

class DatePickerVariants extends StatelessWidget {
  const DatePickerVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDatePicker(variant: NebaVariant.solid, label: const Text('Solid'), defaultValue: _day),
        NebaDatePicker(
          variant: NebaVariant.outline,
          label: const Text('Outline'),
          defaultValue: _day,
        ),
        NebaDatePicker(variant: NebaVariant.text, label: const Text('Text'), defaultValue: _day),
      ],
    );
  }
}
