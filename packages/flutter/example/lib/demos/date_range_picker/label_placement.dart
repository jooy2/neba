import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DateRangePickerLabelPlacement extends StatelessWidget {
  const DateRangePickerLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaDateRangePicker(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          startPlaceholder: Text('Check in'),
          endPlaceholder: Text('Check out'),
        ),
        NebaDateRangePicker(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          startPlaceholder: Text('Check in'),
          endPlaceholder: Text('Check out'),
          showStartIcon: false,
        ),
      ],
    );
  }
}
