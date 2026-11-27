import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

class MockupFinish extends StatelessWidget {
  const MockupFinish({super.key});

  @override
  Widget build(BuildContext context) {
    return MockupLabels(<(String, Widget)>[
      for (final NebaMockupFinish finish in NebaMockupFinish.values)
        (
          finish.name,
          NebaMockup(device: NebaMockupDevice.mobile, finish: finish, elevation: 1, width: 112),
        ),
    ]);
  }
}
