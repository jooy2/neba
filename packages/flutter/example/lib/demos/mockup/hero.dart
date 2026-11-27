import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

class MockupHero extends StatelessWidget {
  const MockupHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: NebaMockup(
        device: NebaMockupDevice.mobile,
        os: NebaMockupOs.ios,
        elevation: 2,
        width: 260,
        child: MockupPhoneScreen(),
      ),
    );
  }
}
