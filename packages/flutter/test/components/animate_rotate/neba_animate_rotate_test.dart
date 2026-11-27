// NebaAnimateRotate: the two angles, the point it turns about and the fade.
// The settings every `Animate*` shares are checked on NebaAnimateFade.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 40, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

Transform _transform(WidgetTester tester) {
  return tester.widget<Transform>(
    find.descendant(of: find.byType(NebaAnimateRotate), matching: find.byType(Transform)),
  );
}

/// The angle the frame is turned to, in degrees.
double _angle(WidgetTester tester) {
  final Matrix4 transform = _transform(tester).transform;

  return math.atan2(transform.entry(1, 0), transform.entry(0, 0)) * 180 / math.pi;
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(NebaAnimateRotate), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  testWidgets('renders what it was given, at the size it takes', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateRotate(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(tester.getSize(find.byType(NebaAnimateRotate)), const Size(40, 40));

    await tester.pumpAndSettle();
  });

  testWidgets('swings half a turn into place by default, fading in', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateRotate(child: _content));

    expect(_angle(tester).abs(), closeTo(180, 1e-6));
    expect(_opacity(tester), 0);

    await tester.pump(const Duration(milliseconds: 460));
    expect(_angle(tester), closeTo(0, 1e-6));
    expect(_opacity(tester), 1);
  });

  testWidgets('takes both ends of the turn', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateRotate(from: 10, to: 40, curve: Curves.linear, child: _content),
    );

    expect(_angle(tester), closeTo(10, 1e-6));

    await tester.pump(const Duration(milliseconds: 230));
    expect(_angle(tester), closeTo(25, 1e-6));

    await tester.pumpAndSettle();
    expect(_angle(tester), closeTo(40, 1e-6));
  });

  testWidgets('turns about the point it was told to', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateRotate(origin: Alignment.bottomLeft, child: _content));

    expect(_transform(tester).alignment, Alignment.bottomLeft);
    await tester.pumpAndSettle();
  });

  testWidgets('drops the opacity ramp when fade is off, and spins without end', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const NebaAnimateRotate(
        from: 0,
        to: 360,
        repeat: double.infinity,
        curve: Curves.linear,
        fade: false,
        child: _content,
      ),
    );

    expect(_opacity(tester), 1);

    await tester.pump(const Duration(milliseconds: 115));
    expect(_angle(tester), closeTo(90, 1e-6));

    await tester.pump(const Duration(seconds: 5));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('lands at its to angle under reduced motion', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateRotate(from: 0, to: 90, child: _content),
      disableAnimations: true,
    );

    expect(_angle(tester), closeTo(90, 1e-6));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
