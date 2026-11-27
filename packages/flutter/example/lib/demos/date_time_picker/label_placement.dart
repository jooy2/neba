import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DateTimePickerLabelPlacement extends StatelessWidget {
  const DateTimePickerLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDateTimePicker(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          placeholder: Text('Pick a moment'),
        ),
        NebaDateTimePicker(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          placeholder: Text('Pick a moment'),
          showStartIcon: false,
        ),
      ],
    );
  }
}
