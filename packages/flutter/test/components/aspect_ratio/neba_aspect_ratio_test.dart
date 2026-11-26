// NebaAspectRatio: the suite the React package runs on AspectRatio, asked the
// way Flutter asks it — the size laid out and the fit and clip built, rather
// than the inline style and the classes.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

/// A one-pixel transparent PNG, so an [Image] has something to decode.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget box, {double width = 320, NebaDefaults? defaults}) {
    final Widget sized = Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: box),
    );

    return tester.pumpWidget(
      host(defaults == null ? sized : NebaProvider(defaults: defaults, child: sized)),
    );
  }

  Size boxSize(WidgetTester tester) => tester.getSize(find.byType(NebaAspectRatio));

  ClipRRect clipOf(WidgetTester tester) => tester.widget<ClipRRect>(find.byType(ClipRRect));

  group('rendering', () {
    testWidgets('holds its child, stretched to the box', (WidgetTester tester) async {
      await pump(tester, const NebaAspectRatio(child: Text('Content')));

      expect(find.text('Content'), findsOneWidget);
      expect(
        tester.getSize(
          find.ancestor(of: find.text('Content'), matching: find.byType(SizedBox)).first,
        ),
        const Size(320, 320),
      );
    });

    testWidgets('draws nothing of its own', (WidgetTester tester) async {
      await pump(tester, const NebaAspectRatio(child: Text('Content')));

      expect(
        find.descendant(of: find.byType(NebaAspectRatio), matching: find.byType(DecoratedBox)),
        findsNothing,
      );
      expect(clipOf(tester).borderRadius, BorderRadius.zero);
    });
  });

  group('ratio', () {
    testWidgets('is square by default', (WidgetTester tester) async {
      await pump(tester, const NebaAspectRatio());

      expect(boxSize(tester), const Size(320, 320));
    });

    testWidgets('holds the proportion it was given, at the width it was given', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAspectRatio(ratio: 16 / 9));
      expect(boxSize(tester), const Size(320, 180));

      await pump(tester, const NebaAspectRatio(ratio: 16 / 9), width: 640);
      expect(boxSize(tester), const Size(640, 360));
    });

    testWidgets('reflects a changed ratio on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaAspectRatio(ratio: 2));
      expect(boxSize(tester).height, 160);

      await pump(tester, const NebaAspectRatio(ratio: 4));
      expect(boxSize(tester).height, 80);
    });

    testWidgets('keeps its height whether the content has arrived or not', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAspectRatio(ratio: 4 / 3));
      final Size empty = boxSize(tester);

      await pump(
        tester,
        const NebaAspectRatio(
          ratio: 4 / 3,
          child: SizedBox(height: 900, child: Text('Tall')),
        ),
      );
      expect(boxSize(tester), empty);
    });
  });

  group('fit', () {
    Widget image() => Image.memory(_pixel);

    testWidgets('covers an image by default, stretched to the box', (WidgetTester tester) async {
      await pump(tester, NebaAspectRatio(child: image()));

      final Finder fitted = find.byType(FittedBox);

      expect(tester.widget<FittedBox>(fitted).fit, BoxFit.cover);
      expect(tester.getSize(fitted), const Size(320, 320));
    });

    testWidgets('takes the other fits', (WidgetTester tester) async {
      for (final BoxFit fit in <BoxFit>[
        BoxFit.contain,
        BoxFit.fill,
        BoxFit.none,
        BoxFit.scaleDown,
      ]) {
        await pump(tester, NebaAspectRatio(fit: fit, child: image()));

        expect(tester.widget<FittedBox>(find.byType(FittedBox)).fit, fit, reason: fit.name);
      }
    });

    testWidgets('does not reach anything that is not an image', (WidgetTester tester) async {
      await pump(tester, const NebaAspectRatio(fit: BoxFit.contain, child: Text('Content')));

      expect(find.byType(FittedBox), findsNothing);
    });

    testWidgets('clips what runs past the box', (WidgetTester tester) async {
      await pump(tester, NebaAspectRatio(ratio: 2, child: image()));

      expect(clipOf(tester).clipBehavior, isNot(Clip.none));
    });
  });

  group('rounded', () {
    testWidgets('cuts the corners to the size step of the radius ladder', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAspectRatio(rounded: true));
      expect(clipOf(tester).borderRadius, BorderRadius.circular(tokens.radius[NebaSize.md]!));

      await pump(tester, const NebaAspectRatio(rounded: true, size: NebaSize.lg));
      expect(clipOf(tester).borderRadius, BorderRadius.circular(tokens.radius[NebaSize.lg]!));
    });

    testWidgets('takes the size from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAspectRatio(rounded: true),
        defaults: const NebaDefaults(size: NebaSize.xs),
      );

      expect(clipOf(tester).borderRadius, BorderRadius.circular(tokens.radius[NebaSize.xs]!));
    });
  });
}
