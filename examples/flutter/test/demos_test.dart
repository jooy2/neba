// Every demo the app shows, laid out the way the app lays it out at three
// screen sizes, a small phone, a large one and a tablet, and every picture a
// demo names, checked to be one the app can load rather than one only the
// documentation site serves.

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';
import 'package:neba_showcase/main.dart';

const List<Size> _screens = <Size>[Size(360, 640), Size(390, 844), Size(834, 1194)];

/// Where the gallery's demos and pictures are, from this app's folder, which
/// is where `flutter test` runs.
const String _gallery = '../../packages/flutter/example';

void main() {
  for (final Size screen in _screens) {
    group('at ${screen.width.toInt()}×${screen.height.toInt()}', () {
      for (final String key in demos.keys) {
        testWidgets('$key lays out', (WidgetTester tester) async {
          tester.view.physicalSize = screen * 3;
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(ShowcaseApp(colorScheme: NebaColorScheme.light, demo: key));
          // A second of frames rather than a settle: a busy control's ring
          // turns for as long as it is on screen.
          await tester.pump(const Duration(seconds: 1));

          expect(tester.takeException(), isNull);

          // Gone, so nothing is left running when the test ends.
          await tester.pumpWidget(const SizedBox());
        });
      }
    });
  }

  test('names no picture only the documentation site can serve', () {
    final List<String> problems = <String>[];
    final RegExp asset = RegExp(r"""AssetImage\(\s*'([^']+)'""");
    final RegExp website = RegExp(r"""NetworkImage\(|Image\.network\(|'/samples/""");

    for (final FileSystemEntity entity in Directory(
      '$_gallery/lib/demos',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final String source = entity.readAsStringSync();
      final String name = entity.path.substring(_gallery.length + 1);

      if (website.hasMatch(source)) {
        problems.add('$name loads a picture from the web or by a site path');
      }

      for (final RegExpMatch match in asset.allMatches(source)) {
        final String path = match[1]!;

        // A demo of a picture that fails to load names one on purpose, and a
        // path built from a name is checked where it is drawn, not here.
        if (path.contains('not-a-real') || path.contains('does-not-exist') || path.contains(r'$')) {
          continue;
        }

        if (!File('$_gallery/$path').existsSync()) {
          problems.add('$name names $path, which the gallery does not bundle');
        }
      }
    }

    expect(problems, isEmpty);
  });
}
