// NebaPageLayout: the suite the React package runs on PageLayout, asked the
// way Flutter asks it — where each region is laid out and where it is held
// while the page scrolls, the regions it announces and the insets it hands
// out — rather than the landmarks, the custom properties and the CSS it
// writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';

void main() {
  /// [layout] as a whole window of [size], with [padding] as its insets.
  Future<void> pumpWindow(
    WidgetTester tester,
    Widget layout, {
    Size size = const Size(1024, 600),
    EdgeInsets padding = EdgeInsets.zero,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // The keys an app binds, so Tab moves the focus as it does in one.
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size, padding: padding),
        child: Directionality(
          textDirection: textDirection,
          child: Shortcuts(
            shortcuts: WidgetsApp.defaultShortcuts,
            child: Actions(
              actions: WidgetsApp.defaultActions,
              child: FocusScope(autofocus: true, child: Overlay.wrap(child: layout)),
            ),
          ),
        ),
      ),
    );
  }

  /// A page [height] pixels tall, with a marker at its top and its bottom.
  Widget page(double height) {
    return SizedBox(
      key: const Key('page'),
      height: height,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text('Top'), Text('Bottom')],
      ),
    );
  }

  Rect rectOf(WidgetTester tester, Type type) => tester.getRect(find.byType(type));

  /// The roles of the semantics nodes around what [finder] finds, nearest
  /// first.
  List<SemanticsRole> rolesAround(WidgetTester tester, Finder finder) {
    final List<SemanticsRole> roles = <SemanticsRole>[];
    SemanticsNode? node = tester.getSemantics(finder);

    while (node != null) {
      roles.add(node.getSemanticsData().role);
      node = node.parent;
    }

    return roles;
  }

  group('regions', () {
    testWidgets('puts the page in a main region and every slot around it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          sidebar: const NebaSidebar(label: 'Sections', child: Text('Nav')),
          endSidebar: const NebaSidebar(label: 'On this page', child: Text('Contents')),
          footer: const NebaFooter(child: Text('Fine print')),
          child: page(200),
        ),
      );

      expect(rolesAround(tester, find.text('Top')).contains(SemanticsRole.main), isTrue);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Nav'), findsOneWidget);
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('Fine print'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('builds nothing for a slot it was given nothing for', (WidgetTester tester) async {
      await pumpWindow(tester, NebaPageLayout(child: page(100)));

      expect(find.byType(NebaHeader), findsNothing);
      expect(find.byType(NebaSidebar), findsNothing);
      expect(find.byType(NebaFooter), findsNothing);
      expect(tester.getRect(find.text('Top')).top, 0);
    });

    testWidgets('makes the footer it was handed the page\'s own, and no other', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pumpWindow(
        tester,
        NebaPageLayout(
          footer: const NebaFooter(child: Text('Site')),
          child: const NebaFooter(child: Text('Article')),
        ),
      );

      expect(
        tester
            .getSemantics(find.ancestor(of: find.text('Site'), matching: find.byType(NebaFooter)))
            .getSemanticsData()
            .role,
        SemanticsRole.contentInfo,
      );
      expect(
        tester
            .getSemantics(
              find.ancestor(of: find.text('Article'), matching: find.byType(NebaFooter)),
            )
            .getSemanticsData()
            .role,
        SemanticsRole.none,
      );
      semantics.dispose();
    });

    testWidgets('puts the page in a plain region with no skip link when main is off', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pumpWindow(tester, NebaPageLayout(main: false, child: page(100)));

      expect(rolesAround(tester, find.text('Top')).contains(SemanticsRole.main), isFalse);
      expect(find.text('Skip to content'), findsNothing);
      semantics.dispose();
    });

    testWidgets('is no second main region inside another layout\'s content', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pumpWindow(
        tester,
        NebaPageLayout(
          child: NebaPageLayout(height: const NebaPageLayoutHeight.pixels(300), child: page(100)),
        ),
      );

      final Iterable<SemanticsRole> mains = rolesAround(
        tester,
        find.text('Top'),
      ).where((SemanticsRole role) => role == SemanticsRole.main);

      expect(mains, hasLength(1));
      expect(find.text('Skip to content', skipOffstage: false), findsOneWidget);
      semantics.dispose();
    });
  });

  group('focus order', () {
    testWidgets('goes through the header, the sidebars and the content in reading order', (
      WidgetTester tester,
    ) async {
      Widget button(String label) => NebaButton(onPressed: () {}, child: Text(label));

      await pumpWindow(
        tester,
        NebaPageLayout(
          skipLink: false,
          header: NebaHeader(actions: <Widget>[button('Account')]),
          sidebar: NebaSidebar(child: button('Nav')),
          endSidebar: NebaSidebar(child: button('Contents')),
          footer: NebaFooter(child: button('Privacy')),
          child: Align(alignment: Alignment.topLeft, child: button('Read')),
        ),
      );

      final List<String> order = <String>[];

      for (int i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        final Element focused = FocusManager.instance.primaryFocus!.context! as Element;
        final Text label = tester.widget<Text>(
          find.descendant(of: find.byWidget(focused.widget), matching: find.byType(Text)).first,
        );

        order.add(label.data!);
      }

      expect(order, <String>['Account', 'Nav', 'Read', 'Contents', 'Privacy']);
    });
  });

  group('the skip link', () {
    testWidgets('is first in the focus order, and drawn only while it has the focus', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: NebaHeader(
            brand: <Widget>[NebaButton(onPressed: () {}, child: const Text('Home'))],
          ),
          child: page(100),
        ),
      );

      final Finder opacity = find.ancestor(
        of: find.text('Skip to content'),
        matching: find.byType(Opacity),
      );

      expect(tester.widget<Opacity>(opacity.first).opacity, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump();

      expect(tester.widget<Opacity>(opacity.first).opacity, 1);
      expect(tester.getRect(find.text('Skip to content')).left, greaterThan(12));
      expect(tester.getRect(find.text('Skip to content')).top, greaterThan(12));
    });

    testWidgets('hands the focus to the main region it jumps to', (WidgetTester tester) async {
      await pumpWindow(tester, NebaPageLayout(child: page(100)));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(FocusManager.instance.primaryFocus?.debugLabel, 'NebaPageLayout main');
    });

    testWidgets('says it in the layout language, or in a word of its own', (
      WidgetTester tester,
    ) async {
      registerNebaMessages('ko', ko);

      await pumpWindow(tester, NebaPageLayout(locale: const Locale('ko'), child: page(100)));

      expect(find.text(ko.messages['layout']!['skipToContent']!), findsOneWidget);

      await pumpWindow(tester, NebaPageLayout(skipLabel: 'Jump', child: page(100)));

      expect(find.text('Jump'), findsOneWidget);
    });

    testWidgets('can be turned off', (WidgetTester tester) async {
      await pumpWindow(tester, NebaPageLayout(skipLink: false, child: page(100)));

      expect(find.text('Skip to content'), findsNothing);
    });
  });

  group('headerSpan', () {
    testWidgets('puts the header above the sidebars by default', (WidgetTester tester) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(100),
        ),
      );

      final Rect header = rectOf(tester, NebaHeader);
      final Rect sidebar = rectOf(tester, NebaSidebar);

      expect(header.width, 1024);
      expect(sidebar.top, header.bottom);
      expect(tester.getRect(find.byKey(const Key('page'))).left, sidebar.right);
    });

    testWidgets('puts the header beside the sidebars when it spans the content', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          headerSpan: NebaPageLayoutSpan.content,
          footerSpan: NebaPageLayoutSpan.content,
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          footer: const NebaFooter(child: Text('Fine print')),
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(100),
        ),
      );

      final Rect header = rectOf(tester, NebaHeader);
      final Rect sidebar = rectOf(tester, NebaSidebar);
      final Rect footer = rectOf(tester, NebaFooter);

      expect(sidebar.top, 0);
      expect(sidebar.height, 600);
      expect(header.left, sidebar.right);
      expect(header.right, 1024);
      expect(footer.left, sidebar.right);
      expect(footer.bottom, 600);
    });
  });

  group('scroll', () {
    testWidgets('scrolls the whole page by default, holding the header and the sidebar', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          footer: const NebaFooter(child: Text('Fine print')),
          child: page(2000),
        ),
      );

      final double bar = rectOf(tester, NebaHeader).height;

      // The column is as tall as what is left of the window under the bar.
      expect(rectOf(tester, NebaSidebar).height, 600 - bar);
      expect(rectOf(tester, NebaFooter).top, greaterThanOrEqualTo(600));

      await tester.drag(find.text('Top'), const Offset(0, -500));
      await tester.pump();

      expect(rectOf(tester, NebaHeader).top, 0);
      expect(rectOf(tester, NebaSidebar).top, bar);
      expect(tester.getRect(find.text('Top')).top, lessThan(0));

      // At the end the footer has arrived and the column has given way to it.
      await tester.drag(find.text('Nav'), const Offset(0, -3000));
      await tester.pumpAndSettle();

      final Rect footer = rectOf(tester, NebaFooter);

      expect(footer.bottom, 600);
      expect(rectOf(tester, NebaSidebar).bottom, footer.top);
    });

    testWidgets('lets a static header scroll away with the page', (WidgetTester tester) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(position: NebaPosition.static, children: <Widget>[Text('Bar')]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(2000),
        ),
      );
      await tester.drag(find.text('Top'), const Offset(0, -500));
      await tester.pump();

      expect(tester.getRect(find.byType(NebaHeader, skipOffstage: false)).bottom, lessThan(0));
      // With no bar held, the column holds the whole window.
      expect(rectOf(tester, NebaSidebar).top, 0);
      expect(rectOf(tester, NebaSidebar).height, 600);
    });

    testWidgets('holds a sticky footer at the bottom while the page scrolls', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          sidebar: const NebaSidebar(child: Text('Nav')),
          footer: const NebaFooter(position: NebaPosition.sticky, child: Text('Save')),
          child: page(2000),
        ),
      );

      final Rect footer = rectOf(tester, NebaFooter);

      expect(footer.bottom, 600);
      expect(rectOf(tester, NebaSidebar).bottom, footer.top);

      await tester.drag(find.text('Top'), const Offset(0, -500));
      await tester.pump();

      expect(rectOf(tester, NebaFooter).bottom, 600);
    });

    testWidgets('lets a column that does not hold its place scroll with the page', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          sidebar: const NebaSidebar(sticky: false, child: Text('Nav')),
          child: page(2000),
        ),
      );

      expect(rectOf(tester, NebaSidebar).height, 2000);

      await tester.drag(find.text('Top'), const Offset(0, -500));
      await tester.pump();

      expect(rectOf(tester, NebaSidebar).top, -500);
    });

    testWidgets('pushes the footer of a short page to the bottom of the window', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          footer: const NebaFooter(child: Text('Fine print')),
          child: page(100),
        ),
      );

      expect(rectOf(tester, NebaFooter).bottom, 600);
    });

    testWidgets('scrolls only the content between the bars when asked to', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          scroll: NebaPageLayoutScroll.content,
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          footer: const NebaFooter(child: Text('Fine print')),
          child: page(2000),
        ),
      );

      final Rect header = rectOf(tester, NebaHeader);
      final Rect footer = rectOf(tester, NebaFooter);

      expect(footer.bottom, 600);
      expect(rectOf(tester, NebaSidebar).top, header.bottom);
      expect(rectOf(tester, NebaSidebar).bottom, footer.top);

      await tester.drag(find.text('Top'), const Offset(0, -500));
      await tester.pump();

      expect(rectOf(tester, NebaHeader), header);
      expect(rectOf(tester, NebaFooter), footer);
      expect(tester.getRect(find.text('Top')).top, lessThan(header.bottom));
    });
  });

  group('height', () {
    testWidgets('is the window by default', (WidgetTester tester) async {
      await pumpWindow(tester, NebaPageLayout(child: page(100)));

      expect(rectOf(tester, NebaPageLayout).height, 600);
    });

    testWidgets('fills its parent when it is not the page, or takes a height of its own', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 320,
            child: NebaPageLayout(height: NebaPageLayoutHeight.auto, child: page(100)),
          ),
        ),
      );

      expect(rectOf(tester, NebaPageLayout).height, 320);

      await pumpWindow(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: NebaPageLayout(height: const NebaPageLayoutHeight.pixels(240), child: page(100)),
          ),
        ),
      );

      expect(rectOf(tester, NebaPageLayout).height, 240);
    });
  });

  group('the sidebars', () {
    testWidgets('owns the open state, so a trigger anywhere can reach it', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pumpWindow(
        tester,
        NebaPageLayout(
          onSidebarOpenChange: changes.add,
          header: const NebaHeader(brand: <Widget>[NebaSidebarTrigger()]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(100),
        ),
        size: const Size(600, 600),
      );

      expect(find.text('Nav'), findsNothing);

      await tester.tap(find.byType(NebaSidebarTrigger));
      await tester.pumpAndSettle();

      expect(find.text('Nav'), findsOneWidget);
      expect(changes, <bool>[true]);
    });

    testWidgets('holds the two sidebars apart', (WidgetTester tester) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(
            brand: <Widget>[
              NebaSidebarTrigger(),
              NebaSidebarTrigger(side: NebaSidebarSide.end, label: 'Contents'),
            ],
          ),
          sidebar: const NebaSidebar(child: Text('Nav')),
          endSidebar: const NebaSidebar(child: Text('On this page')),
          child: page(100),
        ),
        size: const Size(600, 600),
      );

      await tester.tap(find.bySemanticsLabel('Contents'));
      await tester.pumpAndSettle();

      expect(find.text('On this page'), findsOneWidget);
      expect(find.text('Nav'), findsNothing);
      // The trailing one comes in from the right.
      expect(tester.getRect(find.text('On this page')).left, greaterThan(600 - 320));
    });

    testWidgets('stays shut when the caller controls it and says so', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pumpWindow(
        tester,
        NebaPageLayout(
          sidebarOpen: false,
          onSidebarOpenChange: changes.add,
          header: const NebaHeader(brand: <Widget>[NebaSidebarTrigger()]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(100),
        ),
        size: const Size(600, 600),
      );
      await tester.tap(find.byType(NebaSidebarTrigger));
      await tester.pumpAndSettle();

      expect(changes, <bool>[true]);
      expect(find.text('Nav'), findsNothing);
    });

    testWidgets('keeps them columns at every width below xs, which is none', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          collapseBelow: NebaBreakpoint.xs,
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(100),
        ),
        size: const Size(360, 600),
      );

      expect(find.text('Nav'), findsOneWidget);
    });
  });

  group('insets', () {
    const EdgeInsets screen = EdgeInsets.fromLTRB(11, 47, 13, 34);

    EdgeInsets insetsOf(WidgetTester tester, Finder finder) {
      return MediaQuery.paddingOf(tester.element(finder));
    }

    testWidgets('hands each region the insets of the edges it touches', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          sidebar: const NebaSidebar(child: Text('Nav')),
          footer: const NebaFooter(child: Text('Fine print')),
          child: page(100),
        ),
        padding: screen,
      );

      expect(insetsOf(tester, find.text('Bar')), const EdgeInsets.fromLTRB(11, 47, 13, 0));
      expect(insetsOf(tester, find.text('Nav')), const EdgeInsets.only(left: 11));
      expect(insetsOf(tester, find.text('Top')), const EdgeInsets.only(right: 13));
      expect(insetsOf(tester, find.text('Fine print')), const EdgeInsets.fromLTRB(11, 0, 13, 34));
    });

    testWidgets('keeps the bars clear of the insets they were handed', (WidgetTester tester) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          header: const NebaHeader(children: <Widget>[Text('Bar')]),
          footer: const NebaFooter(child: Text('Fine print')),
          child: page(100),
        ),
        padding: screen,
      );

      // The sheets reach the edges; what is on them moves.
      expect(rectOf(tester, NebaHeader).top, 0);
      expect(tester.getRect(find.text('Bar')).top, greaterThan(47));
      expect(rectOf(tester, NebaFooter).bottom, 600);
      expect(tester.getRect(find.text('Fine print')).bottom, lessThan(600 - 34));
    });

    testWidgets('hands the start side of a right-to-left page to the sidebar there', (
      WidgetTester tester,
    ) async {
      await pumpWindow(
        tester,
        NebaPageLayout(
          sidebar: const NebaSidebar(child: Text('Nav')),
          child: page(100),
        ),
        padding: screen,
        textDirection: TextDirection.rtl,
      );

      expect(rectOf(tester, NebaSidebar).right, 1024);
      expect(insetsOf(tester, find.text('Nav')), const EdgeInsets.fromLTRB(0, 47, 13, 34));
      expect(insetsOf(tester, find.text('Top')), const EdgeInsets.fromLTRB(11, 47, 0, 34));
    });
  });
}
