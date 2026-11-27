// The gallery's pictures are copies of the documentation's, so a demo in Dart
// and its React twin hold the same photograph.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final Directory docs = Directory('../../../docs/public');
  final Directory ours = Directory('assets');

  test('every picture the gallery holds is the docs file of the same name', () {
    final List<File> files = ours
        .listSync(recursive: true)
        .whereType<File>()
        // The font is the gallery's own, not a copy of anything the docs serve.
        .where((File file) => !file.path.startsWith('${ours.path}/fonts/'))
        .where((File file) => !file.path.endsWith('README.md'))
        .toList();

    expect(files, isNotEmpty);

    for (final File file in files) {
      final String relative = file.path.substring(ours.path.length + 1);
      final File original = File('${docs.path}/$relative');

      expect(original.existsSync(), isTrue, reason: '$relative is not under docs/public');
      expect(file.readAsBytesSync(), original.readAsBytesSync(), reason: relative);
    }
  }, skip: docs.existsSync() ? false : 'the documentation is not beside this checkout');
}
