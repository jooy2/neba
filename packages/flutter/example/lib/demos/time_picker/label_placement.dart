import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TimePickerLabelPlacement extends StatelessWidget {
  const TimePickerLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaTimePicker(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          placeholder: Text('Pick a time'),
        ),
        NebaTimePicker(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          placeholder: Text('Pick a time'),
          showStartIcon: false,
        ),
      ],
    );
  }
}
