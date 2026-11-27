// NebaAnimateBlink: the cycle, its floor, its count and its rest. The
// settings every `Animate*` shares are checked on NebaAnimateFade.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(NebaAnimateBlink), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  testWidgets('renders what it was given, starting at full opacity', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateBlink(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(_opacity(tester), 1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('goes faint at the middle of a blink and repeats until it goes', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateBlink(child: _content));

    await tester.pump(const Duration(milliseconds: 450));
    expect(_opacity(tester), closeTo(0, 1e-6));

    await tester.pump(const Duration(milliseconds: 450));
    expect(_opacity(tester), closeTo(1, 1e-6));

    await tester.pump(const Duration(seconds: 10));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('counts the cycles when given a number, and ends full', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateBlink(repeat: 3, child: _content));

    // The middle of the third blink.
    await tester.pump(const Duration(milliseconds: 2250));
    expect(_opacity(tester), closeTo(0, 1e-6));

    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('never blinks faster than three times a second', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateBlink(duration: Duration(milliseconds: 100), child: _content),
    );

    // At 100 milliseconds a blink would be over; at 334 it is still dimming.
    await tester.pump(const Duration(milliseconds: 100));
    expect(_opacity(tester), lessThan(1));

    await tester.pump(const Duration(milliseconds: 67));
    expect(_opacity(tester), closeTo(0, 0.01));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dips to the floor it was given rather than to nothing', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateBlink(min: 0.4, child: _content));

    await tester.pump(const Duration(milliseconds: 450));
    expect(_opacity(tester), closeTo(0.4, 1e-6));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('rests at full opacity when held, and starts over when let go', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateBlink(child: _content));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_opacity(tester), lessThan(1));

    await _pump(tester, const NebaAnimateBlink(paused: true, child: _content));
    expect(_opacity(tester), 1);
    expect(tester.hasRunningAnimations, isFalse);

    await _pump(tester, const NebaAnimateBlink(child: _content));
    await tester.pump(const Duration(milliseconds: 1));
    expect(_opacity(tester), closeTo(1, 0.05));

    await tester.pump(const Duration(milliseconds: 450));
    expect(_opacity(tester), closeTo(0, 0.01));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('holds still at full opacity under reduced motion', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateBlink(child: _content), disableAnimations: true);

    expect(_opacity(tester), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
