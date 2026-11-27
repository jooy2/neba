import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

class MockupBezel extends StatelessWidget {
  const MockupBezel({super.key});

  @override
  Widget build(BuildContext context) {
    return MockupLabels(<(String, Widget)>[
      for (final NebaMockupBezel bezel in NebaMockupBezel.values)
        (
          bezel.name,
          // `thick` is an older phone rather than a wider frame, and one with
          // that much bezel had nowhere to put a cut-out.
          NebaMockup(
            device: NebaMockupDevice.mobile,
            bezel: bezel,
            notch: bezel == NebaMockupBezel.thick ? NebaMockupNotch.none : null,
            width: 112,
          ),
        ),
    ]);
  }
}
