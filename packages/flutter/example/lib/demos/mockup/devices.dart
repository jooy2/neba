import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

class MockupDevices extends StatelessWidget {
  const MockupDevices({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        NebaMockup(device: NebaMockupDevice.desktop, width: 300, child: MockupDesktopScreen()),
        NebaMockup(device: NebaMockupDevice.tablet, width: 150, child: MockupDesktopScreen()),
        NebaMockup(device: NebaMockupDevice.mobile, width: 110, child: MockupPhoneScreen()),
      ],
    );
  }
}
