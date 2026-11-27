// NebaTour: the suite the React package runs on Tour, asked the way Flutter
// asks it — where the card is drawn against its target, what the dimming
// lets through, what a screen reader is told and where the focus goes —
// rather than the elements, the classes and the ARIA it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  late GlobalKey save;
  late GlobalKey deploy;

  setUp(() {
    save = GlobalKey(debugLabel: 'save');
    deploy = GlobalKey(debugLabel: 'deploy');
  });

  List<NebaTourStep> steps() => <NebaTourStep>[
    NebaTourStep(
      target: save,
      title: const Text('Save'),
      content: const Text('This writes the change.'),
    ),
    NebaTourStep(
      target: deploy,
      title: const Text('Deploy'),
      content: const Text('And this ships it.'),
    ),
    const NebaTourStep(title: Text('That is all'), content: Text('Nothing else to point at.')),
  ];

  Widget page(
    NebaTour tour, {
    VoidCallback? onDeploy,
    bool disableAnimations = false,
    double deployTop = 200,
  }) {
    return host(
      Overlay.wrap(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 40,
              left: 40,
              child: NebaButton(key: save, onPressed: () {}, child: const Text('Save')),
            ),
            Positioned(
              top: deployTop,
              left: 300,
              child: NebaButton(
                key: deploy,
                onPressed: onDeploy ?? () {},
                child: const Text('Deploy'),
              ),
            ),
            tour,
          ],
        ),
      ),
      disableAnimations: disableAnimations,
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  // The card: the one sheet up the shadows, among the buttons' own.
  Finder card() =>
      find.byWidgetPredicate((Widget widget) => widget is NebaSheet && widget.elevation == 3);

  Finder button(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(NebaButton));

  group('scrolling to a step', () {
    Widget scrolling({required bool reduced, required ScrollController controller}) {
      return host(
        Overlay.wrap(
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 1200),
                NebaButton(key: deploy, onPressed: () {}, child: const Text('Deploy')),
                const SizedBox(height: 1200),
                NebaTour(
                  defaultOpen: true,
                  steps: <NebaTourStep>[NebaTourStep(target: deploy, title: const Text('Ship'))],
                ),
              ],
            ),
          ),
        ),
        disableAnimations: reduced,
      );
    }

    testWidgets('glides to the target', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(scrolling(reduced: false, controller: controller));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final double during = controller.offset;
      expect(during, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, greaterThan(during));
      // Centred in the window.
      expect(tester.getCenter(find.byKey(deploy)).dy, moreOrLessEquals(300, epsilon: 1));
    });

    testWidgets('jumps under a reduced-motion preference', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(scrolling(reduced: true, controller: controller));
      await tester.pump();
      await tester.pump();

      final double landed = controller.offset;
      expect(landed, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, landed);
    });
    testWidgets('scrolls again when it runs again', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      Widget scene(bool open) {
        return host(
          Overlay.wrap(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 1200),
                      NebaButton(key: deploy, onPressed: () {}, child: const Text('Deploy')),
                      const SizedBox(height: 1200),
                    ],
                  ),
                ),
                NebaTour(
                  open: open,
                  steps: <NebaTourStep>[NebaTourStep(target: deploy, title: const Text('Ship'))],
                ),
              ],
            ),
          ),
          disableAnimations: true,
        );
      }

      await tester.pumpWidget(scene(true));
      await settle(tester);
      final double landed = controller.offset;
      expect(landed, greaterThan(0));

      await tester.pumpWidget(scene(false));
      await settle(tester);
      controller.jumpTo(0);
      await tester.pumpWidget(scene(true));
      await settle(tester);

      expect(controller.offset, landed);
    });
  });

  group('rendering', () {
    testWidgets('draws nothing until it is running', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps())));
      await settle(tester);

      expect(find.text('This writes the change.'), findsNothing);
      expect(card(), findsNothing);
    });

    testWidgets('draws the first step when it is', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      expect(find.text('This writes the change.'), findsOneWidget);
      expect(card(), findsOneWidget);
    });

    testWidgets('is a dialog named by its title', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      SemanticsNode? dialog = tester.getSemantics(find.text('This writes the change.'));

      while (dialog != null && dialog.getSemanticsData().role != SemanticsRole.dialog) {
        dialog = dialog.parent;
      }

      expect(dialog, isNotNull);
      expect(dialog!.getSemanticsData().label, 'Save');
      expect(tester.getSemantics(find.text('Save').last), isSemantics(isHeader: true));
      semantics.dispose();
    });

    testWidgets('dims the whole window and cuts the target out of it', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      final Finder mask = find.descendant(
        of: find.byType(Overlay),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter.runtimeType.toString() == '_TourMask',
        ),
      );

      expect(tester.getRect(mask), const Rect.fromLTWH(0, 0, 800, 600));

      final Rect target = tester.getRect(find.byKey(save));

      // The scrim's colour is everywhere but the hole, which reaches six
      // pixels past the target.
      expect(
        tester.renderObject<RenderBox>(mask),
        paints..path(
          color: tokens.scrim,
          includes: <Offset>[const Offset(5, 5), Offset(target.center.dx, target.top - 7)],
          excludes: <Offset>[target.center, Offset(target.center.dx, target.top - 5)],
        ),
      );
    });

    testWidgets('draws no dimming without the mask', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true, mask: false)));
      await settle(tester);

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter.runtimeType.toString() == '_TourMask',
        ),
        findsNothing,
      );
      expect(card(), findsOneWidget);
    });

    testWidgets('counts the steps', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('counts in the language it is given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, locale: const Locale('ko'))),
      );
      await settle(tester);

      expect(find.text('1 of 3'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('renders nothing at all with no steps', (WidgetTester tester) async {
      await tester.pumpWidget(page(const NebaTour(steps: <NebaTourStep>[], defaultOpen: true)));
      await settle(tester);

      expect(card(), findsNothing);
      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Semantics && widget.properties.role == SemanticsRole.dialog,
        ),
        findsNothing,
      );
    });
  });

  group('walking through', () {
    testWidgets('goes forward and back', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('And this ships it.'), findsOneWidget);

      await tester.tap(find.text('Previous'));
      await settle(tester);
      expect(find.text('This writes the change.'), findsOneWidget);
    });

    // The card is rewritten in place and the focus stays on Next.
    testWidgets('says which step it moved to', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      Finder live(String label) => find.bySemanticsLabel(label);

      expect(live('Step 1: Save'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await settle(tester);

      expect(live('Step 2: Deploy'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('keeps the focus on the button that was pressed', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      Focus.of(tester.element(find.text('Next'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(find.text('And this ships it.'), findsOneWidget);
      expect(Focus.of(tester.element(find.text('Next'))).hasPrimaryFocus, isTrue);
    });

    testWidgets('moves the card to the target of each step', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true), deployTop: 420));
      await settle(tester);

      final Rect first = tester.getRect(card());
      expect(first.top, tester.getRect(find.byKey(save)).bottom + 10);

      await tester.tap(find.text('Next'));
      await settle(tester);

      final Rect second = tester.getRect(card());
      final Rect target = tester.getRect(find.byKey(deploy));
      // Below the target, or flipped above it for want of room.
      expect(second.top == target.bottom + 10 || second.bottom == target.top - 10, isTrue);
      expect(second.center.dx, moreOrLessEquals(target.center.dx, epsilon: 1));
    });

    testWidgets('centres a step with no target', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true, defaultStep: 2)));
      await settle(tester);

      expect(tester.getRect(card()).center, const Offset(400, 300));
    });

    testWidgets('follows its target when it moves', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          Overlay.wrap(
            child: Stack(
              children: <Widget>[
                ListView(
                  controller: controller,
                  children: <Widget>[
                    const SizedBox(height: 100),
                    NebaButton(key: save, onPressed: () {}, child: const Text('Save')),
                    const SizedBox(height: 1200),
                  ],
                ),
                NebaTour(
                  defaultOpen: true,
                  scrollIntoView: false,
                  steps: <NebaTourStep>[NebaTourStep(target: save, title: const Text('Here'))],
                ),
              ],
            ),
          ),
        ),
      );
      await settle(tester);

      final double before = tester.getRect(card()).top;

      controller.jumpTo(40);
      await tester.pump();
      await tester.pump();

      expect(tester.getRect(card()).top, before - 40);
    });

    testWidgets('does not rebuild for a scroll that leaves its target where it was', (
      WidgetTester tester,
    ) async {
      int builds = 0;
      final ScrollController pane = ScrollController();
      addTearDown(pane.dispose);

      await tester.pumpWidget(
        host(
          Overlay.wrap(
            child: Column(
              children: <Widget>[
                NebaButton(key: save, onPressed: () {}, child: const Text('Save')),
                SizedBox(
                  height: 60,
                  child: ListView(
                    controller: pane,
                    children: const <Widget>[SizedBox(height: 600)],
                  ),
                ),
                NebaTour(
                  defaultOpen: true,
                  steps: <NebaTourStep>[
                    NebaTourStep(
                      target: save,
                      title: Builder(
                        builder: (BuildContext context) {
                          builds += 1;

                          return const Text('Here');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await settle(tester);

      final int before = builds;

      for (double top = 10; top <= 50; top += 10) {
        pane.jumpTo(top);
        await tester.pump();
      }

      expect(builds, before);
    });

    testWidgets('centres a step whose target is not built rather than throwing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        page(
          NebaTour(
            defaultOpen: true,
            steps: <NebaTourStep>[
              NebaTourStep(
                target: GlobalKey(),
                title: const Text('Intro'),
                content: const Text('Welcome.'),
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Welcome.'), findsOneWidget);
      expect(tester.getRect(card()).center, const Offset(400, 300));
    });

    testWidgets('names the close button with a word of its own', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, closeLabel: 'End the tour')),
      );
      await settle(tester);

      expect(find.bySemanticsLabel('End the tour'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('End the tour')),
        isSemantics(isButton: true),
      );
      semantics.dispose();
    });

    testWidgets('offers no Previous on the first step', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      expect(find.text('Previous'), findsNothing);
    });

    testWidgets('turns Next into Done on the last one', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true, defaultStep: 2)));
      await settle(tester);

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('reports the step it moved to', (WidgetTester tester) async {
      final List<int> moves = <int>[];

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, onStepChange: moves.add)),
      );
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);

      expect(moves, <int>[1]);
    });

    testWidgets('stays where a controlled step puts it', (WidgetTester tester) async {
      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, step: 0, onStepChange: (int _) {})),
      );
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);

      expect(find.text('This writes the change.'), findsOneWidget);
    });

    testWidgets('takes the labels it is given', (WidgetTester tester) async {
      await tester.pumpWidget(
        page(
          NebaTour(
            steps: steps(),
            defaultOpen: true,
            defaultStep: 1,
            previousLabel: const Text('Back'),
            skipLabel: const Text('Not now'),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });
  });

  group('ending', () {
    testWidgets('finishes on the last step and closes', (WidgetTester tester) async {
      int finished = 0;
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        page(
          NebaTour(
            steps: steps(),
            defaultOpen: true,
            defaultStep: 2,
            onFinish: () => finished += 1,
            onOpenChange: changes.add,
          ),
        ),
      );
      await settle(tester);
      await tester.tap(find.text('Done'));
      await settle(tester);

      expect(finished, 1);
      expect(changes, <bool>[false]);
      expect(card(), findsNothing);
    });

    testWidgets('skips out of the middle', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, onOpenChange: changes.add)),
      );
      await settle(tester);
      await tester.tap(find.text('Skip'));
      await settle(tester);

      expect(changes, <bool>[false]);
    });

    testWidgets('offers no Skip on the last step', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true, defaultStep: 2)));
      await settle(tester);

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('ends on Escape, wherever the focus is', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, onOpenChange: changes.add)),
      );
      await settle(tester);

      // On the page, outside the card.
      Focus.of(tester.element(find.text('Deploy'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.text('This writes the change.'), findsNothing);
      expect(changes, <bool>[false]);
    });

    testWidgets('ends on its ×', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, onOpenChange: changes.add)),
      );
      await settle(tester);
      await tester.tap(
        find.descendant(
          of: card(),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.label == 'Close',
          ),
        ),
      );
      await settle(tester);

      expect(changes, <bool>[false]);
    });

    // A tour that has to be walked to its end is only left through its own
    // buttons.
    testWidgets('keeps going on Escape when it is not dismissible', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        page(
          NebaTour(
            steps: steps(),
            defaultOpen: true,
            dismissible: false,
            onOpenChange: changes.add,
          ),
        ),
      );
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.text('This writes the change.'), findsOneWidget);
      expect(changes, isEmpty);
      // And it draws no ×.
      expect(
        find.descendant(
          of: card(),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.properties.label == 'Close',
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('drops the Skip button when it is turned off', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true, skippable: false)));
      await settle(tester);

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('is not ended by a press outside the card', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);
      await tester.tapAt(const Offset(780, 580));
      await settle(tester);

      expect(find.text('This writes the change.'), findsOneWidget);
    });

    testWidgets('takes the focus into the card and gives it back', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps())));
      await settle(tester);

      final FocusNode before = Focus.of(tester.element(find.text('Save').first));
      before.requestFocus();
      await tester.pump();

      await tester.pumpWidget(page(NebaTour(steps: steps(), open: true)));
      await settle(tester);

      expect(before.hasPrimaryFocus, isFalse);
      expect(
        FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<NebaSheet>(),
        isNotNull,
      );

      await tester.pumpWidget(page(NebaTour(steps: steps(), open: false)));
      await settle(tester);

      expect(before.hasPrimaryFocus, isTrue);
    });
  });

  group('the mask', () {
    testWidgets('never takes the pointer, so the page stays usable', (WidgetTester tester) async {
      int deployed = 0;

      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true), onDeploy: () => deployed += 1),
      );
      await settle(tester);

      await tester.tap(find.byKey(deploy));
      await settle(tester);

      expect(deployed, 1);
      expect(find.text('This writes the change.'), findsOneWidget);
    });
  });

  group('shared props', () {
    testWidgets('draws the card on the frosted sheet with an edge in its colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        page(NebaTour(steps: steps(), defaultOpen: true, color: NebaColor.success)),
      );
      await settle(tester);

      final NebaSheet sheet = tester.widget<NebaSheet>(card());
      expect(sheet.fill, tokens.panelPress);
      expect(sheet.edge, tokens.roles(NebaColor.success).line);
      expect(sheet.elevation, 3);
      expect(sheet.plate, NebaPlate.glass);
    });

    testWidgets('holds the card to the widest a popover gets', (WidgetTester tester) async {
      await tester.pumpWidget(
        page(
          NebaTour(
            defaultOpen: true,
            size: NebaSize.sm,
            steps: const <NebaTourStep>[
              NebaTourStep(
                title: Text('A long one'),
                content: Text(
                  'A sentence long enough to run past the widest the card gets at this size, '
                  'and then some more after that.',
                ),
              ),
            ],
          ),
        ),
      );
      await settle(tester);

      expect(tester.getSize(card()).width, NebaPopover.maxWidths[NebaSize.sm]);
    });

    testWidgets('sizes its buttons a rung under the card', (WidgetTester tester) async {
      await tester.pumpWidget(page(NebaTour(steps: steps(), defaultOpen: true)));
      await settle(tester);

      expect(tester.widget<NebaButton>(button('Next')).size, NebaSize.sm);
      expect(tester.widget<NebaButton>(button('Skip')).variant, NebaVariant.text);
    });
  });
}
