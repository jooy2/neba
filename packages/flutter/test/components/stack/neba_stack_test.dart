// NebaStack: the suite the React package runs on Stack, asked the way Flutter
// asks it — where each item is laid out and painted instead of the margins
// and z-indices it writes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/ring.dart';

import '../../support/host.dart';

void main() {
  const List<String> names = <String>['Ada', 'Bo', 'Cai'];

  Widget face(String name, {double side = 40, VoidCallback? onTap}) {
    return GestureDetector(
      key: ValueKey<String>(name),
      onTap: onTap,
      child: SizedBox(width: side, height: side, child: Text(name)),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget stack, {
    NebaDefaults? defaults,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Center(
          child: defaults == null ? stack : NebaProvider(defaults: defaults, child: stack),
        ),
        textDirection: textDirection,
      ),
    );
  }

  Rect rectOf(WidgetTester tester, String name) =>
      tester.getRect(find.byKey(ValueKey<String>(name)));

  group('rendering', () {
    testWidgets('draws one item per child, and the child as it was handed over', (
      WidgetTester tester,
    ) async {
      final List<Widget> faces = <Widget>[for (final String name in names) face(name)];

      await pump(tester, NebaStack(children: faces));

      for (final Widget child in faces) {
        expect(find.byWidget(child), findsOneWidget);
      }
      expect(find.byType(KeyedSubtree), findsNWidgets(3));
    });

    testWidgets('adds no semantics of its own', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaStack(children: <Widget>[for (final String name in names) face(name)]),
      );

      expect(find.bySemanticsLabel('Ada'), findsOneWidget);
      expect(find.bySemanticsLabel('Cai'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('the pile', () {
    testWidgets('pulls every item but the first back along the reading direction', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(overlap: 12, children: <Widget>[for (final String name in names) face(name)]),
      );

      final Rect ada = rectOf(tester, 'Ada');
      final Rect bo = rectOf(tester, 'Bo');

      expect(bo.left - ada.left, 40 - 12);
      expect(bo.top, ada.top);
      // Exactly the room the pile covers: three faces less two overlaps.
      expect(tester.getSize(find.byType(NebaStack)), const Size(40 * 3 - 12 * 2, 40));
    });

    testWidgets('runs down the page when it is vertical', (WidgetTester tester) async {
      await pump(
        tester,
        NebaStack(
          direction: NebaStackDirection.vertical,
          overlap: 12,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      final Rect ada = rectOf(tester, 'Ada');
      final Rect bo = rectOf(tester, 'Bo');

      expect(bo.top - ada.top, 40 - 12);
      expect(bo.left, ada.left);
      expect(tester.getSize(find.byType(NebaStack)), const Size(40, 40 * 3 - 12 * 2));
    });

    testWidgets('flows sideways and falls as it goes when it is diagonal', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          direction: NebaStackDirection.diagonal,
          overlap: 12,
          drop: 5,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      final Rect ada = rectOf(tester, 'Ada');

      expect(rectOf(tester, 'Bo').top - ada.top, 5);
      expect(rectOf(tester, 'Cai').top - ada.top, 10);
      expect(rectOf(tester, 'Bo').left - ada.left, 28);
      expect(tester.getSize(find.byType(NebaStack)).height, 40 + 10);
    });

    testWidgets('drops by the overlap when a diagonal is given no drop', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          direction: NebaStackDirection.diagonal,
          overlap: 8,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      expect(rectOf(tester, 'Bo').top - rectOf(tester, 'Ada').top, 8);
    });

    testWidgets('takes the overlap from size, and size from the provider', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          size: NebaSize.xs,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );
      expect(rectOf(tester, 'Bo').left - rectOf(tester, 'Ada').left, 40 - 6);

      await pump(
        tester,
        NebaStack(children: <Widget>[for (final String name in names) face(name)]),
      );
      expect(rectOf(tester, 'Bo').left - rectOf(tester, 'Ada').left, 40 - 10);

      await pump(
        tester,
        NebaStack(children: <Widget>[for (final String name in names) face(name)]),
        defaults: const NebaDefaults(size: NebaSize.xl),
      );
      expect(rectOf(tester, 'Bo').left - rectOf(tester, 'Ada').left, 40 - 14);
    });

    testWidgets('runs from the right under RTL, and keeps falling down', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          direction: NebaStackDirection.diagonal,
          overlap: 12,
          drop: 5,
          children: <Widget>[for (final String name in names) face(name)],
        ),
        textDirection: TextDirection.rtl,
      );

      final Rect pile = tester.getRect(find.byType(NebaStack));

      expect(rectOf(tester, 'Ada').right, pile.right);
      expect(rectOf(tester, 'Ada').left - rectOf(tester, 'Bo').left, 28);
      expect(rectOf(tester, 'Bo').top - rectOf(tester, 'Ada').top, 5);
    });

    testWidgets('puts the first child at the front, and the last when asked', (
      WidgetTester tester,
    ) async {
      final List<String> pressed = <String>[];

      Widget pile(NebaStackFront front) {
        return NebaStack(
          front: front,
          overlap: 20,
          children: <Widget>[
            for (final String name in names) face(name, onTap: () => pressed.add(name)),
          ],
        );
      }

      // The middle of the strip Ada and Bo share.
      Offset shared() => Offset(rectOf(tester, 'Bo').left + 10, rectOf(tester, 'Bo').center.dy);

      await pump(tester, pile(NebaStackFront.first));
      await tester.tapAt(shared());

      await pump(tester, pile(NebaStackFront.last));
      await tester.tapAt(shared());

      expect(pressed, <String>['Ada', 'Bo']);
    });

    testWidgets('reports the room it covers to an intrinsic measurement', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        IntrinsicWidth(
          child: NebaStack(
            overlap: 12,
            children: <Widget>[for (final String name in names) face(name)],
          ),
        ),
      );

      expect(tester.getSize(find.byType(IntrinsicWidth)).width, 40 * 3 - 12 * 2);
    });
  });

  group('depth', () {
    List<double> scales(WidgetTester tester) {
      return tester
          .widgetList<Transform>(
            find.descendant(of: find.byType(NebaStack), matching: find.byType(Transform)),
          )
          .map((Transform transform) => transform.transform.entry(0, 0))
          .toList();
    }

    List<double> opacities(WidgetTester tester) {
      return tester
          .widgetList<Opacity>(
            find.descendant(of: find.byType(NebaStack), matching: find.byType(Opacity)),
          )
          .map((Opacity opacity) => opacity.opacity)
          .toList();
    }

    testWidgets('shrinks each item against the one before it, and leaves its room', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          scaleStep: 0.9,
          overlap: 12,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      expect(scales(tester)[0], closeTo(1, 1e-9));
      expect(scales(tester)[1], closeTo(0.9, 1e-9));
      expect(scales(tester)[2], closeTo(0.81, 1e-9));
      expect(tester.getSize(find.byType(NebaStack)).width, 40 * 3 - 12 * 2);
    });

    testWidgets('fades each item against the one before it', (WidgetTester tester) async {
      await pump(
        tester,
        NebaStack(
          opacityStep: 0.5,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      expect(opacities(tester), <double>[1, 0.5, 0.25]);
    });

    testWidgets('draws every item as it is while the steps are one', (WidgetTester tester) async {
      await pump(
        tester,
        NebaStack(children: <Widget>[for (final String name in names) face(name)]),
      );

      expect(opacities(tester), everyElement(1));
      expect(scales(tester), everyElement(1));
    });
  });

  group('the ones that did not fit', () {
    Widget marker(int hidden) => Text('+$hidden');

    testWidgets('stops at max and hands the rest to overflow, at the back', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          max: 2,
          overflow: marker,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      expect(find.text('Cai'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
      expect(find.byType(KeyedSubtree), findsNWidgets(3));
      expect(tester.getRect(find.text('+1')).left, greaterThan(rectOf(tester, 'Bo').left));
    });

    testWidgets('counts against total when it was handed only the first few', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          max: 2,
          total: 40,
          overflow: marker,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      expect(find.text('+38'), findsOneWidget);
    });

    testWidgets('draws nothing extra when everything fits, or with no overflow', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaStack(
          max: 5,
          overflow: marker,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );
      expect(find.byType(KeyedSubtree), findsNWidgets(3));

      await pump(
        tester,
        NebaStack(max: 1, children: <Widget>[for (final String name in names) face(name)]),
      );
      expect(find.byType(KeyedSubtree), findsOneWidget);
    });
  });

  group('arriving', () {
    List<NebaEntrance> entrances(WidgetTester tester) {
      return tester.widgetList<NebaEntrance>(find.byType(NebaEntrance)).toList();
    }

    testWidgets('gives each item the effect it was asked for', (WidgetTester tester) async {
      await pump(
        tester,
        NebaStack(
          transition: const NebaTransition.fade(),
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      expect(entrances(tester), hasLength(3));
      expect(
        entrances(tester).map((NebaEntrance entrance) => entrance.transition.type),
        everyElement(NebaAnimation.fade),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('deals the pile with a stagger, and from the back when reversed', (
      WidgetTester tester,
    ) async {
      List<Duration> delays() {
        return entrances(tester).map((NebaEntrance entrance) => entrance.delayOffset).toList();
      }

      await pump(
        tester,
        NebaStack(
          transition: const NebaTransition.fade(),
          stagger: const Duration(milliseconds: 70),
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );
      expect(delays(), const <Duration>[
        Duration.zero,
        Duration(milliseconds: 70),
        Duration(milliseconds: 140),
      ]);
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await pump(
        tester,
        NebaStack(
          transition: const NebaTransition.fade(),
          stagger: const Duration(milliseconds: 70),
          reverse: true,
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );
      expect(delays(), const <Duration>[
        Duration(milliseconds: 140),
        Duration(milliseconds: 70),
        Duration.zero,
      ]);
      await tester.pumpAndSettle();
    });

    testWidgets('lengthens each item by durationStep, and never past zero', (
      WidgetTester tester,
    ) async {
      double arrived(int index) {
        return tester
            .widget<Opacity>(
              find
                  .descendant(
                    of: find.byType(NebaEntrance).at(index),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity;
      }

      await pump(
        tester,
        NebaStack(
          transition: const NebaTransition.fade(duration: Duration(milliseconds: 200)),
          durationStep: const Duration(milliseconds: -150),
          children: <Widget>[for (final String name in names) face(name)],
        ),
      );

      // 200, 50 and 0 milliseconds.
      await tester.pump();
      expect(arrived(2), 1);
      await tester.pump(const Duration(milliseconds: 60));
      expect(arrived(1), 1);
      expect(arrived(0), lessThan(1));
      await tester.pumpAndSettle();
      expect(arrived(0), 1);
    });

    testWidgets('plays no entrance when it was given no transition', (WidgetTester tester) async {
      await pump(
        tester,
        NebaStack(children: <Widget>[for (final String name in names) face(name)]),
      );

      expect(find.byType(NebaEntrance), findsNothing);
    });
  });

  group('ring', () {
    Iterable<BoxDecoration> rings(WidgetTester tester) {
      return tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(NebaRing), matching: find.byType(DecoratedBox)),
          )
          .map((DecoratedBox box) => box.decoration as BoxDecoration)
          .where((BoxDecoration decoration) => decoration.border != null);
    }

    Widget sheets() {
      return const NebaStack(
        ring: true,
        children: <Widget>[
          NebaBox(child: NebaBox(child: Text('Inner'))),
          NebaBox(child: Text('Second')),
        ],
      );
    }

    testWidgets('is drawn by the first sheet in each item, around its corners', (
      WidgetTester tester,
    ) async {
      await pump(tester, sheets());

      final NebaTokens tokens = NebaTokens.light();
      final List<BoxDecoration> drawn = rings(tester).toList();

      // Two items, two rings: the box inside the first box draws none.
      expect(drawn, hasLength(2));

      for (final BoxDecoration decoration in drawn) {
        final BorderSide side = (decoration.border! as Border).top;

        expect(side.color, tokens.surface);
        expect(side.width, nebaRingWidth);
        expect(side.strokeAlign, BorderSide.strokeAlignOutside);
        expect(decoration.borderRadius, BorderRadius.circular(tokens.radius[NebaSize.md]!));
      }
    });

    testWidgets('is not drawn without ring, or outside a pile', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStack(
          children: <Widget>[
            NebaBox(child: Text('One')),
            NebaBox(child: Text('Two')),
          ],
        ),
      );
      expect(rings(tester), isEmpty);

      await pump(tester, const NebaBox(child: Text('Alone')));
      expect(rings(tester), isEmpty);
    });
  });

  group('identity', () {
    testWidgets('keeps a child mounted when another is put in front of it', (
      WidgetTester tester,
    ) async {
      Widget letters(List<String> list) {
        return NebaStack(
          children: <Widget>[for (final String name in list) _Counter(key: ValueKey<String>(name))],
        );
      }

      await pump(tester, letters(<String>['Ada', 'Bo']));
      final State ada = tester.state(find.byKey(const ValueKey<String>('Ada')));

      await pump(tester, letters(<String>['Cai', 'Ada', 'Bo']));
      expect(tester.state(find.byKey(const ValueKey<String>('Ada'))), same(ada));
    });
  });
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  Widget build(BuildContext context) => const SizedBox(width: 20, height: 20);
}
