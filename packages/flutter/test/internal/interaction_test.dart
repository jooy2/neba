// What a control knows about the pointer and the keyboard.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/interaction.dart';

import '../support/host.dart';

void main() {
  late NebaInteraction state;
  late ValueListenable<Offset?> pointer;
  int taps = 0;

  Widget control({bool enabled = true, FocusNode? focusNode}) {
    return host(
      Center(
        child: NebaInteractive(
          enabled: enabled,
          focusNode: focusNode,
          onTap: () => taps++,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> p) {
            state = interaction;
            pointer = p;

            return const SizedBox(key: Key('control'), width: 100, height: 40);
          },
        ),
      ),
    );
  }

  setUp(() => taps = 0);

  testWidgets('is pressed on the pointer going down, before any tap is recognised', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(control());
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('control'))),
    );
    await tester.pump();

    expect(state.pressed, isTrue);
    expect(taps, 0);

    await gesture.up();
    await tester.pump();

    expect(state.pressed, isFalse);
    expect(taps, 1);
  });

  testWidgets('does not tap when a press is dragged off and released', (WidgetTester tester) async {
    await tester.pumpWidget(control());
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('control'))),
    );
    await gesture.moveBy(const Offset(0, 300));
    await gesture.up();
    await tester.pump();

    expect(taps, 0);
    expect(state.pressed, isFalse);
  });

  testWidgets('is hovered by a mouse, and follows it', (WidgetTester tester) async {
    await tester.pumpWidget(control());
    final Offset topLeft = tester.getTopLeft(find.byKey(const Key('control')));
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(topLeft + const Offset(30, 10));
    await tester.pump();

    expect(state.hovered, isTrue);
    expect(pointer.value, const Offset(30, 10));

    await mouse.moveTo(Offset.zero);
    await tester.pump();

    expect(state.hovered, isFalse);
    expect(pointer.value, isNull);
  });

  testWidgets('shows keyboard focus, and is activated by Enter and Space', (
    WidgetTester tester,
  ) async {
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    // The keyboard's mode, which a focus that came from the keyboard puts the
    // focus manager in.
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
    await tester.pumpWidget(control(focusNode: node));

    node.requestFocus();
    // The detector says the highlight changed while the focus change is being
    // applied, so the ring is drawn in the frame after the one that moved the
    // focus.
    await tester.pump();
    await tester.pump();

    expect(state.focusVisible, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(taps, 2);
  });

  testWidgets('a disabled control takes nothing', (WidgetTester tester) async {
    await tester.pumpWidget(control(enabled: false));
    await tester.tap(find.byKey(const Key('control')));
    await tester.pump();

    expect(taps, 0);
    expect(state.enabled, isFalse);
    expect(state.pressed, isFalse);
  });
}
