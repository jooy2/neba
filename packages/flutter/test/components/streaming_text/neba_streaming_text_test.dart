// NebaStreamingText: the suite the React package runs on StreamingText,
// asked the way Flutter asks it — the spans a word fades in as, the text that
// is drawn plain because it did not arrive, the caret, and the floor it holds
// before the first word lands.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget text, {bool disableAnimations = false}) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF000000)),
              child: text,
            ),
          ),
        ),
        disableAnimations: disableAnimations,
      ),
    );
  }

  /// The paragraph the text is drawn in.
  RichText paragraph(WidgetTester tester) {
    return tester.widget<RichText>(
      find.descendant(of: find.byType(NebaStreamingText), matching: find.byType(RichText)).first,
    );
  }

  /// The text pieces the paragraph is drawn as, with the alpha each is drawn
  /// at; a piece with no colour of its own is drawn whole.
  List<(String, double)> pieces(WidgetTester tester) {
    final List<(String, double)> out = <(String, double)>[];

    paragraph(tester).text.visitChildren((InlineSpan span) {
      if (span is TextSpan && span.text != null) {
        out.add((span.text!, span.style?.color?.a ?? 1));
      }

      return true;
    });

    return out;
  }

  String plainText(WidgetTester tester) {
    return paragraph(tester).text.toPlainText(includePlaceholders: false);
  }

  group('rendering', () {
    testWidgets('draws the text it has so far', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(child: Text('Hello there')));

      expect(plainText(tester), 'Hello there');
    });

    testWidgets('keeps the whole string, whitespace and all', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(child: Text('One\n\n  two')));

      expect(plainText(tester), 'One\n\n  two');
    });

    testWidgets('draws something that is not a plain Text untouched', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStreamingText(streaming: true, child: SizedBox(width: 10, height: 10)),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  group('the words', () {
    testWidgets('fades every word that streams in', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('One two')));

      final List<(String, double)> drawn = pieces(tester);
      expect(drawn.map(((String, double) piece) => piece.$1), <String>['One', ' ', 'two']);
      expect(drawn.first.$2, lessThan(0.05));

      // The fade's clock starts on the frame after the word lands.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(pieces(tester).first.$2, greaterThan(0.05));
      expect(pieces(tester).first.$2, lessThan(1));

      await tester.pump(const Duration(milliseconds: 200));
      // Faded in, the words are plain text again.
      expect(pieces(tester), <(String, double)>[('One two', 1)]);
    });

    testWidgets('fades only the new word when the text grows', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('One')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('One two')));

      final List<(String, double)> drawn = pieces(tester);
      final double one = drawn.firstWhere(((String, double) p) => p.$1 == 'One').$2;
      final double two = drawn.firstWhere(((String, double) p) => p.$1 == 'two').$2;

      expect(one, greaterThan(two));
    });

    testWidgets('cuts a script written without spaces a character at a time', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('日本語')));

      expect(pieces(tester).map(((String, double) p) => p.$1), <String>['日', '本', '語']);
    });

    testWidgets('leaves the text in one piece when the fade is off', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, fade: false, child: Text('')));
      await pump(
        tester,
        const NebaStreamingText(streaming: true, fade: false, child: Text('One two')),
      );

      expect(pieces(tester), <(String, double)>[('One two', 1)]);
    });

    testWidgets('lands at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaStreamingText(streaming: true, child: Text('')),
        disableAnimations: true,
      );
      await pump(
        tester,
        const NebaStreamingText(streaming: true, child: Text('One two')),
        disableAnimations: true,
      );

      expect(pieces(tester), <(String, double)>[('One two', 1)]);
    });
  });

  group('text that is not streaming in', () {
    testWidgets('draws the text it is first built with as plain text', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(child: Text('Loaded from history')));

      expect(pieces(tester), <(String, double)>[('Loaded from history', 1)]);
    });

    testWidgets('draws text that arrives while nothing streams as plain text', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStreamingText(child: Text('One')));
      await pump(tester, const NebaStreamingText(child: Text('One two')));

      expect(pieces(tester), <(String, double)>[('One two', 1)]);
    });

    testWidgets('fades only what arrives once a stream starts', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(child: Text('Already here')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('Already here')));
      await pump(
        tester,
        const NebaStreamingText(streaming: true, child: Text('Already here and new')),
      );

      final List<(String, double)> drawn = pieces(tester);
      expect(drawn.first, ('Already here', 1.0));
      expect(drawn.firstWhere(((String, double) p) => p.$1 == 'new').$2, lessThan(0.05));
    });

    testWidgets('does not fade the rest of a word the plain text had started', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStreamingText(child: Text('Hel')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('Hel')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('Hello world')));

      final List<(String, double)> drawn = pieces(tester);
      expect(drawn.firstWhere(((String, double) p) => p.$1 == 'lo').$2, 1);
      expect(drawn.firstWhere(((String, double) p) => p.$1 == 'world').$2, lessThan(0.05));
    });

    testWidgets('fades the words that arrive as the stream ends', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('One')));
      await tester.pump(const Duration(milliseconds: 400));
      await pump(tester, const NebaStreamingText(child: Text('One two')));

      expect(pieces(tester).firstWhere(((String, double) p) => p.$1 == 'two').$2, lessThan(0.05));

      await tester.pump(const Duration(milliseconds: 400));
      expect(pieces(tester), <(String, double)>[('One two', 1)]);
    });

    testWidgets('draws a text that replaces a streamed one plain once nothing streams', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('First answer')));
      await pump(tester, const NebaStreamingText(child: Text('Something else')));

      expect(pieces(tester), <(String, double)>[('Something else', 1)]);
    });

    testWidgets('fades a new answer streaming in over an old one', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(child: Text('The old answer')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('The old answer')));
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('The new one')));

      final List<(String, double)> drawn = pieces(tester);
      expect(drawn.first, ('The ', 1.0));
      expect(drawn.firstWhere(((String, double) p) => p.$1 == 'new').$2, lessThan(0.05));
    });
  });

  group('the caret', () {
    Finder caret() {
      return find.descendant(of: find.byType(NebaStreamingText), matching: find.byType(Container));
    }

    testWidgets('draws one while the stream runs', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('Hi')));

      expect(caret(), findsOneWidget);
      expect(tester.getSize(caret()), const Size(8, 16));
    });

    testWidgets('takes it away when the stream stops', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, child: Text('Hi')));
      await pump(tester, const NebaStreamingText(child: Text('Hi')));

      expect(caret(), findsNothing);
    });

    testWidgets('draws a caret of its own when it is handed one', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStreamingText(streaming: true, cursor: Text('…'), child: Text('Hi')),
      );

      expect(find.text('…'), findsOneWidget);
      expect(caret(), findsNothing);
    });

    testWidgets('draws none at all when it is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaStreamingText(streaming: true, showCursor: false, child: Text('Hi')),
      );

      expect(caret(), findsNothing);
    });

    testWidgets('blinks, and holds still for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      double opacity() {
        return tester
            .widget<Opacity>(find.ancestor(of: caret(), matching: find.byType(Opacity)).first)
            .opacity;
      }

      await pump(tester, const NebaStreamingText(streaming: true, child: Text('Hi')));
      expect(opacity(), 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(opacity(), 0);

      await pump(
        tester,
        const NebaStreamingText(streaming: true, child: Text('Hi')),
        disableAnimations: true,
      );
      expect(find.ancestor(of: caret(), matching: find.byType(Opacity)), findsNothing);
    });
  });

  group('reserving the height', () {
    testWidgets('holds one line before anything has arrived', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(streaming: true, showCursor: false));

      expect(tester.getSize(find.byType(NebaStreamingText)).height, 24);
    });

    testWidgets('holds as many as it was asked for, and keeps them', (WidgetTester tester) async {
      await pump(tester, const NebaStreamingText(lines: 3, child: Text('')));
      expect(tester.getSize(find.byType(NebaStreamingText)).height, 72);

      await pump(tester, const NebaStreamingText(lines: 3, child: Text('One line.')));
      expect(tester.getSize(find.byType(NebaStreamingText)).height, 72);
    });
  });
}
