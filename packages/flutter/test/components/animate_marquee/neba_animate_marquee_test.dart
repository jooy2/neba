// NebaAnimateMarquee: content laid down end to end and scrolled past at a
// speed, as the React package's AnimateMarquee test carries it.

import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const List<Widget> _items = <Widget>[
  SizedBox(width: 40, height: 20, child: Text('A')),
  SizedBox(width: 60, height: 20, child: Text('B')),
];

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(
    host(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 300, child: widget),
      ),
      disableAnimations: disableAnimations,
    ),
  );
}

/// How far the strip has travelled from where it was laid out.
Offset _shift(WidgetTester tester) {
  final Float64List storage = tester
      .widget<Transform>(
        find.descendant(of: find.byType(NebaAnimateMarquee), matching: find.byType(Transform)),
      )
      .transform
      .storage;

  return Offset(storage[12], storage[13]);
}

void main() {
  group('rendering', () {
    testWidgets('lays the content down twice by default, a gap apart', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateMarquee(gap: 10, children: _items));

      expect(find.text('A'), findsNWidgets(2));
      // One copy is the two items and the gap between them, and the next
      // copy starts a gap after it.
      expect(
        tester.getTopLeft(find.text('A').at(1)) - tester.getTopLeft(find.text('A').at(0)),
        const Offset(120, 0),
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('lays it down as many times as it is asked to', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateMarquee(copies: 4, children: _items));

      expect(find.text('B'), findsNWidgets(4));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('takes the width it is given, as tall as its content, and clips it', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateMarquee(copies: 4, children: _items));

      expect(tester.getSize(find.byType(NebaAnimateMarquee)), const Size(300, 20));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reads only the first copy out', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateMarquee(children: _items));

      expect(find.bySemanticsLabel('A'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });

    testWidgets('keeps the copies out of the focus order and out of the pointer', (
      WidgetTester tester,
    ) async {
      int presses = 0;

      await _pump(
        tester,
        NebaAnimateMarquee(
          paused: true,
          children: <Widget>[
            Focus(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => presses += 1,
                child: const SizedBox(key: Key('item'), width: 100, height: 20),
              ),
            ),
          ],
        ),
      );

      // Each copy builds the item afresh, and only the first can take the
      // focus.
      final Finder items = find.byKey(const Key('item'));

      expect(Focus.of(tester.element(items.at(0))).canRequestFocus, isTrue);
      expect(Focus.of(tester.element(items.at(1))).canRequestFocus, isFalse);

      // The first copy takes a press; the second, a gap later, does not.
      await tester.tapAt(const Offset(50, 10));
      await tester.tapAt(const Offset(182, 10));
      expect(presses, 1);
    });

    testWidgets('lays the content down once and wraps it under less motion', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateMarquee(
          gap: 10,
          children: <Widget>[
            SizedBox(width: 200, height: 20, child: Text('A')),
            SizedBox(width: 200, height: 20, child: Text('B')),
          ],
        ),
        disableAnimations: true,
      );

      expect(find.text('A'), findsOneWidget);
      expect(tester.getTopLeft(find.text('B')).dy, 30);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('runs a vertical one past the foot of a box too short for it, under less motion', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          height: 30,
          child: NebaAnimateMarquee(
            orientation: NebaOrientation.vertical,
            gap: 10,
            children: <Widget>[
              SizedBox(height: 20, child: Text('A')),
              SizedBox(height: 20, child: Text('B')),
            ],
          ),
        ),
        disableAnimations: true,
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NebaAnimateMarquee)).height, 30);
      expect(tester.getTopLeft(find.text('B')).dy, 30);
    });

    testWidgets('is as tall as a vertical one laid down, with no height given', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateMarquee(
          orientation: NebaOrientation.vertical,
          gap: 10,
          children: <Widget>[
            SizedBox(height: 20, child: Text('A')),
            SizedBox(height: 20, child: Text('B')),
          ],
        ),
        disableAnimations: true,
      );

      expect(tester.getSize(find.byType(NebaAnimateMarquee)).height, 50);
    });
  });

  group('settings', () {
    testWidgets('travels at its speed, one copy and a gap a lap', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateMarquee(gap: 20, speed: 60, children: _items));
      // Measured on the first frame, and let go on the next.
      await tester.pump();

      expect(_shift(tester), Offset.zero);
      await tester.pump(const Duration(seconds: 1));
      expect(_shift(tester).dx, closeTo(-60, 0.05));

      // A lap is 120 + 20 pixels, so at 60 a second it is back where it began
      // after 2333 milliseconds.
      await tester.pump(const Duration(milliseconds: 1333));
      expect(_shift(tester).dx, closeTo(0, 1e-6));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('takes an explicit duration over the one its speed works out', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateMarquee(gap: 20, duration: Duration(seconds: 10), children: _items),
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 5));
      expect(_shift(tester).dx, closeTo(-70, 1e-6));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('runs the other way when reversed', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateMarquee(
          gap: 20,
          reverse: true,
          duration: Duration(seconds: 10),
          children: _items,
        ),
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      expect(_shift(tester).dx, closeTo(-140 * 0.8, 1e-6));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('runs down the box when vertical', (WidgetTester tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 30,
          child: NebaAnimateMarquee(
            orientation: NebaOrientation.vertical,
            gap: 10,
            duration: Duration(seconds: 10),
            children: _items,
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSize(find.byType(NebaAnimateMarquee)), const Size(300, 30));
      // A copy is two rows of twenty and the gap between them.
      expect(
        tester.getTopLeft(find.text('A').at(1)) - tester.getTopLeft(find.text('A').at(0)),
        const Offset(0, 60),
      );

      await tester.pump(const Duration(seconds: 5));
      expect(_shift(tester), const Offset(0, -30));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keeps its place when it is measured again at another length', (
      WidgetTester tester,
    ) async {
      Widget strip(double width) {
        return NebaAnimateMarquee(
          gap: 20,
          speed: 60,
          children: <Widget>[SizedBox(width: width, height: 20)],
        );
      }

      await _pump(tester, strip(100));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Sixty of the hundred and twenty pixels a lap: half way.
      expect(_shift(tester).dx, closeTo(-60, 1e-6));

      await _pump(tester, strip(220));
      await tester.pump();
      await tester.pump();
      expect(_shift(tester).dx, closeTo(-120, 1e-6));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('stops under the pointer unless that is turned off', (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(500, 500));
      addTearDown(mouse.removePointer);

      await _pump(tester, const NebaAnimateMarquee(children: _items));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      await mouse.moveTo(const Offset(50, 10));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await mouse.moveTo(const Offset(500, 500));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      await _pump(tester, const NebaAnimateMarquee(pauseOnHover: false, children: _items));
      await mouse.moveTo(const Offset(50, 10));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('stops while the focus is inside it', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateMarquee(
          children: <Widget>[Focus(child: SizedBox(key: Key('item'), width: 100, height: 20))],
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      Focus.of(tester.element(find.byKey(const Key('item')).first)).requestFocus();
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('does not stop for the hover that starts it', (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(500, 500));
      addTearDown(mouse.removePointer);

      await _pump(
        tester,
        const NebaAnimateMarquee(trigger: NebaAnimateTrigger.hover, children: _items),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await mouse.moveTo(const Offset(50, 10));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      await mouse.moveTo(const Offset(500, 500));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('starts from where it began when it is played again', (WidgetTester tester) async {
      Widget strip(int play) {
        return NebaAnimateMarquee(
          trigger: NebaAnimateTrigger.manual,
          play: play,
          duration: const Duration(seconds: 10),
          children: _items,
        );
      }

      await _pump(tester, strip(1));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(_shift(tester).dx, lessThan(0));

      await _pump(tester, strip(2));
      expect(_shift(tester), Offset.zero);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
