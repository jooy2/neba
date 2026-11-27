import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxGroupOrientation extends StatelessWidget {
  const CheckboxGroupOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCheckboxGroup(
      label: Text('Days'),
      orientation: NebaOrientation.horizontal,
      defaultValue: <String>['mon', 'wed', 'fri'],
      children: <Widget>[
        NebaCheckbox(value: 'mon', label: Text('Mon')),
        NebaCheckbox(value: 'tue', label: Text('Tue')),
        NebaCheckbox(value: 'wed', label: Text('Wed')),
        NebaCheckbox(value: 'thu', label: Text('Thu')),
        NebaCheckbox(value: 'fri', label: Text('Fri')),
      ],
    );
  }
}
