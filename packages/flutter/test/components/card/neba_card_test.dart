// NebaCard: the suite the React package runs on Card, asked the way Flutter
// asks it — where each section lands, the type it is set in, and the sheet
// and lines it is drawn on — rather than the elements and classes it writes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget card, {double width = 320}) {
    return tester.pumpWidget(
      host(
        Center(
          child: SizedBox(width: width, child: card),
        ),
      ),
    );
  }

  Rect rectOf(WidgetTester tester, String text) => tester.getRect(find.text(text));

  TextStyle styleOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!;
  }

  Iterable<Border> borders(WidgetTester tester) {
    return tester
        .widgetList<DecoratedBox>(
          find.descendant(of: find.byType(NebaCard), matching: find.byType(DecoratedBox)),
        )
        .map((DecoratedBox box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((BoxDecoration decoration) => decoration.border)
        .whereType<Border>();
  }

  const NebaCard full = NebaCard(
    title: Text('Title'),
    subtitle: Text('Subtitle'),
    footer: Text('Footer'),
    child: Text('Body'),
  );

  group('structure', () {
    testWidgets('renders the title, the subtitle, the body and the footer in order', (
      WidgetTester tester,
    ) async {
      await pump(tester, full);

      final List<double> tops = <String>[
        'Title',
        'Subtitle',
        'Body',
        'Footer',
      ].map((String text) => rectOf(tester, text).top).toList();

      expect(tops, orderedEquals(<double>[...tops]..sort()));
      expect(tops.toSet(), hasLength(4));
    });

    testWidgets('builds nothing for a section it was given nothing for', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCard(child: Text('Body')));

      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;
      final Rect sheet = tester.getRect(find.byType(NebaSheet));

      // Only the body, so the sheet is the body and its padding.
      expect(rectOf(tester, 'Body').top - sheet.top, padding + 1);
      expect(sheet.bottom - rectOf(tester, 'Body').bottom, padding + 1);
    });

    testWidgets('renders a header with no body and no footer', (WidgetTester tester) async {
      await pump(tester, const NebaCard(title: Text('Title')));

      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('pins headerAction to the end of the header row', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCard(
          title: Text('Title'),
          headerAction: SizedBox.square(key: Key('action'), dimension: 20),
        ),
      );

      final Rect sheet = tester.getRect(find.byType(NebaSheet));
      final Rect action = tester.getRect(find.byKey(const Key('action')));
      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      expect(sheet.right - action.right, padding + 1);
      expect(action.top, rectOf(tester, 'Title').top);
    });

    testWidgets('pins a header made only of an action to the end', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCard(headerAction: SizedBox.square(key: Key('action'), dimension: 20)),
      );

      final Rect sheet = tester.getRect(find.byType(NebaSheet));
      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      expect(sheet.right - tester.getRect(find.byKey(const Key('action'))).right, padding + 1);
    });

    testWidgets('wraps a long title beside the action instead of running under it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaCard(
          title: Text('A title long enough that it has to wrap onto a second line'),
          headerAction: SizedBox.square(key: Key('action'), dimension: 20),
        ),
        width: 200,
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.textContaining('A title')).right,
        lessThanOrEqualTo(tester.getRect(find.byKey(const Key('action'))).left),
      );
    });

    testWidgets('reflects a changed title on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaCard(title: Text('Draft')));
      await pump(tester, const NebaCard(title: Text('Published')));

      expect(find.text('Published'), findsOneWidget);
    });
  });

  group('type', () {
    testWidgets('sets the title semibold one step above the body, and the subtitle muted', (
      WidgetTester tester,
    ) async {
      await pump(tester, full);

      expect(styleOf(tester, 'Title').fontSize, 15);
      expect(styleOf(tester, 'Title').fontWeight, FontWeight.w600);
      expect(styleOf(tester, 'Subtitle').fontSize, 12);
      expect(styleOf(tester, 'Subtitle').color, tokens.mutedFg);
      expect(styleOf(tester, 'Body').fontSize, 13);
      expect(styleOf(tester, 'Body').height, 22 / 13);
      expect(styleOf(tester, 'Footer').fontSize, 13);
    });

    testWidgets('steps every section with size', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCard(size: NebaSize.xl, title: Text('Title'), child: Text('Body')),
      );

      expect(styleOf(tester, 'Title').fontSize, 20);
      expect(styleOf(tester, 'Body').fontSize, 17);
    });

    testWidgets('keeps the title type for a heading the caller marks as one', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaCard(title: Semantics(header: true, child: const Text('Invite'))));

      expect(styleOf(tester, 'Invite').fontSize, 15);
      expect(
        tester.getSemantics(find.text('Invite')),
        matchesSemantics(label: 'Invite', isHeader: true, textDirection: TextDirection.ltr),
      );
      semantics.dispose();
    });
  });

  group('dividers', () {
    testWidgets('separates the sections with space by default', (WidgetTester tester) async {
      await pump(tester, full);

      expect(borders(tester), isEmpty);
      expect(
        rectOf(tester, 'Body').top - rectOf(tester, 'Subtitle').bottom,
        NebaScale.sheetSectionGap[NebaSize.md],
      );
    });

    testWidgets('draws a hairline above every section but the first', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCard(
          dividers: true,
          color: NebaColor.success,
          title: Text('Title'),
          footer: Text('Footer'),
          child: Text('Body'),
        ),
      );

      final List<Border> lines = borders(tester).toList();

      expect(lines, hasLength(2));
      for (final Border line in lines) {
        expect(line.top.color, tokens.roles(NebaColor.success).line);
        expect(line.bottom, BorderSide.none);
      }
    });

    testWidgets('moves the padding from the sheet onto each section', (WidgetTester tester) async {
      await pump(tester, const NebaCard(dividers: true, title: Text('Title'), child: Text('Body')));

      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;
      final Rect sheet = tester.getRect(find.byType(NebaSheet));

      expect(rectOf(tester, 'Title').top - sheet.top, padding + 1);
      // The body's own padding below the line, and the title's above it.
      expect(rectOf(tester, 'Body').top - rectOf(tester, 'Title').bottom, padding * 2 + 1);
    });
  });

  group('style props', () {
    testWidgets('is an outline sheet by default', (WidgetTester tester) async {
      await pump(tester, full);

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
      expect(sheet.plate, NebaPlate.glass);
      expect(sheet.edge, tokens.roles(NebaColor.primary).line);
    });

    testWidgets('passes the box axes through to the sheet', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCard(
          variant: NebaVariant.solid,
          elevation: 2,
          size: NebaSize.lg,
          child: Text('Body'),
        ),
      );

      final NebaBox box = tester.widget<NebaBox>(find.byType(NebaBox));
      expect(box.variant, NebaVariant.solid);
      expect(box.elevation, 2);
      expect(box.size, NebaSize.lg);
      expect(tester.widget<NebaSheet>(find.byType(NebaSheet)).elevation, 2);
    });

    testWidgets('scales the padding with size and density', (WidgetTester tester) async {
      for (final NebaDensity density in NebaDensity.values) {
        for (final NebaSize size in NebaSize.values) {
          await pump(tester, NebaCard(size: size, density: density, child: const Text('Body')));

          final Rect sheet = tester.getRect(find.byType(NebaSheet));
          expect(
            rectOf(tester, 'Body').left - sheet.left,
            NebaBox.padding[density]![size]! + 1,
            reason: '${size.name} ${density.name}',
          );
        }
      }
    });

    testWidgets('takes its size and density from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.sm, density: NebaDensity.compact),
            child: Center(
              child: SizedBox(width: 320, child: NebaCard(child: Text('Body'))),
            ),
          ),
        ),
      );

      final Rect sheet = tester.getRect(find.byType(NebaSheet));
      expect(rectOf(tester, 'Body').left - sheet.left, 8 + 1);
      expect(styleOf(tester, 'Body').fontSize, 12);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, full);

      expect(
        find.descendant(of: find.byType(NebaCard), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('arrives by its transition', (WidgetTester tester) async {
      await pump(tester, const NebaCard(transition: NebaTransition.fade(), child: Text('Body')));

      final Finder fade = find.ancestor(of: find.byType(NebaSheet), matching: find.byType(Opacity));
      expect(tester.widget<Opacity>(fade.first).opacity, 0);

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(fade.first).opacity, 1);
    });
  });
}
