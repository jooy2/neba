// NebaAnimateFade, and with it everything every `Animate*` shares: the
// timings, the triggers, the stagger and the scroll timeline, as the React
// package's AnimateFade test carries them for the whole set.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// The opacity the fade is drawing [index] at.
double _opacity(WidgetTester tester, [int index = 0]) {
  return tester
      .widgetList<Opacity>(
        find.descendant(of: find.byType(NebaAnimateFade), matching: find.byType(Opacity)),
      )
      .elementAt(index)
      .opacity;
}

void main() {
  group('rendering', () {
    testWidgets('renders what it was given, and takes the room it takes', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateFade(child: _content));

      expect(find.byKey(const Key('content')), findsOneWidget);
      expect(tester.getSize(find.byType(NebaAnimateFade)), const Size(100, 40));

      await tester.pumpAndSettle();
    });

    testWidgets('adds nothing a screen reader hears, and leaves the content to it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateFade(child: Text('Arriving')));

      expect(_opacity(tester), 0);
      expect(find.bySemanticsLabel('Arriving'), findsOneWidget);

      await tester.pumpAndSettle();
      semantics.dispose();
    });
  });

  group('settings', () {
    testWidgets('fades in over its own 320 milliseconds by default', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateFade(child: _content));
      expect(_opacity(tester), 0);

      await tester.pump(const Duration(milliseconds: 160));
      expect(_opacity(tester), inExclusiveRange(0, 1));

      await tester.pump(const Duration(milliseconds: 160));
      expect(_opacity(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('holds the first frame through the delay', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          delay: Duration(milliseconds: 200),
          duration: Duration(milliseconds: 100),
          child: _content,
        ),
      );

      await tester.pump(const Duration(milliseconds: 190));
      expect(_opacity(tester), 0);

      await tester.pump(const Duration(milliseconds: 60));
      expect(_opacity(tester), greaterThan(0));

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('starts from the opacity it was given', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateFade(from: 0.4, child: _content));

      expect(_opacity(tester), closeTo(0.4, 1e-9));
      await tester.pumpAndSettle();
    });

    testWidgets('runs the same fade backwards for an exit, and holds it there', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateFade(mode: NebaAnimateMode.exit, child: _content));

      expect(_opacity(tester), 1);

      await tester.pumpAndSettle();
      expect(_opacity(tester), 0);
    });

    testWidgets('combines alternate with the direction rather than replacing it', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          mode: NebaAnimateMode.exit,
          repeat: 2,
          alternate: true,
          child: _content,
        ),
      );

      await tester.pump(const Duration(milliseconds: 320));
      expect(_opacity(tester), closeTo(0, 1e-6));

      // Out, then back in: two passes that alternate end where they began.
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('repeats for as long as it is built when the count is endless', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateFade(repeat: double.infinity, child: _content));

      await tester.pump(const Duration(seconds: 10));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('holds where it is when paused, and carries on when let go', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateFade(child: _content));
      await tester.pump(const Duration(milliseconds: 100));

      final double held = _opacity(tester);

      await _pump(tester, const NebaAnimateFade(paused: true, child: _content));
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester), held);
      expect(tester.hasRunningAnimations, isFalse);

      await _pump(tester, const NebaAnimateFade(child: _content));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacity(tester), greaterThan(held));

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('stays finished when its timing changes afterwards', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateFade(child: _content));
      await tester.pumpAndSettle();

      await _pump(tester, const NebaAnimateFade(duration: Duration(seconds: 2), child: _content));
      expect(_opacity(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('eases on the curve it was given', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateFade(curve: Curves.linear, child: _content));

      await tester.pump(const Duration(milliseconds: 80));
      expect(_opacity(tester), closeTo(0.25, 1e-6));

      await tester.pumpAndSettle();
    });
  });

  group('a step per child', () {
    testWidgets('fades the whole of them as one while there is no step', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateFade(children: <Widget>[Text('One'), Text('Two'), Text('Three')]),
      );

      expect(
        find.descendant(of: find.byType(NebaAnimateFade), matching: find.byType(Opacity)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(Opacity), matching: find.byType(Column)),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('hands each child the effect, held back by its place in the list', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          stagger: Duration(milliseconds: 100),
          duration: Duration(milliseconds: 100),
          curve: Curves.linear,
          children: <Widget>[Text('One'), Text('Two'), Text('Three')],
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(_opacity(tester, 0), 1);
      expect(_opacity(tester, 1), closeTo(0.5, 1e-6));
      expect(_opacity(tester, 2), 0);

      await tester.pumpAndSettle();
      expect(_opacity(tester, 2), 1);
    });

    testWidgets('lengthens each child by durationStep, and never past zero', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          duration: Duration(milliseconds: 200),
          durationStep: Duration(milliseconds: -150),
          curve: Curves.linear,
          children: <Widget>[Text('One'), Text('Two'), Text('Three')],
        ),
      );

      await tester.pump(const Duration(milliseconds: 25));
      expect(_opacity(tester, 0), closeTo(0.125, 1e-6));
      expect(_opacity(tester, 1), closeTo(0.5, 1e-6));
      // 200 - 300 is less than nothing, so the third is there at once.
      expect(_opacity(tester, 2), 1);

      await tester.pumpAndSettle();
    });

    testWidgets('runs the list the other way when reversed', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          stagger: Duration(milliseconds: 100),
          duration: Duration(milliseconds: 100),
          reverse: true,
          children: <Widget>[Text('One'), Text('Two'), Text('Three')],
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacity(tester, 0), 0);
      expect(_opacity(tester, 2), 1);

      await tester.pumpAndSettle();
    });

    testWidgets('lays the children out as it is told', (WidgetTester tester) async {
      await _pump(
        tester,
        NebaAnimateFade(
          stagger: const Duration(milliseconds: 60),
          layoutBuilder: (List<Widget> children) => Row(children: children),
          children: const <Widget>[
            SizedBox(key: Key('a'), width: 20, height: 20),
            SizedBox(key: Key('b'), width: 20, height: 20),
          ],
        ),
      );

      final Offset a = tester.getTopLeft(find.byKey(const Key('a')));
      final Offset b = tester.getTopLeft(find.byKey(const Key('b')));

      expect(b - a, const Offset(20, 0));

      await tester.pumpAndSettle();
    });

    testWidgets('keeps a child mounted when the list is reordered', (WidgetTester tester) async {
      Widget list(List<String> names) {
        return NebaAnimateFade(
          stagger: const Duration(milliseconds: 60),
          children: <Widget>[for (final String name in names) _Counter(key: ValueKey(name))],
        );
      }

      await _pump(tester, list(<String>['a', 'b']));
      await tester.pumpAndSettle();
      final State first = tester.state(find.byKey(const ValueKey<String>('a')));

      await _pump(tester, list(<String>['b', 'a']));
      expect(tester.state(find.byKey(const ValueKey<String>('a'))), same(first));
    });
  });

  group('triggers', () {
    testWidgets('waits to be told when the trigger is manual, and runs on play', (
      WidgetTester tester,
    ) async {
      Widget fade(Object? play) {
        return NebaAnimateFade(trigger: NebaAnimateTrigger.manual, play: play, child: _content);
      }

      await _pump(tester, fade(false));
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);

      await _pump(tester, fade(true));
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('replays on a new number and keeps what is inside it', (WidgetTester tester) async {
      Widget fade(int play) {
        return NebaAnimateFade(
          trigger: NebaAnimateTrigger.manual,
          play: play,
          child: const _Counter(key: Key('inside')),
        );
      }

      await _pump(tester, fade(1));
      await tester.pumpAndSettle();
      final State inside = tester.state(find.byKey(const Key('inside')));
      expect(_opacity(tester), 1);

      await _pump(tester, fade(2));
      expect(_opacity(tester), 0);
      expect(tester.state(find.byKey(const Key('inside'))), same(inside));

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('runs under the pointer, starting over on each entry', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(trigger: NebaAnimateTrigger.hover, child: _content),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester), 0);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byKey(const Key('content'))));
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(_opacity(tester), 1);

      await mouse.moveTo(tester.getCenter(find.byKey(const Key('content'))));
      await tester.pump();
      expect(_opacity(tester), 0);

      await tester.pumpAndSettle();
    });

    testWidgets('counts the focus arriving from outside, and not moving within', (
      WidgetTester tester,
    ) async {
      final FocusNode first = FocusNode();
      final FocusNode second = FocusNode();
      final FocusNode outside = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(outside.dispose);

      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Focus(focusNode: outside, child: const SizedBox(width: 10, height: 10)),
            NebaAnimateFade(
              trigger: NebaAnimateTrigger.hover,
              child: Column(
                children: <Widget>[
                  Focus(focusNode: first, child: const SizedBox(width: 10, height: 10)),
                  Focus(focusNode: second, child: const SizedBox(width: 10, height: 10)),
                ],
              ),
            ),
          ],
        ),
      );

      // The focus lands after the frame it was asked in, and the run starts
      // on the frame after that.
      first.requestFocus();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final double partway = _opacity(tester);
      expect(partway, inExclusiveRange(0, 1));

      second.requestFocus();
      await tester.pump();
      expect(_opacity(tester), greaterThanOrEqualTo(partway));

      await tester.pumpAndSettle();
      outside.requestFocus();
      await tester.pump();
      first.requestFocus();
      await tester.pump();
      expect(_opacity(tester), 0);

      await tester.pumpAndSettle();
    });

    testWidgets('starts on a finger on a touch screen', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(trigger: NebaAnimateTrigger.hover, child: _content),
      );

      final TestGesture finger = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('content'))),
      );
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);

      await finger.up();
    });

    testWidgets('stops an endless one when the pointer leaves, and finishes a finite one', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          trigger: NebaAnimateTrigger.hover,
          repeat: double.infinity,
          child: _content,
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byKey(const Key('content'))));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('trigger visible', () {
    Widget page(Widget fade, {ScrollController? controller}) {
      return SingleChildScrollView(
        controller: controller,
        child: Column(children: <Widget>[const SizedBox(height: 900), fade]),
      );
    }

    testWidgets('runs when it is on the screen', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(trigger: NebaAnimateTrigger.visible, child: _content),
      );

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('waits below the fold, and runs once enough of it is in view', (
      WidgetTester tester,
    ) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          page(
            const NebaAnimateFade(
              trigger: NebaAnimateTrigger.visible,
              threshold: 0.5,
              child: _content,
            ),
            controller: controller,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester), 0);

      // Ten of its forty pixels showing: a quarter, short of a half.
      controller.jumpTo(310);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester), 0);

      controller.jumpTo(330);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('runs again on every return when once is off', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          page(
            const NebaAnimateFade(
              trigger: NebaAnimateTrigger.visible,
              once: false,
              child: _content,
            ),
            controller: controller,
          ),
        ),
      );

      controller.jumpTo(400);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);

      controller.jumpTo(0);
      await tester.pump();
      await tester.pump();
      controller.jumpTo(400);
      await tester.pump();
      await tester.pump();
      expect(_opacity(tester), 0);

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('counts a share of the window for something taller than it', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SingleChildScrollView(
          child: NebaAnimateFade(
            trigger: NebaAnimateTrigger.visible,
            threshold: 0.5,
            child: SizedBox(width: 100, height: 3000),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('holds an endless one while it is off the screen', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          page(
            const NebaAnimateFade(repeat: double.infinity, child: _content),
            controller: controller,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      controller.jumpTo(400);
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('driven by the scroll instead of the clock', () {
    testWidgets('plays forwards as it comes up the view and back as it goes down', (
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
                SizedBox(height: 600),
                NebaAnimateFade(
                  timeline: NebaAnimateTimeline.view,
                  curve: Curves.linear,
                  range: NebaViewRange.phase(NebaViewPhase.entry),
                  child: _content,
                ),
                SizedBox(height: 600),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(_opacity(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);

      // Its top twenty pixels into the bottom of the view: half way in.
      controller.jumpTo(20);
      await tester.pump();
      expect(_opacity(tester), closeTo(0.5, 1e-6));

      controller.jumpTo(100);
      await tester.pump();
      expect(_opacity(tester), 1);

      controller.jumpTo(10);
      await tester.pump();
      expect(_opacity(tester), closeTo(0.25, 1e-6));
    });

    testWidgets('never waits for a trigger', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          timeline: NebaAnimateTimeline.view,
          trigger: NebaAnimateTrigger.manual,
          child: _content,
        ),
      );
      await tester.pump();

      // In the middle of a window with no scroll view: past the default range.
      expect(_opacity(tester), 1);
    });

    testWidgets('runs an exit backwards', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(
          timeline: NebaAnimateTimeline.view,
          mode: NebaAnimateMode.exit,
          child: _content,
        ),
      );
      await tester.pump();

      expect(_opacity(tester), 0);
    });
  });

  group('less motion', () {
    testWidgets('draws the last frame at once', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateFade(child: _content), disableAnimations: true);

      expect(_opacity(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('leaves an exit gone', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateFade(mode: NebaAnimateMode.exit, child: _content),
        disableAnimations: true,
      );

      expect(_opacity(tester), 0);
    });

    testWidgets('draws one still waiting for its trigger as it is, never unseen', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateFade(trigger: NebaAnimateTrigger.manual, child: _content),
        disableAnimations: true,
      );

      expect(_opacity(tester), 1);
    });
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
