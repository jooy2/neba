// NebaHeader: the suite the React package runs on Header, asked the way
// Flutter asks it — where the slots land, the sheet and the hairline it draws,
// the insets it keeps clear of and the semantics it builds — rather than the
// landmark, the classes and the position it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget header, {EdgeInsets padding = EdgeInsets.zero}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: const Size(800, 600), padding: padding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(alignment: Alignment.topCenter, child: header),
        ),
      ),
    );
  }

  Rect rectOf(WidgetTester tester, String text) => tester.getRect(find.text(text));

  Rect barOf(WidgetTester tester) => tester.getRect(find.byType(NebaHeader));

  group('rendering', () {
    testWidgets('draws all three slots, in order along the bar', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeader(
          brand: <Widget>[Text('Logo'), Text('Neba')],
          actions: <Widget>[Text('Sign in')],
          children: <Widget>[Text('Docs')],
        ),
      );

      expect(rectOf(tester, 'Logo').right, lessThan(rectOf(tester, 'Neba').left));
      expect(rectOf(tester, 'Neba').right, lessThan(rectOf(tester, 'Docs').left));
      expect(rectOf(tester, 'Docs').right, lessThan(rectOf(tester, 'Sign in').left));
      // The gap inside a slot is about half the gap between two.
      expect(rectOf(tester, 'Neba').left - rectOf(tester, 'Logo').right, 12);
      expect(rectOf(tester, 'Docs').left - rectOf(tester, 'Neba').right, 24);
    });

    testWidgets('builds nothing for a slot it was given nothing for', (WidgetTester tester) async {
      await pump(tester, const NebaHeader(brand: <Widget>[Text('Neba')]));

      expect(find.byType(Row), findsNWidgets(2));
    });

    testWidgets('leaves a hidden NebaShow out of its slot, gap and all', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeader(
          brand: <Widget>[
            NebaShow(below: NebaBreakpoint.sm, child: Text('Menu')),
            Text('Neba'),
          ],
          actions: <Widget>[
            Text('Sign in'),
            NebaShow(below: NebaBreakpoint.sm, child: Text('More')),
          ],
          children: <Widget>[
            NebaShow(below: NebaBreakpoint.sm, child: Text('Home')),
            Text('Docs'),
          ],
        ),
      );

      // At 800 pixels each hidden child is gone, and so is the gap beside it:
      // the name starts at the gutter and the sign-in ends at it.
      expect(find.text('Menu'), findsNothing);
      expect(rectOf(tester, 'Neba').left, 16);
      expect(rectOf(tester, 'Docs').left - rectOf(tester, 'Neba').right, 24);
      expect(rectOf(tester, 'Sign in').right, 800 - 16);
    });

    testWidgets('leaves a sidebar trigger with no drawer to open out of its slot', (
      WidgetTester tester,
    ) async {
      Future<void> pumpAt(double width) {
        tester.view
          ..physicalSize = Size(width, 600)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        return tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: Size(width, 600)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              // The drawer the sidebar becomes opens into an overlay.
              child: Overlay.wrap(
                child: const NebaPageLayout(
                  header: NebaHeader(brand: <Widget>[NebaSidebarTrigger(), Text('Neba')]),
                  sidebar: NebaSidebar(child: Text('Nav')),
                  child: Text('Page'),
                ),
              ),
            ),
          ),
        );
      }

      // A column: the trigger builds nothing and takes no gap ahead of the
      // name, which starts at the gutter.
      await pumpAt(1024);

      expect(find.byType(NebaIconButton), findsNothing);
      expect(rectOf(tester, 'Neba').left, 16);

      // A drawer: the trigger is there, a slot's gap ahead of the name.
      await pumpAt(600);

      final Rect trigger = tester.getRect(find.byType(NebaIconButton));

      expect(trigger.left, 16);
      expect(rectOf(tester, 'Neba').left - trigger.right, 12);
    });

    testWidgets('spans the width it is given, on its height floor', (WidgetTester tester) async {
      await pump(tester, const NebaHeader(brand: <Widget>[Text('Neba')]));

      // The floor and the hairline under it, which takes its pixel.
      expect(barOf(tester).width, 800);
      expect(barOf(tester).height, 56 + 1);
    });

    testWidgets('stands on the floor of each size', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaHeader(size: size, divider: false));

        expect(barOf(tester).height, NebaHeader.heights[size], reason: size.name);
      }
    });

    testWidgets('is a group a screen reader reads in order, and no region on its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaHeader(label: 'Site', brand: <Widget>[Text('Neba')]));

      expect(
        tester.getSemantics(find.byType(NebaHeader)).getSemanticsData().role,
        SemanticsRole.none,
      );
      semantics.dispose();
    });

    testWidgets('is a named region as the header of a page', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          Overlay.wrap(
            child: const NebaPageLayout(
              height: NebaPageLayoutHeight.auto,
              header: NebaHeader(label: 'Site', brand: <Widget>[Text('Neba')]),
              child: Text('Page'),
            ),
          ),
        ),
      );

      final SemanticsData data = tester.getSemantics(find.byType(NebaHeader)).getSemanticsData();

      expect(data.role, SemanticsRole.region);
      expect(data.label, 'Site');
      semantics.dispose();
    });
  });

  group('align', () {
    testWidgets('packs the middle against the brand by default', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeader(
          brand: <Widget>[Text('Neba')],
          actions: <Widget>[Text('Sign in')],
          children: <Widget>[Text('Docs')],
        ),
      );

      expect(rectOf(tester, 'Docs').left - rectOf(tester, 'Neba').right, 24);
      // The actions are pushed to the end by the middle taking what is left.
      expect(barOf(tester).right - rectOf(tester, 'Sign in').right, 16);
    });

    testWidgets('gives both ends an equal share so the middle lands on the midline', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeader(
          align: NebaAlign.center,
          brand: <Widget>[Text('A much longer brand')],
          actions: <Widget>[Text('Go')],
          children: <Widget>[Text('Docs')],
        ),
      );

      expect(rectOf(tester, 'Docs').center.dx, barOf(tester).center.dx);
    });

    testWidgets('keeps the middle on the midline when an end is empty', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeader(
          align: NebaAlign.center,
          brand: <Widget>[Text('Neba')],
          children: <Widget>[Text('Docs')],
        ),
      );

      expect(rectOf(tester, 'Docs').center.dx, barOf(tester).center.dx);
    });

    testWidgets('packs the middle against the actions at the end', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeader(
          align: NebaAlign.end,
          brand: <Widget>[Text('Neba')],
          actions: <Widget>[Text('Sign in')],
          children: <Widget>[Text('Docs')],
        ),
      );

      expect(rectOf(tester, 'Sign in').left - rectOf(tester, 'Docs').right, 24);
    });
  });

  group('appearance', () {
    /// The borders drawn inside the bar: the hairline, if there is one.
    List<Border> bordersOf(WidgetTester tester) {
      return tester
          .widgetList<Container>(
            find.descendant(of: find.byType(NebaHeader), matching: find.byType(Container)),
          )
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .map((BoxDecoration decoration) => decoration.border)
          .whereType<Border>()
          .toList();
    }

    testWidgets('draws a hairline along the bottom edge in the colour family', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeader(color: NebaColor.success));

      final List<Border> borders = bordersOf(tester);

      expect(borders, hasLength(1));
      expect(borders.single.bottom.color, tokens.roles(NebaColor.success).line);
      expect(borders.single.top, BorderSide.none);
    });

    testWidgets('drops the hairline when it is turned off', (WidgetTester tester) async {
      await pump(tester, const NebaHeader(divider: false));

      expect(bordersOf(tester), isEmpty);
    });

    testWidgets('is an undyed sheet of each weight', (WidgetTester tester) async {
      await pump(tester, const NebaHeader(color: NebaColor.danger));

      NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet.fill, tokens.panel);
      expect(sheet.plate, NebaPlate.glass);
      expect(sheet.elevation, 0);

      await pump(tester, const NebaHeader(variant: NebaVariant.solid, elevation: 2));
      sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet.fill, tokens.panelPress);
      expect(sheet.plate, NebaPlate.solid);
      expect(sheet.elevation, 2);

      await pump(tester, const NebaHeader(variant: NebaVariant.text));

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('holds the row to a measure without narrowing the sheet', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeader(
          maxWidth: NebaMeasure.size(NebaSize.xs),
          brand: <Widget>[Text('Neba')],
          actions: <Widget>[Text('Sign in')],
          children: <Widget>[Text('Docs')],
        ),
      );

      expect(barOf(tester).width, 800);
      // A 480-pixel row centred in 800, with its 16-pixel gutter.
      expect(rectOf(tester, 'Neba').left, 160 + 16);
      expect(rectOf(tester, 'Sign in').right, 800 - 160 - 16);
    });

    testWidgets('drops the gutter when it is not padded', (WidgetTester tester) async {
      await pump(tester, const NebaHeader(padded: false, brand: <Widget>[Text('Neba')]));

      expect(rectOf(tester, 'Neba').left, 0);
    });
  });

  group('safeArea', () {
    testWidgets('keeps the slots clear of the top and the sides, with the sheet under them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeader(brand: <Widget>[Text('Neba')], actions: <Widget>[Text('Sign in')]),
        padding: const EdgeInsets.fromLTRB(11, 47, 13, 34),
      );

      expect(barOf(tester).top, 0);
      expect(barOf(tester).height, 47 + 56 + 1);
      expect(rectOf(tester, 'Neba').left, 11 + 16);
    });

    testWidgets('takes none when it is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeader(safeArea: false, brand: <Widget>[Text('Neba')]),
        padding: const EdgeInsets.fromLTRB(11, 47, 13, 34),
      );

      expect(barOf(tester).height, 56 + 1);
      expect(rectOf(tester, 'Neba').left, 16);
    });
  });
}
