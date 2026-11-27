// NebaSpoiler: the suite the React package runs on Spoiler, asked the way
// Flutter asks it — what a press and a screen reader can reach while the
// content is covered, the blur and the clamp, the box's height through a
// reveal, where the focus goes and the words the cover says — rather than the
// attributes it writes.

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget spoiler) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 400, child: spoiler),
        ),
      ),
    );
  }

  double heightOf(WidgetTester tester) => tester.getSize(find.byType(NebaSpoiler)).height;

  ImageFiltered blurOf(WidgetTester tester) {
    return tester.widget<ImageFiltered>(
      find.descendant(of: find.byType(NebaSpoiler), matching: find.byType(ImageFiltered)),
    );
  }

  const Widget secret = Text('The butler did it.');
  const String tall =
      'A long line of covered content that wraps across a good number of lines at this '
      'width, long enough that the box clamped to a hundred and twenty pixels cuts it off '
      'well before its end, which is the whole point of the clamp.';

  group('rendering', () {
    testWidgets('holds the content it covers', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      expect(find.text('The butler did it.'), findsOneWidget);
    });

    testWidgets('takes the width it is given', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      expect(tester.getSize(find.byType(NebaSpoiler)).width, 400);
    });
  });

  group('covering', () {
    testWidgets('keeps the covered content from a press and a screen reader', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaSpoiler(child: secret));

      expect(find.text('The butler did it.').hitTestable(), findsNothing);
      expect(find.bySemanticsLabel('The butler did it.'), findsNothing);

      handle.dispose();
    });

    testWidgets('blurs the covered content', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      expect(blurOf(tester).enabled, isTrue);
      expect(
        blurOf(tester).imageFilter,
        ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.decal),
      );
    });

    testWidgets('blurs it as hard as it was told to', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(blur: 16, child: secret));

      expect(
        blurOf(tester).imageFilter,
        ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16, tileMode: TileMode.decal),
      );
    });

    testWidgets('clamps the covered box to maxHeight and lets go on reveal', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSpoiler(maxHeight: 120, child: Text(tall)));

      expect(heightOf(tester), 120 + 2);

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(heightOf(tester), greaterThan(122));
    });

    testWidgets('keeps covered text out of a selection', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      expect(
        find.ancestor(
          of: find.text('The butler did it.'),
          matching: find.byType(SelectionContainer),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.text('The butler did it.'),
          matching: find.byType(SelectionContainer),
        ),
        findsNothing,
      );
    });
  });

  group('revealing', () {
    testWidgets('uncovers the content when the button is pressed', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(find.text('The butler did it.').hitTestable(), findsOneWidget);
      expect(blurOf(tester).enabled, isFalse);
      expect(find.text('Reveal').hitTestable(), findsNothing);
    });

    testWidgets('keeps what the content holds through a reveal', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: _Counter()));

      final _CounterState before = tester.state<_CounterState>(find.byType(_Counter));

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(tester.state<_CounterState>(find.byType(_Counter)), same(before));
    });

    testWidgets('holds the cover in place once the content is out', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: Text('One line.')));
      final double covered = heightOf(tester);

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(heightOf(tester), covered);
    });

    testWidgets('grows to a cover taller than what it covers', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(padded: false, child: SizedBox(height: 4)));

      final Rect button = tester.getRect(find.text('Reveal'));
      final Rect box = tester.getRect(find.byType(NebaSpoiler));

      expect(box.height, greaterThan(4));
      expect(box.contains(button.bottomCenter), isTrue);
    });

    testWidgets('starts uncovered when it is told to', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(defaultRevealed: true, child: secret));

      expect(find.text('The butler did it.').hitTestable(), findsOneWidget);
      expect(blurOf(tester).enabled, isFalse);
    });

    testWidgets('reports the change', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(tester, NebaSpoiler(onRevealedChange: changes.add, child: secret));
      await tester.tap(find.text('Reveal'));

      expect(changes, <bool>[true]);
    });

    testWidgets('stays covered while revealed says so', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaSpoiler(revealed: false, onRevealedChange: changes.add, child: secret),
      );
      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(changes, <bool>[true]);
      expect(find.text('The butler did it.').hitTestable(), findsNothing);
    });

    testWidgets('covers it again when reversible', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(reversible: true, child: secret));

      expect(find.text('Hide').hitTestable(), findsNothing);

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(find.text('The butler did it.').hitTestable(), findsNothing);
      expect(find.text('Reveal').hitTestable(), findsOneWidget);
    });

    testWidgets('holds the way back open while the content is still covered', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSpoiler(reversible: true, child: Text(tall)));
      final double covered = heightOf(tester);

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(heightOf(tester), covered);
    });

    testWidgets('offers no way back when it is not reversible', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      expect(find.text('Hide'), findsNothing);
    });

    testWidgets('keeps the keyboard focus inside through a reveal and a cover', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSpoiler(reversible: true, child: secret));

      Focus.of(tester.element(find.text('Reveal'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(Focus.of(tester.element(find.text('The butler did it.'))).hasPrimaryFocus, isTrue);

      Focus.of(tester.element(find.text('Hide'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(Focus.of(tester.element(find.text('Reveal'))).hasPrimaryFocus, isTrue);
    });

    testWidgets('moves no focus that was not inside', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(Focus.of(tester.element(find.text('The butler did it.'))).hasPrimaryFocus, isFalse);
    });

    testWidgets('tells a screen reader which way each button goes', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaSpoiler(reversible: true, child: secret));

      expect(
        tester.getSemantics(find.text('Reveal')),
        matchesSemantics(
          label: 'Reveal',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasExpandedState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Hide')),
        matchesSemantics(
          label: 'Hide',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasExpandedState: true,
          isExpanded: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      handle.dispose();
    });
  });

  group('words', () {
    tearDown(resetNebaMessages);

    testWidgets('writes its label and notice in English by default', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(child: secret));

      expect(find.text('Reveal'), findsOneWidget);
      expect(find.text('This may contain spoilers'), findsOneWidget);
    });

    testWidgets('writes them in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaSpoiler(locale: Locale('ko'), child: secret));

      expect(find.text('내용 보기'), findsOneWidget);
      expect(find.text('스포일러가 포함되어 있을 수 있습니다'), findsOneWidget);
    });

    testWidgets('resolves a script subtag', (WidgetTester tester) async {
      registerNebaMessages('zh-hant', zhHant);

      await pump(
        tester,
        const NebaSpoiler(
          locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          child: secret,
        ),
      );

      expect(find.text('顯示內容'), findsOneWidget);
    });

    testWidgets('falls back to English for a language it does not know', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSpoiler(locale: Locale('xx'), child: secret));

      expect(find.text('Reveal'), findsOneWidget);
    });

    testWidgets('takes words of its own over the locale', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        const NebaSpoiler(
          locale: Locale('ko'),
          label: Text('Show the ending'),
          description: Text('Season 2, episode 6'),
          child: secret,
        ),
      );

      expect(find.text('Show the ending'), findsOneWidget);
      expect(find.text('Season 2, episode 6'), findsOneWidget);
      expect(find.text('내용 보기'), findsNothing);
    });

    testWidgets('writes nothing above the button when told not to', (WidgetTester tester) async {
      await pump(tester, const NebaSpoiler(showDescription: false, child: secret));

      expect(find.text('This may contain spoilers'), findsNothing);
      expect(find.text('Reveal'), findsOneWidget);
    });

    testWidgets('names the hide button in the same language', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaSpoiler(locale: Locale('ko'), reversible: true, child: secret));

      expect(find.text('숨기기'), findsOneWidget);
    });

    testWidgets('takes its language from the provider', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(locale: Locale('ko')),
          child: NebaSpoiler(child: secret),
        ),
      );

      expect(find.text('내용 보기'), findsOneWidget);
    });
  });

  group('action', () {
    testWidgets('replaces the default button with the one it is handed', (
      WidgetTester tester,
    ) async {
      bool revealed = false;

      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 400,
                  child: NebaSpoiler(
                    revealed: revealed,
                    action: NebaButton(
                      onPressed: () => setState(() => revealed = true),
                      child: const Text('I can take it'),
                    ),
                    child: secret,
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Reveal'), findsNothing);

      await tester.tap(find.text('I can take it'));
      await tester.pumpAndSettle();

      expect(find.text('The butler did it.').hitTestable(), findsOneWidget);
    });
  });

  group('style', () {
    testWidgets('keeps the sheet undyed and the family on the hairline', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSpoiler(color: NebaColor.warning, child: secret));

      final NebaSheet sheet = tester.widget<NebaSheet>(
        find.descendant(of: find.byType(NebaSpoiler), matching: find.byType(NebaSheet)).first,
      );

      expect(sheet.fill, tokens.panel);
      expect(sheet.edge, tokens.roles(NebaColor.warning).line);
    });

    testWidgets('draws no box for text, and still clips to its corners', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSpoiler(variant: NebaVariant.text, child: secret));

      final Finder sheets = find.descendant(
        of: find.byType(NebaSpoiler),
        matching: find.byType(NebaSheet),
      );
      // The reveal button is the only sheet left.
      expect(sheets, findsOneWidget);
      expect(
        find.ancestor(of: find.text('The butler did it.'), matching: find.byType(ClipRRect)),
        findsWidgets,
      );
    });

    testWidgets('pads the content on the box scale unless told not to', (
      WidgetTester tester,
    ) async {
      final double padding = NebaBox.padding[NebaDensity.standard]![NebaSize.md]!;

      await pump(tester, const NebaSpoiler(defaultRevealed: true, child: secret));
      expect(
        tester.getRect(find.text('The butler did it.')).top -
            tester.getRect(find.byType(NebaSpoiler)).top,
        padding + 1,
      );

      await pump(tester, const NebaSpoiler(defaultRevealed: true, padded: false, child: secret));
      expect(
        tester.getRect(find.text('The butler did it.')).top -
            tester.getRect(find.byType(NebaSpoiler)).top,
        1,
      );
    });
  });
}

/// A widget with state of its own, to see that it survives a reveal.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  Widget build(BuildContext context) => const Text('0');
}
