// NebaAnimateCounter: a number counted up to its value, as the React
// package's AnimateCounter test carries it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// The texts it lays out: the ends of the count, unseen, then the count.
List<Text> _texts(WidgetTester tester) {
  return tester
      .widgetList<Text>(
        find.descendant(of: find.byType(NebaAnimateCounter), matching: find.byType(Text)),
      )
      .toList();
}

/// The number drawn.
String _drawn(WidgetTester tester) => _texts(tester).last.data!;

/// The numbers laid out unseen under it.
List<String> _samples(WidgetTester tester) {
  final List<Text> texts = _texts(tester);

  return <String>[for (final Text text in texts.take(texts.length - 1)) text.data!];
}

void main() {
  testWidgets('tells a screen reader the answer, and none of the count', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await _pump(tester, const NebaAnimateCounter(value: 12000));

    expect(find.bySemanticsLabel('12,000'), findsOneWidget);
    expect(find.bySemanticsLabel('0'), findsNothing);

    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('lands on its value over 1.2 seconds on an ease-out', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateCounter(value: 1000));

    expect(_drawn(tester), '0');

    await tester.pump(const Duration(milliseconds: 600));
    // Seven eighths of the way at half the time.
    expect(_drawn(tester), '875');

    await tester.pump(const Duration(milliseconds: 600));
    expect(_drawn(tester), '1,000');
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('holds its box open at both ends of the count from the first frame', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateCounter(value: 12000, style: TextStyle(fontSize: 10)));

    expect(_samples(tester), <String>['12,000', '0']);
    expect(tester.getSize(find.byType(NebaAnimateCounter)), const Size(60, 10));

    await tester.pumpAndSettle();
  });

  testWidgets('lets the start go once the count has landed', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateCounter(value: 5, from: 1000));
    expect(_samples(tester), <String>['5', '1,000']);

    await tester.pumpAndSettle();
    expect(_samples(tester), <String>['5']);
  });

  testWidgets('starts from where it was told, and waits out its delay there', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const NebaAnimateCounter(value: 200, from: 100, delay: Duration(milliseconds: 500)),
    );

    expect(_drawn(tester), '100');
    await tester.pump(const Duration(milliseconds: 500));
    expect(_drawn(tester), '100');
    await tester.pump(const Duration(milliseconds: 600));
    expect(_drawn(tester), '188');

    await tester.pumpAndSettle();
    expect(_drawn(tester), '200');
  });

  testWidgets('counts a new value on from the number on screen, with no delay', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateCounter(value: 100, delay: Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(_drawn(tester), '100');

    await _pump(tester, const NebaAnimateCounter(value: 200, delay: Duration(milliseconds: 300)));
    expect(_drawn(tester), '100');

    await tester.pump(const Duration(milliseconds: 600));
    expect(_drawn(tester), '188');

    await tester.pumpAndSettle();
    expect(_drawn(tester), '200');
  });

  testWidgets('counts in whole numbers towards a whole number', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateCounter(value: 12000));

    for (int frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(_drawn(tester), isNot(contains('.')));
    }
  });

  testWidgets('keeps the decimal places of whichever end has more', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateCounter(value: 10, from: 0.25));

    await tester.pump(const Duration(milliseconds: 300));
    expect(_drawn(tester), matches(RegExp(r'^\d+\.\d{1,2}$')));

    await tester.pumpAndSettle();
  });

  testWidgets('sets its figures at one width', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateCounter(value: 12));

    expect(
      DefaultTextStyle.of(tester.element(find.text('12').first)).style.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('writes the number the way it was told to', (WidgetTester tester) async {
    await _pump(
      tester,
      NebaAnimateCounter(value: 0.184, format: (num value) => '${(value * 100).round()}%'),
    );

    await tester.pumpAndSettle();
    expect(_drawn(tester), '18%');
  });

  testWidgets('jumps straight there when there is no duration', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateCounter(value: 42, duration: Duration.zero));

    expect(_drawn(tester), '42');
    await tester.pumpAndSettle();
  });

  testWidgets('waits at its start for play when the trigger is manual', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateCounter(value: 50, trigger: NebaAnimateTrigger.manual));
    await tester.pump(const Duration(seconds: 2));
    expect(_drawn(tester), '0');

    await _pump(
      tester,
      const NebaAnimateCounter(value: 50, trigger: NebaAnimateTrigger.manual, play: true),
    );
    await tester.pumpAndSettle();
    expect(_drawn(tester), '50');
  });

  testWidgets('counts again from the start when play goes up', (WidgetTester tester) async {
    Widget counter(int play) {
      return NebaAnimateCounter(value: 1000, trigger: NebaAnimateTrigger.manual, play: play);
    }

    await _pump(tester, counter(1));
    await tester.pumpAndSettle();
    expect(_drawn(tester), '1,000');

    await _pump(tester, counter(2));
    expect(_drawn(tester), '0');

    await tester.pump(const Duration(milliseconds: 600));
    expect(_drawn(tester), '875');

    await tester.pumpAndSettle();
  });

  testWidgets('shows the answer itself, untriggered, under less motion', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const NebaAnimateCounter(value: 128400, trigger: NebaAnimateTrigger.manual),
      disableAnimations: true,
    );

    expect(_drawn(tester), '128,400');
    expect(tester.hasRunningAnimations, isFalse);
  });
}
