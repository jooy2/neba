import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

class MockupSystemUi extends StatelessWidget {
  const MockupSystemUi({super.key});

  @override
  Widget build(BuildContext context) {
    return const MockupLabels(<(String, Widget)>[
      (
        'systemUi',
        NebaMockup(device: NebaMockupDevice.mobile, width: 140, child: MockupPhoneScreen()),
      ),
      // The bars gave their room back rather than uncovering anything, and the
      // cut-out stayed, because that one is a hole in the glass.
      (
        'systemUi: false',
        NebaMockup(
          device: NebaMockupDevice.mobile,
          systemUi: false,
          width: 140,
          child: MockupPhoneScreen(),
        ),
      ),
    ]);
  }
}
