import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxGroupStates extends StatelessWidget {
  const CheckboxGroupStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 10,
      children: <Widget>[
        NebaCheckboxGroup(
          label: Text('One option is out of reach'),
          defaultValue: <String>['web'],
          children: <Widget>[
            NebaCheckbox(value: 'web', label: Text('Web')),
            NebaCheckbox(value: 'ios', label: Text('iOS')),
            NebaCheckbox(value: 'android', label: Text('Android'), disabled: true),
          ],
        ),
        NebaCheckboxGroup(
          label: Text('The whole set is read-only'),
          readOnly: true,
          defaultValue: <String>['web', 'ios'],
          children: <Widget>[
            NebaCheckbox(value: 'web', label: Text('Web')),
            NebaCheckbox(value: 'ios', label: Text('iOS')),
          ],
        ),
        NebaCheckboxGroup(
          label: Text('Platforms'),
          error: Text('Choose at least one platform.'),
          children: <Widget>[
            NebaCheckbox(value: 'web', label: Text('Web')),
            NebaCheckbox(value: 'ios', label: Text('iOS')),
          ],
        ),
      ],
    );
  }
}
