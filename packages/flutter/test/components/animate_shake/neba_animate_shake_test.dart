// NebaAnimateShake: an answer played on a count, its swing, and a replay
// that touches nothing inside it. The settings every `Animate*` shares are
// checked on NebaAnimateFade.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// How far the shake has the content to the side.
double _swing(WidgetTester tester) {
  return tester
      .widget<Transform>(
        find.descendant(of: find.byType(NebaAnimateShake), matching: find.byType(Transform)).first,
      )
      .transform
      .getTranslation()
      .x;
}

void main() {
  testWidgets('renders what it was given, where it sits', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateShake(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(_swing(tester), 0);
  });

  testWidgets('waits to be played rather than running on its first build', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateShake(child: _content));

    await tester.pump(const Duration(milliseconds: 84));
    expect(_swing(tester), 0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('swings out to its distance each way and ends where it began', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateShake(play: 1, child: _content));

    // The first stop, a fifth of the way through: the whole distance back.
    await tester.pump(const Duration(milliseconds: 84));
    expect(_swing(tester), closeTo(-6, 1e-6));

    await tester.pump(const Duration(milliseconds: 84));
    expect(_swing(tester), closeTo(6, 1e-6));

    await tester.pump(const Duration(milliseconds: 84));
    expect(_swing(tester), closeTo(-3.3, 1e-6));

    await tester.pumpAndSettle();
    expect(_swing(tester), 0);
  });

  testWidgets('travels as far as it was told', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateShake(play: true, distance: 12, child: _content));

    await tester.pump(const Duration(milliseconds: 168));
    expect(_swing(tester), closeTo(12, 1e-6));

    await tester.pumpAndSettle();
  });

  testWidgets('replays on a new number and keeps what is inside it', (WidgetTester tester) async {
    final FocusNode focus = FocusNode();
    addTearDown(focus.dispose);

    Widget shake(int play) {
      return NebaAnimateShake(
        play: play,
        child: Focus(
          focusNode: focus,
          child: const _Counter(key: Key('inside')),
        ),
      );
    }

    await _pump(tester, shake(1));
    focus.requestFocus();
    await tester.pumpAndSettle();
    final State inside = tester.state(find.byKey(const Key('inside')));

    await _pump(tester, shake(2));
    await tester.pump(const Duration(milliseconds: 84));
    expect(_swing(tester), closeTo(-6, 1e-6));
    expect(tester.state(find.byKey(const Key('inside'))), same(inside));
    expect(focus.hasFocus, isTrue);

    await tester.pumpAndSettle();
  });

  testWidgets('replays only itself, not an effect inside it', (WidgetTester tester) async {
    Widget shake(int play) {
      return NebaAnimateShake(
        play: play,
        child: const NebaAnimateFade(child: _content),
      );
    }

    await _pump(tester, shake(1));
    await tester.pumpAndSettle();

    await _pump(tester, shake(2));
    await tester.pump(const Duration(milliseconds: 20));

    final double fade = tester
        .widget<Opacity>(
          find.descendant(of: find.byType(NebaAnimateFade), matching: find.byType(Opacity)),
        )
        .opacity;

    expect(fade, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('does not move at all under reduced motion', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateShake(play: 1, child: _content), disableAnimations: true);

    expect(_swing(tester), 0);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

/// A widget with state of its own, to see whether it was rebuilt or kept.
class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  Widget build(BuildContext context) => const SizedBox(width: 20, height: 20);
}
