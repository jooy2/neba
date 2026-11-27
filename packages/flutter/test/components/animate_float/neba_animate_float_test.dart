// NebaAnimateFloat: a drift that never ends, its way and its distance, and
// where it rests when it cannot move. The settings every `Animate*` shares
// are checked on NebaAnimateFade.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

Offset _shift(WidgetTester tester) {
  final Matrix4 transform = tester
      .widget<Transform>(
        find.descendant(of: find.byType(NebaAnimateFloat), matching: find.byType(Transform)),
      )
      .transform;

  return Offset(transform.getTranslation().x, transform.getTranslation().y);
}

void main() {
  testWidgets('renders what it was given, starting where the layout put it', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateFloat(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(tester.getSize(find.byType(NebaAnimateFloat)), const Size(100, 40));
    expect(_shift(tester), Offset.zero);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('drifts upward by default, turns round and runs for ever', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateFloat(child: _content));

    await tester.pump(const Duration(milliseconds: 1600));
    expect(_shift(tester).dy, closeTo(-4, 1e-6));

    await tester.pump(const Duration(milliseconds: 1600));
    expect(_shift(tester).dy, closeTo(-8, 1e-6));

    // On the way back rather than jumping: the second pass runs backwards.
    await tester.pump(const Duration(milliseconds: 1600));
    expect(_shift(tester).dy, closeTo(-4, 1e-6));

    await tester.pump(const Duration(seconds: 30));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('drifts the way and the distance it was told', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateFloat(
        from: NebaSide.left,
        distance: 14,
        duration: Duration(milliseconds: 2200),
        child: _content,
      ),
    );

    await tester.pump(const Duration(milliseconds: 2200));
    expect(_shift(tester), const Offset(-14, 0));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('holds where it is when paused', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateFloat(child: _content));
    await tester.pump(const Duration(milliseconds: 1000));
    final Offset held = _shift(tester);

    await _pump(tester, const NebaAnimateFloat(paused: true, child: _content));
    await tester.pump(const Duration(seconds: 2));
    expect(_shift(tester), held);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('does not move at all under reduced motion', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateFloat(child: _content), disableAnimations: true);

    expect(_shift(tester), Offset.zero);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('puts a set out of step with a stagger', (WidgetTester tester) async {
    await _pump(
      tester,
      NebaAnimateFloat(
        stagger: const Duration(milliseconds: 400),
        layoutBuilder: (List<Widget> children) => Row(children: children),
        children: const <Widget>[SizedBox(width: 20, height: 20), SizedBox(width: 20, height: 20)],
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));
    final List<double> drift = tester
        .widgetList<Transform>(
          find.descendant(of: find.byType(NebaAnimateFloat), matching: find.byType(Transform)),
        )
        .map((Transform transform) => transform.transform.getTranslation().y)
        .toList();

    expect(drift[0], lessThan(0));
    expect(drift[1], 0);

    await tester.pumpWidget(const SizedBox());
  });
}
