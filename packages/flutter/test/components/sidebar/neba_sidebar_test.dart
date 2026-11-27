// NebaSidebar and NebaSidebarTrigger: the suite the React package runs on
// Sidebar and SidebarTrigger, asked the way Flutter asks it — the width the
// column takes and how a drag and the keys move it, when it is a drawer, and
// the semantics it builds — rather than the landmark, the custom property and
// the media query it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

void main() {
  /// [child] in a window of [size] with an overlay to open a drawer into.
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(1024, 600),
    TextDirection textDirection = TextDirection.ltr,
  }) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: Directionality(
          textDirection: textDirection,
          child: Overlay.wrap(child: child),
        ),
      ),
    );
  }

  /// [sidebar] beside a page, as a standalone column in a row.
  Widget beside(Widget sidebar) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        sidebar,
        const Expanded(child: Text('Page')),
      ],
    );
  }

  Rect columnOf(WidgetTester tester) => tester.getRect(find.byType(NebaSidebar));

  Finder handle() => find.bySemanticsLabel('Resize sidebar');

  group('rendering', () {
    testWidgets('is a complementary region named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, beside(const NebaSidebar(label: 'Sections', child: Text('Nav'))));

      final SemanticsData data = tester.getSemantics(find.byType(NebaSidebar)).getSemanticsData();

      expect(data.role, SemanticsRole.complementary);
      expect(data.label, 'Sections');
      semantics.dispose();
    });

    testWidgets('falls back to the locale word for a sidebar', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(tester, beside(const NebaSidebar(child: Text('Nav'))));

      expect(tester.getSemantics(find.byType(NebaSidebar)).getSemanticsData().label, 'Sidebar');

      await pump(tester, beside(const NebaSidebar(locale: Locale('ko'), child: Text('Nav'))));

      expect(
        tester.getSemantics(find.byType(NebaSidebar)).getSemanticsData().label,
        ko.messages['layout']!['sidebar'],
      );
      semantics.dispose();
    });

    testWidgets('is no complementary region inside another landmark', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaPageLayout(
          child: SizedBox(height: 300, child: beside(const NebaSidebar(child: Text('Nav')))),
        ),
      );

      expect(
        tester.getSemantics(find.byType(NebaSidebar)).getSemanticsData().role,
        SemanticsRole.none,
      );
      semantics.dispose();
    });

    testWidgets('draws whatever it was handed, inside its gutter', (WidgetTester tester) async {
      await pump(tester, beside(const NebaSidebar(child: Text('Nav'))));

      expect(tester.getRect(find.text('Nav')).topLeft, const Offset(16, 16));
    });

    testWidgets('draws the hairline down its inner edge', (WidgetTester tester) async {
      await pump(tester, beside(const NebaSidebar(child: Text('Nav'))));

      final Iterable<BoxBorder> borders = tester
          .widgetList<Container>(
            find.descendant(of: find.byType(NebaSidebar), matching: find.byType(Container)),
          )
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .map((BoxDecoration decoration) => decoration.border)
          .whereType<BorderDirectional>();

      expect(borders.single, isA<BorderDirectional>());
      expect((borders.single as BorderDirectional).end.width, 1);
      expect((borders.single as BorderDirectional).start, BorderSide.none);
    });
  });

  group('width', () {
    testWidgets('takes the width its size implies', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, beside(NebaSidebar(size: size, child: const Text('Nav'))));

        expect(columnOf(tester).width, NebaSidebar.widths[size], reason: size.name);
      }
    });

    testWidgets('takes a number as logical pixels', (WidgetTester tester) async {
      await pump(tester, beside(const NebaSidebar(width: 200, child: Text('Nav'))));

      expect(columnOf(tester).width, 200);
      expect(tester.getRect(find.text('Page')).left, 200);
    });
  });

  group('resizable', () {
    testWidgets('draws no handle unless it is asked for one', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, beside(const NebaSidebar(child: Text('Nav'))));

      expect(handle(), findsNothing);
      semantics.dispose();
    });

    testWidgets('names a handle on the inner edge that says the width', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        beside(const NebaSidebar(resizable: true, width: 200, child: Text('Nav'))),
      );

      final Rect edge = tester.getRect(handle());

      expect(edge.right, 200);
      expect(edge.width, NebaSidebar.handleWidth);
      expect(tester.getSemantics(handle()).getSemanticsData().value, '200');
      semantics.dispose();
    });

    testWidgets('widens the column on an arrow key, and says so', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<double> moving = <double>[];
      final List<double> settled = <double>[];

      await pump(
        tester,
        beside(
          NebaSidebar(
            resizable: true,
            width: 200,
            onResize: moving.add,
            onResizeEnd: settled.add,
            child: const Text('Nav'),
          ),
        ),
      );

      tester
          .widget<Focus>(
            find
                .descendant(of: find.byType(FocusableActionDetector), matching: find.byType(Focus))
                .first,
          )
          .focusNode!
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(columnOf(tester).width, 216);
      expect(moving, <double>[216]);
      expect(settled, <double>[216]);
      expect(tester.getSemantics(handle()).getSemanticsData().value, '216');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(columnOf(tester).width, 200);
      semantics.dispose();
    });

    testWidgets('follows a drag, and refuses to go past its bounds', (WidgetTester tester) async {
      final List<double> settled = <double>[];

      await pump(
        tester,
        beside(
          NebaSidebar(
            resizable: true,
            width: 200,
            minWidth: 150,
            maxWidth: 260,
            onResizeEnd: settled.add,
            child: const Text('Nav'),
          ),
        ),
      );

      final Offset edge = Offset(200 - NebaSidebar.handleWidth / 2, 300);
      final TestGesture gesture = await tester.startGesture(edge);

      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();

      expect(columnOf(tester).width, 240);

      await gesture.moveBy(const Offset(200, 0));
      await tester.pump();

      expect(columnOf(tester).width, 260);

      await gesture.moveBy(const Offset(-400, 0));
      await gesture.up();
      await tester.pump();

      expect(columnOf(tester).width, 150);
      expect(settled, <double>[150]);
    });

    testWidgets('widens towards the page under a right-to-left direction', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        beside(const NebaSidebar(resizable: true, width: 200, child: Text('Nav'))),
        textDirection: TextDirection.rtl,
      );

      final TestGesture gesture = await tester.startGesture(
        Offset(1024 - 200 + NebaSidebar.handleWidth / 2, 300),
      );

      await gesture.moveBy(const Offset(-40, 0));
      await gesture.up();
      await tester.pump();

      expect(columnOf(tester).width, 240);
    });
  });

  group('collapsing', () {
    testWidgets('stays a column at every width outside a layout', (WidgetTester tester) async {
      await pump(tester, beside(const NebaSidebar(child: Text('Nav'))), size: const Size(360, 600));

      expect(find.text('Nav'), findsOneWidget);
    });

    testWidgets('becomes a closed drawer once the window is too narrow for a column', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        beside(const NebaSidebar(collapseBelow: NebaBreakpoint.md, child: Text('Nav'))),
        size: const Size(600, 600),
      );

      expect(find.text('Nav'), findsNothing);
      expect(find.byType(NebaDrawer), findsOneWidget);
      expect(tester.getRect(find.text('Page')).left, 0);
    });

    testWidgets('opens as a drawer with its content in one place, and reports it', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        beside(
          NebaSidebar(
            collapseBelow: NebaBreakpoint.md,
            open: true,
            onOpenChange: changes.add,
            title: const Text('Sections'),
            child: const Text('Nav'),
          ),
        ),
        size: const Size(600, 600),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nav'), findsOneWidget);
      expect(find.text('Sections'), findsOneWidget);
      // The drawer's own width, not the column's.
      expect(
        tester.getRect(find.ancestor(of: find.text('Nav'), matching: find.byType(NebaSheet))).width,
        NebaDrawer.extents[NebaSize.md],
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(changes, <bool>[false]);
    });

    testWidgets('closes the drawer as the column returns', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaPageLayout(
          onSidebarOpenChange: changes.add,
          defaultSidebarOpen: true,
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: const Text('Page'),
        ),
        size: const Size(600, 600),
      );
      await tester.pumpAndSettle();

      await pump(
        tester,
        NebaPageLayout(
          onSidebarOpenChange: changes.add,
          defaultSidebarOpen: true,
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: const Text('Page'),
        ),
      );
      await tester.pumpAndSettle();

      expect(changes, <bool>[false]);
      expect(find.text('Nav'), findsOneWidget);
    });

    testWidgets('keeps a closed drawer built with keepMounted, and the column as it was', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        beside(
          const NebaSidebar(
            collapseBelow: NebaBreakpoint.md,
            keepMounted: true,
            child: Text('Nav'),
          ),
        ),
        size: const Size(600, 600),
      );

      expect(find.text('Nav'), findsNothing);
      expect(find.text('Nav', skipOffstage: false), findsOneWidget);
    });
  });

  group('inside a layout', () {
    testWidgets('stretches a resizable column that does not hold its place to the page', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPageLayout(
          sidebar: NebaSidebar(sticky: false, resizable: true, child: Text('Nav')),
          child: SizedBox(height: 1200),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(columnOf(tester).height, 1200);
    });

    testWidgets('takes the side of the slot it was handed to', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPageLayout(
          endSidebar: NebaSidebar(child: Text('Contents')),
          child: Text('Page'),
        ),
      );

      expect(columnOf(tester).right, 1024);
    });

    testWidgets('inherits the layout language', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        const NebaPageLayout(
          locale: Locale('ko'),
          sidebar: NebaSidebar(child: Text('Nav')),
          child: Text('Page'),
        ),
      );

      expect(
        tester.getSemantics(find.byType(NebaSidebar)).getSemanticsData().label,
        ko.messages['layout']!['sidebar'],
      );
      semantics.dispose();
    });
  });

  group('NebaSidebarTrigger', () {
    testWidgets('builds nothing outside a layout, having nothing to open', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSidebarTrigger(), size: const Size(600, 600));

      expect(find.byType(NebaIconButton), findsNothing);
    });

    testWidgets('is there exactly while the sidebar is not', (WidgetTester tester) async {
      Widget layout() {
        return const NebaPageLayout(
          header: NebaHeader(brand: <Widget>[NebaSidebarTrigger()]),
          sidebar: NebaSidebar(child: Text('Nav')),
          child: Text('Page'),
        );
      }

      await pump(tester, layout());

      expect(find.byType(NebaIconButton), findsNothing);

      await pump(tester, layout(), size: const Size(600, 600));

      expect(find.byType(NebaIconButton), findsOneWidget);
    });

    testWidgets('says whether the sidebar it opens is open, and what a press does', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaPageLayout(
          header: NebaHeader(brand: <Widget>[NebaSidebarTrigger()]),
          sidebar: NebaSidebar(child: Text('Nav')),
          child: Text('Page'),
        ),
        size: const Size(600, 600),
      );

      expect(
        tester.getSemantics(find.byType(NebaSidebarTrigger)),
        matchesSemantics(
          label: 'Open sidebar',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasExpandedState: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.byType(NebaSidebarTrigger));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(NebaSidebarTrigger)).getSemanticsData().label,
        'Close sidebar',
      );
      semantics.dispose();
    });
  });
}
