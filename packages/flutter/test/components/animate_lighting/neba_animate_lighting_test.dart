// NebaAnimateLighting: a light travelling round the outside of what it wraps,
// as the React package's AnimateLighting test carries it.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/animate.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

Finder _inside(Type type) {
  return find.descendant(of: find.byType(NebaAnimateLighting), matching: find.byType(type)).first;
}

void main() {
  group('rendering', () {
    testWidgets('renders what it lights, and takes its room and no more', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateLighting(child: _content));

      expect(find.byKey(const Key('content')), findsOneWidget);
      expect(tester.getSize(find.byType(NebaAnimateLighting)), const Size(100, 40));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('draws its light behind the content, out of the pointer and the reader', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateLighting(child: Text('Live')));

      final Stack stack = tester.widget<Stack>(_inside(Stack));

      expect(stack.children.last, isA<Text>());
      expect(
        find.descendant(of: _inside(Positioned), matching: find.byType(IgnorePointer)),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Live'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });
  });

  group('the light', () {
    testWidgets('reaches past the content by its spread, along its corners, softened by blur', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateLighting(size: NebaSize.lg, spread: 6, blur: 9, child: _content),
      );

      final Positioned ring = tester.widget<Positioned>(_inside(Positioned));

      expect(<double?>[ring.left, ring.top, ring.right, ring.bottom], <double>[-6, -6, -6, -6]);
      expect(tester.getSize(_inside(ClipRRect)), const Size(112, 52));
      expect(
        tester.widget<ClipRRect>(_inside(ClipRRect)).borderRadius,
        BorderRadius.circular(NebaTokens.defaultRadius[NebaSize.lg]!),
      );
      expect(
        find.descendant(of: _inside(Positioned), matching: find.byType(ImageFiltered)),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('is drawn in the family it was given, or a colour of its own', (
      WidgetTester tester,
    ) async {
      final NebaTokens tokens = NebaTokens.light();

      // Under less motion the light is the colour all round, which says it.
      await _pump(
        tester,
        const NebaAnimateLighting(color: NebaColor.danger, child: _content),
        disableAnimations: true,
      );
      expect(
        tester.renderObject(_inside(CustomPaint)),
        paints..rect(color: tokens.roles(NebaColor.danger).accent),
      );

      await _pump(
        tester,
        const NebaAnimateLighting(glow: Color(0xffd946ef), child: _content),
        disableAnimations: true,
      );
      expect(
        tester.renderObject(_inside(CustomPaint)),
        paints..rect(color: const Color(0xffd946ef)),
      );
    });

    testWidgets('travels a lap in three seconds, forever unless told otherwise', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateLighting(child: _content));

      final NebaAnimateRun run = tester.widget<NebaAnimateRun>(_inside(NebaAnimateRun));

      expect(run.timing.duration, 3000);
      expect(run.timing.repeat, double.infinity);

      await tester.pump(const Duration(seconds: 10));
      expect(tester.hasRunningAnimations, isTrue);

      await _pump(tester, const NebaAnimateLighting(repeat: 1, child: _content));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('runs the other way round when reversed', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateLighting(reverse: true, child: _content));

      expect(tester.widget<NebaAnimateRun>(_inside(NebaAnimateRun)).timing.reversed, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('becomes an even glow that does not move under less motion', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateLighting(child: _content), disableAnimations: true);

      expect(tester.renderObject(_inside(CustomPaint)), paints..rect());
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('when it runs', () {
    testWidgets('holds the light while it is off the screen, and runs again once back', (
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
                NebaAnimateLighting(child: _content),
              ],
            ),
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

    testWidgets('runs under the pointer on hover, and stops when it leaves', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateLighting(trigger: NebaAnimateTrigger.hover, child: _content),
      );
      expect(tester.hasRunningAnimations, isFalse);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byKey(const Key('content'))));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('holds where it is when paused', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateLighting(paused: true, child: _content));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
