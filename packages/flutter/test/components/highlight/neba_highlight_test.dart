import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget highlight) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 600, child: highlight))));
  }

  /// The paragraph the highlight drew.
  RichText paragraphOf(WidgetTester tester) => tester.widget<RichText>(find.byType(RichText));

  /// The text of every span drawn in [ink], in order.
  List<String> marksIn(WidgetTester tester, Color ink) {
    final List<String> found = <String>[];

    paragraphOf(tester).text.visitChildren((InlineSpan span) {
      if (span is TextSpan && span.style?.color == ink && span.text != null) {
        found.add(span.text!);
      }

      return true;
    });

    return found;
  }

  NebaTokens tokensOf(WidgetTester tester) => NebaTheme.of(tester.element(find.byType(RichText)));

  /// The marks of a solid `warning` highlight, the default one.
  List<String> marks(WidgetTester tester) {
    return marksIn(tester, tokensOf(tester).roles(NebaColor.warning).onSolid);
  }

  group('matching', () {
    testWidgets('marks every occurrence and leaves the text around them intact', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHighlight(query: 'cat', child: Text('cat, cat and a dog')));

      expect(marks(tester), <String>['cat', 'cat']);
      expect(paragraphOf(tester).text.toPlainText(), 'cat, cat and a dog');
    });

    testWidgets('hands back the child itself when nothing matches', (WidgetTester tester) async {
      const Text child = Text('a dog');

      await pump(tester, const NebaHighlight(query: 'cat', child: child));
      expect(tester.widget<Text>(find.byType(Text)), same(child));

      await pump(tester, const NebaHighlight(query: '  ', child: child));
      expect(tester.widget<Text>(find.byType(Text)), same(child));
    });

    testWidgets('takes several terms, the longest first', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHighlight.terms(
          query: <String>['data', 'database'],
          child: Text('One data row in one database.'),
        ),
      );

      expect(marks(tester), <String>['data', 'database']);
    });

    testWidgets('reads a string as text rather than as a pattern', (WidgetTester tester) async {
      await pump(tester, const NebaHighlight(query: 'a.c', child: Text('abc and a.c')));

      expect(marks(tester), <String>['a.c']);
    });

    testWidgets('takes a RegExp as written', (WidgetTester tester) async {
      await pump(
        tester,
        NebaHighlight.pattern(
          query: RegExp(r'\b[A-Z]{2,}\b'),
          child: const Text('HTTP and TLS are acronyms; Http and Tls are not.'),
        ),
      );

      expect(marks(tester), <String>['HTTP', 'TLS']);
    });

    testWidgets('does not hang on a pattern that can match nothing', (WidgetTester tester) async {
      await pump(tester, NebaHighlight.pattern(query: RegExp('x*'), child: const Text('axxb')));

      expect(marks(tester), <String>['xx']);
    });

    testWidgets('ignores case unless asked not to', (WidgetTester tester) async {
      await pump(tester, const NebaHighlight(query: 'fox', child: Text('Fox, FOX and fox')));
      expect(marks(tester), <String>['Fox', 'FOX', 'fox']);

      await pump(
        tester,
        const NebaHighlight(query: 'fox', caseSensitive: true, child: Text('Fox, FOX and fox')),
      );
      expect(marks(tester), <String>['fox']);
    });
  });

  group('accents', () {
    testWidgets('marks an accented word for a query without the accent', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHighlight(query: 'jose', child: Text('José, JOSÉ and Jose')));

      expect(marks(tester), <String>['José', 'JOSÉ', 'Jose']);
    });

    testWidgets('marks the whole of a decomposed letter, accent included', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHighlight(query: 'cafe', child: Text('Café au lait')));

      expect(marks(tester), <String>['Café']);
      expect(paragraphOf(tester).text.toPlainText(), 'Café au lait');
    });

    testWidgets('marks an unaccented word for a query with the accent', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHighlight(query: 'résumé', child: Text('A resume')));

      expect(marks(tester), <String>['resume']);
    });

    testWidgets('folds Greek and Cyrillic as well', (WidgetTester tester) async {
      await pump(tester, const NebaHighlight(query: 'αθηνα', child: Text('Αθήνα')));
      expect(marks(tester), <String>['Αθήνα']);

      await pump(tester, const NebaHighlight(query: 'еще', child: Text('ещё')));
      expect(marks(tester), <String>['ещё']);
    });

    testWidgets('does not mark part of a Hangul syllable', (WidgetTester tester) async {
      await pump(tester, const NebaHighlight(query: '가', child: Text('각 가')));

      expect(marks(tester), <String>['가']);
    });
  });

  group('wholeWord', () {
    testWidgets('matches inside a word by default, and only whole words when asked', (
      WidgetTester tester,
    ) async {
      const Text sentence = Text('A cat that concatenates is still a cat.');

      await pump(tester, const NebaHighlight(query: 'cat', child: sentence));
      expect(marks(tester), <String>['cat', 'cat', 'cat']);

      await pump(tester, const NebaHighlight(query: 'cat', wholeWord: true, child: sentence));
      expect(marks(tester), <String>['cat', 'cat']);
    });

    testWidgets('finds a whole word that starts inside a rejected match', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHighlight.terms(
          query: <String>['a b', 'b'],
          wholeWord: true,
          child: Text('xa b'),
        ),
      );

      expect(marks(tester), <String>['b']);
    });

    testWidgets('counts accented letters as part of a word', (WidgetTester tester) async {
      await pump(tester, const NebaHighlight(query: 'caf', wholeWord: true, child: Text('café')));

      expect(marks(tester), isEmpty);
    });
  });

  group('spans', () {
    testWidgets('marks text inside a span and keeps the span around it', (
      WidgetTester tester,
    ) async {
      const TextStyle bold = TextStyle(fontWeight: FontWeight.w700);

      await pump(
        tester,
        const NebaHighlight(
          query: 'surface',
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'A '),
                TextSpan(text: 'surface', style: bold),
                TextSpan(text: ' is a sheet.'),
              ],
            ),
          ),
        ),
      );

      expect(marks(tester), <String>['surface']);

      // The paragraph's root is the default style Text.rich wraps it in.
      final TextSpan root = (paragraphOf(tester).text as TextSpan).children!.single as TextSpan;
      final TextSpan strong = root.children![1] as TextSpan;
      expect(strong.style, bold);
      expect((strong.children!.single as TextSpan).text, 'surface');
    });

    testWidgets('keeps a span\'s gestures on every piece of it', (WidgetTester tester) async {
      final TapGestureRecognizer tap = TapGestureRecognizer()..onTap = () {};
      addTearDown(tap.dispose);

      await pump(
        tester,
        NebaHighlight(
          query: 'link',
          child: Text.rich(TextSpan(text: 'a link here', recognizer: tap)),
        ),
      );

      final List<TextSpan> pieces = <TextSpan>[];
      paragraphOf(tester).text.visitChildren((InlineSpan span) {
        if (span is TextSpan && span.text != null) {
          pieces.add(span);
        }

        return true;
      });

      expect(pieces.map((TextSpan span) => span.text), <String>['a ', 'link', ' here']);
      expect(pieces.map((TextSpan span) => span.recognizer), everyElement(same(tap)));
    });

    testWidgets('marks a NebaTypography and keeps its level', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHighlight(
          query: 'b',
          child: NebaTypography('a b c', level: NebaTypographyLevel.lead),
        ),
      );

      expect(marks(tester), <String>['b']);
      expect(
        tester.widget<NebaTypography>(find.byType(NebaTypography)).level,
        NebaTypographyLevel.lead,
      );

      // An overline is in capitals, and the search runs on what is drawn.
      await pump(
        tester,
        const NebaHighlight(
          query: 'NEW',
          caseSensitive: true,
          child: NebaTypography('new', level: NebaTypographyLevel.overline),
        ),
      );
      expect(marks(tester), <String>['NEW']);
    });

    testWidgets('carries the text\'s own settings over', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHighlight(
          query: 'b',
          child: Text('a b c', maxLines: 1, textAlign: TextAlign.end, semanticsLabel: 'letters'),
        ),
      );

      final Text text = tester.widget<Text>(find.byType(Text));
      expect(text.maxLines, 1);
      expect(text.textAlign, TextAlign.end);
      expect(text.semanticsLabel, 'letters');
    });
  });

  group('look', () {
    Finder marksPainter() =>
        find.byWidgetPredicate((Widget widget) => widget.runtimeType.toString() == '_Marks');

    testWidgets('fills a solid mark in the family and inks it to read on the fill', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHighlight(query: 'b', child: Text('a b c')));
      final NebaColorRoles warning = tokensOf(tester).roles(NebaColor.warning);

      expect(marks(tester), <String>['b']);
      expect(marksPainter(), paints..rrect(color: warning.fill));
    });

    testWidgets('draws a hairline around an outline mark and nothing behind a text one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHighlight(
          query: 'b',
          variant: NebaVariant.outline,
          color: NebaColor.primary,
          child: Text('a b c'),
        ),
      );
      final NebaColorRoles primary = tokensOf(tester).roles(NebaColor.primary);

      expect(marksIn(tester, primary.onTint), <String>['b']);
      expect(
        marksPainter(),
        paints
          ..rrect(color: primary.panel)
          ..rrect(color: primary.line, style: PaintingStyle.stroke),
      );

      await pump(
        tester,
        const NebaHighlight(
          query: 'b',
          variant: NebaVariant.text,
          color: NebaColor.primary,
          child: Text('a b c'),
        ),
      );

      expect(marksIn(tester, primary.onTint), <String>['b']);
      expect(marksPainter(), isNot(paints..rrect()));
    });

    testWidgets('takes the provider\'s variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const NebaProvider(
            defaults: NebaDefaults(variant: NebaVariant.text),
            child: Center(
              child: NebaHighlight(query: 'b', child: Text('a b c')),
            ),
          ),
        ),
      );

      expect(marksIn(tester, tokensOf(tester).roles(NebaColor.warning).onTint), <String>['b']);
    });

    testWidgets('underlines and weights a mark only when asked', (WidgetTester tester) async {
      await pump(tester, const NebaHighlight(query: 'b', child: Text('a b c')));
      expect(marksPainter(), isNot(paints..rect()));

      await pump(
        tester,
        const NebaHighlight(
          query: 'b',
          underline: true,
          weight: FontWeight.w700,
          child: Text('a b c'),
        ),
      );
      final Color ink = tokensOf(tester).roles(NebaColor.warning).onSolid;

      expect(marksPainter(), paints..rect(color: ink));

      TextSpan? marked;
      paragraphOf(tester).text.visitChildren((InlineSpan span) {
        if (span is TextSpan && span.text == 'b') {
          marked = span;
        }

        return true;
      });
      expect(marked!.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('draws each mark behind its own word, past a widget in the text', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHighlight(
          query: 'b',
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                WidgetSpan(child: SizedBox(width: 40, height: 10)),
                TextSpan(text: 'a b c'),
              ],
            ),
          ),
        ),
      );

      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(find.byType(RichText));
      // The placeholder is one unit, so `b` is at 3 in the paragraph.
      final Rect word = paragraph
          .getBoxesForSelection(const TextSelection(baseOffset: 3, extentOffset: 4))
          .single
          .toRect();
      final Offset origin = paragraph.localToGlobal(Offset.zero);
      final Offset painterOrigin = tester
          .renderObject<RenderBox>(find.byWidgetPredicate((Widget w) => w is NebaHighlight))
          .localToGlobal(Offset.zero);
      final Rect drawn = word.shift(origin - painterOrigin);
      final Rect expected = Rect.fromLTRB(
        drawn.left - NebaHighlight.inset,
        drawn.top,
        drawn.right + NebaHighlight.inset,
        drawn.bottom,
      );

      expect(
        marksPainter(),
        paints..rrect(
          rrect: RRect.fromRectAndRadius(expected, const Radius.circular(NebaHighlight.radius)),
        ),
      );
    });
  });
}
