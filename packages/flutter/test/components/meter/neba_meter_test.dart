// NebaMeter: the suite the React package runs on Meter, asked the way
// Flutter asks it — what a screen reader is told instead of the ARIA
// attributes, and the groove's fill colour actually drawn instead of a CSS
// variable.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/progress.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget child, {bool reduced = false}) {
    return tester.pumpWidget(
      host(
        Center(child: SizedBox(width: 300, child: child)),
        disableAnimations: reduced,
      ),
    );
  }

  SemanticsNode node(WidgetTester tester) => tester.getSemantics(find.byType(NebaMeter));

  NebaGroove groove(WidgetTester tester) => tester.widget<NebaGroove>(find.byType(NebaGroove));

  group('rendering', () {
    testWidgets('tells a screen reader its reading, named by its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaMeter(value: 40, label: Text('Storage')));

      expect(node(tester), matchesSemantics(label: 'Storage', value: '40%'));
      expect(node(tester).getSemanticsData().role, SemanticsRole.none);

      semantics.dispose();
    });

    testWidgets('takes a range of its own', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaMeter(value: 3, max: 4, label: Text('Seats')));

      expect(node(tester), matchesSemantics(label: 'Seats', value: '75%'));
      expect(groove(tester).fraction, 0.75);

      semantics.dispose();
    });

    testWidgets('takes a name of its own in place of the label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaMeter(value: 40, label: Text('Disk'), semanticLabel: 'Storage'));

      expect(node(tester), matchesSemantics(label: 'Storage', value: '40%'));

      semantics.dispose();
    });

    testWidgets('reflects a changed value on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaMeter(value: 10, showValue: true));
      await pump(tester, const NebaMeter(value: 90, showValue: true));

      expect(find.text('90%'), findsOneWidget);
    });

    testWidgets('is never indeterminate, and never moves on its own', (WidgetTester tester) async {
      await pump(tester, const NebaMeter(value: double.nan, showValue: true));

      expect(find.text('0%'), findsOneWidget);
      expect(groove(tester).fraction, 0);
      expect(groove(tester).clock, isNull);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('takes the width it is given, and none where there is no limit', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaMeter(value: 40));
      expect(tester.getSize(find.byType(NebaMeter)).width, 300);

      await tester.pumpWidget(
        host(
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[NebaMeter(value: 40, label: Text('Storage'), showValue: true)],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NebaMeter)).width, 0);
    });
  });

  group('value text', () {
    testWidgets('does not draw the value unless asked', (WidgetTester tester) async {
      await pump(tester, const NebaMeter(value: 40, label: Text('Storage')));

      expect(find.text('40%'), findsNothing);
    });

    testWidgets('writes the value as a share of the range', (WidgetTester tester) async {
      await pump(tester, const NebaMeter(value: 2, max: 8, showValue: true));

      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('writes the value through format when it is given one, and announces it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaMeter(
          value: 12,
          max: 20,
          showValue: true,
          format: (double value) => '${value.round()} GB',
        ),
      );

      expect(find.text('12 GB'), findsOneWidget);
      expect(find.text('60%'), findsNothing);
      expect(node(tester), matchesSemantics(value: '12 GB'));

      semantics.dispose();
    });
  });

  group('thresholds', () {
    const List<NebaThreshold> thresholds = <NebaThreshold>[
      NebaThreshold(from: 70, color: NebaColor.warning),
      NebaThreshold(from: 90, color: NebaColor.danger),
    ];

    testWidgets('keeps its own colour below every threshold', (WidgetTester tester) async {
      await pump(tester, const NebaMeter(value: 40, thresholds: thresholds));

      expect(groove(tester).fill, tokens.roles(NebaColor.primary).fill);
    });

    testWidgets('takes the family of the last threshold it has reached', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaMeter(value: 75, thresholds: thresholds));

      expect(groove(tester).fill, tokens.roles(NebaColor.warning).fill);
      expect(groove(tester).track, tokens.roles(NebaColor.warning).soft);
    });

    testWidgets('moves on to the next family as the value climbs, easing the fill', (
      WidgetTester tester,
    ) async {
      final Color warning = tokens.roles(NebaColor.warning).fill;
      final Color danger = tokens.roles(NebaColor.danger).fill;

      await pump(tester, const NebaMeter(value: 75, thresholds: thresholds));
      await pump(tester, const NebaMeter(value: 95, thresholds: thresholds));
      await tester.pump(const Duration(milliseconds: 40));

      expect(groove(tester).fill, isNot(warning));
      expect(groove(tester).fill, isNot(danger));

      await tester.pumpAndSettle();
      expect(groove(tester).fill, danger);
    });

    testWidgets('changes colour at once under reduced motion', (WidgetTester tester) async {
      await pump(tester, const NebaMeter(value: 75, thresholds: thresholds), reduced: true);
      await pump(tester, const NebaMeter(value: 95, thresholds: thresholds), reduced: true);
      await tester.pump();

      expect(groove(tester).fill, tokens.roles(NebaColor.danger).fill);
      expect(groove(tester).fraction, 0.95);
    });

    testWidgets('maps color onto the groove when there are no thresholds', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaMeter(value: 40, color: NebaColor.success));

      expect(groove(tester).fill, tokens.roles(NebaColor.success).fill);
    });
  });

  group('size', () {
    testWidgets('cuts the groove on the ladder a progress bar uses, or as thick as asked', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaMeter(value: 40));
      expect(tester.getSize(find.byType(NebaGroove)).height, 4);

      await pump(tester, const NebaMeter(value: 40, size: NebaSize.xs));
      expect(tester.getSize(find.byType(NebaGroove)).height, 2);

      await pump(tester, const NebaMeter(value: 40, thickness: 10));
      expect(tester.getSize(find.byType(NebaGroove)).height, 10);
    });

    testWidgets('takes its size from NebaProvider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.xl),
          child: NebaMeter(value: 40),
        ),
      );

      expect(tester.getSize(find.byType(NebaGroove)).height, 8);
    });
  });
}
