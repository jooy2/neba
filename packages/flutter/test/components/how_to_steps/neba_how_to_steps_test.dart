// NebaHowToSteps: the suite the React package runs on HowToSteps, asked the
// way Flutter asks it — what is showing and what a press and a screen reader
// can reach, where the focus goes, how the list and the body are laid out
// and what plays as a step arrives — rather than the elements, attributes and
// classes it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

const List<NebaHowToStep> _steps = <NebaHowToStep>[
  NebaHowToStep(title: Text('Install'), content: Text('One package.')),
  NebaHowToStep(title: Text('Wrap'), content: Text('Nothing to wrap.')),
  NebaHowToStep(title: Text('Use it'), content: Text('Import it and render it.')),
];

void main() {
  Future<void> pump(WidgetTester tester, Widget guide, {double width = 800}) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width - 40, child: guide),
        ),
        width: width,
        height: 900,
      ),
    );
  }

  Finder list() {
    return find.byWidgetPredicate(
      (Widget widget) => widget is Semantics && widget.properties.role == SemanticsRole.list,
    );
  }

  Finder inList(String text) => find.descendant(of: list(), matching: find.text(text));

  Finder inPanel(String text) {
    return find.descendant(of: find.byType(NebaEntrance), matching: find.text(text));
  }

  bool showing(WidgetTester tester, String text) {
    return inPanel(text).hitTestable().evaluate().isNotEmpty;
  }

  Finder button(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(NebaButton));
  }

  group('rendering', () {
    testWidgets('lists every step', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      for (final String title in <String>['Install', 'Wrap', 'Use it']) {
        expect(inList(title), findsOneWidget);
      }
    });

    testWidgets('says the list is a list of steps', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(tester.widget<Semantics>(list()).properties.label, 'Steps');
    });

    testWidgets('names a step row once, by its place and its title', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(find.bySemanticsLabel('Step 3: Use it'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Step 3: Use it')),
        matchesSemantics(
          label: 'Step 3: Use it',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('leaves a row whose title is not words to its contents', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(
        tester,
        const NebaHowToSteps(
          steps: <NebaHowToStep>[
            NebaHowToStep(title: Text.rich(TextSpan(text: 'Rich'))),
            NebaHowToStep(title: Text('Plain')),
          ],
        ),
      );

      expect(find.bySemanticsLabel(RegExp('^Step 1')), findsNothing);
      expect(find.bySemanticsLabel('Step 2: Plain'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('draws the guide a heading of its own, at the level asked for', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(
        tester,
        const NebaHowToSteps(title: Text('Getting started'), headingLevel: 2, steps: _steps),
      );

      expect(
        tester.getSemantics(find.text('Getting started')),
        matchesSemantics(
          label: 'Getting started',
          isHeader: true,
          textDirection: TextDirection.ltr,
        ),
      );
      expect(tester.getSemantics(find.text('Getting started')).getSemanticsData().headingLevel, 2);
      expect(
        tester.getSemantics(inPanel('Install')),
        matchesSemantics(label: 'Install', isHeader: true, textDirection: TextDirection.ltr),
      );
      expect(tester.getSemantics(inPanel('Install')).getSemanticsData().headingLevel, 3);

      handle.dispose();
    });

    testWidgets('puts the guide at level 3 and a step at 4 by default', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaHowToSteps(title: Text('Guide'), steps: _steps));

      expect(tester.getSemantics(find.text('Guide')).getSemanticsData().headingLevel, 3);
      expect(tester.getSemantics(inPanel('Install')).getSemanticsData().headingLevel, 4);

      handle.dispose();
    });

    testWidgets('puts a step at the level itself when there is no title', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(tester.getSemantics(inPanel('Install')).getSemanticsData().headingLevel, 3);

      handle.dispose();
    });

    testWidgets('builds nothing at all with no steps', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: <NebaHowToStep>[]));

      expect(find.byType(NebaSheet), findsNothing);
      expect(tester.getSize(find.byType(NebaHowToSteps)).height, 0);
    });
  });

  group('the step image', () {
    testWidgets('draws a picture named by the title unless told otherwise', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaHowToSteps(
          steps: <NebaHowToStep>[
            NebaHowToStep(title: const Text('Open the panel'), image: MemoryImage(_pixel)),
            NebaHowToStep(
              title: const Text('Close it'),
              image: MemoryImage(_pixel),
              imageAlt: 'The panel, closed',
            ),
          ],
        ),
      );

      final List<Image> images = tester.widgetList<Image>(find.byType(Image)).toList();

      expect(images.map((Image image) => image.semanticLabel), <String>[
        'Open the panel',
        'The panel, closed',
      ]);
    });

    testWidgets('reserves the proportion it was given', (WidgetTester tester) async {
      await pump(
        tester,
        NebaHowToSteps(
          steps: <NebaHowToStep>[
            NebaHowToStep(
              title: const Text('Open the panel'),
              image: MemoryImage(_pixel),
              imageWidth: 1600,
              imageHeight: 900,
            ),
          ],
        ),
      );

      expect(tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio, 1600 / 900);

      final Size box = tester.getSize(find.byType(AspectRatio));

      expect(box.width / box.height, closeTo(1600 / 900, 0.01));
    });
  });

  group('moving between steps', () {
    testWidgets('starts on the first step', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(showing(tester, 'One package.'), isTrue);
      expect(showing(tester, 'Nothing to wrap.'), isFalse);
    });

    testWidgets('starts wherever it was told to', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(defaultStep: 1, steps: _steps));

      expect(showing(tester, 'Nothing to wrap.'), isTrue);
    });

    testWidgets('moves forward and back', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(showing(tester, 'Nothing to wrap.'), isTrue);

      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      expect(showing(tester, 'One package.'), isTrue);
    });

    testWidgets('jumps to a step pressed in the list', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      await tester.tap(inList('Use it'));
      await tester.pumpAndSettle();

      expect(showing(tester, 'Import it and render it.'), isTrue);
    });

    testWidgets('reports every change', (WidgetTester tester) async {
      final List<int> changes = <int>[];

      await pump(tester, NebaHowToSteps(steps: _steps, onStepChange: changes.add));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(inList('Use it'));
      await tester.pumpAndSettle();
      await tester.tap(inList('Use it'));
      await tester.pumpAndSettle();

      expect(changes, <int>[1, 2]);
    });

    testWidgets('has nowhere to go back to on the first step', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(tester.widget<NebaButton>(button('Previous')).onPressed, isNull);
    });

    testWidgets('keeps the focus on Previous when it reaches the first step', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(defaultStep: 1, steps: _steps));

      Focus.of(tester.element(find.text('Previous'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(showing(tester, 'One package.'), isTrue);
      expect(Focus.of(tester.element(find.text('Previous'))).hasPrimaryFocus, isTrue);
    });

    testWidgets('takes the step it is given and changes nothing on its own', (
      WidgetTester tester,
    ) async {
      final List<int> changes = <int>[];

      await pump(tester, NebaHowToSteps(step: 1, onStepChange: changes.add, steps: _steps));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(changes, <int>[2]);
      expect(showing(tester, 'Nothing to wrap.'), isTrue);
    });

    testWidgets('holds a step past the end of the list to the last', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(step: 9, steps: _steps));

      expect(showing(tester, 'Import it and render it.'), isTrue);
    });
  });

  group('finishing', () {
    testWidgets('offers Done in place of Next on the last step', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(defaultStep: 2, steps: _steps));

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('says so, and offers to start again', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(defaultStep: 2, steps: _steps));

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('All steps complete').hitTestable(), findsOneWidget);
      expect(find.text('Start over'), findsOneWidget);
      expect(showing(tester, 'Import it and render it.'), isFalse);
    });

    testWidgets('marks no step current once finished', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(defaultCompleted: true, steps: _steps));

      for (final String label in <String>['Step 1: Install', 'Step 2: Wrap', 'Step 3: Use it']) {
        expect(_row(tester, label).properties.selected, isNull);
      }
    });

    testWidgets('goes back to the first step when it is started again', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(defaultCompleted: true, steps: _steps));

      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();

      expect(showing(tester, 'One package.'), isTrue);
    });

    testWidgets('keeps the focus in the row of buttons through Done and Start over', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(defaultStep: 2, steps: _steps));

      Focus.of(tester.element(find.text('Done'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(Focus.of(tester.element(find.text('Start over'))).hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(Focus.of(tester.element(find.text('Next'))).hasPrimaryFocus, isTrue);
    });

    testWidgets('reports finishing and starting again', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaHowToSteps(defaultStep: 2, onCompletedChange: changes.add, steps: _steps),
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();

      expect(changes, <bool>[true, false]);
    });

    testWidgets('takes a finished state it is given', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(completed: true, steps: _steps));

      expect(find.text('All steps complete').hitTestable(), findsOneWidget);
    });

    testWidgets('says what it was told to say instead', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHowToSteps(
          completed: true,
          completedContent: Text('You are set up.'),
          steps: _steps,
        ),
      );

      expect(find.text('You are set up.').hitTestable(), findsOneWidget);
      expect(find.text('All steps complete'), findsNothing);
    });

    testWidgets('stands the finished panel centred in the height the steps hold open', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHowToSteps(
          completed: true,
          steps: <NebaHowToStep>[
            NebaHowToStep(title: Text('Tall'), content: SizedBox(height: 400)),
          ],
        ),
      );

      final Rect cell = tester.getRect(
        find.ancestor(of: find.text('All steps complete'), matching: find.byType(NebaEntrance)),
      );
      final Rect words = tester.getRect(find.text('All steps complete'));

      expect(cell.height, greaterThan(400));
      expect(words.center.dy, greaterThan(cell.top + cell.height / 2));
      expect(words.bottom, lessThan(cell.bottom - 100));
    });

    testWidgets('has no finished state when completion is off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHowToSteps(completion: false, defaultStep: 2, completed: true, steps: _steps),
      );

      expect(find.text('Done'), findsNothing);
      expect(find.text('All steps complete'), findsNothing);
      expect(tester.widget<NebaButton>(button('Next')).onPressed, isNull);
      expect(showing(tester, 'Import it and render it.'), isTrue);
    });
  });

  group('the panel', () {
    const List<NebaHowToStep> uneven = <NebaHowToStep>[
      NebaHowToStep(title: Text('Short'), content: Text('One line.')),
      NebaHowToStep(
        title: Text('Long'),
        content: Column(
          children: <Widget>[Text('One'), Text('Two'), Text('Three'), Text('Four'), Text('Five')],
        ),
      ),
    ];

    testWidgets('keeps every step built', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(inPanel('Nothing to wrap.'), findsOneWidget);
      expect(inPanel('Import it and render it.'), findsOneWidget);
    });

    testWidgets('keeps the steps that are not showing from a press and a screen reader', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(showing(tester, 'Nothing to wrap.'), isFalse);
      expect(find.bySemanticsLabel('Nothing to wrap.'), findsNothing);
      expect(find.bySemanticsLabel('One package.'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('is as tall as the tallest step whichever is showing', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: uneven));
      final double first = tester.getSize(find.byType(NebaHowToSteps)).height;

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(NebaHowToSteps)).height, first);
    });

    testWidgets('keeps what a step holds when the reader leaves it and comes back', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHowToSteps(
          steps: <NebaHowToStep>[
            NebaHowToStep(title: Text('Form'), content: _Kept()),
            NebaHowToStep(title: Text('Next one')),
          ],
        ),
      );

      final State<_Kept> kept = tester.state(find.byType(_Kept));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();

      expect(tester.state(find.byType(_Kept)), same(kept));
    });
  });

  group('appearance', () {
    testWidgets('bounds its height when it is told to, and scrolls the list', (
      WidgetTester tester,
    ) async {
      final List<NebaHowToStep> many = <NebaHowToStep>[
        for (int i = 1; i <= 14; i++) NebaHowToStep(title: Text('Migration $i')),
      ];

      await pump(tester, NebaHowToSteps(maxHeight: 340, steps: many));

      expect(tester.getSize(find.byType(NebaHowToSteps)).height, lessThanOrEqualTo(340));
      expect(
        find.ancestor(of: list(), matching: find.byType(SingleChildScrollView)),
        findsOneWidget,
      );
    });

    testWidgets('keeps the current row in view as the step changes', (WidgetTester tester) async {
      final List<NebaHowToStep> many = <NebaHowToStep>[
        for (int i = 1; i <= 14; i++) NebaHowToStep(title: Text('Migration $i')),
      ];

      await pump(tester, NebaHowToSteps(maxHeight: 340, steps: many));

      for (int i = 0; i < 12; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(inList('Migration 13').hitTestable(), findsOneWidget);
    });

    testWidgets('takes the list width it was given beside the body', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(railWidth: 200, divider: false, steps: _steps));

      expect(tester.getSize(list()).width, 200);
    });

    testWidgets('stacks the list over the body on a narrow window', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps), width: 390);

      expect(
        tester.getRect(list()).bottom,
        lessThanOrEqualTo(tester.getRect(inPanel('One package.')).top),
      );
    });

    testWidgets('runs the numbers across the top when horizontal', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHowToSteps(orientation: NebaOrientation.horizontal, steps: _steps),
      );

      expect(
        tester.getCenter(inList('Install')).dy,
        closeTo(tester.getCenter(inList('Use it')).dy, 0.5),
      );
      expect(tester.getRect(list()).bottom, lessThan(tester.getRect(inPanel('One package.')).top));
    });

    testWidgets('drops the row of buttons when navigation is off', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(navigation: false, steps: _steps));

      expect(find.text('Next'), findsNothing);
      expect(find.text('Previous'), findsNothing);
    });

    testWidgets('still moves from the list with no buttons', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(navigation: false, steps: _steps));

      await tester.tap(inList('Wrap'));
      await tester.pumpAndSettle();

      expect(showing(tester, 'Nothing to wrap.'), isTrue);
    });

    testWidgets('keeps the sheet undyed and the family on the numbers', (
      WidgetTester tester,
    ) async {
      final NebaTokens tokens = NebaTokens.light();

      await pump(tester, const NebaHowToSteps(color: NebaColor.success, steps: _steps));

      expect(tester.widget<NebaSheet>(find.byType(NebaSheet).first).fill, tokens.panel);
    });
  });

  group('the step icon', () {
    testWidgets('draws a glyph before the title on the step showing, and not in the list', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHowToSteps(
          steps: <NebaHowToStep>[
            NebaHowToStep(
              title: Text('Open'),
              icon: SizedBox(key: Key('icon'), width: 8),
            ),
          ],
        ),
      );

      expect(find.byKey(const Key('icon')), findsOneWidget);
      expect(find.descendant(of: list(), matching: find.byKey(const Key('icon'))), findsNothing);
      expect(
        tester.getRect(find.byKey(const Key('icon'))).right,
        lessThan(tester.getRect(inPanel('Open')).left),
      );
    });
  });

  group('the divider', () {
    Iterable<BoxBorder> borders(WidgetTester tester) {
      return tester
          .widgetList<Container>(
            find.descendant(of: find.byType(NebaHowToSteps), matching: find.byType(Container)),
          )
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .map((BoxDecoration decoration) => decoration.border)
          .whereType<BoxBorder>()
          // The discs are ringed all round; the divider is one side alone.
          .where((BoxBorder border) => !border.isUniform);
    }

    testWidgets('draws a hairline down the inner edge of the list beside the body', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(borders(tester).single, isA<BorderDirectional>());
    });

    testWidgets('draws it under the list once they have stacked', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps), width: 390);

      expect(borders(tester).single, isA<Border>());
    });

    testWidgets('leaves it out when it is turned off', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(divider: false, steps: _steps));

      expect(borders(tester), isEmpty);
    });
  });

  group('the step transition', () {
    double opacityOver(WidgetTester tester, String text) {
      return tester
          .widget<Opacity>(find.ancestor(of: inPanel(text), matching: find.byType(Opacity)).first)
          .opacity;
    }

    testWidgets('draws the step it starts on without an entrance', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(opacityOver(tester, 'One package.'), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('fades a step in by default once the reader moves to it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(opacityOver(tester, 'Nothing to wrap.'), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();
      expect(opacityOver(tester, 'Nothing to wrap.'), 1);
    });

    testWidgets('fades the first step in too when the reader comes back to it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Previous'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(opacityOver(tester, 'One package.'), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
    });

    testWidgets('runs the effect it was given', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHowToSteps(
          transition: NebaTransition.slide(from: NebaSide.right, distance: 24),
          steps: _steps,
        ),
      );

      final double rest = tester.getRect(inPanel('One package.')).left;

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(tester.getRect(inPanel('Nothing to wrap.')).left, greaterThan(rest));
      await tester.pumpAndSettle();
      expect(tester.getRect(inPanel('Nothing to wrap.')).left, rest);
    });

    testWidgets('animates nothing at all with none', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(transition: null, steps: _steps));

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(opacityOver(tester, 'Nothing to wrap.'), 1);
    });

    testWidgets('cuts it to its last frame for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 760, child: NebaHowToSteps(steps: _steps)),
          ),
          disableAnimations: true,
          height: 900,
        ),
      );

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(opacityOver(tester, 'Nothing to wrap.'), 1);
    });
  });

  group('accessibility', () {
    tearDown(resetNebaMessages);

    testWidgets('marks the current row as the current step, and moves the mark', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(_row(tester, 'Step 1: Install').properties.selected, isTrue);
      expect(_row(tester, 'Step 2: Wrap').properties.selected, isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(_row(tester, 'Step 1: Install').properties.selected, isNull);
      expect(_row(tester, 'Step 2: Wrap').properties.selected, isTrue);
    });

    testWidgets('tells a screen reader on the web that the row is the current one', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaHowToSteps(steps: _steps));

      expect(
        tester.getSemantics(inList('Install')),
        matchesSemantics(
          label: 'Step 1: Install',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('says which step it moved to', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(steps: _steps));

      Text announcement() {
        return tester.widget<Text>(
          find.descendant(of: find.byType(NebaLiveRegion), matching: find.byType(Text)),
        );
      }

      expect(tester.widget<NebaLiveRegion>(find.byType(NebaLiveRegion)).role, SemanticsRole.status);
      expect(announcement().data, 'Step 1: Install');

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(announcement().data, 'Step 2: Wrap');
    });

    testWidgets('is a group named by its title', (WidgetTester tester) async {
      await pump(tester, const NebaHowToSteps(title: Text('Getting started'), steps: _steps));

      final Semantics group = tester.widget<Semantics>(
        find.descendant(of: find.byType(NebaHowToSteps), matching: find.byType(Semantics)).first,
      );

      expect(group.properties.label, 'Getting started');
      expect(group.container, isTrue);
    });

    testWidgets('says its own words in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaHowToSteps(locale: Locale('ko'), steps: _steps));

      final Map<String, String> words = ko.messages['steps']!;

      expect(find.text(words['next']!), findsOneWidget);
      expect(find.text(words['previous']!), findsOneWidget);
      expect(tester.widget<Semantics>(list()).properties.label, words['steps']);
    });

    testWidgets('takes labels written out over the locale', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHowToSteps(
          defaultStep: 2,
          previousLabel: 'Back',
          doneLabel: 'Finish',
          steps: _steps,
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
    });
  });
}

/// The semantics of the row named [label].
Semantics _row(WidgetTester tester, String label) {
  return tester.widget<Semantics>(
    find.byWidgetPredicate(
      (Widget widget) => widget is Semantics && widget.properties.label == label,
    ),
  );
}

/// A widget with state of its own, to see that it survives a step change.
class _Kept extends StatefulWidget {
  const _Kept();

  @override
  State<_Kept> createState() => _KeptState();
}

class _KeptState extends State<_Kept> {
  @override
  Widget build(BuildContext context) => const Text('kept');
}

/// A one-pixel PNG.
final Uint8List _pixel = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x02, 0x00, 0x00, 0x00, 0x7B, 0x40, 0xE8, 0xDD, 0x00, 0x00, 0x00, //
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0x00, 0x04, //
  0xFF, 0x01, 0x07, 0x00, 0x01, 0xFF, 0xE2, 0x23, 0x9E, 0x59, 0x00, 0x00, //
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
]);
