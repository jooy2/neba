// NebaProgressBox: the suite the React package runs on ProgressBox, asked
// the way Flutter asks it — the plates actually laid out and painted instead
// of their class names and inline widths, and the wave on a running clock
// instead of a keyframe with a delay per plate.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reduced = false,
    TextDirection direction = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Center(child: child),
        disableAnimations: reduced,
        textDirection: direction,
      ),
    );
  }

  SemanticsNode node(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaProgressBox));
  }

  // A plate with any fill over its wash: the wash, then a rectangle in the
  // fill colour. The canvas is matched call by call, so the wash comes first.
  final PaintPattern filled = paints
    ..rect(color: primary.soft)
    ..rect(color: primary.fill);

  Finder plates() {
    return find.descendant(of: find.byType(NebaProgressBox), matching: find.byType(CustomPaint));
  }

  group('rendering', () {
    testWidgets('draws four plates by default, and as many as it is asked for', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressBox(value: 40));
      expect(plates(), findsNWidgets(4));

      await pump(tester, const NebaProgressBox(value: 40, count: 7));
      expect(plates(), findsNWidgets(7));
    });

    testWidgets('never draws a row of none', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 40, count: 0));
      expect(plates(), findsOneWidget);

      await pump(tester, const NebaProgressBox(value: 40, count: -3));
      expect(plates(), findsOneWidget);
    });

    testWidgets('tells a screen reader its reading, named by its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressBox(value: 2, max: 4, label: Text('Building')));
      expect(node(tester), matchesSemantics(label: 'Building', value: '50%'));

      await pump(tester, const NebaProgressBox(value: 2, max: 4, semanticLabel: 'Uploading'));
      expect(node(tester), matchesSemantics(label: 'Uploading', value: '50%'));

      semantics.dispose();
    });

    testWidgets('lays the plates out on the size ladder, a gap apart', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 40));

      final List<Rect> drawn = plates()
          .evaluate()
          .map((Element e) => tester.getRect(find.byWidget(e.widget)))
          .toList();
      expect(drawn.first.size, const Size.square(12));
      expect(drawn[1].left - drawn[0].right, 6);

      await pump(tester, const NebaProgressBox(value: 40, size: NebaSize.xl));
      expect(tester.getSize(plates().first), const Size.square(20));
    });

    testWidgets('is as wide as the row above the plates when that is wider', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaProgressBox(value: 62, label: Text('Migrating'), showValue: true),
      );

      final Rect box = tester.getRect(find.byType(NebaProgressBox));
      expect(tester.getRect(find.text('Migrating')).left, box.left);
      expect(tester.getRect(find.text('62%')).right, box.right);
      expect(tester.getRect(plates().first).left, box.left);
      expect(box.width, greaterThan(4 * 12 + 3 * 6));
    });

    testWidgets('fits where there is no limit', (WidgetTester tester) async {
      await pump(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[NebaProgressBox(value: 40, label: Text('Building'), showValue: true)],
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('the fill', () {
    testWidgets('fills the leading plate partially', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 30));

      final List<Element> row = plates().evaluate().toList();
      expect(
        find.byWidget(row[0].widget),
        paints
          ..rect(color: primary.soft)
          ..path(color: tokens.plateTop)
          ..rect(rect: const Rect.fromLTWH(0, 0, 12, 12), color: primary.fill),
      );
      expect(
        find.byWidget(row[1].widget),
        paints
          ..rect(color: primary.soft)
          ..rect(rect: Rect.fromLTWH(0, 0, 12 * (0.3 * 4 - 1), 12), color: primary.fill),
      );
      expect(find.byWidget(row[2].widget), isNot(filled));
      expect(find.byWidget(row[3].widget), isNot(filled));
    });

    testWidgets('fills every plate at the top of the range', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 100, count: 3));

      for (final Element plate in plates().evaluate()) {
        expect(
          find.byWidget(plate.widget),
          paints
            ..rect(color: primary.soft)
            ..rect(rect: const Rect.fromLTWH(0, 0, 12, 12), color: primary.fill),
        );
      }
    });

    testWidgets('fills from the start edge, the right one under RTL', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 30), direction: TextDirection.rtl);

      final List<Element> row = plates().evaluate().toList();
      expect(
        tester.getRect(find.byWidget(row[0].widget)).left,
        greaterThan(tester.getRect(find.byWidget(row[3].widget)).left),
      );

      final double length = 12 * (0.3 * 4 - 1);
      expect(
        find.byWidget(row[1].widget),
        paints
          ..rect(color: primary.soft)
          ..rect(rect: Rect.fromLTWH(12 - length, 0, length, 12), color: primary.fill),
      );
    });

    testWidgets('shows the value as a percentage of the range', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 2, max: 4, showValue: true));

      expect(find.text('50%'), findsOneWidget);
    });
  });

  group('indeterminate', () {
    testWidgets('is indeterminate by default, and tells a screen reader it is busy', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressBox(label: Text('Building')));

      expect(node(tester), matchesSemantics(label: 'Building'));
      expect(node(tester).getSemanticsData().role, SemanticsRole.loadingSpinner);

      semantics.dispose();
    });

    testWidgets('lights the plates in turn, each held back by its place', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressBox());
      // The clock starts on the first frame after the plates are built.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));

      final List<Element> row = plates().evaluate().toList();
      expect(tester.hasRunningAnimations, isTrue);
      // The first is lit, with the full hairline of a solid plate.
      expect(
        find.byWidget(row[0].widget),
        paints
          ..rect(color: primary.fill)
          ..rrect(color: tokens.plateEdge, style: PaintingStyle.stroke),
      );
      // The last has only just started on its way.
      expect(find.byWidget(row[3].widget), isNot(paints..rect(color: primary.fill)));
      expect(
        find.descendant(of: find.byType(NebaProgressBox), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('stops cycling once it is given a value', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox());
      await pump(tester, const NebaProgressBox(value: 40));
      await tester.pumpAndSettle();

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('still cycles, more slowly, under reduced motion', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(), reduced: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));

      expect(tester.hasRunningAnimations, isTrue);
      // A third of the way into a pass at full speed, a sixth at half.
      expect(
        find.byWidget(plates().evaluate().first.widget),
        isNot(paints..rect(color: primary.fill)),
      );
    });
  });

  group('style props', () {
    testWidgets('draws the plates in its colour family', (WidgetTester tester) async {
      await pump(tester, const NebaProgressBox(value: 100, count: 1, color: NebaColor.info));

      final NebaColorRoles info = tokens.roles(NebaColor.info);
      expect(
        plates(),
        paints
          ..rect(color: info.soft)
          ..rect(color: info.fill),
      );
    });
  });
}
