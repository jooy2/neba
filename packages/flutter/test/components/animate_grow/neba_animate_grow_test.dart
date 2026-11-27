// NebaAnimateGrow: the scale it starts from, the point it unfolds about, and
// the fade that comes with it. The settings every `Animate*` shares are
// checked on NebaAnimateFade.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(host(Center(child: widget)));
}

Transform _transform(WidgetTester tester) {
  return tester.widget<Transform>(
    find.descendant(of: find.byType(NebaAnimateGrow), matching: find.byType(Transform)),
  );
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(NebaAnimateGrow), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  testWidgets('renders what it was given, at the size it takes', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateGrow(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(tester.getSize(find.byType(NebaAnimateGrow)), const Size(100, 40));

    await tester.pumpAndSettle();
  });

  testWidgets('starts a little under full size and transparent by default', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateGrow(child: _content));

    expect(_transform(tester).transform.entry(0, 0), closeTo(0.8, 1e-9));
    expect(_opacity(tester), 0);

    await tester.pump(const Duration(milliseconds: 340));
    expect(_transform(tester).transform.entry(0, 0), closeTo(1, 1e-9));
    expect(_opacity(tester), 1);
  });

  testWidgets('starts from the scale it was given, above 1 as well', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateGrow(from: 1.3, child: _content));

    expect(_transform(tester).transform.entry(0, 0), closeTo(1.3, 1e-9));
    await tester.pumpAndSettle();
  });

  testWidgets('unfolds about the point it was told to', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateGrow(origin: Alignment.topLeft, from: 0.5, child: _content),
    );

    expect(_transform(tester).alignment, Alignment.topLeft);

    // The top left corner holds still while the rest is half its size.
    final RenderBox content = tester.renderObject(find.byKey(const Key('content')));
    final Offset corner = content.localToGlobal(Offset.zero);
    final Offset far = content.localToGlobal(const Offset(100, 40));

    expect(corner, tester.getTopLeft(find.byType(NebaAnimateGrow)));
    expect(far - corner, const Offset(50, 20));

    await tester.pumpAndSettle();
  });

  testWidgets('drops the opacity ramp when fade is off', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateGrow(fade: false, child: _content));

    expect(_opacity(tester), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('folds away for an exit, and stays folded', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateGrow(mode: NebaAnimateMode.exit, child: _content));

    expect(_transform(tester).transform.entry(0, 0), closeTo(1, 1e-9));

    await tester.pumpAndSettle();
    expect(_transform(tester).transform.entry(0, 0), closeTo(0.8, 1e-9));
    expect(_opacity(tester), 0);
  });

  testWidgets('lands at full size at once under reduced motion', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(const Center(child: NebaAnimateGrow(child: _content)), disableAnimations: true),
    );

    expect(_transform(tester).transform.entry(0, 0), closeTo(1, 1e-9));
    expect(_opacity(tester), 1);
  });
}
