// NebaBox: the suite the React package runs on Box, asked the way Flutter asks
// it — the sheet it builds instead of the classes it carries.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget box, {NebaDefaults? defaults}) {
    return tester.pumpWidget(
      host(
        Center(
          child: defaults == null ? box : NebaProvider(defaults: defaults, child: box),
        ),
      ),
    );
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  EdgeInsets paddingOf(WidgetTester tester) {
    return tester
        .widget<Padding>(
          find.ancestor(of: find.text('Content'), matching: find.byType(Padding)).first,
        )
        .padding
        .resolve(TextDirection.ltr);
  }

  group('rendering', () {
    testWidgets('holds its child, and a changed child on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaBox(child: Text('Content')));
      expect(find.text('Content'), findsOneWidget);

      await pump(tester, const NebaBox(child: Text('Other')));
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('never applies a transform, so nothing in the box can move', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBox(variant: NebaVariant.solid, child: Text('Content')));

      expect(
        find.descendant(of: find.byType(NebaBox), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });

  group('style props', () {
    testWidgets('is an outline in the primary family by default', (WidgetTester tester) async {
      await pump(tester, const NebaBox(child: Text('Content')));

      expect(sheetOf(tester).edge, tokens.roles(NebaColor.primary).line);
      expect(sheetOf(tester).plate, NebaPlate.glass);
    });

    testWidgets('puts color on the hairline and leaves the sheet undyed', (
      WidgetTester tester,
    ) async {
      for (final NebaColor color in NebaColor.values) {
        await pump(tester, NebaBox(color: color, child: const Text('Content')));

        expect(sheetOf(tester).edge, tokens.roles(color).line, reason: color.name);
        expect(sheetOf(tester).fill, tokens.panel, reason: color.name);
      }
    });

    testWidgets('is flat by default and maps elevation onto the shadow ladder', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBox(child: Text('Content')));
      expect(sheetOf(tester).elevation, 0);

      await pump(tester, const NebaBox(elevation: 2, child: Text('Content')));
      expect(sheetOf(tester).elevation, 2);
    });

    testWidgets('changes the radius with size, and nothing else', (WidgetTester tester) async {
      await pump(tester, const NebaBox(child: Text('Content')));
      final Size md = tester.getSize(find.byType(NebaBox));

      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaBox(size: size, padded: false, child: const Text('Content')));

        expect(sheetOf(tester).borderRadius, BorderRadius.circular(tokens.radius[size]!));
      }

      await pump(tester, const NebaBox(padded: false, child: Text('Content')));
      expect(tester.getSize(find.byType(NebaBox)).height, lessThan(md.height));
    });

    testWidgets('changes padding with size and with density', (WidgetTester tester) async {
      await pump(tester, const NebaBox(child: Text('Content')));
      expect(paddingOf(tester), const EdgeInsets.all(16));

      await pump(tester, const NebaBox(size: NebaSize.xl, child: Text('Content')));
      expect(paddingOf(tester), const EdgeInsets.all(24));

      await pump(tester, const NebaBox(density: NebaDensity.compact, child: Text('Content')));
      expect(paddingOf(tester), const EdgeInsets.all(10));
    });

    testWidgets('drops the padding entirely when padded is false', (WidgetTester tester) async {
      await pump(tester, const NebaBox(padded: false, child: Text('Content')));

      // What is left is the sheet's own: a zero padding for its decoration, and
      // the pixel an outline's hairline takes, as a CSS border does.
      final Iterable<Padding> paddings = tester.widgetList<Padding>(
        find.ancestor(of: find.text('Content'), matching: find.byType(Padding)),
      );

      expect(
        paddings.map((Padding padding) => padding.padding.resolve(TextDirection.ltr)),
        everyElement(anyOf(EdgeInsets.zero, const EdgeInsets.all(1))),
      );
    });

    testWidgets('draws a hairline for the outline variant only', (WidgetTester tester) async {
      await pump(tester, const NebaBox(variant: NebaVariant.solid, child: Text('Content')));

      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(sheetOf(tester).plate, NebaPlate.solid);
    });

    testWidgets('gives the text variant no sheet and no shadow', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBox(variant: NebaVariant.text, elevation: 3, child: Text('Content')),
      );

      expect(find.byType(NebaSheet), findsNothing);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('takes size, density and variant from the provider, and its own over them', (
      WidgetTester tester,
    ) async {
      const NebaDefaults defaults = NebaDefaults(
        size: NebaSize.xl,
        density: NebaDensity.compact,
        variant: NebaVariant.solid,
      );

      await pump(tester, const NebaBox(child: Text('Content')), defaults: defaults);
      expect(paddingOf(tester), const EdgeInsets.all(16));
      expect(sheetOf(tester).plate, NebaPlate.solid);

      await pump(
        tester,
        const NebaBox(variant: NebaVariant.outline, child: Text('Content')),
        defaults: defaults,
      );
      expect(sheetOf(tester).plate, NebaPlate.glass);
    });
  });
}
