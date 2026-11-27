// NebaAnimateSlide: the edge it comes from, how far, and an entrance that
// waits for the screen where it will land. The settings every `Animate*`
// shares are checked on NebaAnimateFade.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

const Widget _content = SizedBox(key: Key('content'), width: 100, height: 40);

Future<void> _pump(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(host(Center(child: widget)));
}

Offset _fraction(WidgetTester tester) {
  return tester
      .widget<FractionalTranslation>(
        find.descendant(
          of: find.byType(NebaAnimateSlide),
          matching: find.byType(FractionalTranslation),
        ),
      )
      .translation;
}

Offset _shift(WidgetTester tester) {
  final Matrix4 transform = tester
      .widget<Transform>(
        find.descendant(of: find.byType(NebaAnimateSlide), matching: find.byType(Transform)),
      )
      .transform;

  return Offset(transform.getTranslation().x, transform.getTranslation().y);
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(NebaAnimateSlide), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  testWidgets('renders what it was given, and takes no room for the travel', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateSlide(child: _content));

    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(tester.getSize(find.byType(NebaAnimateSlide)), const Size(100, 40));

    await tester.pumpAndSettle();
  });

  testWidgets('comes up from below by its own height by default', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateSlide(child: _content));

    expect(_fraction(tester), const Offset(0, 1));
    expect(_opacity(tester), 0);

    await tester.pump(const Duration(milliseconds: 380));
    expect(_fraction(tester), Offset.zero);
    expect(_opacity(tester), 1);
  });

  testWidgets('comes from the edge it was told, whatever the direction', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateSlide(from: NebaSide.top, child: _content));
    expect(_fraction(tester), const Offset(0, -1));

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      host(
        const Center(
          child: NebaAnimateSlide(from: NebaSide.left, child: _content),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
    expect(_fraction(tester), const Offset(-1, 0));

    await tester.pumpAndSettle();
  });

  testWidgets('takes a distance in logical pixels', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateSlide(from: NebaSide.right, distance: 24, child: _content),
    );

    expect(_fraction(tester), Offset.zero);
    expect(_shift(tester), const Offset(24, 0));

    await tester.pumpAndSettle();
    expect(_shift(tester), Offset.zero);
  });

  testWidgets('drops the fade when told', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateSlide(fade: false, child: _content));

    expect(_opacity(tester), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('leaves by the same edge for an exit, and stays gone', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateSlide(mode: NebaAnimateMode.exit, from: NebaSide.right, child: _content),
    );

    expect(_fraction(tester), Offset.zero);

    await tester.pumpAndSettle();
    expect(_fraction(tester), const Offset(1, 0));
    expect(_opacity(tester), 0);
  });

  group('waiting to be scrolled into view', () {
    Widget page(Widget slide, ScrollController controller) {
      return SingleChildScrollView(
        controller: controller,
        child: Column(children: <Widget>[const SizedBox(height: 900), slide]),
      );
    }

    testWidgets('is held unseen where it will land, not a width away', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          page(
            const NebaAnimateSlide(
              from: NebaSide.left,
              fade: false,
              trigger: NebaAnimateTrigger.visible,
              child: _content,
            ),
            controller,
          ),
        ),
      );
      await tester.pump();

      expect(_fraction(tester), Offset.zero);
      expect(_opacity(tester), 0);

      controller.jumpTo(400);
      await tester.pump();
      await tester.pump();

      // Let go, it starts from its own first frame, a width away.
      expect(_fraction(tester).dx, lessThan(0));
      expect(_opacity(tester), 1);

      await tester.pumpAndSettle();
      expect(_fraction(tester), Offset.zero);
    });

    testWidgets('starts inside a box that clips it', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          page(
            const ClipRect(
              child: NebaAnimateSlide(trigger: NebaAnimateTrigger.visible, child: _content),
            ),
            controller,
          ),
        ),
      );

      controller.jumpTo(400);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(_fraction(tester), Offset.zero);
      expect(_opacity(tester), 1);
    });
  });
}
