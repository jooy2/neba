// NebaAnimateScramble: a line settling out of noise a character at a time,
// as the React package's AnimateScramble test carries it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// What the line shows: each word's noise where it has not settled, and the
/// word itself where it has, with the spaces between them.
String _shown(WidgetTester tester) {
  final RichText line = tester.widget<RichText>(
    find.descendant(of: find.byType(NebaAnimateScramble), matching: find.byType(RichText)).first,
  );
  final StringBuffer shown = StringBuffer();

  line.text.visitChildren((InlineSpan span) {
    if (span is WidgetSpan) {
      // A word is its text once it has settled, and the finished word laid
      // out unseen under its noise until then: what shows is the last.
      final Finder texts = find.descendant(
        of: find.byWidget(span.child),
        matching: find.byType(Text),
      );

      shown.write(tester.widget<Text>(texts.last).data);
    } else if (span is TextSpan && span.text != null) {
      shown.write(span.text);
    }

    return true;
  });

  return shown.toString();
}

void main() {
  testWidgets('tells a screen reader the finished text, and none of the noise', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await _pump(tester, const NebaAnimateScramble(text: 'HELLO WORLD'));

    expect(find.bySemanticsLabel('HELLO WORLD'), findsOneWidget);
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('lays its box out from the finished text from the first frame', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const NebaAnimateScramble(
        text: 'AB CD',
        trigger: NebaAnimateTrigger.manual,
        style: TextStyle(fontSize: 10),
      ),
    );

    expect(tester.getSize(find.byType(NebaAnimateScramble)), const Size(50, 10));
  });

  testWidgets('is the finished length from the first frame, and never scrambles a space', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateScramble(text: 'ab cd  e'));

    final String first = _shown(tester);

    expect(first.length, 'ab cd  e'.length);
    expect(first[2], ' ');
    expect(first.substring(5, 7), '  ');

    await tester.pumpAndSettle();
  });

  testWidgets('settles every letter at a speed that does not divide a second', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateScramble(text: 'ABCDEFG', speed: 13, characters: '#'));
    await tester.pumpAndSettle();

    expect(_shown(tester), 'ABCDEFG');
  });

  testWidgets('settles one letter at a time from the left, at its speed', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateScramble(text: 'ABCD', speed: 10, characters: '#'));

    expect(_shown(tester), '####');
    await tester.pump(const Duration(milliseconds: 100));
    expect(_shown(tester), 'A###');
    await tester.pump(const Duration(milliseconds: 200));
    expect(_shown(tester), 'ABC#');
    await tester.pump(const Duration(milliseconds: 100));
    expect(_shown(tester), 'ABCD');
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('takes a duration as the whole run', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateScramble(text: 'ABCD', duration: Duration(seconds: 4), characters: '#'),
    );

    await tester.pump(const Duration(seconds: 2));
    expect(_shown(tester), 'AB##');

    await tester.pumpAndSettle();
  });

  testWidgets('waits out its delay before the first letter settles', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateScramble(
        text: 'AB',
        speed: 10,
        delay: Duration(milliseconds: 500),
        characters: '#',
      ),
    );

    await tester.pump(const Duration(milliseconds: 550));
    expect(_shown(tester), '##');
    await tester.pump(const Duration(milliseconds: 50));
    expect(_shown(tester), 'A#');

    await tester.pumpAndSettle();
  });

  testWidgets('draws the noise from the pool it was given, and redraws it on every tick', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const NebaAnimateScramble(text: 'ABCDEFGH', speed: 1, characters: '01'));

    final String first = _shown(tester);

    expect(first, matches(RegExp(r'^[01]{8}$')));

    await tester.pump(const Duration(milliseconds: 45));
    final String second = _shown(tester);

    expect(second, matches(RegExp(r'^[01]{8}$')));
    expect(second, isNot(first));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('draws the same noise again on a build that is not a tick', (
    WidgetTester tester,
  ) async {
    Widget scramble(Color color) {
      return NebaAnimateScramble(
        text: 'ABCDEFGH',
        speed: 1,
        style: TextStyle(color: color),
      );
    }

    await _pump(tester, scramble(const Color(0xff000000)));
    await tester.pump(const Duration(milliseconds: 100));
    final String before = _shown(tester);

    await _pump(tester, scramble(const Color(0xff111111)));
    expect(_shown(tester), before);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('draws a word that has settled as the word itself', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateScramble(text: 'AB CD', speed: 10));
    await tester.pump(const Duration(milliseconds: 200));

    // The first word has settled and has nothing laid over it.
    expect(
      find.descendant(of: find.byType(NebaAnimateScramble), matching: find.byType(Stack)),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(NebaAnimateScramble), matching: find.byType(Stack)),
      findsNothing,
    );
  });

  testWidgets('picks up where it was paused rather than starting over', (
    WidgetTester tester,
  ) async {
    Widget scramble({required bool paused}) {
      return NebaAnimateScramble(text: 'ABCD', speed: 10, characters: '#', paused: paused);
    }

    await _pump(tester, scramble(paused: false));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_shown(tester), 'AB##');

    await _pump(tester, scramble(paused: true));
    await tester.pump(const Duration(seconds: 1));
    expect(_shown(tester), 'AB##');

    await _pump(tester, scramble(paused: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_shown(tester), 'ABC#');

    await tester.pumpAndSettle();
  });

  testWidgets('scrambles the text again when play goes up', (WidgetTester tester) async {
    Widget scramble(int play) {
      return NebaAnimateScramble(
        text: 'AB',
        trigger: NebaAnimateTrigger.manual,
        play: play,
        speed: 10,
        characters: '#',
      );
    }

    await _pump(tester, scramble(1));
    await tester.pumpAndSettle();
    expect(_shown(tester), 'AB');

    await _pump(tester, scramble(2));
    expect(_shown(tester), '##');

    await tester.pumpAndSettle();
    expect(_shown(tester), 'AB');
  });

  testWidgets('holds its noise still until it is triggered', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateScramble(text: 'ABCD', trigger: NebaAnimateTrigger.manual),
    );

    final String waiting = _shown(tester);

    await tester.pump(const Duration(seconds: 1));
    expect(_shown(tester), waiting);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('settles a new text from its first letter', (WidgetTester tester) async {
    await _pump(tester, const NebaAnimateScramble(text: 'AB', speed: 10, characters: '#'));
    await tester.pumpAndSettle();

    await _pump(tester, const NebaAnimateScramble(text: 'CD', speed: 10, characters: '#'));
    expect(_shown(tester), '##');

    await tester.pumpAndSettle();
    expect(_shown(tester), 'CD');
  });

  testWidgets('shows the text itself, untriggered, under less motion', (WidgetTester tester) async {
    await _pump(
      tester,
      const NebaAnimateScramble(text: 'AB CD', trigger: NebaAnimateTrigger.manual),
      disableAnimations: true,
    );

    expect(_shown(tester), 'AB CD');
    expect(tester.hasRunningAnimations, isFalse);
  });
}
