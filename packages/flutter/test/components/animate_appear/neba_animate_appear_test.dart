// NebaAnimateAppear: a list settling in a child at a time, as the React
// package's AnimateAppear test carries it. What it shares with every other
// `Animate*` is covered by NebaAnimateFade's test.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const List<Widget> _three = <Widget>[
  SizedBox(key: Key('first'), width: 100, height: 20),
  SizedBox(key: Key('second'), width: 100, height: 20),
  SizedBox(key: Key('third'), width: 100, height: 20),
];

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// The opacity the child [index] is drawn at.
double _opacity(WidgetTester tester, int index) {
  return tester
      .widgetList<Opacity>(
        find.descendant(of: find.byType(NebaAnimateAppear), matching: find.byType(Opacity)),
      )
      .elementAt(index)
      .opacity;
}

/// How far the child [index] is drawn from where it was laid out.
Offset _shift(WidgetTester tester, int index) {
  final Transform transform = tester
      .widgetList<Transform>(
        find.descendant(of: find.byType(NebaAnimateAppear), matching: find.byType(Transform)),
      )
      .elementAt(index);
  final Float64List storage = transform.transform.storage;

  return Offset(storage[12], storage[13]);
}

void main() {
  group('rendering', () {
    testWidgets('renders every child, one under the other', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateAppear(children: _three));

      expect(find.byKey(const Key('first')), findsOneWidget);
      expect(find.byKey(const Key('third')), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('second'))) -
            tester.getTopLeft(find.byKey(const Key('first'))),
        const Offset(0, 20),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('hands each child an effect of its own, and lays them out as told', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        NebaAnimateAppear(
          stagger: Duration.zero,
          layoutBuilder: (List<Widget> children) => Row(children: children),
          children: _three,
        ),
      );

      // One frame per child even with no step, so a row stays a row.
      expect(
        find.descendant(of: find.byType(NebaAnimateAppear), matching: find.byType(Opacity)),
        findsNWidgets(3),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('second'))) -
            tester.getTopLeft(find.byKey(const Key('first'))),
        const Offset(100, 0),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('adds nothing a screen reader hears', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateAppear(children: <Widget>[Text('First')]));

      expect(_opacity(tester, 0), 0);
      expect(find.bySemanticsLabel('First'), findsOneWidget);

      await tester.pumpAndSettle();
      semantics.dispose();
    });
  });

  group('the stagger', () {
    testWidgets('holds each child back by 80 milliseconds of its place by default', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateAppear(curve: Curves.linear, children: _three));

      await tester.pump(const Duration(milliseconds: 80));
      expect(_opacity(tester, 0), greaterThan(0));
      expect(_opacity(tester, 1), 0);

      await tester.pump(const Duration(milliseconds: 80));
      expect(_opacity(tester, 1), greaterThan(0));
      expect(_opacity(tester, 2), 0);

      // The last starts at 160 and runs its 420.
      await tester.pump(const Duration(milliseconds: 419));
      expect(_opacity(tester, 2), lessThan(1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(_opacity(tester, 2), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('counts from the delay it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateAppear(
          delay: Duration(milliseconds: 500),
          stagger: Duration(milliseconds: 100),
          children: _three,
        ),
      );

      await tester.pump(const Duration(milliseconds: 499));
      expect(_opacity(tester, 0), 0);
      await tester.pump(const Duration(milliseconds: 51));
      expect(_opacity(tester, 0), greaterThan(0));
      expect(_opacity(tester, 1), 0);

      await tester.pumpAndSettle();
    });

    testWidgets('runs the list backwards when told to', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateAppear(
          reverse: true,
          stagger: Duration(milliseconds: 100),
          children: _three,
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(_opacity(tester, 2), greaterThan(0));
      expect(_opacity(tester, 0), 0);

      await tester.pumpAndSettle();
    });

    testWidgets('drifts only a little way, up from below', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateAppear(children: _three));

      expect(_shift(tester, 0), const Offset(0, 12));

      await tester.pumpAndSettle();
      expect(_shift(tester, 0), Offset.zero);
    });

    testWidgets('drifts in from the edge and by the distance it was given', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateAppear(from: NebaSide.left, distance: 30, children: _three),
      );

      expect(_shift(tester, 0), const Offset(-30, 0));

      await tester.pumpAndSettle();
    });

    testWidgets('settles without fading when fade is off', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateAppear(fade: false, children: _three));

      expect(_opacity(tester, 0), 1);
      expect(_shift(tester, 0), const Offset(0, 12));

      await tester.pumpAndSettle();
    });
  });

  group('triggers', () {
    testWidgets('waits to be told when the trigger is manual', (WidgetTester tester) async {
      Widget appear(Object? play) {
        return NebaAnimateAppear(trigger: NebaAnimateTrigger.manual, play: play, children: _three);
      }

      await _pump(tester, appear(false));
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester, 0), 0);
      expect(tester.hasRunningAnimations, isFalse);

      await _pump(tester, appear(true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacity(tester, 0), greaterThan(0));

      await tester.pumpAndSettle();
      expect(_opacity(tester, 2), 1);
    });

    testWidgets('starts every child over when it is played again', (WidgetTester tester) async {
      Widget appear(int play) {
        return NebaAnimateAppear(trigger: NebaAnimateTrigger.manual, play: play, children: _three);
      }

      await _pump(tester, appear(1));
      await tester.pumpAndSettle();
      expect(_opacity(tester, 2), 1);

      await _pump(tester, appear(2));
      expect(_opacity(tester, 0), 0);
      expect(_opacity(tester, 2), 0);

      await tester.pumpAndSettle();
      expect(_opacity(tester, 2), 1);
    });

    testWidgets('never waits for a trigger when the scroll drives it', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateAppear(
          timeline: NebaAnimateTimeline.view,
          trigger: NebaAnimateTrigger.manual,
          children: _three,
        ),
      );
      await tester.pump();

      // In the middle of a window with no scroll view: past the default range.
      expect(_opacity(tester, 0), 1);
      expect(_opacity(tester, 2), 1);
    });
  });

  group('less motion', () {
    testWidgets('draws the whole list at once', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateAppear(children: _three), disableAnimations: true);

      expect(_opacity(tester, 0), 1);
      expect(_opacity(tester, 2), 1);
      expect(_shift(tester, 2), Offset.zero);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
