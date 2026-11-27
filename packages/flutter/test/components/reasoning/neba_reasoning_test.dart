// NebaReasoning: the suite the React package runs on Reasoning, asked the way
// Flutter asks it — the sentence the header button is named by, the clock
// that times the stream, and the panel the stream opens and closes without
// overruling a reader who moved it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/glyphs.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget reasoning) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 480, child: reasoning),
        ),
      ),
    );
  }

  /// Builds [reasoning] and lets the panel finish moving. Not a settle: the
  /// mark turns for as long as the stream runs.
  Future<void> settle(WidgetTester tester, Widget reasoning) async {
    await pump(tester, reasoning);
    await tester.pump(const Duration(milliseconds: 400));
  }

  const Widget thought = Text('Weighing two options.');

  Finder trigger() => find.byType(NebaFoldTrigger);

  /// A header that can be pressed, named [label], [expanded] or not.
  Matcher live({required bool expanded, String? label}) {
    return matchesSemantics(
      label: label,
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

  void expectHeader(WidgetTester tester, {required bool expanded, String? label}) {
    expect(
      tester.getSemantics(find.descendant(of: trigger(), matching: find.byType(Semantics)).first),
      live(expanded: expanded, label: label),
    );
  }

  /// Whether the thinking is on screen, rather than built and folded away.
  bool shown() => find.text('Weighing two options.').evaluate().isNotEmpty;

  group('the header', () {
    testWidgets('says it is thinking while the stream runs', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(streaming: true, child: thought));

      expectHeader(tester, expanded: true, label: 'Thinking…');
      expect(find.byType(NebaSpinner), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('reports how long it took once the stream has stopped', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(
        tester,
        const NebaReasoning(duration: Duration(milliseconds: 4200), child: thought),
      );

      expectHeader(tester, expanded: false, label: 'Thought for 4.2s');
      expect(find.byType(NebaSpinner), findsNothing);
      semantics.dispose();
    });

    testWidgets('says so in words when nothing timed it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(child: thought));

      expectHeader(tester, expanded: false, label: 'Finished thinking');
      semantics.dispose();
    });

    testWidgets('takes a label of its own over any of them', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(
        tester,
        const NebaReasoning(streaming: true, label: Text('Planning the change'), child: thought),
      );

      expectHeader(tester, expanded: true, label: 'Planning the change');
      semantics.dispose();
    });

    testWidgets('draws the header muted, on the sheet title ladder', (WidgetTester tester) async {
      await settle(tester, const NebaReasoning(size: NebaSize.lg, child: thought));

      final TextStyle style = DefaultTextStyle.of(
        tester.element(find.text('Finished thinking')),
      ).style;
      expect(style.fontSize, NebaScale.sheetTitleText[NebaSize.lg]);
      expect(style.color, tokens.mutedFg);
    });
  });

  group('its clock', () {
    Duration now = Duration.zero;

    setUp(() {
      now = Duration.zero;
      debugNebaRunNow = () => now;
    });

    tearDown(() => debugNebaRunNow = null);

    Future<String?> thinkFor(WidgetTester tester, Duration spent) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(streaming: true, child: thought));
      now += spent;
      await tester.pump(spent);
      await settle(tester, const NebaReasoning(child: thought));

      final String label = tester
          .getSemantics(find.descendant(of: trigger(), matching: find.byType(Semantics)).first)
          .label;
      semantics.dispose();

      return label;
    }

    // The clock ticks once a second, and the total was whichever tick came
    // last: 4.9 seconds read "4s".
    testWidgets('reports the time it took rather than the last whole second', (
      WidgetTester tester,
    ) async {
      expect(await thinkFor(tester, const Duration(milliseconds: 4900)), 'Thought for 4.9s');
    });

    // And a run shorter than the first tick said nothing at all.
    testWidgets('reports a run under a second', (WidgetTester tester) async {
      expect(await thinkFor(tester, const Duration(milliseconds: 900)), 'Thought for 900ms');
    });

    // The heading says "Thinking" until the stream ends, so a clock counting
    // the seconds would rebuild the whole panel for a number not on screen.
    testWidgets('keeps no timer while it thinks', (WidgetTester tester) async {
      await settle(tester, const NebaReasoning(streaming: true, child: thought));

      expect(find.byType(NebaRunTime), findsNothing);
    });
  });

  group('the panel', () {
    testWidgets('is closed before any stream has run', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(child: thought));

      expectHeader(tester, expanded: false);
      expect(shown(), isFalse);
      semantics.dispose();
    });

    testWidgets('keeps a closed panel built, unless keepMounted is off', (
      WidgetTester tester,
    ) async {
      await settle(tester, const NebaReasoning(child: thought));
      expect(find.text('Weighing two options.', skipOffstage: false), findsOneWidget);

      await settle(tester, const NebaReasoning(keepMounted: false, child: thought));
      expect(find.text('Weighing two options.', skipOffstage: false), findsNothing);
    });

    testWidgets('opens when the stream starts', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(child: thought));
      await settle(tester, const NebaReasoning(streaming: true, child: thought));

      expectHeader(tester, expanded: true);
      expect(shown(), isTrue);
      semantics.dispose();
    });

    testWidgets('shows what the stream adds while it is open', (WidgetTester tester) async {
      await settle(tester, const NebaReasoning(streaming: true, child: Text('Weighing')));
      await settle(tester, const NebaReasoning(streaming: true, child: thought));

      expect(shown(), isTrue);
    });

    testWidgets('folds itself away when the stream ends', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(streaming: true, child: thought));
      expect(shown(), isTrue);

      await settle(
        tester,
        const NebaReasoning(duration: Duration(milliseconds: 900), child: thought),
      );

      expectHeader(tester, expanded: false);
      expect(shown(), isFalse);
      semantics.dispose();
    });

    // A panel that folds itself away moves the answer under it up the page
    // with nobody having pressed anything.
    testWidgets('stays open after the stream ends when autoClose is off', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(streaming: true, autoClose: false, child: thought));
      expectHeader(tester, expanded: true);

      await settle(
        tester,
        const NebaReasoning(
          duration: Duration(milliseconds: 900),
          autoClose: false,
          child: thought,
        ),
      );

      expectHeader(tester, expanded: true, label: 'Thought for 900ms');
      expect(shown(), isTrue);
      semantics.dispose();
    });

    testWidgets('still opens when the stream starts with autoClose off', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(autoClose: false, child: thought));
      await settle(tester, const NebaReasoning(streaming: true, autoClose: false, child: thought));

      expectHeader(tester, expanded: true);
      semantics.dispose();
    });

    testWidgets('closes when the reader presses it after the stream with autoClose off', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(streaming: true, autoClose: false, child: thought));
      await settle(tester, const NebaReasoning(autoClose: false, child: thought));
      await tester.tap(trigger());
      await tester.pump(const Duration(milliseconds: 400));

      expectHeader(tester, expanded: false);
      semantics.dispose();
    });

    testWidgets('stays where the reader put it when autoOpen is off', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(tester, const NebaReasoning(autoOpen: false, child: thought));
      await settle(tester, const NebaReasoning(autoOpen: false, streaming: true, child: thought));

      expectHeader(tester, expanded: false);
      expect(shown(), isFalse);
      semantics.dispose();
    });

    // A reader who folds it mid-stream is not overruled by the next token.
    testWidgets('stays folded when the reader folds it mid-stream', (WidgetTester tester) async {
      await settle(tester, const NebaReasoning(streaming: true, child: Text('Weighing')));
      await tester.tap(trigger());
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester, const NebaReasoning(streaming: true, child: thought));

      expect(shown(), isFalse);
    });

    testWidgets('leaves a controlled Reasoning where its caller put it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await settle(tester, NebaReasoning(open: false, onOpenChange: changes.add, child: thought));
      await settle(
        tester,
        NebaReasoning(open: false, onOpenChange: changes.add, streaming: true, child: thought),
      );

      expectHeader(tester, expanded: false);
      expect(shown(), isFalse);
      expect(changes, isEmpty);
      semantics.dispose();
    });

    // The stream moves an uncontrolled panel on its own, and that is not a
    // change the caller has to be told about.
    testWidgets('does not report a panel the stream opened and closed', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await settle(tester, NebaReasoning(onOpenChange: changes.add, child: thought));
      await settle(
        tester,
        NebaReasoning(onOpenChange: changes.add, streaming: true, child: thought),
      );
      expect(shown(), isTrue);

      await settle(tester, NebaReasoning(onOpenChange: changes.add, child: thought));
      expect(shown(), isFalse);
      expect(changes, isEmpty);
    });

    testWidgets('answers a press whichever way the stream left it', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await settle(tester, NebaReasoning(onOpenChange: changes.add, child: thought));
      await tester.tap(trigger());
      await tester.pump(const Duration(milliseconds: 400));

      expect(changes, <bool>[true]);
      expect(shown(), isTrue);
    });

    testWidgets('rules the inside edge of the panel in the family', (WidgetTester tester) async {
      await settle(
        tester,
        const NebaReasoning(color: NebaColor.info, defaultOpen: true, child: thought),
      );

      final Container body = tester.widget<Container>(
        find
            .ancestor(of: find.text('Weighing two options.'), matching: find.byType(Container))
            .first,
      );
      final BoxDecoration decoration = body.decoration! as BoxDecoration;
      final BorderDirectional border = decoration.border! as BorderDirectional;

      expect(border.start.width, 2);
      expect(border.start.color, tokens.roles(NebaColor.info).line);
    });
  });

  group('rendering', () {
    testWidgets('lets a caller write its sentences out', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await settle(
        tester,
        const NebaReasoning(
          streaming: true,
          labels: <String, String>{'thinking': 'Réflexion…'},
          child: thought,
        ),
      );

      expectHeader(tester, expanded: true, label: 'Réflexion…');
      semantics.dispose();
    });

    testWidgets('fills the duration into a sentence of the caller\'s', (WidgetTester tester) async {
      await settle(
        tester,
        const NebaReasoning(
          duration: Duration(milliseconds: 2400),
          labels: <String, String>{'thought': '{duration} spent'},
          child: thought,
        ),
      );

      expect(find.text('2.4s spent'), findsOneWidget);
    });
  });
}
