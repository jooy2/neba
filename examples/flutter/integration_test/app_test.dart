// The flows on a simulator, an emulator or a real device.
//
//   flutter test integration_test -d <device>
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/app_test.dart -d <device>
//
// `examples/README.md` says how to start a device without its window.

import 'package:integration_test/integration_test.dart';

import 'flows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  flows();
}
