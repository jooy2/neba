// The flows on the host, at a phone's size and a tablet's, with no device.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration_test/flows.dart';

void main() {
  for (final Size size in <Size>[const Size(390, 844), const Size(834, 1194)]) {
    group('at ${size.width.toInt()}×${size.height.toInt()}', () {
      setUp(() {
        final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
        binding.platformDispatcher.views.first.physicalSize = size * 3;
        binding.platformDispatcher.views.first.devicePixelRatio = 3;
      });

      tearDown(() {
        final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
        binding.platformDispatcher.views.first.resetPhysicalSize();
        binding.platformDispatcher.views.first.resetDevicePixelRatio();
      });

      flows();
    });
  }
}
