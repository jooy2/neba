import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SwitchSizes extends StatelessWidget {
  const SwitchSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaSwitch(size: size, label: Text(size.name), defaultChecked: true),
      ],
    );
  }
}
