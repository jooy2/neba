// NebaAnimateTyping: a line typed a character at a time, as the React
// package's AnimateTyping test carries it.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget widget, {bool disableAnimations = false}) {
  return tester.pumpWidget(host(Center(child: widget), disableAnimations: disableAnimations));
}

/// The paragraph that is typed into: the first one not inside the finished
/// line, which is laid out unseen beneath it.
Finder _typedLine() {
  return find
      .descendant(
        of: find.byType(NebaAnimateTyping),
        matching: find.byElementPredicate((Element line) {
          bool hidden = false;

          if (line.widget is! RichText) {
            return false;
          }

          line.visitAncestorElements((Element ancestor) {
            hidden = ancestor.widget is Visibility;

            return !hidden && ancestor.widget is! NebaAnimateTyping;
          });

          return !hidden;
        }),
      )
      .first;
}

/// What has been typed so far.
String _typed(WidgetTester tester) {
  return tester.widget<RichText>(_typedLine()).text.toPlainText(includePlaceholders: false);
}

const Duration _minute = Duration(minutes: 1);

void main() {
  group('rendering', () {
    testWidgets('tells a screen reader the whole line straight away, and nothing typed', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await _pump(tester, const NebaAnimateTyping(text: 'Hello there'));

      expect(find.bySemanticsLabel('Hello there'), findsOneWidget);
      expect(find.bySemanticsLabel('H'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    });

    testWidgets('lays its box out from the whole line before anything is typed', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateTyping(
          text: 'Hello',
          trigger: NebaAnimateTrigger.manual,
          caret: false,
          style: TextStyle(fontSize: 10),
        ),
      );

      expect(_typed(tester), '');
      expect(tester.getSize(find.byType(NebaAnimateTyping)), const Size(50, 10));
    });

    testWidgets('lays the typed line out with the room the finished one had', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateTyping(text: 'Hello', caret: false, style: TextStyle(fontSize: 10)),
      );
      await tester.pumpAndSettle();

      // Laid out at exactly its own width, a line could break before its
      // last character; it is laid out against the room the finished line
      // was, and at least as wide as that one.
      final RenderParagraph typed = tester.renderObject<RenderParagraph>(_typedLine());

      expect(typed.constraints.maxWidth, 800);
      expect(typed.constraints.minWidth, 50);
      expect(typed.size, const Size(50, 10));
    });

    testWidgets('leaves room at the end of the line for its caret', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateTyping(
          text: 'Hello',
          trigger: NebaAnimateTrigger.manual,
          style: TextStyle(fontSize: 10),
        ),
      );

      expect(tester.getSize(find.byType(NebaAnimateTyping)), const Size(60, 10));
    });

    testWidgets('draws a caret unless told not to, and the one it is given', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateTyping(text: 'Hi'));
      // The finished line's and the typed line's.
      expect(find.text('|'), findsNWidgets(2));

      await _pump(tester, const NebaAnimateTyping(text: 'Hi', caret: false));
      expect(find.text('|'), findsNothing);

      await _pump(
        tester,
        const NebaAnimateTyping(
          text: 'Hi',
          caretChar: SizedBox(key: Key('block'), width: 6, height: 12),
        ),
      );
      expect(find.byKey(const Key('block')), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('blinks the caret on for a little over half of every second', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateTyping(text: 'Hi', speed: 1000));

      double caret() {
        return tester
            .widget<Opacity>(
              find.ancestor(of: find.text('|').last, matching: find.byType(Opacity)).first,
            )
            .opacity;
      }

      await tester.pump(const Duration(milliseconds: 500));
      expect(caret(), 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(caret(), 0);
      await tester.pump(const Duration(milliseconds: 450));
      expect(caret(), 1);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('typing', () {
    testWidgets('types a character at a time at its speed, and gets to the end', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const NebaAnimateTyping(text: 'Hello', speed: 10, caret: false));

      expect(_typed(tester), 'H');
      await tester.pump(const Duration(milliseconds: 100));
      expect(_typed(tester), 'He');
      await tester.pump(const Duration(milliseconds: 300));
      expect(_typed(tester), 'Hello');
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('ends on the whole line at a speed that does not divide a second', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateTyping(
          text: r'$ npm run dev',
          speed: 26,
          delay: Duration(milliseconds: 900),
          caret: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(_typed(tester), r'$ npm run dev');
    });

    testWidgets('takes a duration as the time for the whole line', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateTyping(text: 'Hello', duration: Duration(seconds: 5), caret: false),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(_typed(tester), 'Hel');

      await tester.pumpAndSettle();
    });

    testWidgets('waits out its delay before the first character', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateTyping(text: 'Hello', delay: Duration(milliseconds: 900), caret: false),
      );

      expect(_typed(tester), '');
      await tester.pump(const Duration(milliseconds: 899));
      expect(_typed(tester), '');
      await tester.pump(const Duration(milliseconds: 1));
      expect(_typed(tester), 'H');

      await tester.pumpAndSettle();
    });

    testWidgets('shows nothing at all before it is triggered', (WidgetTester tester) async {
      Widget typing({Object? play}) {
        return NebaAnimateTyping(
          text: 'Hello',
          trigger: NebaAnimateTrigger.manual,
          play: play,
          speed: 200,
          caret: false,
        );
      }

      await _pump(tester, typing());
      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), '');

      await _pump(tester, typing(play: true));
      await tester.pumpAndSettle();
      expect(_typed(tester), 'Hello');
    });

    testWidgets('types the line again when play goes up', (WidgetTester tester) async {
      Widget typing(int play) {
        return NebaAnimateTyping(
          text: 'Hello',
          trigger: NebaAnimateTrigger.manual,
          play: play,
          duration: _minute * 5,
          caret: false,
        );
      }

      await _pump(tester, typing(1));
      await tester.pumpAndSettle();
      expect(_typed(tester), 'Hello');

      await _pump(tester, typing(2));
      expect(_typed(tester), 'H');
      await tester.pump(_minute);
      expect(_typed(tester), 'He');

      await tester.pumpAndSettle();
    });

    testWidgets('holds, erases and types again, and stops on its last pass', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateTyping(
          text: 'ab',
          duration: Duration(seconds: 2),
          hold: Duration(seconds: 1),
          eraseSpeed: 1,
          repeat: 2,
          erase: true,
          caret: false,
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), 'ab');

      // The hold, then a character deleted a second.
      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), 'a');
      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), '');

      // The second pass, a step later.
      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), 'a');
      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), 'ab');

      // The last pass is not deleted.
      await tester.pump(const Duration(seconds: 10));
      expect(_typed(tester), 'ab');
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('clears in one frame between passes without erase', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateTyping(
          text: 'ab',
          duration: Duration(seconds: 2),
          hold: Duration(seconds: 1),
          repeat: 2,
          caret: false,
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(_typed(tester), '');
      await tester.pump(const Duration(seconds: 1));
      expect(_typed(tester), 'a');

      await tester.pumpAndSettle();
    });

    testWidgets('keeps count of its passes across a pause', (WidgetTester tester) async {
      Widget typing({required bool paused}) {
        return NebaAnimateTyping(
          text: 'ab',
          duration: _minute * 2,
          hold: _minute,
          repeat: 2,
          erase: true,
          paused: paused,
          caret: false,
        );
      }

      await _pump(tester, typing(paused: false));
      await tester.pump(_minute);
      expect(_typed(tester), 'ab');

      await tester.pump(_minute + const Duration(seconds: 1));
      expect(_typed(tester), '');

      await _pump(tester, typing(paused: true));
      await tester.pump(_minute * 10);
      expect(_typed(tester), '');

      await _pump(tester, typing(paused: false));
      await tester.pump(_minute * 2);
      expect(_typed(tester), 'ab');

      // The second pass is the last, so nothing is deleted after its hold.
      await tester.pump(_minute * 2);
      expect(_typed(tester), 'ab');
    });

    testWidgets('types a new line from its start', (WidgetTester tester) async {
      await _pump(tester, const NebaAnimateTyping(text: 'abc', speed: 200, caret: false));
      await tester.pumpAndSettle();
      expect(_typed(tester), 'abc');

      await _pump(
        tester,
        const NebaAnimateTyping(text: 'xyz', duration: Duration(minutes: 3), caret: false),
      );
      expect(_typed(tester), 'x');

      await tester.pumpAndSettle();
    });

    testWidgets('advances by characters a reader counts rather than by code points', (
      WidgetTester tester,
    ) async {
      const String line = '한글 👩\u200D👩\u200D👧 ok';
      const List<String> frames = <String>[
        '한',
        '한글',
        '한글 ',
        '한글 👩\u200D👩\u200D👧',
        '한글 👩\u200D👩\u200D👧 ',
        '한글 👩\u200D👩\u200D👧 o',
        line,
      ];

      await _pump(
        tester,
        NebaAnimateTyping(text: line, duration: _minute * frames.length, caret: false),
      );

      for (int index = 0; index < frames.length; index++) {
        if (index > 0) {
          await tester.pump(_minute);
        }

        expect(_typed(tester), frames[index]);
      }
    });

    testWidgets('types under the pointer, and empties when an endless one is left', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const NebaAnimateTyping(
          text: 'Hello',
          trigger: NebaAnimateTrigger.hover,
          repeat: double.infinity,
          caret: false,
        ),
      );
      expect(_typed(tester), '');

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(find.byType(NebaAnimateTyping)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_typed(tester), isNotEmpty);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(_typed(tester), '');
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('less motion', () {
    testWidgets('shows the line itself, before any trigger too', (WidgetTester tester) async {
      await _pump(
        tester,
        const NebaAnimateTyping(text: 'Hello', trigger: NebaAnimateTrigger.manual),
        disableAnimations: true,
      );

      expect(_typed(tester), 'Hello');
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
