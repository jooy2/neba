// NebaBadge: the suite the React package runs on Badge, asked the way
// Flutter asks it — what the mark says and what a screen reader hears, its
// size, and where it hangs off the thing it is pinned to.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  const Key anchor = Key('anchor');

  Future<void> pump(
    WidgetTester tester,
    Widget badge, {
    TextDirection direction = TextDirection.ltr,
  }) {
    return tester.pumpWidget(host(Center(child: badge), textDirection: direction));
  }

  Rect markOf(WidgetTester tester) => tester.getRect(find.byType(NebaSheet));

  group('content', () {
    testWidgets('shows a count, capped with a plus past max', (WidgetTester tester) async {
      await pump(tester, const NebaBadge.count(count: 12));
      expect(find.text('12'), findsOneWidget);

      await pump(tester, const NebaBadge.count(count: 120));
      expect(find.text('99+'), findsOneWidget);

      await pump(tester, const NebaBadge.count(count: 12, max: 9));
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('hides a count of zero but keeps its room, unless showZero', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBadge.count(count: 0));
      expect(tester.widget<Visibility>(find.byType(Visibility)).visible, isFalse);

      await pump(tester, const NebaBadge.count(count: 0, showZero: true));
      expect(find.text('0'), findsOneWidget);
      expect(tester.widget<Visibility>(find.byType(Visibility)).visible, isTrue);
    });

    testWidgets('is a dot with no content, on the dot ladder', (WidgetTester tester) async {
      await pump(tester, const NebaBadge());
      expect(markOf(tester).size, const Size.square(10));

      await pump(tester, const NebaBadge(size: NebaSize.xl));
      expect(markOf(tester).size, const Size.square(12));
    });

    testWidgets('is a dot when asked, still saying its count to a screen reader', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaBadge.count(count: 4, dot: true));

      expect(find.text('4'), findsNothing);
      expect(find.bySemanticsLabel('4'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('says its sentence rather than its count', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaBadge.count(count: 3, semanticLabel: '3 unread notifications'));

      expect(find.bySemanticsLabel('3 unread notifications'), findsOneWidget);
      expect(find.bySemanticsLabel('3'), findsNothing);
      semantics.dispose();
    });

    testWidgets('says nothing as a bare dot or while hidden', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaBadge.count(count: 5, invisible: true));
      expect(find.bySemanticsLabel('5'), findsNothing);

      semantics.dispose();
    });
  });

  group('style', () {
    testWidgets('is solid in the primary family by default, on its own height ladder', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBadge.count(count: 3));

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
      expect(sheet.fill, tokens.roles(NebaColor.primary).fill);
      expect(markOf(tester).height, 18);
      expect(markOf(tester).width, greaterThanOrEqualTo(18));

      for (final (NebaSize size, double tall) in <(NebaSize, double)>[
        (NebaSize.xs, 14),
        (NebaSize.lg, 20),
        (NebaSize.xl, 24),
      ]) {
        await pump(tester, NebaBadge.count(count: 3, size: size));
        expect(markOf(tester).height, tall, reason: size.name);
      }
    });

    testWidgets('lays a text badge on its own bed', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBadge.count(count: 3, variant: NebaVariant.text, color: NebaColor.info),
      );

      expect(
        tester.widget<NebaSheet>(find.byType(NebaSheet)).fill,
        Color.alphaBlend(tokens.roles(NebaColor.info).softHover, tokens.surface),
      );
    });
  });

  group('placement', () {
    Widget pinned(NebaBadge Function(Widget child) badge) {
      return badge(const SizedBox(key: anchor, width: 40, height: 40));
    }

    testWidgets('leaves the anchor laid out as it is bare', (WidgetTester tester) async {
      await pump(tester, pinned((Widget c) => NebaBadge.count(count: 3, child: c)));

      expect(tester.getSize(find.byType(NebaBadge)), const Size(40, 40));
    });

    testWidgets('hangs half of a badge past the top-end corner', (WidgetTester tester) async {
      await pump(tester, pinned((Widget c) => NebaBadge.count(count: 3, child: c)));

      final Rect box = tester.getRect(find.byKey(anchor));
      expect(markOf(tester).top, box.top - 8);
      expect(markOf(tester).right, box.right + 8);
    });

    testWidgets('takes the other corners, and turns round under RTL', (WidgetTester tester) async {
      await pump(
        tester,
        pinned((Widget c) => NebaBadge(placement: NebaCorner.bottomStart, child: c)),
      );
      Rect box = tester.getRect(find.byKey(anchor));
      expect(markOf(tester).bottom, box.bottom + 4);
      expect(markOf(tester).left, box.left - 4);

      await pump(
        tester,
        pinned((Widget c) => NebaBadge(placement: NebaCorner.bottomStart, child: c)),
        direction: TextDirection.rtl,
      );
      box = tester.getRect(find.byKey(anchor));
      expect(markOf(tester).right, box.right + 4);
    });

    testWidgets('tucks in by 7% of a round anchor', (WidgetTester tester) async {
      await pump(
        tester,
        pinned((Widget c) => NebaBadge(overlap: NebaBadgeOverlap.circle, child: c)),
      );

      final Rect box = tester.getRect(find.byKey(anchor));
      expect(markOf(tester).top, moreOrLessEquals(box.top - 4 + 40 * 0.07));
      expect(markOf(tester).right, moreOrLessEquals(box.right + 4 - 40 * 0.07));
    });
  });
}
