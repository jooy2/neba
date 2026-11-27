// NebaEntrance: what the `transition` prop plays, checked frame by frame
// against the keyframes the React stylesheet runs.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/animate.dart';

import '../support/host.dart';

void main() {
  const Widget content = SizedBox(key: Key('content'), width: 100, height: 50);

  Future<void> pump(
    WidgetTester tester,
    NebaTransition transition, {
    bool disableAnimations = false,
    Duration delayOffset = Duration.zero,
    Duration durationOffset = Duration.zero,
  }) {
    return tester.pumpWidget(
      host(
        Center(
          child: NebaEntrance(
            transition: transition,
            delayOffset: delayOffset,
            durationOffset: durationOffset,
            child: content,
          ),
        ),
        disableAnimations: disableAnimations,
      ),
    );
  }

  double opacityOf(WidgetTester tester) {
    return tester.widget<Opacity>(find.byType(Opacity)).opacity;
  }

  Offset fractionOf(WidgetTester tester) {
    return tester.widget<FractionalTranslation>(find.byType(FractionalTranslation)).translation;
  }

  Matrix4 transformOf(WidgetTester tester) {
    return tester.widget<Transform>(find.byType(Transform)).transform;
  }

  group('timing', () {
    testWidgets('runs a fade from transparent to the widget as it is, over its own duration', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.fade());
      expect(opacityOf(tester), 0);

      await tester.pump(const Duration(milliseconds: 160));
      expect(opacityOf(tester), inExclusiveRange(0, 1));

      await tester.pump(const Duration(milliseconds: 160));
      expect(opacityOf(tester), 1);
    });

    testWidgets('holds the first frame through the delay', (WidgetTester tester) async {
      await pump(tester, const NebaTransition.fade(delay: Duration(milliseconds: 200)));

      await tester.pump(const Duration(milliseconds: 190));
      expect(opacityOf(tester), 0);

      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(tester), greaterThan(0));

      await tester.pumpAndSettle();
      expect(opacityOf(tester), 1);
    });

    testWidgets('adds the offsets a pile staggers by, and never runs for less than nothing', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTransition.fade(),
        delayOffset: const Duration(milliseconds: 100),
        durationOffset: const Duration(milliseconds: -1000),
      );

      await tester.pump(const Duration(milliseconds: 90));
      expect(opacityOf(tester), 0);

      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump();
      expect(opacityOf(tester), 1);
    });

    testWidgets('repeats, and with alternate ends a pair of passes where it began', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.fade(repeat: 2, alternate: true));

      await tester.pump(const Duration(milliseconds: 320));
      await tester.pump(const Duration(milliseconds: 160));
      expect(opacityOf(tester), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();
      expect(opacityOf(tester), 0);
    });

    testWidgets('starts every pass over without alternate', (WidgetTester tester) async {
      await pump(tester, const NebaTransition.fade(repeat: 2));

      await tester.pump(const Duration(milliseconds: 320));
      await tester.pump(const Duration(milliseconds: 1));
      expect(opacityOf(tester), lessThan(0.2));

      await tester.pumpAndSettle();
      expect(opacityOf(tester), 1);
    });

    testWidgets('blinks until the widget goes, and never faster than three times a second', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.blink(duration: Duration(milliseconds: 100)));

      expect(opacityOf(tester), 1);

      await tester.pump(const Duration(milliseconds: 167));
      expect(opacityOf(tester), lessThan(0.05));

      await tester.pump(const Duration(milliseconds: 167));
      await tester.pump(const Duration(seconds: 10));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('stops a blink given a count', (WidgetTester tester) async {
      await pump(tester, const NebaTransition.blink(repeat: 2));

      await tester.pumpAndSettle();
      expect(opacityOf(tester), 1);
    });

    testWidgets('starts over when the effect changes, and not when it is rebuilt', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.fade());
      await tester.pumpAndSettle();

      await pump(tester, const NebaTransition.fade(duration: Duration(seconds: 1)));
      expect(opacityOf(tester), 1);

      await pump(tester, const NebaTransition.reveal());
      expect(tester.widget<ClipRect>(find.byType(ClipRect)).clipBehavior, Clip.hardEdge);
      await tester.pumpAndSettle();
    });

    testWidgets('starts at rest when told not to play on build, and plays on a new trigger', (
      WidgetTester tester,
    ) async {
      Future<void> place(Object trigger) {
        return tester.pumpWidget(
          host(
            Center(
              child: NebaEntrance(
                transition: const NebaTransition.fade(),
                playsOnBuild: false,
                trigger: trigger,
                child: const _Kept(),
              ),
            ),
          ),
        );
      }

      await place(0);
      expect(opacityOf(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);

      final State<_Kept> kept = tester.state(find.byType(_Kept));

      await place(1);
      expect(opacityOf(tester), 0);

      await tester.pumpAndSettle();
      expect(opacityOf(tester), 1);
      expect(tester.state(find.byType(_Kept)), same(kept));
    });

    testWidgets('draws the last frame at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.blink(), disableAnimations: true);

      expect(opacityOf(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('effects', () {
    testWidgets('slides from an edge by the widget\'s own size, or by a distance', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.slide());
      expect(fractionOf(tester), const Offset(0, 1));
      await tester.pumpAndSettle();
      expect(fractionOf(tester), Offset.zero);

      await tester.pumpWidget(const SizedBox());
      await pump(tester, const NebaTransition.slide(from: NebaSide.left, distance: 24));
      expect(fractionOf(tester), Offset.zero);
      expect(transformOf(tester).getTranslation().x, -24);
    });

    testWidgets('grows from 0.8 and zooms from 0.4 of the size', (WidgetTester tester) async {
      await pump(tester, const NebaTransition.grow());
      expect(transformOf(tester).entry(0, 0), closeTo(0.8, 1e-9));

      await tester.pumpWidget(const SizedBox());
      await pump(tester, const NebaTransition.zoom());
      expect(transformOf(tester).entry(0, 0), closeTo(0.4, 1e-9));

      await tester.pumpAndSettle();
      expect(transformOf(tester).entry(0, 0), closeTo(1, 1e-9));
    });

    testWidgets('turns in from half a turn back', (WidgetTester tester) async {
      await pump(tester, const NebaTransition.rotate());

      // cos(-180°) on the diagonal: the widget starts upside down.
      expect(transformOf(tester).entry(0, 0), closeTo(-1, 1e-9));

      await tester.pumpAndSettle();
      expect(transformOf(tester).entry(0, 0), closeTo(1, 1e-9));
    });

    testWidgets('wipes a reveal in from its side without fading it', (WidgetTester tester) async {
      await pump(tester, const NebaTransition.reveal());

      expect(opacityOf(tester), 1);

      await tester.pump(const Duration(milliseconds: 310));
      final RenderClipRect clip = tester.renderObject<RenderClipRect>(find.byType(ClipRect));
      final Rect shown = clip.clipper!.getClip(const Size(100, 50));

      expect(shown.left, 0);
      expect(shown.width, inExclusiveRange(0, 100));

      await tester.pumpAndSettle();
      expect(clip.clipper!.getClip(const Size(100, 50)), const Rect.fromLTWH(0, 0, 100, 50));
    });

    testWidgets('leaves the content to a screen reader on the first frame', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const Center(
            child: NebaEntrance(transition: NebaTransition.fade(), child: Text('Arriving')),
          ),
        ),
      );

      expect(opacityOf(tester), 0);
      expect(find.bySemanticsLabel('Arriving'), findsOneWidget);

      await tester.pumpAndSettle();
      semantics.dispose();
    });

    testWidgets('takes nothing out of the layout, so a pile is laid out where it will land', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransition.slide());

      expect(tester.getSize(find.byType(NebaEntrance)), const Size(100, 50));
      await tester.pumpAndSettle();
    });
  });
}

/// A widget with state of its own, to see that a replay keeps it.
class _Kept extends StatefulWidget {
  const _Kept();

  @override
  State<_Kept> createState() => _KeptState();
}

class _KeptState extends State<_Kept> {
  @override
  Widget build(BuildContext context) => const SizedBox(width: 10, height: 10);
}
