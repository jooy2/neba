import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

/// A phone runs `ios` or `android`, a tablet `ipados` or `android`. The
/// status bar, the bar at the bottom and the cut-out all follow from the pair.
class MockupHandhelds extends StatelessWidget {
  const MockupHandhelds({super.key});

  @override
  Widget build(BuildContext context) {
    return const MockupLabels(<(String, Widget)>[
      ('ios', NebaMockup(device: NebaMockupDevice.mobile, os: NebaMockupOs.ios, width: 128)),
      (
        'android',
        NebaMockup(device: NebaMockupDevice.mobile, os: NebaMockupOs.android, width: 128),
      ),
      ('ipados', NebaMockup(device: NebaMockupDevice.tablet, os: NebaMockupOs.ipados, width: 168)),
    ]);
  }
}
