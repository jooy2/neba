// A control drawn smaller than a finger and pressed at the size of one.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/hit.dart';

import '../support/host.dart';

void main() {
  int taps = 0;
  int neighbourTaps = 0;

  setUp(() {
    taps = 0;
    neighbourTaps = 0;
  });

  // A 12-pixel control at the end of a row, with a neighbour 4 pixels before
  // it, in an area padded by 16.
  Widget area({bool withArea = true}) {
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => neighbourTaps++,
          child: const SizedBox(key: Key('neighbour'), width: 40, height: 12),
        ),
        NebaHitTarget(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(key: Key('control'), width: 12, height: 12),
          ),
        ),
      ],
    );
    final Widget padded = Padding(padding: const EdgeInsets.all(16), child: row);

    return host(Center(child: withArea ? NebaHitArea(child: padded) : padded));
  }

  Rect control(WidgetTester tester) => tester.getRect(find.byKey(const Key('control')));

  testWidgets('takes no more room than the control', (WidgetTester tester) async {
    await tester.pumpWidget(area());

    expect(control(tester).size, const Size(12, 12));
    expect(
      tester.getSize(find.byType(NebaHitArea)),
      const Size(16 + 40 + 4 + 12 + 16, 16 + 12 + 16),
    );
  });

  testWidgets('takes a press up to 12 pixels from its centre in each direction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(area());

    final Offset centre = control(tester).center;

    for (final Offset offset in const <Offset>[
      Offset(11.5, 0),
      Offset(0, 11.5),
      Offset(0, -11.5),
      Offset(11.5, 11.5),
    ]) {
      await tester.tapAt(centre + offset);
    }

    expect(taps, 4);

    await tester.tapAt(centre + const Offset(12.5, 0));
    await tester.tapAt(centre + const Offset(0, 12.5));
    expect(taps, 4);
  });

  testWidgets('never takes a press from a neighbour it reaches over', (WidgetTester tester) async {
    await tester.pumpWidget(area());

    final Rect neighbour = tester.getRect(find.byKey(const Key('neighbour')));
    // Inside the neighbour and inside the control's grown target.
    await tester.tapAt(Offset(neighbour.right - 1, neighbour.center.dy));

    expect(neighbourTaps, 1);
    expect(taps, 0);
  });

  testWidgets('is only its own box without an area above it', (WidgetTester tester) async {
    await tester.pumpWidget(area(withArea: false));

    await tester.tapAt(control(tester).center + const Offset(8, 0));
    expect(taps, 0);

    await tester.tapAt(control(tester).center);
    expect(taps, 1);
  });

  testWidgets('is hovered from the room around it', (WidgetTester tester) async {
    bool hovered = false;

    await tester.pumpWidget(
      host(
        Center(
          child: NebaHitArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: NebaHitTarget(
                child: MouseRegion(
                  onEnter: (PointerEnterEvent e) => hovered = true,
                  onExit: (PointerExitEvent e) => hovered = false,
                  child: const SizedBox(key: Key('control'), width: 12, height: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(control(tester).center + const Offset(10, 0));
    await tester.pump();
    expect(hovered, isTrue);

    await mouse.moveTo(control(tester).center + const Offset(14, 0));
    await tester.pump();
    expect(hovered, isFalse);

    await mouse.removePointer();
  });

  testWidgets('forgets a control that is taken away', (WidgetTester tester) async {
    await tester.pumpWidget(area());
    await tester.pumpWidget(
      host(
        const Center(
          child: NebaHitArea(child: SizedBox(key: Key('empty'), width: 80, height: 44)),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byKey(const Key('empty'))));
    expect(taps, 0);
  });
}
