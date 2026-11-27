// That every demo builds, in both themes and on the narrowest phone, 320
// pixels wide, without an exception or an overflow, and with semantics on at
// that width, where a role the semantics tree refuses (two unnamed landmarks
// of one kind, say) throws.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';
import 'package:neba_example/main.dart';

/// The demos wider than 320 pixels by what they show rather than by a row
/// that does not give way, and why.
const Map<String, String> _widerThanAPhone = <String, String>{
  // Seven cells at `lg` are 308 pixels before the sheet's padding, as they
  // are in the React package: a calendar is as wide as its size says.
  'calendar/marks': 'a calendar at lg',
  // `Mod+Alt+Shift+Delete` written out in words, as it is everywhere but on a
  // Mac, in the monospaced face the gallery does not bundle, which a test
  // then draws a full em wide per letter.
  'shortcut/keys': 'key caps in a face the test cannot load',
};

void main() {
  // The face the gallery draws in, so a phone's width is measured in the
  // letters a phone shows rather than in the test font's squares, which are
  // nearly twice as wide.
  setUpAll(() async {
    final FontLoader inter = FontLoader(galleryFont);

    for (final String face in <String>['Regular', 'SemiBold']) {
      inter.addFont(File('assets/fonts/Inter-$face.ttf').readAsBytes().then(ByteData.sublistView));
    }

    await inter.load();
  });

  for (final MapEntry<String, Widget Function()> demo in demos.entries) {
    for (final NebaColorScheme scheme in <NebaColorScheme>[
      NebaColorScheme.light,
      NebaColorScheme.dark,
    ]) {
      testWidgets('${demo.key} builds in the ${scheme.name} theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          GalleryApp(query: <String, String>{'demo': demo.key, 'theme': scheme.name}),
        );
        // A second of frames rather than a settle: a busy button's ring turns
        // for as long as it is on screen, so some demos never settle.
        await tester.pump(const Duration(seconds: 1));

        expect(tester.takeException(), isNull);

        // Gone, so nothing is left running when the test ends.
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  // And once at the narrowest phone's width, where a row that does not give
  // way overflows.
  for (final MapEntry<String, Widget Function()> demo in demos.entries) {
    testWidgets('${demo.key} fits a phone', skip: _widerThanAPhone.containsKey(demo.key), (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(GalleryApp(query: <String, String>{'demo': demo.key}));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });
  }

  testWidgets('lists every demo without a query', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.text(demos.keys.first), findsOneWidget);
  });
}
