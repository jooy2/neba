// NebaProgressCircular: the suite the React package runs on
// ProgressCircular, asked the way Flutter asks it — what a screen reader is
// told instead of the ARIA attributes, and the circle and the arc actually
// painted instead of an SVG's stroke attributes.

import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  const double top = -math.pi / 2;

  Future<void> pump(WidgetTester tester, Widget child, {bool reduced = false}) {
    return tester.pumpWidget(host(Center(child: child), disableAnimations: reduced));
  }

  SemanticsNode node(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaProgressCircular));
  }

  Finder ring() {
    return find.descendant(
      of: find.byType(NebaProgressCircular),
      matching: find.byType(CustomPaint),
    );
  }

  group('rendering', () {
    testWidgets('tells a screen reader its reading', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressCircular(value: 40));

      expect(node(tester), matchesSemantics(value: '40%'));

      semantics.dispose();
    });

    testWidgets('is named by its label, or by a name of its own', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressCircular(value: 40, label: Text('Saving')));
      expect(node(tester), matchesSemantics(label: 'Saving', value: '40%'));

      await pump(
        tester,
        const NebaProgressCircular(value: 40, label: Text('Up'), semanticLabel: 'Uploading'),
      );
      expect(node(tester), matchesSemantics(label: 'Uploading', value: '40%'));

      semantics.dispose();
    });

    testWidgets('reflects a changed value on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaProgressCircular(value: 10, showValue: true));
      expect(find.text('10%'), findsOneWidget);

      await pump(tester, const NebaProgressCircular(value: 90, showValue: true));
      expect(find.text('90%'), findsOneWidget);
    });

    testWidgets('sets the label and the value beside the ring, in that order', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaProgressCircular(value: 72, label: Text('Indexing'), showValue: true),
      );

      final Rect drawn = tester.getRect(ring());
      final Rect label = tester.getRect(find.text('Indexing'));
      final Rect value = tester.getRect(find.text('72%'));

      expect(label.left, drawn.right + 6);
      expect(value.left, label.right + 6);
      expect(label.center.dy, moreOrLessEquals(drawn.center.dy, epsilon: 1));
    });

    testWidgets('fits where there is no limit, and cuts a long label short where there is one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NebaProgressCircular(value: 40, label: Text('Indexing'), showValue: true),
          ],
        ),
      );
      expect(tester.takeException(), isNull);

      await pump(
        tester,
        const SizedBox(
          width: 80,
          child: NebaProgressCircular(
            value: 40,
            label: Text('Indexing every file in the workspace'),
            showValue: true,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NebaProgressCircular)).width, 80);
      expect(
        tester.getRect(find.text('40%')).right,
        lessThanOrEqualTo(tester.getRect(find.byType(NebaProgressCircular)).right),
      );
    });
  });

  group('the arc', () {
    testWidgets('starts at the top and runs clockwise as far as the reading', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressCircular(value: 40));

      final Rect circle = Rect.fromCircle(center: const Offset(10, 10), radius: 9);
      expect(
        ring(),
        paints
          ..circle(x: 10, y: 10, radius: 9, strokeWidth: 2)
          ..arc(
            rect: circle,
            startAngle: top,
            sweepAngle: 2 * math.pi * 0.4,
            strokeCap: StrokeCap.round,
          ),
      );
    });

    testWidgets('closes the gap as the value climbs', (WidgetTester tester) async {
      await pump(tester, const NebaProgressCircular(value: 0));
      expect(ring(), isNot(paints..arc()));

      await pump(tester, const NebaProgressCircular(value: 100));
      await tester.pumpAndSettle();
      expect(ring(), paints..arc(startAngle: top, sweepAngle: 2 * math.pi));
    });

    testWidgets('eases to a new reading', (WidgetTester tester) async {
      await pump(tester, const NebaProgressCircular(value: 0));
      await pump(tester, const NebaProgressCircular(value: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(ring(), isNot(paints..arc(sweepAngle: 2 * math.pi)));

      await tester.pumpAndSettle();
      expect(ring(), paints..arc(sweepAngle: 2 * math.pi));
    });

    testWidgets('grows with size, just under the control ladder', (WidgetTester tester) async {
      final Map<NebaSize, double> diameters = <NebaSize, double>{
        NebaSize.xs: 14,
        NebaSize.sm: 16,
        NebaSize.md: 20,
        NebaSize.lg: 26,
        NebaSize.xl: 32,
      };

      for (final MapEntry<NebaSize, double> step in diameters.entries) {
        await pump(tester, NebaProgressCircular(value: 40, size: step.key));
        expect(tester.getSize(ring()), Size.square(step.value), reason: step.key.name);
      }
    });

    testWidgets('takes its size from NebaProvider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.xl),
          child: NebaProgressCircular(value: 40),
        ),
      );

      expect(tester.getSize(ring()), const Size.square(32));
    });
  });

  group('thickness', () {
    testWidgets('takes a stroke of its own over the step it would have had', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressCircular(value: 40, size: NebaSize.xl, thickness: 6));

      expect(ring(), paints..circle(strokeWidth: 6, radius: 13));
    });

    testWidgets('holds the stroke to half the radius, so a hole remains', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressCircular(value: 40, thickness: 400));

      expect(ring(), paints..circle(strokeWidth: 5, radius: 7.5));
    });
  });

  group('indeterminate', () {
    testWidgets('is indeterminate by default, and tells a screen reader it is busy', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressCircular(label: Text('Saving')));

      expect(node(tester), matchesSemantics(label: 'Saving'));
      expect(node(tester).getSemanticsData().role, SemanticsRole.loadingSpinner);

      semantics.dispose();
    });

    testWidgets('turns a quarter of the ring, without a transform', (WidgetTester tester) async {
      await pump(tester, const NebaProgressCircular());

      expect(ring(), paints..arc(startAngle: top, sweepAngle: 2 * math.pi * 0.28));

      await tester.pump(const Duration(milliseconds: 225));

      expect(tester.hasRunningAnimations, isTrue);
      expect(ring(), isNot(paints..arc(startAngle: top)));
      expect(
        find.descendant(of: find.byType(NebaProgressCircular), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('stops turning once it is given a value', (WidgetTester tester) async {
      await pump(tester, const NebaProgressCircular());
      await pump(tester, const NebaProgressCircular(value: 40));
      await tester.pumpAndSettle();

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('still turns under reduced motion', (WidgetTester tester) async {
      await pump(tester, const NebaProgressCircular(), reduced: true);
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.hasRunningAnimations, isTrue);
    });
  });

  group('style props', () {
    testWidgets('draws the ring in the wash and the arc in the accent of its family', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressCircular(value: 40, color: NebaColor.danger));

      final NebaColorRoles danger = tokens.roles(NebaColor.danger);
      expect(
        ring(),
        paints
          ..circle(color: danger.soft)
          ..arc(color: danger.accent),
      );
    });
  });
}
