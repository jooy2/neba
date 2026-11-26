// That the files pub.dev reads stay under the size it accepts.
//
// pub.dev refuses a package whose changelog, readme or licence is over
// 256 KiB, and it says so only when the version is being published. The React
// package's changelog is already past that, so this one is held to it from
// the first release.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final String name in <String>['CHANGELOG.md', 'README.md', 'LICENSE']) {
    test('$name is under 256 KiB', () {
      expect(File(name).lengthSync(), lessThan(256 * 1024));
    });
  }
}
