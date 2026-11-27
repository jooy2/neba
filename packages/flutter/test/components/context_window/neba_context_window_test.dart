// NebaContextWindow: the suite the React package runs on ContextWindow, asked
// the way Flutter asks it — one reading a screen reader hears with the same
// sentence that is drawn, the split outside it, the total the parts add up
// to, the money, the thresholds and the words.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/messages.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget window) async {
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 400, child: window),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The reading's node: the one whose value is the sentence drawn.
  SemanticsNode reading(WidgetTester tester) {
    return tester.getSemantics(
      find.descendant(of: find.byType(NebaContextWindow), matching: find.byType(Semantics)).first,
    );
  }

  /// The colour the ring's arc is painted in.
  Color fill(WidgetTester tester) {
    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(of: find.byType(NebaContextWindow), matching: find.byType(CustomPaint)),
    );
    return (paint.painter! as dynamic).fill as Color;
  }

  group('rendering', () {
    testWidgets('is one reading whose value is the sentence it draws', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaContextWindow(max: 200000, used: 124000));

      expect(find.text('124K of 200K'), findsOneWidget);
      expect(reading(tester).value, '124K of 200K');
      expect(reading(tester).label, 'Context');
      semantics.dispose();
    });

    testWidgets('names itself when it was not given a name', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 1000, used: 100));

      expect(find.text('Context'), findsOneWidget);
    });

    testWidgets('takes a name of its own', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 1000, used: 100, label: Text('This thread')));

      expect(find.text('This thread'), findsOneWidget);
    });

    // The whole gauge was the meter, whose children are presentational, so
    // the split stopped being a list and a link under it stopped being one.
    testWidgets('keeps the split, the cost and the child outside the reading', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          tokens: NebaContextTokens(input: 40000, output: 10000),
          cost: 0.42,
          child: Text('Clear the thread'),
        ),
      );

      final SemanticsNode node = reading(tester);
      expect(node.value, '50K of 100K');
      expect(node.label, isNot(contains('Input')));
      expect(node.label, isNot(contains('0.42')));
      expect(node.label, isNot(contains('Clear the thread')));
      expect(find.bySemanticsLabel(RegExp(r'\$0\.42')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NebaContextWindow),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.role == SemanticsRole.list,
          ),
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('follows a value that changes on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 200000, used: 10000));
      await pump(tester, const NebaContextWindow(max: 200000, used: 190000));

      expect(find.text('190K of 200K'), findsOneWidget);
    });

    // A toolbar's end and a prompt field's row of controls give their
    // children no width in particular.
    testWidgets('is as wide as what it says in a row of controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NebaContextWindow(max: 200000, used: 48000, cost: 0.42, breakdown: false),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NebaContextWindow)).width, lessThan(800));
    });

    testWidgets('sizes the ring on its own ladder', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 100, used: 50, size: NebaSize.lg));

      expect(
        tester.getSize(
          find.descendant(of: find.byType(NebaContextWindow), matching: find.byType(CustomPaint)),
        ),
        const Size.square(44),
      );
    });
  });

  group('the split', () {
    testWidgets('adds the parts up when it was not told a total', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          tokens: NebaContextTokens(input: 40000, output: 10000),
        ),
      );

      expect(find.text('50K of 100K'), findsOneWidget);
    });

    testWidgets('draws a row per part it was told about', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          tokens: NebaContextTokens(input: 40000, output: 10000),
        ),
      );

      expect(find.text('Input'), findsOneWidget);
      expect(find.text('Output'), findsOneWidget);
      expect(find.text('Cached'), findsNothing);
      expect(find.text('40K'), findsOneWidget);
    });

    // Every model that reports a cache means "this much of the input came
    // out of it", so the tokens are already inside the input.
    testWidgets('leaves the cached part out of a total it works out itself', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          tokens: NebaContextTokens(input: 40000, output: 10000, cached: 30000),
        ),
      );

      expect(find.text('50K of 100K'), findsOneWidget);
      expect(find.text('Cached'), findsOneWidget);
    });

    testWidgets('still takes a total it was handed', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          used: 80000,
          tokens: NebaContextTokens(input: 40000, cached: 30000),
        ),
      );

      expect(find.text('80K of 100K'), findsOneWidget);
    });

    testWidgets('draws a part that is zero, which is not one that was not reported', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaContextWindow(max: 100000, tokens: NebaContextTokens(cached: 0)),
      );

      expect(find.text('Cached'), findsOneWidget);
    });

    testWidgets('leaves the split out when it is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          tokens: NebaContextTokens(input: 40000),
          breakdown: false,
        ),
      );

      expect(find.text('Input'), findsNothing);
    });

    testWidgets('colours each part with its chart slot, in order', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaContextWindow(max: 100000, tokens: NebaContextTokens(output: 1, cached: 2)),
      );

      final List<Color?> swatches = tester
          .widgetList<Container>(
            find.descendant(of: find.byType(Wrap), matching: find.byType(Container)),
          )
          .map((Container box) => (box.decoration as BoxDecoration?)?.color)
          .toList();

      expect(swatches, <Color>[tokens.chart.series[1], tokens.chart.series[3]]);
    });
  });

  group('cost', () {
    testWidgets('writes the money in US dollars to the cent', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 100000, used: 10000, cost: 0.4));

      expect(find.text(r'$0.40'), findsOneWidget);
      expect(find.text('Estimated cost'), findsOneWidget);
    });

    testWidgets('writes it with a function of the caller\'s', (WidgetTester tester) async {
      await pump(
        tester,
        NebaContextWindow(
          max: 100000,
          used: 10000,
          cost: 0.42,
          formatCost: (double cost) => '${cost.toStringAsFixed(2).replaceAll('.', ',')} €',
        ),
      );

      expect(find.text('0,42 €'), findsOneWidget);
    });

    testWidgets('says nothing about money when there is none to say', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 100000, used: 10000));

      expect(find.text('Estimated cost'), findsNothing);
    });
  });

  group('thresholds', () {
    const List<NebaThreshold> thresholds = <NebaThreshold>[
      NebaThreshold(from: 70000, color: NebaColor.warning),
      NebaThreshold(from: 90000, color: NebaColor.danger),
    ];

    testWidgets('keeps its own colour below every threshold', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 100000, used: 40000, thresholds: thresholds));

      expect(fill(tester), tokens.roles(NebaColor.primary).fill);
    });

    testWidgets('takes the family of the last one it has reached', (WidgetTester tester) async {
      await pump(tester, const NebaContextWindow(max: 100000, used: 95000, thresholds: thresholds));

      expect(fill(tester), tokens.roles(NebaColor.danger).fill);
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets('writes the counts with a function of the caller\'s', (WidgetTester tester) async {
      await pump(
        tester,
        NebaContextWindow(
          max: 200000,
          used: 124000,
          format: (double value) => value.round().toString(),
        ),
      );

      expect(find.text('124000 of 200000'), findsOneWidget);
    });

    testWidgets('takes its words from a provider', (WidgetTester tester) async {
      registerNebaMessages(
        'de',
        const NebaLocale(<String, Map<String, String>>{
          'context': <String, String>{'label': 'Kontext', 'usage': '{used} von {max}'},
        }),
      );

      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(locale: Locale('de', 'DE')),
          child: NebaContextWindow(max: 100000, used: 10000),
        ),
      );

      expect(find.text('Kontext'), findsOneWidget);
      expect(find.text('10K von 100K'), findsOneWidget);
    });

    testWidgets('lets a caller write its words out', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaContextWindow(
          max: 100000,
          tokens: NebaContextTokens(input: 1200),
          labels: <String, String>{'input': 'Prompt'},
        ),
      );

      expect(find.text('Prompt'), findsOneWidget);
      expect(find.text('1.2K'), findsOneWidget);
    });
  });
}
