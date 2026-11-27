// The focus ring: drawn for keyboard focus, as `:focus-visible` draws it, and
// for any focus on a field, as `:focus-within` does.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';

import '../support/host.dart';

void main() {
  setUp(() {
    // Flutter's own half of the decision, pinned: the focus manager thinks a
    // ring belongs, and what is under test is whether the last input says so.
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  });
  tearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);

  /// The colour the button's ring is heading for: transparent when it is off.
  Color ringOf(WidgetTester tester) {
    final TweenAnimationBuilder<Color?> ring = tester.widget<TweenAnimationBuilder<Color?>>(
      find
          .descendant(
            of: find.byType(NebaFocusRing),
            matching: find.byType(TweenAnimationBuilder<Color?>),
          )
          .first,
    );

    return ring.tween.end!;
  }

  Future<void> pumpButton(WidgetTester tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: NebaButton(onPressed: () {}, child: const Text('Save')),
        ),
      ),
    );
    // The detector learns the highlight mode after its first frame.
    await tester.pump();
  }

  testWidgets('shows for focus reached from the keyboard', (WidgetTester tester) async {
    await pumpButton(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    Focus.of(tester.element(find.text('Save'))).requestFocus();
    // The focus lands, then the detector reports the highlight.
    await tester.pump();
    await tester.pump();

    expect(ringOf(tester).a, greaterThan(0));
  });

  testWidgets('stays off after a mouse press, and comes back with a key', (
    WidgetTester tester,
  ) async {
    await pumpButton(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    Focus.of(tester.element(find.text('Save'))).requestFocus();
    // The focus lands, then the detector reports the highlight.
    await tester.pump();
    await tester.pump();

    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(tester.getCenter(find.text('Save')));
    await mouse.up();
    await tester.pump();
    expect(ringOf(tester).a, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(ringOf(tester).a, greaterThan(0));
  });

  testWidgets('answers any focus on a field, a press included', (WidgetTester tester) async {
    const Color red = Color(0xFFFF0000);

    await tester.pumpWidget(
      host(
        const Center(
          child: NebaFocusRing(
            visible: true,
            keyboardOnly: false,
            color: red,
            child: SizedBox.square(dimension: 20),
          ),
        ),
      ),
    );
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(tester.getCenter(find.byType(SizedBox).last));
    await mouse.up();
    await tester.pump();

    expect(NebaInputModality.pointer.value, isTrue);
    expect(ringOf(tester), red);
  });
}
