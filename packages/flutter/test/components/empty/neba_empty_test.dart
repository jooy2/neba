// NebaEmpty: the suite the React package runs on Empty, asked the way
// Flutter asks it — the words it says, the glyph, where the actions land, the
// padding and the sheet, and the live region — rather than the elements and
// classes it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget empty) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 480, child: empty),
        ),
      ),
    );
  }

  TextStyle styleOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!;
  }

  Finder glyph() => find.descendant(of: find.byType(NebaEmpty), matching: find.byType(NebaGlyph));

  group('rendering', () {
    testWidgets('says there is nothing here with no arguments at all', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty());

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('puts the detail under the headline', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(child: Text('Start from scratch.')));

      expect(
        tester.getRect(find.text('Start from scratch.')).top,
        greaterThan(tester.getRect(find.text('Nothing here')).bottom - 1),
      );
    });

    testWidgets('reflects a changed detail on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(child: Text('One')));
      await pump(tester, const NebaEmpty(child: Text('Two')));

      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('takes the width it is given and centres what it holds', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaEmpty(title: Text('No invoices')));

      final Rect empty = tester.getRect(find.byType(NebaEmpty));

      expect(empty.width, 480);
      expect(tester.getCenter(find.text('No invoices')).dx, closeTo(empty.center.dx, 0.5));
      expect(tester.getCenter(glyph()).dx, closeTo(empty.center.dx, 0.5));
    });

    testWidgets('centres what it holds in a height it is stretched to', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 480,
              height: 400,
              child: NebaEmpty(variant: NebaVariant.outline),
            ),
          ),
        ),
      );

      final Rect empty = tester.getRect(find.byType(NebaEmpty));
      final double above = tester.getRect(glyph()).top - empty.top;
      final double below = empty.bottom - tester.getRect(find.text('Nothing here')).bottom;

      expect(empty.height, 400);
      expect(above, closeTo(below, 1));
    });

    testWidgets('keeps a long sentence to a readable measure', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 2000, child: NebaEmpty(child: Text('word ' * 200))),
          ),
          width: 2000,
        ),
      );

      expect(tester.getSize(find.text('word ' * 200)).width, lessThan(1900));
    });
  });

  group('title', () {
    testWidgets('takes a headline of its own', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(title: Text('No projects yet')));

      expect(find.text('No projects yet'), findsOneWidget);
      expect(find.text('Nothing here'), findsNothing);
    });

    testWidgets('drops the headline when asked', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(showTitle: false, child: Text('Nothing matched.')));

      expect(find.text('Nothing here'), findsNothing);
      expect(find.text('Nothing matched.'), findsOneWidget);
    });

    testWidgets('sets the headline in the sheet title type', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(size: NebaSize.lg));

      final TextStyle style = styleOf(tester, 'Nothing here');

      expect(style.fontSize, NebaScale.sheetTitleText[NebaSize.lg]);
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('mutes the detail under a headline and not without one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaEmpty(child: Text('Detail')));
      expect(styleOf(tester, 'Detail').color, tokens.mutedFg);

      await pump(tester, const NebaEmpty(showTitle: false, child: Text('Detail')));
      expect(styleOf(tester, 'Detail').color, tokens.fg);
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets('writes the default headline in the language it was given', (
      WidgetTester tester,
    ) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaEmpty(locale: Locale('ko')));

      expect(find.text(ko.messages['empty']!['title']!), findsOneWidget);
    });

    testWidgets('resolves a regional locale through its language', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaEmpty(locale: Locale('ko', 'KR')));

      expect(find.text(ko.messages['empty']!['title']!), findsOneWidget);
    });

    testWidgets('falls back to English for a language it does not have', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaEmpty(locale: Locale('xx')));

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('is ignored once a title is given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaEmpty(locale: Locale('ko'), title: Text('No invoices')));

      expect(find.text('No invoices'), findsOneWidget);
      expect(find.text(ko.messages['empty']!['title']!), findsNothing);
    });
  });

  group('icon', () {
    testWidgets('draws the empty tray by default, on the size ladder', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty());

      expect(glyph(), findsOneWidget);
      expect(tester.getSize(glyph()), Size.square(NebaEmpty.glyphScale[NebaSize.md]! * 1.2));
    });

    testWidgets('drops the glyph when asked', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(showIcon: false));

      expect(glyph(), findsNothing);
    });

    testWidgets('takes a glyph of its own, handed the size and the muted ink', (
      WidgetTester tester,
    ) async {
      late IconThemeData seen;

      await pump(
        tester,
        NebaEmpty(
          icon: Builder(
            builder: (BuildContext context) {
              seen = IconTheme.of(context);
              return const SizedBox(key: Key('own'));
            },
          ),
        ),
      );

      expect(glyph(), findsNothing);
      expect(find.byKey(const Key('own')), findsOneWidget);
      expect(seen.size, NebaEmpty.glyphScale[NebaSize.md]! * 1.2);
      expect(seen.color, tokens.mutedFg);
    });

    testWidgets('keeps the default glyph out of the semantics tree', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaEmpty());

      expect(
        tester.getSemantics(find.byType(NebaLiveRegion)),
        matchesSemantics(
          label: 'Nothing here',
          textDirection: TextDirection.ltr,
          isLiveRegion: true,
        ),
      );

      handle.dispose();
    });
  });

  group('actions', () {
    testWidgets('renders what it is given, under the text', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(actions: <Widget>[Text('Clear filters')]));

      expect(
        tester.getRect(find.text('Clear filters')).top,
        greaterThan(tester.getRect(find.text('Nothing here')).bottom),
      );
    });

    testWidgets('builds no row when given nothing', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty());

      expect(
        find.descendant(of: find.byType(NebaEmpty), matching: find.byType(Wrap)),
        findsNothing,
      );
    });

    testWidgets('holds more than one in a row 8 pixels apart', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaEmpty(
          actions: <Widget>[
            SizedBox(key: Key('a'), width: 40, height: 20),
            SizedBox(key: Key('b'), width: 40, height: 20),
          ],
        ),
      );

      final Rect a = tester.getRect(find.byKey(const Key('a')));
      final Rect b = tester.getRect(find.byKey(const Key('b')));

      expect(a.top, b.top);
      expect(b.left - a.right, 8);
      expect((a.left + b.right) / 2, closeTo(tester.getCenter(find.byType(NebaEmpty)).dx, 0.5));
    });
  });

  group('variant', () {
    testWidgets('draws no surface by default', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty());

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('draws an undyed sheet with a hairline in its family for outline', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaEmpty(variant: NebaVariant.outline, color: NebaColor.danger));

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet.fill, tokens.panel);
      expect(sheet.edge, tokens.roles(NebaColor.danger).line);
    });

    testWidgets('draws the brighter sheet for solid', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(variant: NebaVariant.solid));

      expect(tester.widget<NebaSheet>(find.byType(NebaSheet)).fill, tokens.panelHover);
    });

    testWidgets('puts its hairline in secondary by default', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(variant: NebaVariant.outline));

      expect(
        tester.widget<NebaSheet>(find.byType(NebaSheet)).edge,
        tokens.roles(NebaColor.secondary).line,
      );
    });
  });

  group('size and density', () {
    double top(WidgetTester tester) {
      return tester.getRect(glyph()).top - tester.getRect(find.byType(NebaEmpty)).top;
    }

    testWidgets('pads on its own vertical ladder', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty());
      expect(top(tester), NebaEmpty.paddingY[NebaDensity.standard]![NebaSize.md]);

      await pump(tester, const NebaEmpty(size: NebaSize.xl));
      expect(top(tester), NebaEmpty.paddingY[NebaDensity.standard]![NebaSize.xl]);
    });

    testWidgets('takes the compact track when asked', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(density: NebaDensity.compact));

      expect(top(tester), NebaEmpty.paddingY[NebaDensity.compact]![NebaSize.md]);
    });

    testWidgets('takes its size from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.sm),
          child: NebaEmpty(),
        ),
      );

      expect(top(tester), NebaEmpty.paddingY[NebaDensity.standard]![NebaSize.sm]);
    });
  });

  group('live region', () {
    testWidgets('is a status region by default', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty());

      expect(tester.widget<NebaLiveRegion>(find.byType(NebaLiveRegion)).role, SemanticsRole.status);
    });

    testWidgets('gives up the live region when told to', (WidgetTester tester) async {
      await pump(tester, const NebaEmpty(role: SemanticsRole.none));

      expect(tester.widget<NebaLiveRegion>(find.byType(NebaLiveRegion)).role, SemanticsRole.none);
    });
  });
}
