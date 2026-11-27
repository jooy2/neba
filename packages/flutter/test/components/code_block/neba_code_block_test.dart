// NebaCodeBlock: the suite the React package runs on CodeBlock, asked the way
// Flutter asks it — the lines and the runs it draws, the colours they take,
// what the clipboard is handed, what a selection holds and what a screen
// reader hears — rather than the elements and attributes it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';

import '../../support/host.dart';

const String source = 'const answer = 42;\nconsole.log(answer);';

void main() {
  final NebaTokens light = NebaTokens.light();

  tearDown(resetNebaMessages);

  Future<void> pump(WidgetTester tester, Widget block, {double width = 480}) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: block),
          ),
        ),
      ),
    );
  }

  /// Every line the block drew, as its code's text.
  List<String> lines(WidgetTester tester) {
    return tester
        .widgetList<RichText>(
          find.descendant(of: find.byType(SelectableRegion), matching: find.byType(RichText)),
        )
        .where((RichText text) => text.text is TextSpan && (text.text as TextSpan).children != null)
        .map((RichText text) => text.text.toPlainText())
        .toList();
  }

  /// The runs of the line whose code is [line], with their colours.
  List<TextSpan> runs(WidgetTester tester, int line) {
    final RichText text = tester
        .widgetList<RichText>(
          find.descendant(of: find.byType(SelectableRegion), matching: find.byType(RichText)),
        )
        .where((RichText text) => text.text is TextSpan && (text.text as TextSpan).children != null)
        .elementAt(line);

    return ((text.text as TextSpan).children!.single as TextSpan).children!.cast<TextSpan>();
  }

  Color? colourOf(WidgetTester tester, int line, String run) {
    return runs(tester, line).firstWhere((TextSpan span) => span.text == run).style?.color;
  }

  /// The containers each line is drawn in, in order.
  List<BoxDecoration> rows(WidgetTester tester) {
    return tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(SelectableRegion),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).border is BorderDirectional,
            ),
          ),
        )
        .map((Container row) => row.decoration! as BoxDecoration)
        .toList();
  }

  /// The clipboard, stubbed: what it was handed, and whether it refuses.
  List<String> clipboard(WidgetTester tester, {bool refuses = false}) {
    final List<String> handed = <String>[];

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
      MethodCall call,
    ) async {
      if (call.method == 'Clipboard.setData') {
        if (refuses) {
          throw PlatformException(code: 'denied');
        }

        handed.add((call.arguments as Map<Object?, Object?>)['text']! as String);
      }

      return null;
    });
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    return handed;
  }

  group('rendering', () {
    testWidgets('draws the code it was given, one line per line', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source));

      expect(lines(tester), <String>['const answer = 42;', 'console.log(answer);']);
    });

    testWidgets('keeps a blank line in the middle', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'a\n\nb'));

      expect(lines(tester), <String>['a', '', 'b']);
    });

    testWidgets('drops trailing blank lines', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'a\nb\n\n\n'));

      expect(lines(tester), <String>['a', 'b']);
    });

    testWidgets('normalises CRLF line endings', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'a\r\nb'));

      expect(lines(tester), <String>['a', 'b']);
      expect(NebaCodeBlock.normalise('a\r\nb\rc\n'), 'a\nb\nc');
    });

    testWidgets('takes the width it is given', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'a'));

      expect(tester.getSize(find.byType(NebaCodeBlock)).width, 480);
    });
  });

  group('highlighting', () {
    final NebaCodePalette dark = NebaTokens.dark().code;

    testWidgets('colours the code on the first frame', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'ts'));

      expect(colourOf(tester, 0, 'const'), dark.keyword);
      expect(colourOf(tester, 0, '42'), dark.number);
      expect(colourOf(tester, 1, 'console'), dark.variable);
      expect(colourOf(tester, 1, 'log'), dark.function);
    });

    testWidgets('draws new code at once', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'ts'));
      await pump(tester, const NebaCodeBlock(code: 'local total = 7', language: 'lua'));

      expect(lines(tester), <String>['local total = 7']);
    });

    testWidgets('understands an alias for the language', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'TSX'));

      expect(colourOf(tester, 0, 'const'), dark.keyword);
    });

    testWidgets('draws no colour at all when highlight is off', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'ts', highlight: false));

      expect(runs(tester, 0).single.text, 'const answer = 42;');
      expect(runs(tester, 0).single.style, isNull);
    });

    testWidgets('draws an unknown language plain', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'klingon'));

      expect(lines(tester).first, 'const answer = 42;');
      expect(runs(tester, 0).single.style, isNull);
    });

    testWidgets('keeps a token that spans two lines on both of them', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCodeBlock(code: '/* one\n   two */\nconst a = 1;', language: 'ts'),
      );

      expect(colourOf(tester, 0, '/* one'), dark.comment);
      expect(colourOf(tester, 1, '   two */'), dark.comment);
      expect(runs(tester, 1).first.style!.fontStyle, FontStyle.italic);
    });

    testWidgets('sets the structure heavier on mono', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCodeBlock(code: source, language: 'ts', theme: NebaCodeTheme.mono),
      );

      expect(runs(tester, 0).first.style!.fontWeight, FontWeight.w600);
      expect(colourOf(tester, 0, 'const'), light.fg);
    });
  });

  group('the toolbar', () {
    testWidgets('names the language', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'yml'));

      expect(find.text('YAML'), findsOneWidget);
      expect(find.bySemanticsLabel('yaml'), findsOneWidget);
    });

    testWidgets('draws a title when it is given one', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, title: Text('answer.ts')));

      expect(find.text('answer.ts'), findsOneWidget);
    });

    testWidgets('leaves the language out when showLanguage is off', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'yml', showLanguage: false));

      expect(find.text('YAML'), findsNothing);
    });

    testWidgets('drops the whole bar when toolbar is off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCodeBlock(
          code: source,
          language: 'yml',
          toolbar: false,
          title: Text('answer.ts'),
        ),
      );

      expect(find.text('Copy'), findsNothing);
      expect(find.text('answer.ts'), findsNothing);
      expect(find.text('YAML'), findsNothing);
    });

    testWidgets('draws no bar when there is nothing to put on it', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'a', copyable: false));

      final double bare = tester.getSize(find.byType(NebaCodeBlock)).height;

      await pump(tester, const NebaCodeBlock(code: 'a', copyable: false, toolbar: false));

      expect(tester.getSize(find.byType(NebaCodeBlock)).height, bare);
    });

    testWidgets('offers the raw toggle only when it is asked for', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'ts'));

      expect(find.bySemanticsLabel('Raw'), findsNothing);

      await pump(tester, const NebaCodeBlock(code: source, language: 'ts', rawToggle: true));

      expect(find.bySemanticsLabel('Raw'), findsOneWidget);
    });

    testWidgets('drops the colouring while the raw toggle is pressed', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, language: 'ts', rawToggle: true));

      expect(runs(tester, 0).length, greaterThan(1));

      await tester.tap(find.bySemanticsLabel('Raw'));
      await tester.pumpAndSettle();

      expect(runs(tester, 0).single.style, isNull);
    });
  });

  group('copying', () {
    testWidgets('puts the code on the clipboard and says so', (WidgetTester tester) async {
      final List<String> handed = clipboard(tester);
      final List<String> copied = <String>[];

      await pump(tester, NebaCodeBlock(code: source, onCopy: copied.add));
      await tester.tap(find.text('Copy'));
      await tester.pump();

      expect(find.text('Copied'), findsOneWidget);
      expect(handed, <String>[source]);
      expect(copied, <String>[source]);

      await tester.pump(NebaCodeBlock.copiedFor);

      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('says so again when it is pressed again', (WidgetTester tester) async {
      clipboard(tester);

      await pump(tester, const NebaCodeBlock(code: source));

      Finder spoken(String word) =>
          find.descendant(of: find.byType(NebaVisuallyHidden), matching: find.text(word));

      await tester.tap(find.text('Copy'));
      await tester.pump();

      expect(spoken(''), findsOneWidget);

      await tester.pump(NebaCodeBlock.speakAfter);

      expect(spoken('Copied'), findsOneWidget);

      // A second copy empties the announcement and writes it again.
      await tester.tap(find.text('Copied').first);
      await tester.pump();

      expect(spoken(''), findsOneWidget);

      await tester.pump(NebaCodeBlock.speakAfter);

      expect(spoken('Copied'), findsOneWidget);

      await tester.pump(NebaCodeBlock.copiedFor);
    });

    testWidgets('says so when the clipboard refuses', (WidgetTester tester) async {
      clipboard(tester, refuses: true);

      final List<String> copied = <String>[];

      await pump(tester, NebaCodeBlock(code: source, onCopy: copied.add));
      await tester.tap(find.text('Copy'));
      await tester.pump();

      expect(find.text('Could not copy'), findsOneWidget);
      expect(copied, isEmpty);

      await tester.pump(NebaCodeBlock.copiedFor);
    });

    testWidgets('leaves the button out when copyable is off', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, copyable: false, language: 'ts'));

      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('copies the code without the prompt symbols', (WidgetTester tester) async {
      final List<String> handed = clipboard(tester);

      await pump(tester, const NebaCodeBlock(code: 'npm install\nnpm test', prompt: r'$'));
      await tester.tap(find.text('Copy'));
      await tester.pump();

      expect(handed, <String>['npm install\nnpm test']);

      await tester.pump(NebaCodeBlock.copiedFor);
    });
  });

  group('line numbers and prompts', () {
    Finder gutter() => find.descendant(
      of: find.byType(SelectableRegion),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.textAlign == TextAlign.end,
      ),
    );

    testWidgets('numbers the lines from one', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, lineNumbers: true));

      expect(tester.widgetList<Text>(gutter()).map((Text t) => t.data), <String>['1', '2']);
    });

    testWidgets('starts an excerpt where it actually starts', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, lineNumbers: true, startLine: 286));

      expect(tester.widgetList<Text>(gutter()).map((Text t) => t.data), <String>['286', '287']);
    });

    testWidgets('sizes the gutter for the last number', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'a\nb', lineNumbers: true, startLine: 99));

      // The test font's glyphs are as wide as its size: three digits at 13.
      expect(tester.getSize(find.text('99')).width, 39);
      expect(tester.getSize(find.text('100')).width, 39);
    });

    testWidgets('draws no numbers unless it is asked to', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source));

      expect(gutter(), findsNothing);
    });

    testWidgets('marks every line with something on it with the prompt', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCodeBlock(code: 'a\n\nb', prompt: r'$'));

      expect(find.text(r'$'), findsNWidgets(2));
    });

    testWidgets('keeps the numbers and the prompt out of a screen reader', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCodeBlock(code: 'a', prompt: r'$', lineNumbers: true));

      expect(find.bySemanticsLabel(RegExp(r'\$')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('^1')), findsNothing);

      semantics.dispose();
    });
  });

  group('marked lines', () {
    test('marks one line from a number', () {
      expect(NebaCodeBlock.markedLines('2', 1, 3), <int>{2});
    });

    test('marks a range', () {
      expect(NebaCodeBlock.markedLines('2-3', 1, 4), <int>{2, 3});
    });

    test('takes a list of lines and ranges', () {
      expect(NebaCodeBlock.markedLines('1,3-4', 1, 5), <int>{1, 3, 4});
    });

    test('reads a backwards range the way it was meant', () {
      expect(NebaCodeBlock.markedLines('3-2', 1, 3), <int>{2, 3});
    });

    test('marks only the lines a far-reaching range lands on, and at once', () {
      final Stopwatch watch = Stopwatch()..start();

      expect(NebaCodeBlock.markedLines('2-100000000', 1, 3), <int>{2, 3});
      expect(watch.elapsedMilliseconds, lessThan(1000));
    });

    test('drops what it cannot read rather than throwing', () {
      expect(NebaCodeBlock.markedLines('two, 2', 1, 2), <int>{2});
    });

    test('marks nothing when it is not asked to', () {
      expect(NebaCodeBlock.markedLines(null, 1, 2), isEmpty);
    });

    testWidgets('tints a marked row and rules its leading edge', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCodeBlock(
          code: 'a\nb\nc',
          lineNumbers: true,
          startLine: 286,
          highlightLines: '287',
        ),
      );

      final List<BoxDecoration> drawn = rows(tester);
      final Color ink = NebaTokens.dark().code.foreground;

      expect(drawn.map((BoxDecoration row) => row.color != null), <bool>[false, true, false]);
      expect(drawn[1].color!.a, closeTo(ink.a * 0.1, 0.01));

      final BorderDirectional edge = drawn[1].border! as BorderDirectional;

      expect(edge.start.width, 2);
      expect((drawn[0].border! as BorderDirectional).start.width, 2);
      expect((drawn[0].border! as BorderDirectional).start.color.a, 0);
    });
  });

  group('selecting', () {
    Future<String> copySelection(WidgetTester tester, List<String> handed) async {
      Actions.invoke(tester.element(find.text('const a = 1;')), CopySelectionTextIntent.copy);
      await tester.pump();

      return handed.last;
    }

    testWidgets('selects the code and nothing else on Ctrl+A', (WidgetTester tester) async {
      final List<String> handed = clipboard(tester);

      await pump(
        tester,
        const NebaCodeBlock(
          code: 'const a = 1;\n\nconst b = 2;',
          maxHeight: 40,
          prompt: '>',
          lineNumbers: true,
        ),
      );

      Focus.of(tester.element(find.text('const a = 1;'))).requestFocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyA), isTrue);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(await copySelection(tester, handed), 'const a = 1;\n\nconst b = 2;');
    });

    testWidgets('leaves a plain A alone', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: 'const a = 1;', maxHeight: 8));

      Focus.of(tester.element(find.text('const a = 1;'))).requestFocus();
      await tester.pump();

      expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyA), isFalse);
    });
  });

  group('appearance', () {
    BoxDecoration sheet(WidgetTester tester) {
      return tester
              .widget<AnimatedContainer>(
                find
                    .descendant(
                      of: find.byType(NebaCodeBlock),
                      matching: find.byType(AnimatedContainer),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;
    }

    testWidgets('wears the dark palette by default, whatever the page', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCodeBlock(code: source));

      expect(sheet(tester).color, NebaTokens.dark().code.background);

      await pump(tester, const NebaCodeBlock(code: source, theme: NebaCodeTheme.dracula));

      expect(sheet(tester).color, const Color(0xFF282A36));
    });

    testWidgets('follows the page on auto', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, theme: NebaCodeTheme.auto));

      expect(sheet(tester).color, light.code.background);
    });

    testWidgets('wears a theme of the caller\'s own', (WidgetTester tester) async {
      const NebaCodePalette ours = NebaCodePalette(
        background: Color(0xFF101418),
        foreground: Color(0xFFD7DCE2),
        comment: Color(0xFF59626E),
        keyword: Color(0xFFFF8AB3),
        string: Color(0xFF9AD48F),
        number: Color(0xFF9AD48F),
        function: Color(0xFF9AD48F),
        type: Color(0xFF9AD48F),
        variable: Color(0xFF9AD48F),
        tag: Color(0xFF9AD48F),
        attribute: Color(0xFF9AD48F),
        meta: Color(0xFF9AD48F),
        addition: Color(0xFF9AD48F),
        deletion: Color(0xFF9AD48F),
      );

      await pump(
        tester,
        const NebaCodeBlock(code: source, language: 'ts', theme: NebaCodeTheme(ours)),
      );

      expect(sheet(tester).color, ours.background);
      expect(colourOf(tester, 0, 'const'), ours.keyword);
    });

    testWidgets('wraps long lines only when it is told to', (WidgetTester tester) async {
      final String long = List<String>.filled(80, 'word').join(' ');

      await pump(tester, NebaCodeBlock(code: long, toolbar: false));

      final double scrolled = tester.getSize(find.byType(NebaCodeBlock)).height;

      await pump(tester, NebaCodeBlock(code: long, toolbar: false, wrap: true));

      expect(tester.getSize(find.byType(NebaCodeBlock)).height, greaterThan(scrolled * 2));
    });

    testWidgets('takes the type settings it was handed', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaCodeBlock(
          code: source,
          fontFamily: 'Iosevka',
          fontSize: 15,
          lineHeight: 2,
          letterSpacing: 0.6,
        ),
      );

      final TextStyle style =
          (tester
                      .widget<RichText>(
                        find
                            .descendant(
                              of: find.byType(SelectableRegion),
                              matching: find.byType(RichText),
                            )
                            .first,
                      )
                      .text
                  as TextSpan)
              .children!
              .single
              .style!;

      expect(style.fontFamily, 'Iosevka');
      expect(style.fontSize, 15);
      expect(style.height, 2);
      expect(style.letterSpacing, 0.6);
    });

    testWidgets('bounds its height when it is told to', (WidgetTester tester) async {
      await pump(
        tester,
        NebaCodeBlock(
          code: List<String>.filled(40, 'line').join('\n'),
          toolbar: false,
          maxHeight: 120,
        ),
      );

      // The height, and the hairline above and below it.
      expect(tester.getSize(find.byType(NebaCodeBlock)).height, 122);
    });

    testWidgets('sits flat until it is given an elevation', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source));

      expect(sheet(tester).boxShadow, isEmpty);

      await pump(tester, const NebaCodeBlock(code: source, elevation: 2));

      expect(sheet(tester).boxShadow, light.elevation(2));
    });
  });

  group('accessibility', () {
    testWidgets('names a block that scrolls after its title', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCodeBlock(code: source, title: Text('answer.ts'), maxHeight: 8));
      await tester.pump();

      expect(
        tester.getSemantics(find.bySemanticsLabel('answer.ts').last),
        matchesSemantics(label: 'answer.ts', isFocusable: true, role: SemanticsRole.region),
      );

      semantics.dispose();
    });

    testWidgets('falls back to the language, and then to the word for code', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCodeBlock(code: source, language: 'ts', maxHeight: 8));
      await tester.pump();

      expect(find.bySemanticsLabel('typescript'), findsWidgets);

      await pump(
        tester,
        const NebaCodeBlock(
          code: source,
          maxHeight: 8,
          title: Text.rich(TextSpan(text: 'x')),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('Code'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('is neither a region nor a tab stop while nothing in it scrolls', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCodeBlock(code: 'const a = 1;', toolbar: false));
      await tester.pump();

      expect(find.bySemanticsLabel('Code'), findsNothing);
      expect(Focus.of(tester.element(find.text('const a = 1;'))).skipTraversal, isTrue);

      await pump(tester, const NebaCodeBlock(code: 'const a = 1;', toolbar: false, maxHeight: 8));
      await tester.pump();

      expect(find.bySemanticsLabel('Code'), findsOneWidget);
      expect(Focus.of(tester.element(find.text('const a = 1;'))).skipTraversal, isFalse);

      semantics.dispose();
    });

    testWidgets('says the raw toggle is pressed while it is', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaCodeBlock(code: source, language: 'ts', rawToggle: true));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Raw')),
        matchesSemantics(
          label: 'Raw',
          isButton: true,
          hasSelectedState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Raw'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Raw')),
        matchesSemantics(
          label: 'Raw',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('says its own words in the locale it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaCodeBlock(code: source, locale: Locale('ko')));

      expect(find.text('복사'), findsOneWidget);
    });

    testWidgets('takes a label written out over the locale', (WidgetTester tester) async {
      await pump(tester, const NebaCodeBlock(code: source, copyLabel: 'Grab it'));

      expect(find.text('Grab it'), findsOneWidget);
    });

    testWidgets('rings the focus inside the edge of a block that scrolls', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaCodeBlock(code: source, maxHeight: 8));

      Focus.of(tester.element(find.text('const answer = 42;'))).requestFocus();
      await tester.pump();
      await tester.pump();

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(
        find.ancestor(
          of: find.byType(SingleChildScrollView).first,
          matching: find.byType(NebaFocusRing),
        ),
      );

      expect(ring.visible, isTrue);
      expect(ring.offset, -focusRingWidth);
    });
  });
}
