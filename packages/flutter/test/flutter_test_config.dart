// Run before every test file in this folder.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/focus_ring.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // The binding a widget test would create on its own, made up front so that
  // a plain test has a keyboard to reset too.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Every test starts as if nothing had been pressed yet, and with the key
  // listener the test binding took away after the last test attached again.
  setUp(NebaInputModality.reset);

  await testMain();
}
