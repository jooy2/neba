// NebaScrollArea: the suite the React package runs on ScrollArea, asked the
// way Flutter asks it — the scroll views, the rails and the mask it builds,
// and what the keys and the pointer do to them.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/scroll_fade.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Widget lines(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 1; index <= count; index += 1)
          SizedBox(height: 20, child: Text('Line $index')),
      ],
    );
  }

  Future<void> pump(WidgetTester tester, Widget area, {NebaDefaults? defaults}) {
    final Widget sized = Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 300, child: area),
    );

    return tester.pumpWidget(
      host(defaults == null ? sized : NebaProvider(defaults: defaults, child: sized)),
    );
  }

  Iterable<RawScrollbar> rails(WidgetTester tester) {
    return tester.widgetList<RawScrollbar>(find.byWidgetPredicate((Widget w) => w is RawScrollbar));
  }

  ScrollbarPainter painterOf(WidgetTester tester) {
    final CustomPaint paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.byWidgetPredicate((Widget w) => w is RawScrollbar),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

    return paint.foregroundPainter! as ScrollbarPainter;
  }

  group('rendering', () {
    testWidgets('holds its content and scrolls it', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(tester, NebaScrollArea(height: 100, controller: controller, child: lines(20)));

      expect(find.text('Line 1'), findsOneWidget);
      expect(tester.getSize(find.byType(NebaScrollArea)).height, 100);

      await tester.drag(find.byType(NebaScrollArea), const Offset(0, -60));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));
    });

    testWidgets('holds a ceiling with maxHeight and shrinks to shorter content', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollArea(maxHeight: 100, child: lines(20)));
      expect(tester.getSize(find.byType(NebaScrollArea)).height, 100);

      await pump(tester, NebaScrollArea(maxHeight: 100, child: lines(2)));
      expect(tester.getSize(find.byType(NebaScrollArea)).height, 40);
    });

    testWidgets('names itself, in the locale\'s words without a label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaScrollArea(height: 100, child: lines(20)));
      expect(find.bySemanticsLabel('Scrollable content'), findsOneWidget);

      await pump(tester, NebaScrollArea(height: 100, label: 'Activity', child: lines(20)));
      expect(find.bySemanticsLabel('Activity'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('orientation', () {
    List<Axis> axes(WidgetTester tester) {
      return tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .map((SingleChildScrollView view) => view.scrollDirection)
          .toList();
    }

    testWidgets('scrolls down by default, with one rail', (WidgetTester tester) async {
      await pump(tester, NebaScrollArea(height: 100, child: lines(20)));

      expect(axes(tester), <Axis>[Axis.vertical]);
      expect(rails(tester), hasLength(1));
    });

    testWidgets('scrolls across when horizontal', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScrollArea(
          orientation: NebaScrollAreaOrientation.horizontal,
          child: SizedBox(width: 900, height: 40),
        ),
      );

      expect(axes(tester), <Axis>[Axis.horizontal]);
      expect(rails(tester), hasLength(1));
    });

    testWidgets('scrolls both ways with a rail on each', (WidgetTester tester) async {
      final ScrollController down = ScrollController();
      final ScrollController across = ScrollController();
      addTearDown(down.dispose);
      addTearDown(across.dispose);

      await pump(
        tester,
        NebaScrollArea(
          orientation: NebaScrollAreaOrientation.both,
          height: 100,
          controller: down,
          horizontalController: across,
          child: const SizedBox(width: 900, height: 900),
        ),
      );

      expect(axes(tester), <Axis>[Axis.horizontal, Axis.vertical]);
      expect(rails(tester), hasLength(2));

      // A drag scrolls one axis at a time, as nested scroll views do.
      await tester.drag(find.byType(NebaScrollArea), const Offset(0, -50));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(NebaScrollArea), const Offset(-50, 0));
      await tester.pumpAndSettle();
      expect(down.offset, greaterThan(0));
      expect(across.offset, greaterThan(0));
    });
  });

  group('the rail', () {
    testWidgets('is as thick as size says, from the provider too', (WidgetTester tester) async {
      await pump(tester, NebaScrollArea(height: 100, child: lines(20)));
      // The thumb, a pixel inside each side of a six-pixel rail.
      expect(rails(tester).single.thickness, 4);

      await pump(tester, NebaScrollArea(height: 100, size: NebaSize.xl, child: lines(20)));
      expect(rails(tester).single.thickness, 8);

      await pump(
        tester,
        NebaScrollArea(height: 100, child: lines(20)),
        defaults: const NebaDefaults(size: NebaSize.xs),
      );
      expect(rails(tester).single.thickness, 2);
    });

    testWidgets('carries the family at a fraction of itself', (WidgetTester tester) async {
      await pump(tester, NebaScrollArea(height: 100, color: NebaColor.secondary, child: lines(20)));

      final Color accent = tokens.roles(NebaColor.secondary).accent;

      expect(painterOf(tester).color, accent.withValues(alpha: accent.a * 0.35));
    });

    testWidgets('shows while the pointer is over the area', (WidgetTester tester) async {
      await pump(tester, NebaScrollArea(height: 100, child: lines(20)));
      expect(rails(tester).single.thumbVisibility, isFalse);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.byType(NebaScrollArea)));
      addTearDown(mouse.removePointer);
      await tester.pump();

      expect(rails(tester).single.thumbVisibility, isTrue);

      await mouse.moveTo(const Offset(700, 500));
      await tester.pump();
      expect(rails(tester).single.thumbVisibility, isFalse);
    });
  });

  group('fade', () {
    NebaEdgeFade fadeOf(WidgetTester tester) =>
        tester.widget<NebaEdgeFade>(find.byType(NebaEdgeFade));

    testWidgets('fades only the edges with more beyond them', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        NebaScrollArea(height: 100, fade: true, controller: controller, child: lines(20)),
      );
      await tester.pump();
      expect(fadeOf(tester).vertical, (false, true));
      expect(fadeOf(tester).reach, 24);

      controller.jumpTo(100);
      await tester.pump();
      expect(fadeOf(tester).vertical, (true, true));

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      expect(fadeOf(tester).vertical, (true, false));
    });

    testWidgets('draws no mask without fade', (WidgetTester tester) async {
      await pump(tester, NebaScrollArea(height: 100, child: lines(20)));

      expect(find.byType(NebaEdgeFade), findsNothing);
    });
  });

  group('keyboard', () {
    FocusNode nodeOf(WidgetTester tester) => Focus.of(tester.element(find.text('Line 1')));

    testWidgets('takes the focus only while there is something to scroll', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollArea(height: 100, child: lines(2)));
      await tester.pump();
      expect(nodeOf(tester).canRequestFocus, isFalse);

      await pump(tester, NebaScrollArea(height: 100, child: lines(20)));
      await tester.pump();
      expect(nodeOf(tester).canRequestFocus, isTrue);
      expect(nodeOf(tester).debugLabel, 'NebaScrollArea');
    });

    testWidgets('scrolls with the arrows, the page keys, Home and End', (
      WidgetTester tester,
    ) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(tester, NebaScrollArea(height: 100, controller: controller, child: lines(40)));
      await tester.pump();
      nodeOf(tester).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.offset, 40);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(controller.offset, 40 + 87.5);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(controller.offset, controller.position.maxScrollExtent);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
    });
  });
}
