import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

/// The bezel and the cut-out turn with the screen.
class MockupOrientation extends StatelessWidget {
  const MockupOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        NebaMockup(device: NebaMockupDevice.tablet, width: 150, child: MockupDesktopScreen()),
        NebaMockup(
          device: NebaMockupDevice.tablet,
          orientation: NebaMockupOrientation.landscape,
          width: 230,
          child: MockupDesktopScreen(),
        ),
        NebaMockup(
          device: NebaMockupDevice.mobile,
          orientation: NebaMockupOrientation.landscape,
          notch: NebaMockupNotch.notch,
          width: 200,
        ),
      ],
    );
  }
}
