import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

class MockupHardware extends StatelessWidget {
  const MockupHardware({super.key});

  @override
  Widget build(BuildContext context) {
    return const MockupLabels(<(String, Widget)>[
      (
        'monitor',
        NebaMockup(
          device: NebaMockupDevice.desktop,
          hardware: NebaMockupHardware.monitor,
          width: 300,
          child: MockupDesktopScreen(),
        ),
      ),
      (
        'laptop',
        NebaMockup(
          device: NebaMockupDevice.desktop,
          hardware: NebaMockupHardware.laptop,
          os: NebaMockupOs.macos,
          width: 300,
          child: MockupDesktopScreen(),
        ),
      ),
    ]);
  }
}
