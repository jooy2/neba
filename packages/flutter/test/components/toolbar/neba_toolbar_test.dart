// NebaToolbar: the suite the React package runs on Toolbar, asked the way
// Flutter asks it — where each slot lands, the padding and the sheet the bar
// is drawn with, and where a pinned bar goes — rather than the classes it
// writes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget bar, {EdgeInsets padding = EdgeInsets.zero}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: const Size(800, 600), padding: padding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 600, child: bar),
          ),
        ),
      ),
    );
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  double padTop(WidgetTester tester, String text) {
    return tester.getRect(find.text(text)).top - tester.getRect(find.byType(NebaToolbar)).top;
  }

  double padBottom(WidgetTester tester, String text) {
    return tester.getRect(find.byType(NebaToolbar)).bottom - tester.getRect(find.text(text)).bottom;
  }

  group('rendering', () {
    testWidgets('lays out its three slots in order', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToolbar(
          start: <Widget>[Text('Start')],
          end: <Widget>[Text('End')],
          children: <Widget>[Text('Middle')],
        ),
      );

      final double start = tester.getRect(find.text('Start')).left;
      final double middle = tester.getRect(find.text('Middle')).left;
      final double end = tester.getRect(find.text('End')).left;

      expect(start, lessThan(middle));
      expect(middle, lessThan(end));
    });

    testWidgets('holds the ends apart even with nothing in the middle', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolbar(start: <Widget>[Text('Start')], end: <Widget>[Text('End')]),
      );

      final Rect bar = tester.getRect(find.byType(NebaToolbar));
      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      // The hairline of the outline sheet is a pixel of its own.
      expect(tester.getRect(find.text('Start')).left, bar.left + padding + 1);
      expect(tester.getRect(find.text('End')).right, bar.right - padding - 1);
    });

    testWidgets('spaces the widgets of a slot 8 pixels apart', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToolbar(
          start: <Widget>[
            SizedBox(key: Key('a'), width: 20, height: 20),
            SizedBox(key: Key('b'), width: 20, height: 20),
          ],
        ),
      );

      final double gap =
          tester.getRect(find.byKey(const Key('b'))).left -
          tester.getRect(find.byKey(const Key('a'))).right;

      expect(gap, 8);
    });

    testWidgets('reflects changed slots on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaToolbar(start: <Widget>[Text('One')]));
      await pump(tester, const NebaToolbar(start: <Widget>[Text('Two')]));

      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('takes the width it is given', (WidgetTester tester) async {
      await pump(tester, const NebaToolbar(start: <Widget>[Text('Start')]));

      expect(tester.getSize(find.byType(NebaToolbar)).width, 600);
    });

    testWidgets('does not claim a focus stop or a node it does not implement', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolbar(start: <Widget>[Text('Start')], children: <Widget>[Text('Middle')]),
      );

      Finder within(Type type) {
        return find.descendant(of: find.byType(NebaToolbar), matching: find.byType(type));
      }

      expect(within(Focus), findsNothing);
      expect(within(Semantics), findsNothing);
    });
  });

  group('position', () {
    testWidgets('sits in the flow by default, with the corners of a sheet', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToolbar(start: <Widget>[Text('Start')]));

      expect(sheetOf(tester).borderRadius, BorderRadius.circular(tokens.radius[NebaSize.md]!));
    });

    testWidgets('drops its corners once it is held against an edge', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToolbar(position: NebaPosition.sticky, start: <Widget>[Text('Start')]),
      );

      expect(sheetOf(tester).borderRadius, BorderRadius.zero);
    });

    testWidgets('keeps a pinned bar clear of the screen inset on its edge', (
      WidgetTester tester,
    ) async {
      const EdgeInsets notch = EdgeInsets.only(top: 20, bottom: 30);
      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      await pump(
        tester,
        const NebaToolbar(position: NebaPosition.sticky, start: <Widget>[Text('Start')]),
        padding: notch,
      );

      expect(padTop(tester, 'Start'), padding + 1 + 20);
      expect(padBottom(tester, 'Start'), padding + 1);

      await pump(
        tester,
        const NebaToolbar(
          position: NebaPosition.sticky,
          side: NebaSide.bottom,
          start: <Widget>[Text('Start')],
        ),
        padding: notch,
      );

      expect(padTop(tester, 'Start'), padding + 1);
      expect(padBottom(tester, 'Start'), padding + 1 + 30);
    });

    testWidgets('leaves the inset alone in the flow or when told to', (WidgetTester tester) async {
      const EdgeInsets notch = EdgeInsets.only(top: 20);
      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      await pump(tester, const NebaToolbar(start: <Widget>[Text('Start')]), padding: notch);

      expect(padTop(tester, 'Start'), padding + 1);

      await pump(
        tester,
        const NebaToolbar(
          position: NebaPosition.sticky,
          safeArea: false,
          start: <Widget>[Text('Start')],
        ),
        padding: notch,
      );

      expect(padTop(tester, 'Start'), padding + 1);
    });

    testWidgets('leaves the flow for the overlay when fixed', (WidgetTester tester) async {
      Future<void> place(NebaSide side) {
        return tester.pumpWidget(
          host(
            Overlay(
              // A new overlay for each side: an entry keeps the builder it
              // was first given.
              key: ValueKey<NebaSide>(side),
              initialEntries: <OverlayEntry>[
                OverlayEntry(
                  builder: (BuildContext context) => Column(
                    children: <Widget>[
                      NebaToolbar(
                        position: NebaPosition.fixed,
                        side: side,
                        start: const <Widget>[Text('Start')],
                      ),
                      const Text('Below'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      await place(NebaSide.top);

      final Rect overlay = tester.getRect(find.byType(Overlay));
      Rect bar = tester.getRect(find.byType(NebaSheet));

      // Nothing is held open where it was written.
      expect(tester.getRect(find.text('Below')).top, overlay.top);
      expect(bar.top, overlay.top);
      expect(bar.width, overlay.width);

      await place(NebaSide.bottom);
      bar = tester.getRect(find.byType(NebaSheet));

      expect(bar.bottom, overlay.bottom);
      expect(bar.width, overlay.width);
    });

    testWidgets('turns its divider to face the content', (WidgetTester tester) async {
      Border? border() {
        final Iterable<Border> found = tester
            .widgetList<Container>(
              find.descendant(of: find.byType(NebaToolbar), matching: find.byType(Container)),
            )
            .map((Container container) => container.decoration)
            .whereType<BoxDecoration>()
            .map((BoxDecoration decoration) => decoration.border)
            .whereType<Border>();

        return found.isEmpty ? null : found.single;
      }

      final BorderSide rule = BorderSide(color: tokens.roles(NebaColor.primary).line);

      await pump(
        tester,
        const NebaToolbar(variant: NebaVariant.solid, divider: true, start: <Widget>[Text('S')]),
      );
      expect(border(), Border(bottom: rule));

      await pump(
        tester,
        const NebaToolbar(
          variant: NebaVariant.solid,
          divider: true,
          side: NebaSide.bottom,
          start: <Widget>[Text('S')],
        ),
      );
      expect(border(), Border(top: rule));

      // An outline bar's own hairline is already there.
      await pump(tester, const NebaToolbar(divider: true, start: <Widget>[Text('S')]));
      expect(border(), isNull);
    });

    testWidgets('gives the divider a pixel of its own', (WidgetTester tester) async {
      await pump(tester, const NebaToolbar(variant: NebaVariant.solid, start: <Widget>[Text('S')]));
      final double plain = tester.getSize(find.byType(NebaToolbar)).height;

      await pump(
        tester,
        const NebaToolbar(variant: NebaVariant.solid, divider: true, start: <Widget>[Text('S')]),
      );

      expect(tester.getSize(find.byType(NebaToolbar)).height, plain + 1);
    });
  });

  group('style', () {
    testWidgets('changes only its padding with density', (WidgetTester tester) async {
      TextStyle styleOf() {
        return tester
            .widget<RichText>(find.descendant(of: find.text('S'), matching: find.byType(RichText)))
            .text
            .style!;
      }

      await pump(tester, const NebaToolbar(start: <Widget>[Text('S')]));
      final double standard = padTop(tester, 'S');
      final double? size = styleOf().fontSize;

      await pump(
        tester,
        const NebaToolbar(density: NebaDensity.compact, start: <Widget>[Text('S')]),
      );

      expect(standard, NebaBox.padding[NebaDensity.standard]![NebaSize.md]! + 1);
      expect(padTop(tester, 'S'), NebaBox.padding[NebaDensity.compact]![NebaSize.md]! + 1);
      expect(styleOf().fontSize, size);
    });

    testWidgets('keeps its sheet undyed, exactly as a Box does', (WidgetTester tester) async {
      await pump(tester, const NebaToolbar(color: NebaColor.danger, start: <Widget>[Text('S')]));

      expect(sheetOf(tester).fill, tokens.panel);
      expect(sheetOf(tester).edge, tokens.roles(NebaColor.danger).line);

      await pump(
        tester,
        const NebaToolbar(
          variant: NebaVariant.solid,
          color: NebaColor.danger,
          start: <Widget>[Text('S')],
        ),
      );

      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(sheetOf(tester).edge, isNull);

      await pump(tester, const NebaToolbar(variant: NebaVariant.text, start: <Widget>[Text('S')]));

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('is flat by default and maps elevation onto the shadow scale', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToolbar(start: <Widget>[Text('S')]));
      expect(sheetOf(tester).elevation, 0);

      await pump(tester, const NebaToolbar(elevation: 2, start: <Widget>[Text('S')]));
      expect(sheetOf(tester).elevation, 2);
    });

    testWidgets('takes its size and density from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.lg, density: NebaDensity.compact),
          child: NebaToolbar(start: <Widget>[Text('S')]),
        ),
      );

      expect(padTop(tester, 'S'), NebaBox.padding[NebaDensity.compact]![NebaSize.lg]! + 1);
    });
  });
}
