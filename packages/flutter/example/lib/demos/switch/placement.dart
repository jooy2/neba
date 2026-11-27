import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SwitchPlacement extends StatelessWidget {
  const SwitchPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          NebaSwitch(
            labelSide: NebaSwitchLabelSide.start,
            label: Text('Two-factor authentication'),
            description: Text('Required for admins.'),
            defaultChecked: true,
          ),
          NebaSwitch(
            labelSide: NebaSwitchLabelSide.start,
            label: Text('Session timeout'),
            description: Text('After 30 minutes.'),
          ),
        ],
      ),
    );
  }
}
