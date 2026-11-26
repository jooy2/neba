// That the generated files are up to date.
//
// `lib/neba.dart` and the gallery's demo registry are lists of other files,
// and a list somebody has to remember to update is a list that is wrong. This
// runs the generator in its checking mode, which writes nothing.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the barrel and the demo registry match the files on disk', () async {
    final ProcessResult result = await Process.run('dart', <String>[
      'run',
      'tool/generate.dart',
      '--check',
    ]);

    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
