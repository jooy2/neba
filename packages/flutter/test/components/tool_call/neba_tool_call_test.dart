// NebaToolCall: the suite the React package runs on ToolCall, asked the way
// Flutter asks it — the header a screen reader hears as a button with the
// status in words, the panel that opens on a press and on a failure, the
// block an error replaces the result with, and the clock behind the time.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget call) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 480, child: call),
        ),
      ),
    );
  }

  Finder trigger() => find.byType(NebaFoldTrigger);

  /// The trigger's own node: the one that is a button.
  SemanticsNode header(WidgetTester tester) {
    return tester.getSemantics(
      find.descendant(of: trigger(), matching: find.byType(Semantics)).first,
    );
  }

  /// A header that can be pressed, [expanded] or not.
  Matcher live({required bool expanded}) {
    return matchesSemantics(
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      hasExpandedState: true,
      isExpanded: expanded,
      isFocusable: true,
      hasTapAction: true,
      hasFocusAction: true,
    );
  }

  /// Whether the header is heard as expanded.
  void expectExpanded(WidgetTester tester, bool expanded) {
    expect(header(tester), live(expanded: expanded));
  }

  group('rendering', () {
    testWidgets('draws the name it was given, in the monospaced face', (WidgetTester tester) async {
      await pump(tester, const NebaToolCall(name: Text('search_docs')));

      expect(find.text('search_docs'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('search_docs'))).style.fontFamily,
        NebaScale.monoFonts.first,
      );
    });

    testWidgets('says the status in words as well as in a shape', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(name: Text('search_docs'), status: NebaRunStatus.running),
      );

      expect(find.bySemanticsLabel(RegExp('Running')), findsOneWidget);
      expect(find.byType(NebaSpinner), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('draws a finished call in the success family and a failed one in danger', (
      WidgetTester tester,
    ) async {
      Color markColor() {
        return IconTheme.of(tester.element(find.byType(NebaRunMark))).color!;
      }

      await pump(
        tester,
        const NebaToolCall(name: Text('run'), status: NebaRunStatus.success, color: NebaColor.info),
      );
      expect(markColor(), tokens.roles(NebaColor.success).accent);

      await pump(
        tester,
        const NebaToolCall(name: Text('run'), status: NebaRunStatus.error, color: NebaColor.info),
      );
      expect(markColor(), tokens.roles(NebaColor.danger).accent);

      await pump(
        tester,
        const NebaToolCall(name: Text('run'), status: NebaRunStatus.running, color: NebaColor.info),
      );
      expect(markColor(), tokens.roles(NebaColor.info).accent);

      await pump(tester, const NebaToolCall(name: Text('run'), color: NebaColor.info));
      expect(markColor(), tokens.roles(NebaColor.secondary).accent);
    });

    testWidgets('names the header button after the call', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.success,
          result: Text('4 hits'),
        ),
      );

      final SemanticsNode node = header(tester);
      expect(node.label, contains('search_docs'));
      expect(node.label, contains('Finished'));
      expect(node, live(expanded: false));
      semantics.dispose();
    });

    testWidgets('follows a status that changes on rebuild', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaToolCall(name: Text('run')));
      expect(find.bySemanticsLabel(RegExp('Waiting')), findsOneWidget);

      await pump(tester, const NebaToolCall(name: Text('run'), status: NebaRunStatus.success));
      expect(find.bySemanticsLabel(RegExp('Finished')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('drops the mark with showIcon off and takes one of the caller\'s', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToolCall(name: Text('run'), showIcon: false));
      expect(find.byType(NebaRunMark), findsNothing);

      await pump(tester, const NebaToolCall(name: Text('run'), icon: Text('*')));
      expect(find.byType(NebaRunMark), findsNothing);
      expect(find.text('*'), findsOneWidget);
    });
  });

  group('the panel', () {
    testWidgets('is not a disclosure at all when there is nothing to disclose', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToolCall(name: Text('ping'), status: NebaRunStatus.success));

      expect(trigger(), findsNothing);
      expect(find.byType(NebaDisclosureChevron), findsNothing);
    });

    testWidgets('stays closed until the header is pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.success,
          args: Text("{ q: 'acrylic' }"),
          result: Text('4 hits'),
        ),
      );

      expectExpanded(tester, false);
      expect(find.text('4 hits'), findsNothing);

      await tester.tap(trigger());
      await tester.pumpAndSettle();

      expectExpanded(tester, true);
      expect(find.text('4 hits'), findsOneWidget);
      expect(find.text("{ q: 'acrylic' }"), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('closes again when the header is pressed a second time', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.success,
          result: Text('4 hits'),
          defaultOpen: true,
        ),
      );

      expect(find.text('4 hits'), findsOneWidget);

      await tester.tap(trigger());
      await tester.pumpAndSettle();

      expectExpanded(tester, false);
      expect(find.text('4 hits'), findsNothing);
      semantics.dispose();
    });

    testWidgets('keeps a closed panel built, unless keepMounted is off', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.success,
          result: Text('4 hits'),
        ),
      );

      expect(find.text('4 hits', skipOffstage: false), findsOneWidget);

      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.success,
          result: Text('4 hits'),
          keepMounted: false,
        ),
      );

      expect(find.text('4 hits', skipOffstage: false), findsNothing);
    });

    testWidgets('sets a plain Text in the groove and any other widget as it is', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('run'),
          status: NebaRunStatus.success,
          defaultOpen: true,
          args: Text('{ "a": 1 }'),
          result: Text.rich(TextSpan(text: '4 rows')),
        ),
      );

      expect(
        find.ancestor(of: find.text('{ "a": 1 }'), matching: find.byType(NebaPreformatted)),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: find.text('4 rows'), matching: find.byType(NebaPreformatted)),
        findsNothing,
      );
    });

    testWidgets('shows the error in place of the result when the call failed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.error,
          result: Text('4 hits'),
          error: Text('Rate limit exceeded'),
          defaultOpen: true,
        ),
      );

      expect(find.text('Rate limit exceeded'), findsOneWidget);
      expect(find.text('4 hits', skipOffstage: false), findsNothing);
      expect(
        tester.widget<Text>(find.text('Rate limit exceeded')).style?.color,
        tokens.roles(NebaColor.danger).accent,
      );
    });

    // It sat under the heading "Result", which said the call had come back
    // with something.
    testWidgets('heads an error with the word a failed status is read as', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.error,
          error: Text('Rate limit exceeded'),
          defaultOpen: true,
        ),
      );

      expect(find.text('FAILED'), findsOneWidget);
      expect(find.text('RESULT'), findsNothing);
    });

    testWidgets('keeps "Result" over a failed call that has no error of its own', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('search_docs'),
          status: NebaRunStatus.error,
          result: Text('HTTP 500'),
          defaultOpen: true,
        ),
      );

      expect(find.text('RESULT'), findsOneWidget);
    });

    testWidgets('reads a heading as its word rather than its capitals', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(
          name: Text('run'),
          status: NebaRunStatus.success,
          result: Text('ok'),
          defaultOpen: true,
        ),
      );

      expect(find.bySemanticsLabel('Result'), findsOneWidget);
      semantics.dispose();
    });

    // A reader should not have to go looking for the reason something did
    // not work, which is the one case the component decides for itself.
    testWidgets('opens itself when a running call fails', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(
          name: Text('deploy'),
          status: NebaRunStatus.running,
          args: Text("{ env: 'prod' }"),
        ),
      );

      expectExpanded(tester, false);

      await pump(
        tester,
        const NebaToolCall(
          name: Text('deploy'),
          status: NebaRunStatus.error,
          args: Text("{ env: 'prod' }"),
          error: Text('No such environment'),
        ),
      );
      await tester.pumpAndSettle();

      expectExpanded(tester, true);
      expect(find.text('No such environment'), findsOneWidget);

      // Closed again by the reader, it stays closed through the next build.
      await tester.tap(trigger());
      await tester.pumpAndSettle();
      await pump(
        tester,
        const NebaToolCall(
          name: Text('deploy'),
          status: NebaRunStatus.error,
          args: Text("{ env: 'prod' }"),
          error: Text('No such environment'),
        ),
      );
      await tester.pumpAndSettle();

      expectExpanded(tester, false);
      semantics.dispose();
    });

    testWidgets('leaves a controlled tool call where its caller put it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaToolCall(
          name: const Text('deploy'),
          status: NebaRunStatus.running,
          args: const Text("{ env: 'prod' }"),
          open: false,
          onOpenChange: changes.add,
        ),
      );
      await pump(
        tester,
        NebaToolCall(
          name: const Text('deploy'),
          status: NebaRunStatus.error,
          args: const Text("{ env: 'prod' }"),
          error: const Text('No such environment'),
          open: false,
          onOpenChange: changes.add,
        ),
      );
      await tester.pumpAndSettle();

      expectExpanded(tester, false);
      expect(find.text('No such environment'), findsNothing);
      expect(changes, isEmpty);
      semantics.dispose();
    });

    testWidgets('reports a press to its caller', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaToolCall(
          name: const Text('deploy'),
          result: const Text('done'),
          onOpenChange: changes.add,
        ),
      );
      await tester.tap(trigger());
      await tester.pumpAndSettle();

      expect(changes, <bool>[true]);
    });
  });

  group('duration', () {
    testWidgets('writes a sub-second call in milliseconds', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('ping'),
          status: NebaRunStatus.success,
          duration: Duration(milliseconds: 340),
        ),
      );

      expect(find.text('340ms'), findsOneWidget);
    });

    testWidgets('writes a longer one in seconds, to one decimal place', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('build'),
          status: NebaRunStatus.success,
          duration: Duration(milliseconds: 4200),
        ),
      );

      expect(find.text('4.2s'), findsOneWidget);
    });

    testWidgets('drops the decimal place past ten seconds', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToolCall(
          name: Text('build'),
          status: NebaRunStatus.success,
          duration: Duration(milliseconds: 247300),
        ),
      );

      expect(find.text('247s'), findsOneWidget);
    });

    testWidgets('says nothing at all when it has not been told one', (WidgetTester tester) async {
      await pump(tester, const NebaToolCall(name: Text('ping'), status: NebaRunStatus.success));

      expect(find.textContaining(RegExp(r'\d+(ms|s)$')), findsNothing);
    });

    group('counted', () {
      Duration now = Duration.zero;

      setUp(() {
        now = Duration.zero;
        debugNebaRunNow = () => now;
      });

      tearDown(() => debugNebaRunNow = null);

      Future<void> wait(WidgetTester tester, Duration step) async {
        now += step;
        await tester.pump(step);
      }

      testWidgets('counts a running call once a second, after the first', (
        WidgetTester tester,
      ) async {
        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.running));

        await wait(tester, const Duration(milliseconds: 600));
        expect(find.textContaining(RegExp(r'\d')), findsNothing);

        await wait(tester, const Duration(milliseconds: 600));
        expect(find.text('1s'), findsOneWidget);

        await wait(tester, const Duration(seconds: 1));
        expect(find.text('2s'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('measures the call once more when it ends', (WidgetTester tester) async {
        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.running));
        await wait(tester, const Duration(milliseconds: 4900));

        expect(find.text('4s'), findsOneWidget);

        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.success));

        expect(find.text('4.9s'), findsOneWidget);
      });

      testWidgets('takes a duration that arrives over its own count', (WidgetTester tester) async {
        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.running));
        await wait(tester, const Duration(seconds: 3));

        await pump(
          tester,
          const NebaToolCall(
            name: Text('build'),
            status: NebaRunStatus.success,
            duration: Duration(milliseconds: 3180),
          ),
        );

        expect(find.text('3.2s'), findsOneWidget);
      });

      testWidgets('counts a retried call from its own start', (WidgetTester tester) async {
        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.running));
        await wait(tester, const Duration(seconds: 3));
        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.error));

        expect(find.text('3s'), findsOneWidget);

        await pump(tester, const NebaToolCall(name: Text('build'), status: NebaRunStatus.running));

        expect(find.text('3s'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      });
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets('says the status in the words it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaToolCall(
          name: Text('ping'),
          status: NebaRunStatus.running,
          labels: <String, String>{'running': 'En cours'},
        ),
      );

      expect(find.bySemanticsLabel(RegExp('En cours')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes the locale from a provider', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      registerNebaMessages(
        'de',
        const NebaLocale(<String, Map<String, String>>{
          'run': <String, String>{'success': 'Fertig'},
          'tool': <String, String>{'result': 'Ergebnis'},
        }),
      );

      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(locale: Locale('de', 'DE')),
          child: NebaToolCall(
            name: Text('build'),
            status: NebaRunStatus.success,
            result: Text('ok'),
            defaultOpen: true,
          ),
        ),
      );

      expect(find.bySemanticsLabel(RegExp('Fertig')), findsOneWidget);
      expect(find.text('ERGEBNIS'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('formatDuration', () {
    test('writes each unit the way the React package does in English', () {
      expect(nebaFormatDuration(const Duration(milliseconds: 340)), '340ms');
      expect(nebaFormatDuration(const Duration(microseconds: 999400)), '999ms');
      expect(nebaFormatDuration(const Duration(milliseconds: 4000)), '4s');
      expect(nebaFormatDuration(const Duration(milliseconds: 4250)), '4.3s');
      expect(nebaFormatDuration(const Duration(milliseconds: 12400)), '12s');
      expect(nebaFormatDuration(const Duration(seconds: 1234)), '1,234s');
    });
  });
}
