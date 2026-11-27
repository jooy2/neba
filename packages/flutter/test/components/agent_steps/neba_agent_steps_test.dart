// NebaAgentSteps: the suite the React package runs on AgentSteps, asked the
// way Flutter asks it — a list a screen reader hears with each step's status
// in words, the running step selected, a marker for what is still to come
// with a clock of its own, and the families the statuses are drawn in.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/glyphs.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget steps) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 480, child: steps),
        ),
      ),
    );
  }

  /// The colour a step's mark is drawn in.
  Color markColor(WidgetTester tester, {int at = 0}) {
    return IconTheme.of(tester.element(find.byType(NebaRunMark).at(at))).color!;
  }

  Finder rails() {
    return find.descendant(
      of: find.byType(NebaAgentStep),
      matching: find.byType(PositionedDirectional),
    );
  }

  group('rendering', () {
    testWidgets('is a list of the steps it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Read the request')),
            NebaAgentStep(title: Text('Search the docs'), status: NebaRunStatus.running),
          ],
        ),
      );

      expect(find.text('Read the request'), findsOneWidget);
      expect(find.text('Search the docs'), findsOneWidget);
      expect(
        tester
            .getSemantics(
              find
                  .descendant(of: find.byType(NebaAgentSteps), matching: find.byType(Semantics))
                  .first,
            )
            .getSemanticsData()
            .role,
        SemanticsRole.list,
      );
      semantics.dispose();
    });

    testWidgets("says each step's status in words", (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Read the request')),
            NebaAgentStep(title: Text('Search the docs'), status: NebaRunStatus.error),
          ],
        ),
      );

      expect(find.bySemanticsLabel(RegExp('^Finished')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Failed')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('marks the step that is happening now', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Read the request')),
            NebaAgentStep(title: Text('Search the docs'), status: NebaRunStatus.running),
          ],
        ),
      );

      final SemanticsNode current = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Search the docs')),
      );
      final SemanticsData data = current.getSemanticsData();
      expect(data.role, SemanticsRole.listItem);
      expect(data.label, 'Running\nSearch the docs');
      expect(
        current,
        matchesSemantics(label: data.label, hasSelectedState: true, isSelected: true),
      );
      semantics.dispose();
    });

    testWidgets('holds whatever a step did under its title', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Search the docs'), child: Text('query: acrylic surface')),
          ],
        ),
      );

      expect(find.text('query: acrylic surface'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('query: acrylic surface')).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.text('Search the docs')).dy),
      );
    });

    testWidgets('renders on its own outside a chain', (WidgetTester tester) async {
      await pump(tester, const NebaAgentStep(title: Text('On its own')));

      expect(find.text('On its own'), findsOneWidget);
      expect(rails(), findsNothing);
    });

    testWidgets('runs a rail from every step but the last', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('One')),
            NebaAgentStep(title: Text('Two')),
            NebaAgentStep(title: Text('Three')),
          ],
        ),
      );

      expect(rails(), findsNWidgets(2));
    });

    testWidgets('inks the title by status', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Done')),
            NebaAgentStep(title: Text('Now'), status: NebaRunStatus.running),
            NebaAgentStep(title: Text('Later'), status: NebaRunStatus.pending),
          ],
        ),
      );

      Color? ink(String text) => DefaultTextStyle.of(tester.element(find.text(text))).style.color;

      expect(ink('Done'), tokens.fg);
      expect(ink('Now'), tokens.roles(NebaColor.primary).accent);
      expect(ink('Later'), tokens.mutedFg);
    });
  });

  group('growing', () {
    testWidgets('takes a step that was appended after the first build', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAgentSteps(children: <Widget>[NebaAgentStep(title: Text('Read the request'))]),
      );
      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Read the request')),
            NebaAgentStep(title: Text('Search the docs'), status: NebaRunStatus.running),
          ],
        ),
      );

      expect(find.text('Search the docs'), findsOneWidget);
      expect(rails(), findsOneWidget);
    });

    // The step has no name yet, which is the whole reason it is an argument
    // of the chain rather than one more step.
    testWidgets('draws one more marker while there is more to come', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaAgentSteps(
          running: true,
          children: <Widget>[NebaAgentStep(title: Text('Read the request'))],
        ),
      );

      expect(find.byType(NebaAgentStep), findsNWidgets(2));
      expect(find.byType(NebaSpinner), findsOneWidget);
      // No visible label: the turning ring has said it, and the status is
      // read out.
      expect(find.bySemanticsLabel('Running'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('labels that marker with whatever it was handed', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          running: true,
          runningTitle: Text('Deciding what to do next'),
          children: <Widget>[NebaAgentStep(title: Text('Read the request'))],
        ),
      );

      expect(find.text('Deciding what to do next'), findsOneWidget);
    });

    group('clock', () {
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

      // The marker stands for whichever step is under way. Kept as steps
      // were appended in front of it, it went on counting from the first.
      testWidgets("starts the marker's clock again for each step it stands for", (
        WidgetTester tester,
      ) async {
        await pump(
          tester,
          const NebaAgentSteps(
            running: true,
            children: <Widget>[NebaAgentStep(title: Text('Read the request'))],
          ),
        );
        await wait(tester, const Duration(seconds: 5));

        expect(find.text('5s'), findsOneWidget);

        await pump(
          tester,
          const NebaAgentSteps(
            running: true,
            children: <Widget>[
              NebaAgentStep(title: Text('Read the request')),
              NebaAgentStep(title: Text('Search the docs'), duration: Duration(seconds: 5)),
            ],
          ),
        );
        await wait(tester, const Duration(seconds: 2));

        expect(find.text('2s'), findsOneWidget);
        expect(find.text('5s'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      });
    });

    testWidgets('draws nothing extra when the chain has finished', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(children: <Widget>[NebaAgentStep(title: Text('Read the request'))]),
      );

      expect(find.byType(NebaAgentStep), findsOneWidget);
      expect(rails(), findsNothing);
    });
  });

  group('duration', () {
    testWidgets('writes the time a step took', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          children: <Widget>[
            NebaAgentStep(title: Text('Search the docs'), duration: Duration(milliseconds: 1500)),
          ],
        ),
      );

      expect(find.text('1.5s'), findsOneWidget);
    });

    testWidgets('says nothing when it was not told one', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(children: <Widget>[NebaAgentStep(title: Text('Search the docs'))]),
      );

      expect(find.textContaining(RegExp(r'\d')), findsNothing);
    });
  });

  group('colour', () {
    testWidgets('gives a failed step the danger family whatever the chain says', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAgentSteps(
          color: NebaColor.info,
          children: <Widget>[
            NebaAgentStep(title: Text('Search the docs'), status: NebaRunStatus.error),
          ],
        ),
      );

      expect(markColor(tester), tokens.roles(NebaColor.danger).accent);
    });

    testWidgets("gives a running step the chain's own", (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          color: NebaColor.info,
          children: <Widget>[
            NebaAgentStep(title: Text('Search the docs'), status: NebaRunStatus.running),
          ],
        ),
      );

      expect(markColor(tester), tokens.roles(NebaColor.info).accent);
    });

    testWidgets("lets a step's own colour win over the chain's", (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          color: NebaColor.info,
          children: <Widget>[
            NebaAgentStep(
              title: Text('Search the docs'),
              status: NebaRunStatus.running,
              color: NebaColor.warning,
            ),
          ],
        ),
      );

      expect(markColor(tester), tokens.roles(NebaColor.warning).accent);
    });
  });

  group('labels', () {
    testWidgets('reads a status in the words it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaAgentSteps(
          labels: <String, String>{'success': 'Fait'},
          children: <Widget>[NebaAgentStep(title: Text('Read the request'))],
        ),
      );

      expect(find.bySemanticsLabel(RegExp('^Fait')), findsOneWidget);
      semantics.dispose();
    });
  });

  group('size', () {
    testWidgets('sizes the mark on the tick ladder', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAgentSteps(
          size: NebaSize.lg,
          children: <Widget>[NebaAgentStep(title: Text('Read the request'))],
        ),
      );

      expect(tester.getSize(find.byType(NebaRunMark)), const Size.square(20));
    });
  });
}
