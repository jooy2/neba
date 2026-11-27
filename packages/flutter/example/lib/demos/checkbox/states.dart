import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxStates extends StatelessWidget {
  const CheckboxStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaCheckbox(label: Text('Unchecked')),
        NebaCheckbox(label: Text('Checked'), defaultChecked: true),
        NebaCheckbox(label: Text('Read-only'), readOnly: true, defaultChecked: true),
        NebaCheckbox(label: Text('Disabled'), disabled: true),
        NebaCheckbox(label: Text('Disabled and checked'), disabled: true, defaultChecked: true),
        NebaCheckbox(
          label: Text('I agree to the terms'),
          error: Text('You have to agree to continue.'),
        ),
      ],
    );
  }
}
