// NebaSelect: the suite the React package runs on Select, asked the way
// Flutter asks it — the shell, the list and the width it lays out, the
// semantics it builds, and what a press, a key and typing do — rather than
// the elements, the classes and the ARIA it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);
  final NebaColorRoles danger = tokens.roles(NebaColor.danger);

  const List<NebaSelectOption<String>> plans = <NebaSelectOption<String>>[
    NebaSelectOption<String>(value: 'starter', label: Text('Starter')),
    NebaSelectOption<String>(value: 'team', label: Text('Team')),
    NebaSelectOption<String>(value: 'enterprise', label: Text('Enterprise'), disabled: true),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget select, {
    NebaDefaults? defaults,
    double width = 800,
    double height = 600,
    Widget? after,
  }) {
    final Widget placed = Overlay.wrap(
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[select, ?after]),
      ),
    );

    return tester.pumpWidget(
      host(
        defaults == null ? placed : NebaProvider(defaults: defaults, child: placed),
        width: width,
        height: height,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder shellSheet() =>
      find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(NebaSheet));

  NebaSheet shellOf(WidgetTester tester) => tester.widget<NebaSheet>(shellSheet().first);

  Finder listSheet() =>
      find.descendant(of: find.byType(NebaListSheet), matching: find.byType(NebaSheet));

  Finder row(String text) =>
      find.ancestor(of: find.text(text), matching: find.byType(NebaListRow)).first;

  NebaListRow rowOf(WidgetTester tester, String text) => tester.widget<NebaListRow>(row(text));

  SemanticsData triggerData(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaFieldWidth)).getSemanticsData();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(NebaFieldShell));
    await settle(tester);
  }

  FocusNode triggerNode(WidgetTester tester) {
    return Focus.of(
      tester.element(find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(Row))),
    );
  }

  Future<void> focusTrigger(WidgetTester tester) async {
    triggerNode(tester).requestFocus();
    await tester.pump();
    await tester.pump();
  }

  group('rendering', () {
    testWidgets('is a button named by its label that says its value and opens a list', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan'), defaultValue: 'team'),
      );

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Plan',
          value: 'Team',
          isButton: true,
          hasExpandedState: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('is named by semanticLabel when it has no label of its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSelect<String>(items: plans, semanticLabel: 'Plan'));

      expect(triggerData(tester).label, 'Plan');
      semantics.dispose();
    });

    testWidgets('shows a muted placeholder while nothing is chosen', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan'), placeholder: Text('Pick one')),
      );
      await settle(tester);

      expect(find.text('Pick one'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Pick one'))).style.color,
        tokens.mutedFg,
      );
    });

    testWidgets("shows the chosen option's label rather than its value", (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan'), defaultValue: 'team'),
      );

      expect(find.text('Team'), findsOneWidget);
      expect(find.text('team'), findsNothing);
    });

    testWidgets('falls back to the value when an option has no label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(
          items: <NebaSelectOption<String>>[NebaSelectOption<String>(value: 'kr')],
          label: Text('Country'),
          defaultValue: 'kr',
        ),
      );

      expect(find.text('kr'), findsOneWidget);
    });

    testWidgets('reads the description after its name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSelect<String>(
          items: plans,
          label: Text('Plan'),
          description: Text('Change it any time.'),
        ),
      );

      expect(find.text('Change it any time.'), findsOneWidget);
      expect(triggerData(tester).hint, 'Change it any time.');
      semantics.dispose();
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Before')));
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('never applies a transform but to its chevron', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));

      final Finder transforms = find.descendant(
        of: find.byType(NebaSelect<String>),
        matching: find.byType(Transform),
      );
      final Finder turning = find.descendant(
        of: find.byType(NebaDisclosureChevron),
        matching: find.byType(Transform),
      );
      expect(transforms.evaluate().length, turning.evaluate().length);
    });
  });

  group('behaviour', () {
    testWidgets('opens the list on a tap and chooses an option', (WidgetTester tester) async {
      final List<String> chosen = <String>[];

      await pump(
        tester,
        NebaSelect<String>(
          items: plans,
          label: const Text('Plan'),
          placeholder: const Text('Pick one'),
          onValueChange: chosen.add,
        ),
      );

      expect(find.byType(NebaListSheet), findsNothing);
      await open(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(tester.widget<NebaDisclosureChevron>(find.byType(NebaDisclosureChevron)).open, isTrue);

      await tester.tap(row('Team'));
      await settle(tester);

      expect(chosen, <String>['team']);
      expect(find.byType(NebaListSheet), findsNothing);
      expect(find.text('Team'), findsOneWidget);
    });

    testWidgets('opens for a mouse on the press going down', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));

      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(find.byType(NebaFieldShell)),
        kind: PointerDeviceKind.mouse,
      );
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await mouse.up();
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);
    });

    testWidgets('closes when the trigger is pressed again', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));

      await open(tester);
      await open(tester);

      expect(find.byType(NebaListSheet), findsNothing);
    });

    testWidgets('marks the chosen option and opens on it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan'), defaultValue: 'team'),
      );
      await open(tester);

      expect(rowOf(tester, 'Starter').selected, isFalse);
      expect(rowOf(tester, 'Team').selected, isTrue);
      expect(rowOf(tester, 'Team').highlighted, isTrue);
      expect(rowOf(tester, 'Team').indicator, isNotNull);
      expect(
        tester.getSemantics(row('Team')),
        matchesSemantics(
          label: 'Team',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('lists a disabled option as unavailable, and it takes no press', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> chosen = <String>[];

      await pump(
        tester,
        NebaSelect<String>(items: plans, label: const Text('Plan'), onValueChange: chosen.add),
      );
      await open(tester);

      expect(
        tester.getSemantics(row('Enterprise')),
        matchesSemantics(
          label: 'Enterprise',
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
        ),
      );

      await tester.tap(row('Enterprise'));
      await settle(tester);

      expect(chosen, isEmpty);
      expect(find.byType(NebaListSheet), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('honours a controlled value', (WidgetTester tester) async {
      await pump(
        tester,
        NebaSelect<String>(
          items: plans,
          label: const Text('Plan'),
          value: 'team',
          onValueChange: (_) {},
        ),
      );
      expect(find.text('Team'), findsOneWidget);

      await pump(
        tester,
        NebaSelect<String>(
          items: plans,
          label: const Text('Plan'),
          value: 'starter',
          onValueChange: (_) {},
        ),
      );
      expect(find.text('Starter'), findsOneWidget);
    });

    testWidgets('starts open with defaultOpen', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan'), defaultOpen: true),
      );
      await settle(tester);

      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Plan',
          isButton: true,
          hasExpandedState: true,
          isExpanded: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('honours a controlled open state, and reports the reader closing it', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaSelect<String>(
          items: plans,
          label: const Text('Plan'),
          open: true,
          onOpenChange: changes.add,
        ),
      );
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(changes, <bool>[false]);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await pump(
        tester,
        NebaSelect<String>(
          items: plans,
          label: const Text('Plan'),
          open: false,
          onOpenChange: changes.add,
        ),
      );
      await settle(tester);
      expect(find.byType(NebaListSheet), findsNothing);
    });

    testWidgets('does not open, and takes no focus, when disabled', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan'), disabled: true),
      );

      await open(tester);

      expect(find.byType(NebaListSheet), findsNothing);
      expect(triggerNode(tester).canRequestFocus, isFalse);
    });

    testWidgets('opens when read-only so the options can be read, and chooses nothing', (
      WidgetTester tester,
    ) async {
      final List<String> chosen = <String>[];

      await pump(
        tester,
        NebaSelect<String>(
          items: plans,
          label: const Text('Plan'),
          readOnly: true,
          defaultValue: 'team',
          onValueChange: chosen.add,
        ),
      );
      expect(find.byType(ColorFiltered), findsOneWidget);

      await tester.tap(find.byType(NebaFieldShell), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await tester.tap(row('Starter'), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(chosen, isEmpty);
      expect(find.byType(NebaListSheet), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(rowOf(tester, 'Starter').highlighted, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(chosen, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(triggerNode(tester).hasPrimaryFocus, isTrue);

      // Typing at the closed trigger chooses nothing either.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      expect(chosen, isEmpty);
      expect(find.text('Team'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('closes on a press outside', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan')),
        after: const SizedBox(key: Key('outside'), width: 100, height: 40),
      );
      await open(tester);

      await tester.tap(find.byKey(const Key('outside')), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(find.byType(NebaListSheet), findsNothing);
    });
  });

  group('keyboard', () {
    testWidgets('opens on the arrow keys on the chosen option, or the first', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));
      await focusTrigger(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(rowOf(tester, 'Starter').highlighted, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.byType(NebaListSheet), findsNothing);
      // Escape gives the focus back to the trigger.
      expect(triggerNode(tester).hasPrimaryFocus, isTrue);

      // Up opens on the last option there is to choose, past the disabled one.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await settle(tester);
      expect(rowOf(tester, 'Team').highlighted, isTrue);
    });

    testWidgets('walks the list with the arrows, Home and End, past a disabled option', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));
      await focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      bool on(String text) => rowOf(tester, text).highlighted;
      expect(on('Starter'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(on('Team'), isTrue);

      // Past the disabled one and round to the start.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(on('Starter'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(on('Team'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(on('Starter'), isTrue);
    });

    testWidgets('chooses the highlighted option on Enter and gives the focus back', (
      WidgetTester tester,
    ) async {
      final List<String> chosen = <String>[];

      await pump(
        tester,
        NebaSelect<String>(items: plans, label: const Text('Plan'), onValueChange: chosen.add),
      );
      await focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(chosen, <String>['team']);
      expect(find.byType(NebaListSheet), findsNothing);
      expect(triggerNode(tester).hasPrimaryFocus, isTrue);
    });

    testWidgets('reaches an option by its first letters while open', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(
          items: <NebaSelectOption<String>>[
            NebaSelectOption<String>(value: 'icn', label: Text('Seoul')),
            NebaSelectOption<String>(value: 'sin', label: Text('Singapore')),
            NebaSelectOption<String>(value: 'nrt', label: Text('Tokyo')),
            NebaSelectOption<String>(value: 'syd', label: Text('Sydney')),
          ],
          label: Text('City'),
        ),
      );
      await focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      bool on(String text) => rowOf(tester, text).highlighted;

      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.pump();
      expect(on('Tokyo'), isTrue);

      await tester.pump(const Duration(seconds: 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
      await tester.pump();
      expect(on('Singapore'), isTrue);

      // The same letter again steps through the ones it begins.
      await tester.pump(const Duration(seconds: 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      expect(on('Sydney'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      expect(on('Seoul'), isTrue);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('chooses the option its first letters reach while closed', (
      WidgetTester tester,
    ) async {
      final List<String> chosen = <String>[];

      await pump(
        tester,
        NebaSelect<String>(items: plans, label: const Text('Plan'), onValueChange: chosen.add),
      );
      await focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.pump();

      expect(chosen, <String>['team']);
      expect(find.byType(NebaListSheet), findsNothing);
      expect(find.text('Team'), findsOneWidget);

      // A disabled option is not reached.
      await tester.pump(const Duration(seconds: 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.pump();
      expect(chosen, <String>['team']);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('closes on Tab and moves the focus on', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(items: plans, label: Text('Plan')),
        after: Focus(debugLabel: 'next', child: const SizedBox(width: 10, height: 10)),
      );
      await focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await settle(tester);

      expect(find.byType(NebaListSheet), findsNothing);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'next');
    });

    testWidgets('rings the trigger for keyboard focus only', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));

      NebaFocusRing ring() => tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));

      // A press, then the list closing, gives the focus back without a ring.
      await open(tester);
      await tester.tap(row('Team'));
      await settle(tester);
      expect(triggerNode(tester).hasFocus, isTrue);
      expect(ring().visible, isFalse);
      // The edge still answers the focus.
      expect(shellOf(tester).edge, primary.ring);

      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      await tester.pump();
      expect(ring().visible, isTrue);
    });
  });

  group('groups', () {
    const List<NebaSelectOption<String>> zones = <NebaSelectOption<String>>[
      NebaSelectOption<String>(value: 'any', label: Text('Anywhere')),
      NebaSelectOption<String>(value: 'seoul', label: Text('Seoul'), group: 'Asia'),
      NebaSelectOption<String>(value: 'tokyo', label: Text('Tokyo'), group: 'Asia'),
      NebaSelectOption<String>(value: 'paris', label: Text('Paris'), group: 'Europe'),
    ];

    testWidgets('puts a heading over each run of options, and leaves it unpickable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSelect<String>(items: zones, label: Text('Time zone')));
      await open(tester);

      expect(find.byType(NebaListHeading), findsNWidgets(2));
      expect(find.text('ASIA'), findsOneWidget);
      expect(find.text('EUROPE'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('ASIA'), matching: find.byType(NebaListRow)),
        findsNothing,
      );
      expect(
        tester.getSemantics(find.byType(NebaListHeading).first),
        matchesSemantics(label: 'Asia', isHeader: true),
      );
      semantics.dispose();
    });

    testWidgets('keeps an ungrouped run outside any group, and in its place', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSelect<String>(items: zones, label: Text('Time zone')));
      await open(tester);

      expect(
        tester.getRect(row('Anywhere')).bottom,
        lessThanOrEqualTo(tester.getRect(find.text('ASIA')).top),
      );
      expect(
        find.ancestor(of: find.text('Anywhere'), matching: find.byType(NebaListHeading)),
        findsNothing,
      );
    });

    testWidgets('still shows a grouped option in the trigger by its label', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(items: zones, label: Text('Time zone'), defaultValue: 'paris'),
      );

      expect(find.text('Paris'), findsOneWidget);
    });
  });

  group('validation', () {
    testWidgets('renders the error and turns the family over to danger, the list too', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSelect<String>(
          items: plans,
          label: Text('Plan'),
          color: NebaColor.success,
          error: Text('Choose a plan.'),
        ),
      );

      expect(find.text('Choose a plan.'), findsOneWidget);
      expect(shellOf(tester).edge, danger.line);
      expect(triggerData(tester).validationResult, SemanticsValidationResult.invalid);

      await open(tester);
      expect(tester.widget<NebaSheet>(listSheet()).edge, danger.line);
      semantics.dispose();
    });
  });

  group('style', () {
    testWidgets('is drawn on the same shell as a TextField', (WidgetTester tester) async {
      await pump(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NebaSelect<String>(items: plans, label: Text('Plan')),
            NebaTextField(label: Text('Name')),
          ],
        ),
      );

      final List<Size> sizes = tester
          .widgetList<NebaSheet>(shellSheet())
          .map((NebaSheet sheet) => tester.getSize(find.byWidget(sheet)))
          .toList();
      expect(sizes.first.height, 32);
      expect(sizes.first.height, sizes.last.height);
      expect(shellOf(tester).fill, tokens.panel);
      expect(shellOf(tester).edge, primary.line);
    });

    testWidgets('changes height with size but not with density', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, size: NebaSize.lg));
      final double width = tester.getSize(shellSheet()).width;
      expect(tester.getSize(shellSheet()).height, 40);

      await pump(
        tester,
        const NebaSelect<String>(items: plans, size: NebaSize.lg, density: NebaDensity.compact),
      );
      expect(tester.getSize(shellSheet()).height, 40);
      expect(tester.getSize(shellSheet()).width, lessThan(width));
    });

    testWidgets('takes its size, variant and density from the provider', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(items: plans),
        defaults: const NebaDefaults(size: NebaSize.lg, variant: NebaVariant.solid),
      );

      expect(tester.getSize(shellSheet()).height, 40);
      expect(shellOf(tester).edge, isNull);
    });

    testWidgets('opens its list on the frosted sheet, raised, under the trigger', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSelect<String>(items: plans, color: NebaColor.info));
      await open(tester);

      final NebaSheet sheet = tester.widget<NebaSheet>(listSheet());
      expect(sheet.fill, tokens.panelPress);
      expect(sheet.edge, tokens.roles(NebaColor.info).line);
      expect(sheet.elevation, 3);

      final Rect trigger = tester.getRect(shellSheet());
      final Rect list = tester.getRect(listSheet());
      expect(list.top, trigger.bottom + 6);
      expect(list.width, greaterThanOrEqualTo(trigger.width));
    });

    testWidgets('lights the highlighted row in its family', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));
      await open(tester);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(row('Team')));
      addTearDown(mouse.removePointer);
      await mouse.moveBy(const Offset(1, 0));
      await settle(tester);

      expect(rowOf(tester, 'Team').highlighted, isTrue);
      final DecoratedBox wash = tester.widget<DecoratedBox>(
        find.descendant(of: row('Team'), matching: find.byType(DecoratedBox)).first,
      );
      expect((wash.decoration as BoxDecoration).color, primary.softHover);

      await mouse.moveTo(tester.getCenter(row('Starter')));
      await tester.pump();
      expect(rowOf(tester, 'Team').highlighted, isFalse);
      expect(rowOf(tester, 'Starter').highlighted, isTrue);
    });

    testWidgets('fades the list in opacity only', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: plans, label: Text('Plan')));

      await tester.tap(find.byType(NebaFieldShell));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.byType(NebaListSheet), matching: find.byType(FadeTransition)).first,
      );
      expect(fade.opacity.value, greaterThan(0));
      expect(fade.opacity.value, lessThan(1));
      expect(
        find.ancestor(of: find.byType(NebaListSheet), matching: find.byType(Transform)),
        findsNothing,
      );
      await settle(tester);
    });

    testWidgets('scrolls a long list, and keeps the highlight in view', (
      WidgetTester tester,
    ) async {
      final List<NebaSelectOption<int>> rows = <NebaSelectOption<int>>[
        for (int i = 0; i < 40; i++) NebaSelectOption<int>(value: i, label: Text('Row $i')),
      ];

      await pump(tester, NebaSelect<int>(items: rows, label: const Text('Row')));
      await focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      final Rect list = tester.getRect(listSheet());
      expect(list.height, lessThanOrEqualTo(nebaListMaxHeight));

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await settle(tester);

      final Rect last = tester.getRect(row('Row 39'));
      expect(last.bottom, lessThanOrEqualTo(list.bottom));
      expect(last.top, greaterThanOrEqualTo(list.top));
    });

    testWidgets('opens a long list on the chosen option, in view', (WidgetTester tester) async {
      final List<NebaSelectOption<int>> rows = <NebaSelectOption<int>>[
        for (int i = 0; i < 40; i++) NebaSelectOption<int>(value: i, label: Text('Row $i')),
      ];

      await pump(tester, NebaSelect<int>(items: rows, label: const Text('Row'), defaultValue: 30));
      await open(tester);

      final Rect list = tester.getRect(listSheet());
      final Rect chosen = tester.getRect(row('Row 30'));
      expect(chosen.bottom, lessThanOrEqualTo(list.bottom));
    });
  });

  group('width', () {
    const List<NebaSelectOption<String>> cities = <NebaSelectOption<String>>[
      NebaSelectOption<String>(value: 'kr', label: Text('Seoul')),
      NebaSelectOption<String>(value: 'us', label: Text('Washington DC')),
      NebaSelectOption<String>(value: 'de'),
    ];

    testWidgets('is as wide as its widest option, whichever is chosen', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(items: cities, label: Text('Region'), defaultValue: 'kr'),
      );
      final double seoul = tester.getSize(shellSheet()).width;

      // A new key, so the second select starts from its own default.
      await pump(
        tester,
        const NebaSelect<String>(
          key: Key('second'),
          items: cities,
          label: Text('Region'),
          defaultValue: 'us',
        ),
      );
      final double washington = tester.getSize(shellSheet()).width;

      expect(seoul, washington);

      // The trigger holds the widest label with its padding and the chevron.
      final double text = tester.getSize(find.text('Washington DC')).width;
      expect(washington, greaterThanOrEqualTo(text + 2 * 16));
    });

    testWidgets('reserves the room without putting the words on the screen', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(items: cities, label: Text('Region'), defaultValue: 'kr'),
      );

      expect(find.text('Washington DC'), findsNothing);
      expect(find.text('Seoul'), findsOneWidget);
    });

    testWidgets('reserves room for the placeholder too', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSelect<String>(
          items: <NebaSelectOption<String>>[NebaSelectOption<String>(value: 'a', label: Text('A'))],
          placeholder: Text('Choose a region'),
        ),
      );
      final double withPlaceholder = tester.getSize(shellSheet()).width;

      await pump(
        tester,
        const NebaSelect<String>(
          key: Key('bare'),
          items: <NebaSelectOption<String>>[NebaSelectOption<String>(value: 'a', label: Text('A'))],
          defaultValue: 'a',
          placeholder: Text('Choose a region'),
        ),
      );
      expect(tester.getSize(shellSheet()).width, withPlaceholder);
    });

    testWidgets('follows a changed item list', (WidgetTester tester) async {
      await pump(tester, const NebaSelect<String>(items: cities, label: Text('Region')));
      final double before = tester.getSize(shellSheet()).width;

      await pump(
        tester,
        const NebaSelect<String>(
          items: <NebaSelectOption<String>>[
            NebaSelectOption<String>(value: 'jp', label: Text('Tokyo')),
          ],
          label: Text('Region'),
        ),
      );

      expect(tester.getSize(shellSheet()).width, lessThan(before));
    });

    testWidgets('stretches to the container when full width, and yields to a narrow one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const SizedBox(
          width: 500,
          child: NebaSelect<String>(items: cities, label: Text('Region'), fullWidth: true),
        ),
      );
      expect(tester.getSize(shellSheet()).width, 500);

      await pump(
        tester,
        const SizedBox(
          width: 60,
          child: NebaSelect<String>(items: cities, label: Text('Region'), defaultValue: 'us'),
        ),
      );
      expect(tester.getSize(shellSheet()).width, 60);
      expect(tester.takeException(), isNull);
    });

    test('lays out only the samples that could be the widest', () {
      const List<Widget> samples = <Widget>[
        Text('Korea'),
        Text('Bolivia (Plurinational State of)'),
        Text('United Kingdom of Great Britain and Northern Ireland'),
        Text('Chad'),
        SizedBox(width: 10),
      ];

      final List<Widget> kept = nebaWidestSamples(samples);

      expect(kept, <Widget>[samples[1], samples[2], samples[4]]);
    });
  });

  group('label placement', () {
    testWidgets('names the trigger from a notched label on its edge', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSelect<String>(
          items: plans,
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Plan'),
        ),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(triggerData(tester).label, 'Plan');
      semantics.dispose();
    });

    testWidgets('rests a floating label while nothing is chosen and the list is closed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(
          items: plans,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Billing plan'),
          placeholder: Text('Pick'),
        ),
      );
      await settle(tester);

      bool resting() => tester.widget<NebaNotch>(find.byType(NebaNotch)).resting;
      expect(resting(), isTrue);
      // The placeholder is under it, out of sight.
      expect(DefaultTextStyle.of(tester.element(find.text('Pick'))).style.color!.a, 0);

      await open(tester);
      expect(resting(), isFalse);

      await tester.tap(row('Team'));
      await settle(tester);
      expect(resting(), isFalse);
    });

    testWidgets('makes room for a resting label longer than every option', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(
          items: <NebaSelectOption<String>>[NebaSelectOption<String>(value: 'a', label: Text('A'))],
          labelPlacement: NebaLabelPlacement.float,
          label: Text('A rather long name for a field'),
        ),
      );
      final double floating = tester.getSize(shellSheet()).width;

      await pump(
        tester,
        const NebaSelect<String>(
          items: <NebaSelectOption<String>>[NebaSelectOption<String>(value: 'a', label: Text('A'))],
        ),
      );

      expect(floating, greaterThan(tester.getSize(shellSheet()).width));
    });

    testWidgets('keeps a floating label on the edge beside a start icon', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSelect<String>(
          items: plans,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Plan'),
          startIcon: SizedBox(width: 10, height: 10),
        ),
      );

      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).resting, isFalse);
    });
  });

  group('inside a popover', () {
    testWidgets('opens its list over the popover, which stays open, and takes the focus', (
      WidgetTester tester,
    ) async {
      final List<String> chosen = <String>[];

      await pump(
        tester,
        NebaPopover(
          trigger: NebaButton(onPressed: () {}, child: const Text('Filter')),
          title: const Text('Filter'),
          child: NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 3,
            children: <Widget>[
              const NebaTextField(label: Text('Commit'), fullWidth: true),
              NebaSelect<String>(
                items: plans,
                label: const Text('Plan'),
                fullWidth: true,
                onValueChange: chosen.add,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Filter').first, kind: PointerDeviceKind.mouse);
      await settle(tester);

      await tester.tap(find.byType(NebaFieldShell).last, kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(find.byType(NebaListSheet), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'NebaSelect list');

      await tester.tap(row('Team'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(chosen, <String>['team']);
      expect(find.byType(NebaListSheet), findsNothing);
      // The popover is still there, with the focus back on the select.
      expect(find.byType(NebaSelect<String>), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'NebaSelect');
    });
  });
}
