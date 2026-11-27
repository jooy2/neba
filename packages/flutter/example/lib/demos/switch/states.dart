import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SwitchStates extends StatelessWidget {
  const SwitchStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaSwitch(label: Text('Off')),
        NebaSwitch(label: Text('On'), defaultChecked: true),
        NebaSwitch(label: Text('Read-only'), readOnly: true, defaultChecked: true),
        NebaSwitch(label: Text('Disabled'), disabled: true),
        NebaSwitch(label: Text('Disabled and on'), disabled: true, defaultChecked: true),
      ],
    );
  }
}
