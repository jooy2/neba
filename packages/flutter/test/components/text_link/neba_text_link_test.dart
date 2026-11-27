import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/text_marks.dart';

import '../../support/host.dart';

void noop() {}

void main() {
  Future<void> pump(WidgetTester tester, Widget link) {
    return tester.pumpWidget(
      host(
        Center(
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 13, color: Color(0xFF123456)),
            child: link,
          ),
        ),
      ),
    );
  }

  NebaTokens tokensOf(WidgetTester tester) =>
      NebaTheme.of(tester.element(find.byType(NebaTextLink)));

  /// The colour the label is drawn in, with every ambient style merged in.
  Color? inkOf(WidgetTester tester) {
    return tester.widget<RichText>(find.byType(RichText)).text.style?.color;
  }

  NebaTextMarks marksOf(WidgetTester tester) =>
      tester.widget<NebaTextMarks>(find.byType(NebaTextMarks));

  group('pressing', () {
    testWidgets('runs onPressed on a tap and on Enter, and not on Space', (
      WidgetTester tester,
    ) async {
      int presses = 0;
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(
        tester,
        NebaTextLink(onPressed: () => presses++, focusNode: focus, child: const Text('Docs')),
      );

      await tester.tap(find.text('Docs'));
      expect(presses, 1);

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(presses, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(presses, 2);
    });

    testWidgets('rings for keyboard focus in the primary ring when it has no colour', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);

      await pump(
        tester,
        NebaTextLink(onPressed: noop, focusNode: focus, child: const Text('Docs')),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.pump();

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));
      expect(ring.visible, isTrue);
      expect(ring.color, tokensOf(tester).roles(NebaColor.primary).ring);
    });
  });

  group('semantics', () {
    testWidgets('is a link to a safe address, and to none for another scheme', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaTextLink(
          onPressed: noop,
          href: Uri.parse('https://neba.cdget.com/components/'),
          child: const Text('Docs'),
        ),
      );
      SemanticsData data() => tester.getSemantics(find.byType(NebaTextLink)).getSemanticsData();

      expect(
        tester.getSemantics(find.byType(NebaTextLink)),
        matchesSemantics(
          isLink: true,
          label: 'Docs',
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(data().linkUrl, Uri.parse('https://neba.cdget.com/components/'));

      await pump(
        tester,
        NebaTextLink(
          onPressed: noop,
          href: Uri.parse('javascript:alert(1)'),
          child: const Text('Docs'),
        ),
      );
      expect(data().linkUrl, isNull);

      await pump(
        tester,
        NebaTextLink(onPressed: noop, href: Uri.parse('/guide/'), child: const Text('Docs')),
      );
      expect(data().linkUrl, Uri.parse('/guide/'));

      semantics.dispose();
    });

    testWidgets('is no link without onPressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextLink(onPressed: null, child: Text('Docs')));

      expect(tester.getSemantics(find.byType(NebaTextLink)), matchesSemantics(label: 'Docs'));
      semantics.dispose();
    });

    testWidgets('says a new-tab link opens a new tab, in the locale\'s words', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextLink(onPressed: null, newTab: true, child: Text('All')));
      expect(tester.getSemantics(find.byType(NebaTextLink)).label, 'All\n(opens in a new tab)');

      registerNebaMessages('ko', ko);
      await pump(
        tester,
        const NebaTextLink(onPressed: null, newTab: true, locale: Locale('ko'), child: Text('전체')),
      );
      final String label = tester.getSemantics(find.byType(NebaTextLink)).label;
      expect(label, startsWith('전체\n'));
      expect(label, isNot(contains('opens in a new tab')));
      semantics.dispose();
    });
  });

  group('glyph', () {
    List<List<NebaGlyphPart>> glyphsOf(WidgetTester tester) {
      return tester
          .widgetList<NebaGlyph>(find.byType(NebaGlyph))
          .map((NebaGlyph glyph) => glyph.parts)
          .toList();
    }

    testWidgets('draws the external mark for a new tab, and none when told not to', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextLink(onPressed: null, newTab: true, child: Text('All')));
      expect(glyphsOf(tester), <List<NebaGlyphPart>>[NebaGlyphs.externalLink]);

      await pump(
        tester,
        const NebaTextLink(onPressed: null, newTab: true, showIcon: false, child: Text('All')),
      );
      expect(glyphsOf(tester), isEmpty);
    });

    testWidgets('draws the chain for a same-tab link that asks, or a glyph of its own', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextLink(onPressed: null, showIcon: true, child: Text('All')));
      expect(glyphsOf(tester), <List<NebaGlyphPart>>[NebaGlyphs.link]);

      await pump(
        tester,
        const NebaTextLink(
          onPressed: null,
          icon: SizedBox(key: Key('own')),
          child: Text('All'),
        ),
      );
      expect(find.byKey(const Key('own')), findsOneWidget);
      expect(glyphsOf(tester), isEmpty);
    });

    testWidgets('sets the glyph at the end of the text and keeps it out of the line', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextLink(onPressed: null, newTab: true, child: Text('All')));

      final RichText paragraph = tester.widget<RichText>(find.byType(RichText).first);
      expect(paragraph.text.toPlainText(includeSemanticsLabels: false), 'All￼');
      expect(marksOf(tester).ranges, <TextRange>[const TextRange(start: 0, end: 3)]);
    });
  });

  group('look', () {
    testWidgets('takes the colour around it, or its family\'s accent', (WidgetTester tester) async {
      await pump(tester, const NebaTextLink(onPressed: null, child: Text('Docs')));
      expect(inkOf(tester), const Color(0xFF123456));

      await pump(
        tester,
        const NebaTextLink(onPressed: null, color: NebaColor.success, child: Text('Docs')),
      );
      expect(inkOf(tester), tokensOf(tester).roles(NebaColor.success).accent);
    });

    testWidgets('takes the size around it, or the type scale\'s', (WidgetTester tester) async {
      await pump(tester, const NebaTextLink(onPressed: null, child: Text('Docs')));
      expect(tester.widget<RichText>(find.byType(RichText)).text.style!.fontSize, 13);

      await pump(
        tester,
        const NebaTextLink(onPressed: null, size: NebaSize.xl, child: Text('Docs')),
      );
      expect(
        tester.widget<RichText>(find.byType(RichText)).text.style!.fontSize,
        NebaScale.controlText[NebaSize.xl],
      );
    });

    testWidgets('underlines in part of its colour, and in all of it under the pointer', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextLink(onPressed: noop, child: Text('Docs')));
      await tester.pumpAndSettle();

      const Color ink = Color(0xFF123456);
      expect(marksOf(tester).underline, ink.withValues(alpha: NebaTextLink.restingLine));
      expect(find.byType(NebaTextMarks), paints..rect(color: ink.withValues(alpha: 0.45)));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Docs')));
      await tester.pumpAndSettle();

      expect(marksOf(tester).underline, ink);
    });

    testWidgets('draws the line under the pointer alone for hover, and never for none', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextLink(
          onPressed: noop,
          underline: NebaTextLinkUnderline.hover,
          child: Text('Docs'),
        ),
      );
      await tester.pumpAndSettle();
      expect(marksOf(tester).underline, isNull);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Docs')));
      await tester.pumpAndSettle();
      expect(marksOf(tester).underline, isNotNull);

      await pump(
        tester,
        const NebaTextLink(
          onPressed: noop,
          underline: NebaTextLinkUnderline.none,
          child: Text('Docs'),
        ),
      );
      await tester.pumpAndSettle();
      expect(marksOf(tester).underline, isNull);
    });
  });
}
