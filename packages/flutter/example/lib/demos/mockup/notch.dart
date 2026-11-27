import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

const List<NebaMockupNotch> _notches = <NebaMockupNotch>[
  NebaMockupNotch.dynamicIsland,
  NebaMockupNotch.notch,
  NebaMockupNotch.punchHole,
  NebaMockupNotch.none,
];

class MockupNotch extends StatelessWidget {
  const MockupNotch({super.key});

  @override
  Widget build(BuildContext context) {
    return MockupLabels(<(String, Widget)>[
      for (final NebaMockupNotch notch in _notches)
        (notch.name, NebaMockup(device: NebaMockupDevice.mobile, notch: notch, width: 112)),
    ]);
  }
}
