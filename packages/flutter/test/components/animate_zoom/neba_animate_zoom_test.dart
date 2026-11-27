// NebaAnimateZoom: a grow from much further, always about the middle. The
// settings every `Animate*` shares are checked on NebaAnimateFade.

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
    find.descendant(of: find.byType(NebaAnimateZoom), matching: find.byType(Transform)),
  );
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(NebaAnimateZoom), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  testWidgets('renders what it was given, at the size it takes', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateZoom(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(tester.getSize(find.byType(NebaAnimateZoom)), const Size(100, 40));

    await tester.pumpAndSettle();
  });

  testWidgets('starts much smaller than a grow does, and transparent', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateZoom(child: _content));

    expect(_transform(tester).transform.entry(0, 0), closeTo(0.4, 1e-9));
    expect(_opacity(tester), 0);

    await tester.pump(const Duration(milliseconds: 340));
    expect(_transform(tester).transform.entry(0, 0), closeTo(1, 1e-9));
  });

  testWidgets('always comes from the middle', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateZoom(from: 0.5, child: _content));

    expect(_transform(tester).alignment, Alignment.center);
    expect(
      tester.renderObject<RenderBox>(find.byKey(const Key('content'))).localToGlobal(Offset.zero),
      tester.getCenter(find.byType(NebaAnimateZoom)) - const Offset(25, 10),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('starts from the scale it was given, and without the fade when told', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateZoom(from: 1.8, fade: false, child: _content));

    expect(_transform(tester).transform.entry(0, 0), closeTo(1.8, 1e-9));
    expect(_opacity(tester), 1);

    await tester.pumpAndSettle();
  });

  testWidgets('falls away for an exit', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateZoom(mode: NebaAnimateMode.exit, child: _content));
    await tester.pumpAndSettle();

    expect(_transform(tester).transform.entry(0, 0), closeTo(0.4, 1e-9));
    expect(_opacity(tester), 0);
  });

  testWidgets('waits for the screen unseen where it will land, not shrunk', (
    WidgetTester tester,
  ) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      host(
        SingleChildScrollView(
          controller: controller,
          child: const Column(
            children: <Widget>[
              SizedBox(height: 900),
              NebaAnimateZoom(trigger: NebaAnimateTrigger.visible, fade: false, child: _content),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(_opacity(tester), 0);
    expect(_transform(tester).transform.entry(0, 0), closeTo(1, 1e-9));

    controller.jumpTo(400);
    await tester.pump();
    await tester.pump();

    // Let go: on its first frame, shrunk and in plain sight, and on its way.
    expect(_opacity(tester), 1);
    expect(_transform(tester).transform.entry(0, 0), lessThan(1));

    await tester.pumpAndSettle();
  });
}
