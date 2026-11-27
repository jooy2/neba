// NebaSkeleton: the suite the React package runs on Skeleton, asked the way
// Flutter asks it — the size of each shape, the lines of a paragraph, what a
// screen reader is told, and that the light moves without a transform.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child, {bool reduced = false}) {
    return tester.pumpWidget(
      host(
        Center(child: SizedBox(width: 300, child: child)),
        disableAnimations: reduced,
      ),
    );
  }

  List<Rect> shapes(WidgetTester tester) {
    return tester
        .elementList(
          find.descendant(of: find.byType(NebaSkeleton), matching: find.byType(CustomPaint)),
        )
        .map((Element e) => tester.getRect(find.byElementPredicate((Element x) => x == e)))
        .toList();
  }

  testWidgets('is a bar the height of a line of body text, the width it is given', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaSkeleton());
    expect(shapes(tester).single.size, const Size(300, 13));

    await pump(tester, const NebaSkeleton(size: NebaSize.xl));
    expect(shapes(tester).single.height, 17);
  });

  testWidgets('stacks lines, the last one shorter', (WidgetTester tester) async {
    await pump(tester, const NebaSkeleton(lines: 3));

    final List<Rect> bars = shapes(tester);
    expect(bars, hasLength(3));
    expect(bars[0].width, 300);
    expect(bars[2].width, moreOrLessEquals(180));
    expect(bars[1].top - bars[0].bottom, 9);
  });

  testWidgets('draws a block and a disc on the ladder, or at a size of its own', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaSkeleton(shape: NebaSkeletonShape.rect));
    expect(shapes(tester).single.size, const Size(300, 80));

    await pump(tester, const NebaSkeleton(shape: NebaSkeletonShape.rect, height: 120, width: 200));
    expect(shapes(tester).single.size, const Size(200, 120));

    await pump(tester, const NebaSkeleton(shape: NebaSkeletonShape.circle, size: NebaSize.lg));
    expect(shapes(tester).single.size, const Size.square(40));
  });

  testWidgets('says nothing without a label, and its label as a status with one', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const NebaSkeleton(semanticLabel: 'Loading comments'));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Loading comments')),
      matchesSemantics(label: 'Loading comments', isLiveRegion: true),
    );

    semantics.dispose();
  });

  testWidgets('moves its light without a transform, and keeps going', (WidgetTester tester) async {
    await pump(tester, const NebaSkeleton());
    await tester.pump(const Duration(milliseconds: 700));

    expect(tester.hasRunningAnimations, isTrue);
    expect(
      find.descendant(of: find.byType(NebaSkeleton), matching: find.byType(Transform)),
      findsNothing,
    );
  });

  testWidgets('holds still when not animated', (WidgetTester tester) async {
    await pump(tester, const NebaSkeleton(animated: false));

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('still breathes under reduced motion', (WidgetTester tester) async {
    await pump(tester, const NebaSkeleton(), reduced: true);
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('takes no width where there is no limit, and never throws', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[NebaSkeleton()]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
