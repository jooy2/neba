import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SwitchHero extends StatelessWidget {
  const SwitchHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaSwitch(label: Text('Email alerts'), defaultChecked: true),
        NebaSwitch(
          label: Text('Preview deployments'),
          description: Text('Builds every pull request.'),
        ),
        NebaSwitch(label: Text('Maintenance mode'), color: NebaColor.warning),
        NebaSwitch(label: Text('Enforced by your workspace'), disabled: true, defaultChecked: true),
      ],
    );
  }
}
