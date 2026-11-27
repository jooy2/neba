// NebaAnimateSplit: a line cut into words or characters, each arriving on an
// effect of the library's own, as the React package's AnimateSplit test
// carries it. What it shares with every other `Animate*` is covered by
// NebaAnimateFade's test.

import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

Finder _pieceFinder() {
  return find.descendant(
    of: find.byType(NebaAnimateSplit),
    matching: find.byWidgetPredicate((Widget widget) => widget is Text && widget.data != null),
  );
}

/// What each piece draws, in the order of the line.
List<String> _pieces(WidgetTester tester) {
  return <String>[for (final Text text in tester.widgetList<Text>(_pieceFinder())) text.data!];
}

/// The opacity piece [index] is drawn at.
double _opacity(WidgetTester tester, int index) {
  return tester
      .widget<Opacity>(find.ancestor(of: _pieceFinder().at(index), matching: find.byType(Opacity)))
      .opacity;
}

/// How far piece [index] is drawn from where it was laid out.
Offset _shift(WidgetTester tester, int index) {
  final Float64List storage = tester
      .widget<Transform>(
        find.ancestor(of: _pieceFinder().at(index), matching: find.byType(Transform)).first,
      )
      .transform
      .storage;

  return Offset(storage[12], storage[13]);
}

void main() {
  group('splitting', () {
    testWidgets('cuts the line into words by default, the spaces left between them', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateSplit(text: 'One two, three'));

      expect(_pieces(tester), <String>['One', 'two,', 'three']);
      await tester.pumpAndSettle();
    });

    testWidgets('cuts it into characters when asked', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateSplit(text: 'abc', by: NebaSplitBy.character));

      expect(_pieces(tester), <String>['a', 'b', 'c']);
      await tester.pumpAndSettle();
    });

    testWidgets('counts characters as a reader does', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateSplit(text: '한글 e\u0301', by: NebaSplitBy.character));

      expect(_pieces(tester), <String>['한', '글', 'e\u0301']);
      await tester.pumpAndSettle();
    });

    testWidgets('keeps the characters of a word together on one line', (WidgetTester tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 40,
          child: NebaAnimateSplit(
            text: 'ab cd',
            by: NebaSplitBy.character,
            style: TextStyle(fontSize: 10),
          ),
        ),
      );
      await tester.pumpAndSettle();

      double top(int index) => tester.getTopLeft(_pieceFinder().at(index)).dy;

      // A word to a line, each word's letters on the same one.
      expect(top(0), top(1));
      expect(top(2), top(3));
      expect(top(2), greaterThan(top(0)));
    });

    testWidgets('lays the line out where a text would, a line to a row', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 200,
          child: NebaAnimateSplit(text: 'One two', style: TextStyle(fontSize: 10)),
        ),
      );
      await tester.pumpAndSettle();

      final Offset one = tester.getTopLeft(_pieceFinder().at(0));
      final Offset two = tester.getTopLeft(_pieceFinder().at(1));

      // Three letters and the space after them.
      expect(two - one, const Offset(40, 0));
    });
  });

  group('the effect', () {
    testWidgets('slides each piece up by four tenths of the font size by default', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateSplit(text: 'One two', style: TextStyle(fontSize: 20)));

      expect(_shift(tester, 0), const Offset(0, 8));
      expect(_opacity(tester, 0), 0);

      await tester.pumpAndSettle();
      expect(_shift(tester, 0), Offset.zero);
      expect(_opacity(tester, 1), 1);
    });

    testWidgets('holds each piece back by its place in the line', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateSplit(
          text: 'One two three',
          stagger: Duration(milliseconds: 50),
          delay: Duration(milliseconds: 10),
        ),
      );

      await tester.pump(const Duration(milliseconds: 30));
      expect(_opacity(tester, 0), greaterThan(0));
      expect(_opacity(tester, 1), 0);

      await tester.pump(const Duration(milliseconds: 50));
      expect(_opacity(tester, 1), greaterThan(0));
      expect(_opacity(tester, 2), 0);

      await tester.pumpAndSettle();
      expect(_opacity(tester, 2), 1);
    });

    testWidgets('runs the line the other way when reversed', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateSplit(
          text: 'One two',
          stagger: Duration(milliseconds: 100),
          reverse: true,
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(_opacity(tester, 1), greaterThan(0));
      expect(_opacity(tester, 0), 0);

      await tester.pumpAndSettle();
    });

    testWidgets('takes any other effect, read from the library table', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateSplit(text: 'One two', effect: NebaAnimation.fade));

      expect(_opacity(tester, 0), 0);
      expect(_shift(tester, 0), Offset.zero);

      await tester.pumpAndSettle();
      expect(_opacity(tester, 0), 1);
    });

    testWidgets('grows each piece about its own middle', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateSplit(text: 'One two', effect: NebaAnimation.grow, stagger: Duration.zero),
      );

      // A frame per piece even with no step.
      expect(
        find.descendant(of: find.byType(NebaAnimateSplit), matching: find.byType(Opacity)),
        findsNWidgets(2),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('blinks without end unless it is given a repeat', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateSplit(text: 'One two', effect: NebaAnimation.blink));

      await tester.pump(const Duration(seconds: 10));
      expect(tester.hasRunningAnimations, isTrue);

      await _pump(
        tester,
        const NebaAnimateSplit(text: 'One two', effect: NebaAnimation.blink, repeat: 1),
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('starts every piece over when it is played again', (WidgetTester tester) async {
      Widget split(int play) {
        return NebaAnimateSplit(text: 'One two', trigger: NebaAnimateTrigger.manual, play: play);
      }

      await _pump(tester, split(1));
      await tester.pumpAndSettle();
      expect(_opacity(tester, 1), 1);

      await _pump(tester, split(2));
      expect(_opacity(tester, 0), 0);
      expect(_opacity(tester, 1), 0);

      await tester.pumpAndSettle();
      expect(_opacity(tester, 1), 1);
    });

    testWidgets('runs under the pointer when the trigger is hover', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateSplit(text: 'One two', trigger: NebaAnimateTrigger.hover),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester, 0), 0);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byType(NebaAnimateSplit)));
      await tester.pumpAndSettle();
      expect(_opacity(tester, 1), 1);
    });

    testWidgets('never waits for a trigger when the scroll drives it', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateSplit(
          text: 'One two',
          timeline: NebaAnimateTimeline.view,
          trigger: NebaAnimateTrigger.manual,
        ),
      );
      await tester.pump();

      expect(_opacity(tester, 0), 1);
    });
  });

  group('what a reader is told', () {
    testWidgets('the whole line once, and none of the pieces', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateSplit(text: 'One two three'));

      expect(find.bySemanticsLabel('One two three'), findsOneWidget);
      expect(find.bySemanticsLabel('One'), findsNothing);

      await tester.pumpAndSettle();
      semantics.dispose();
    });

    testWidgets('the line whole under less motion', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateSplit(text: 'One two'), disableAnimations: true);

      expect(_opacity(tester, 0), 1);
      expect(_shift(tester, 1), Offset.zero);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
