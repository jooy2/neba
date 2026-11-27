import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DatePickerLabelPlacement extends StatelessWidget {
  const DatePickerLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDatePicker(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          placeholder: Text('Pick a day'),
        ),
        NebaDatePicker(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          placeholder: Text('Pick a day'),
          showStartIcon: false,
        ),
      ],
    );
  }
}
