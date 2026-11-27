// NebaDragRegion, the scaffold every dragging widget stands on: when it claims
// the pointer, what it reports while the pointer moves, and how a drag ends.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/drag.dart';

import '../support/host.dart';

void main() {
  const Key region = Key('region');

  Widget square({
    bool Function(Offset position)? onStart,
    ValueChanged<Offset>? onMove,
    VoidCallback? onEnd,
    bool eager = true,
    bool enabled = true,
    ValueChanged<bool>? onBuilt,
  }) {
    return NebaDragRegion(
      key: region,
      onStart: onStart,
      onMove: onMove,
      onEnd: onEnd,
      eager: eager,
      enabled: enabled,
      builder: (BuildContext context, bool dragging) {
        onBuilt?.call(dragging);
        return const SizedBox(width: 100, height: 100);
      },
    );
  }

  testWidgets('reports the travel from the press, and the end once', (WidgetTester tester) async {
    final List<Offset> moves = <Offset>[];
    final List<bool> built = <bool>[];
    Offset? pressed;
    int ended = 0;

    await tester.pumpWidget(
      host(
        Center(
          child: square(
            onStart: (Offset position) {
              pressed = position;
              return true;
            },
            onMove: moves.add,
            onEnd: () => ended += 1,
            onBuilt: built.add,
          ),
        ),
      ),
    );

    final TestGesture press = await tester.startGesture(tester.getCenter(find.byKey(region)));
    await tester.pump();
    expect(pressed, const Offset(50, 50));
    expect(built.last, isTrue);

    await press.moveBy(const Offset(10, 0));
    await press.moveBy(const Offset(5, -3));
    expect(moves, <Offset>[const Offset(10, 0), const Offset(15, -3)]);
    expect(ended, 0);

    await press.up();
    await tester.pump();
    expect(ended, 1);
    expect(built.last, isFalse);
  });

  testWidgets('measures the travel in its own pixels inside a scaled ancestor', (
    WidgetTester tester,
  ) async {
    final List<Offset> moves = <Offset>[];

    await tester.pumpWidget(
      host(
        Center(
          child: Transform.scale(scale: 0.5, child: square(onMove: moves.add)),
        ),
      ),
    );

    final TestGesture press = await tester.startGesture(tester.getCenter(find.byKey(region)));
    await press.moveBy(const Offset(20, 10));
    await press.up();

    expect(moves.single, const Offset(40, 20));
  });

  testWidgets('claims the press, so a scroll view around it does not scroll', (
    WidgetTester tester,
  ) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final List<Offset> moves = <Offset>[];

    await tester.pumpWidget(
      host(
        ListView(
          controller: controller,
          children: <Widget>[
            Center(child: square(onMove: moves.add)),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );

    await tester.drag(find.byKey(region), const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
    expect(moves.last, const Offset(0, -80));
  });

  testWidgets('lets the pointer go when onStart says no', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final List<Offset> moves = <Offset>[];

    await tester.pumpWidget(
      host(
        ListView(
          controller: controller,
          children: <Widget>[
            Center(
              child: square(onStart: (Offset position) => false, onMove: moves.add),
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );

    await tester.drag(find.byKey(region), const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(moves, isEmpty);
  });

  testWidgets('leaves a tap alone until the pointer travels, when it is not eager', (
    WidgetTester tester,
  ) async {
    int tapped = 0;
    final List<Offset> moves = <Offset>[];

    await tester.pumpWidget(
      host(
        Center(
          child: GestureDetector(
            onTap: () => tapped += 1,
            child: square(eager: false, onMove: moves.add),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(region));
    expect(tapped, 1);

    await tester.drag(find.byKey(region), const Offset(40, 0));
    expect(tapped, 1);
    expect(moves.last.dx, 40);
  });

  testWidgets('takes the tap from what is around it when it is eager', (WidgetTester tester) async {
    int tapped = 0;

    await tester.pumpWidget(
      host(
        Center(
          child: GestureDetector(onTap: () => tapped += 1, child: square()),
        ),
      ),
    );

    await tester.tap(find.byKey(region));
    expect(tapped, 0);
  });

  testWidgets('starts nothing on a secondary button or while disabled', (
    WidgetTester tester,
  ) async {
    int started = 0;

    bool start(Offset position) {
      started += 1;
      return true;
    }

    await tester.pumpWidget(host(Center(child: square(onStart: start))));

    final TestGesture secondary = await tester.startGesture(
      tester.getCenter(find.byKey(region)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await secondary.up();
    expect(started, 0);

    await tester.pumpWidget(host(Center(child: square(onStart: start, enabled: false))));
    await tester.tap(find.byKey(region));
    expect(started, 0);
  });

  testWidgets('reports no end when it is disposed mid-drag', (WidgetTester tester) async {
    int ended = 0;
    final List<Offset> moves = <Offset>[];

    await tester.pumpWidget(
      host(
        Center(
          child: square(onMove: moves.add, onEnd: () => ended += 1),
        ),
      ),
    );

    final TestGesture press = await tester.startGesture(tester.getCenter(find.byKey(region)));
    await press.moveBy(const Offset(10, 0));

    await tester.pumpWidget(host(const SizedBox()));
    await press.moveBy(const Offset(10, 0));
    await press.up();

    expect(moves, <Offset>[const Offset(10, 0)]);
    expect(ended, 0);
    expect(tester.takeException(), isNull);
  });
}
