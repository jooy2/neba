// NebaProgressLinear: the suite the React package runs on ProgressLinear,
// asked the way Flutter asks it — what a screen reader is told instead of the
// ARIA attributes, the groove actually laid out instead of a class name, and
// the segment crossing it on a running clock instead of a keyframe.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/progress.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reduced = false,
    TextDirection direction = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Center(child: SizedBox(width: 300, child: child)),
        disableAnimations: reduced,
        textDirection: direction,
      ),
    );
  }

  SemanticsNode node(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaProgressLinear));
  }

  NebaGroove groove(WidgetTester tester) => tester.widget<NebaGroove>(find.byType(NebaGroove));

  group('rendering', () {
    testWidgets('tells a screen reader its reading', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressLinear(value: 40));

      expect(node(tester), matchesSemantics(value: '40%'));
      expect(node(tester).getSemanticsData().role, SemanticsRole.none);

      semantics.dispose();
    });

    testWidgets('is named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressLinear(value: 40, label: Text('Uploading')));

      expect(node(tester), matchesSemantics(label: 'Uploading', value: '40%'));

      semantics.dispose();
    });

    testWidgets('takes a name of its own in place of the label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaProgressLinear(
          value: 40,
          label: Text('Up'),
          showValue: true,
          semanticLabel: 'Uploading',
        ),
      );

      expect(node(tester), matchesSemantics(label: 'Uploading', value: '40%'));

      semantics.dispose();
    });

    testWidgets('reflects a changed value on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 10, showValue: true));
      expect(find.text('10%'), findsOneWidget);

      await pump(tester, const NebaProgressLinear(value: 90, showValue: true));
      expect(find.text('90%'), findsOneWidget);
    });

    testWidgets('takes the width it is given, and none where there is no limit', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressLinear(value: 40));
      expect(tester.getSize(find.byType(NebaProgressLinear)).width, 300);

      await tester.pumpWidget(
        host(
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[NebaProgressLinear(value: 40, label: Text('Uploading'))],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NebaProgressLinear)).width, 0);
    });
  });

  group('the value', () {
    testWidgets('shows a percentage of the range, not of 100', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 3, max: 4, showValue: true));

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('says the same thing to a screen reader as it does on screen', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressLinear(value: 3, max: 4, showValue: true));

      expect(node(tester), matchesSemantics(value: '75%'));

      semantics.dispose();
    });

    testWidgets("uses the caller's format when there is one", (WidgetTester tester) async {
      await pump(
        tester,
        NebaProgressLinear(
          value: 1200,
          max: 4000,
          showValue: true,
          format: (double value) => '${value.round()} MB',
        ),
      );

      expect(find.text('1200 MB'), findsOneWidget);
      expect(find.text('30%'), findsNothing);
    });

    testWidgets('hides the value until it is asked for', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 40));

      expect(find.text('40%'), findsNothing);
    });

    testWidgets('puts the label at the start and the value at the end', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaProgressLinear(value: 40, label: Text('Uploading'), showValue: true),
      );

      final Rect bar = tester.getRect(find.byType(NebaProgressLinear));
      expect(tester.getRect(find.text('Uploading')).left, bar.left);
      expect(tester.getRect(find.text('40%')).right, bar.right);
      expect(
        tester.getRect(find.text('40%')).bottom,
        lessThan(tester.getRect(find.byType(NebaGroove)).top),
      );
    });

    testWidgets('eases to a new reading over the fill duration', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 20));
      await pump(tester, const NebaProgressLinear(value: 80));
      await tester.pump(const Duration(milliseconds: 100));

      expect(groove(tester).fraction, inExclusiveRange(0.2, 0.8));

      await tester.pumpAndSettle();
      expect(groove(tester).fraction, 0.8);
    });

    testWidgets('jumps to a new reading under reduced motion', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 20), reduced: true);
      await pump(tester, const NebaProgressLinear(value: 80), reduced: true);
      await tester.pump();

      expect(groove(tester).fraction, 0.8);
    });
  });

  group('thickness', () {
    testWidgets('takes a groove height of its own over the step it would have had', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaProgressLinear(value: 40, thickness: 12));

      expect(tester.getSize(find.byType(NebaGroove)).height, 12);
    });

    testWidgets('leaves the ladder to decide when it is not given', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 40));
      expect(tester.getSize(find.byType(NebaGroove)).height, 4);

      await pump(tester, const NebaProgressLinear(value: 40, size: NebaSize.xl));
      expect(tester.getSize(find.byType(NebaGroove)).height, 8);
    });

    testWidgets('takes its size from NebaProvider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.lg),
          child: NebaProgressLinear(value: 40),
        ),
      );

      expect(tester.getSize(find.byType(NebaGroove)).height, 6);
    });
  });

  group('indeterminate', () {
    testWidgets('is indeterminate by default, and tells a screen reader it is busy', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressLinear(label: Text('Uploading')));

      expect(node(tester), matchesSemantics(label: 'Uploading'));
      expect(node(tester).getSemanticsData().role, SemanticsRole.loadingSpinner);
      expect(groove(tester).fraction, isNull);

      semantics.dispose();
    });

    testWidgets('announces no value where it draws none', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaProgressLinear(value: 0, max: 0));
      expect(node(tester).getSemanticsData().value, isEmpty);
      expect(groove(tester).fraction, isNull);

      await pump(tester, const NebaProgressLinear(value: double.infinity));
      expect(node(tester).getSemanticsData().value, isEmpty);
      expect(groove(tester).fraction, isNull);

      semantics.dispose();
    });

    testWidgets('sweeps on a running clock, without a transform', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.hasRunningAnimations, isTrue);
      expect(groove(tester).clock, isNotNull);
      expect(
        find.descendant(of: find.byType(NebaProgressLinear), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('stops sweeping once it is given a value', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear());
      await pump(tester, const NebaProgressLinear(value: 40));
      await tester.pumpAndSettle();

      expect(tester.hasRunningAnimations, isFalse);
      expect(groove(tester).clock, isNull);
    });

    testWidgets('still moves under reduced motion', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(), reduced: true);
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('clamps a value that ran past its own maximum', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 140, showValue: true));

      expect(find.text('100%'), findsOneWidget);
      expect(groove(tester).fraction, 1);
    });
  });

  group('style props', () {
    testWidgets('draws the groove in its colour family', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 40, color: NebaColor.success));

      final NebaColorRoles success = tokens.roles(NebaColor.success);
      expect(groove(tester).fill, success.fill);
      expect(groove(tester).track, success.soft);
    });

    testWidgets('is primary by default', (WidgetTester tester) async {
      await pump(tester, const NebaProgressLinear(value: 40));

      expect(groove(tester).fill, tokens.roles(NebaColor.primary).fill);
    });

    testWidgets('lays out under a right-to-left direction', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProgressLinear(value: 40, label: Text('Uploading'), showValue: true),
        direction: TextDirection.rtl,
      );

      final Rect bar = tester.getRect(find.byType(NebaProgressLinear));
      expect(tester.getRect(find.text('Uploading')).right, bar.right);
      expect(tester.getRect(find.text('40%')).left, bar.left);
    });
  });
}
