// NebaFooter: the suite the React package runs on Footer, asked the way
// Flutter asks it — the sheet and the hairline it draws, where its content
// lands, the insets it keeps clear of and the semantics it builds — rather
// than the landmark, the classes and the position it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget footer, {EdgeInsets padding = EdgeInsets.zero}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: const Size(800, 600), padding: padding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(alignment: Alignment.bottomCenter, child: footer),
        ),
      ),
    );
  }

  Rect barOf(WidgetTester tester) => tester.getRect(find.byType(NebaFooter));

  group('rendering', () {
    testWidgets('draws whatever it was handed, with no slots of its own', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaFooter(
          child: Row(children: <Widget>[Text('© 2026 Neba'), Spacer(), Text('Privacy')]),
        ),
      );

      expect(tester.getRect(find.text('© 2026 Neba')).left, 16);
      expect(tester.getRect(find.text('Privacy')).right, 800 - 16);
      // Under the hairline and the gutter above.
      expect(tester.getRect(find.text('Privacy')).top, barOf(tester).top + 1 + 16);
    });

    testWidgets('is the page\'s own information as the footer of a page', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          Overlay.wrap(
            child: const NebaPageLayout(
              height: NebaPageLayoutHeight.auto,
              footer: NebaFooter(label: 'Site', child: Text('Fine print')),
              child: Text('Page'),
            ),
          ),
        ),
      );

      final SemanticsData data = tester.getSemantics(find.byType(NebaFooter)).getSemanticsData();

      expect(data.role, SemanticsRole.contentInfo);
      expect(data.label, 'Site');
      semantics.dispose();
    });

    testWidgets('is no landmark anywhere else', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaFooter(label: 'Site', child: Text('Fine print')));

      expect(
        tester.getSemantics(find.byType(NebaFooter)).getSemanticsData().role,
        SemanticsRole.none,
      );
      semantics.dispose();
    });
  });

  group('appearance', () {
    testWidgets('draws a hairline along the top edge in the colour family', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFooter(color: NebaColor.info, child: Text('Fine print')));

      final Border border = tester
          .widgetList<Container>(
            find.descendant(of: find.byType(NebaFooter), matching: find.byType(Container)),
          )
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .map((BoxDecoration decoration) => decoration.border)
          .whereType<Border>()
          .single;

      expect(border.top.color, tokens.roles(NebaColor.info).line);
      expect(border.bottom, BorderSide.none);
    });

    testWidgets('is an undyed sheet', (WidgetTester tester) async {
      await pump(tester, const NebaFooter(color: NebaColor.danger, child: Text('Fine print')));

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet.fill, tokens.panel);
      expect(sheet.edge, isNull);
    });

    testWidgets('holds the content to a measure without narrowing the sheet', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaFooter(maxWidth: NebaMeasure.width(400), child: Text('Fine print')),
      );

      expect(barOf(tester).width, 800);
      expect(tester.getRect(find.text('Fine print')).left, 200 + 16);
    });

    testWidgets('drops the gutter when it is not padded', (WidgetTester tester) async {
      await pump(tester, const NebaFooter(padded: false, child: Text('Fine print')));

      expect(tester.getRect(find.text('Fine print')).topLeft, Offset(0, barOf(tester).top + 1));
    });
  });

  group('safeArea', () {
    testWidgets('keeps the content clear of the bottom and the sides', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFooter(child: Text('Fine print')),
        padding: const EdgeInsets.fromLTRB(11, 47, 13, 34),
      );

      expect(barOf(tester).bottom, 600);
      expect(tester.getRect(find.text('Fine print')).left, 11 + 16);
      expect(600 - tester.getRect(find.text('Fine print')).bottom, greaterThanOrEqualTo(34 + 16));
    });

    testWidgets('takes none when it is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFooter(safeArea: false, child: Text('Fine print')),
        padding: const EdgeInsets.fromLTRB(11, 47, 13, 34),
      );

      expect(tester.getRect(find.text('Fine print')).left, 16);
    });
  });
}
