// NebaRadioGroup: the suite the React package runs on RadioGroup, asked the
// way Flutter asks it — the radio group a screen reader hears, the value it
// keeps, the one stop it makes in the focus order and where the arrow keys go,
// what each option takes from the set, and the dot that grows into the ring.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Widget plans({
    String? value,
    String? defaultValue,
    ValueChanged<String?>? onValueChange,
    NebaOrientation orientation = NebaOrientation.vertical,
    NebaSize? size,
    NebaColor? color,
    double? spacing,
    Widget? description,
    Widget? error,
    bool disabled = false,
    bool readOnly = false,
  }) {
    return NebaRadioGroup<String>(
      label: const Text('Plan'),
      value: value,
      defaultValue: defaultValue,
      onValueChange: onValueChange,
      orientation: orientation,
      size: size,
      color: color,
      spacing: spacing,
      description: description,
      error: error,
      disabled: disabled,
      readOnly: readOnly,
      children: const <Widget>[
        NebaRadio<String>(value: 'starter', label: Text('Starter')),
        NebaRadio<String>(value: 'team', label: Text('Team')),
        NebaRadio<String>(value: 'enterprise', label: Text('Enterprise'), disabled: true),
      ],
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget group, {
    TextDirection direction = TextDirection.ltr,
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      host(
        Center(child: group),
        textDirection: direction,
        disableAnimations: disableAnimations,
      ),
    );
  }

  Finder option(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(NebaRadio<String>));
  }

  Finder ring(String label) {
    return find.descendant(of: option(label), matching: find.byType(NebaSheet));
  }

  NebaSheet sheetOf(WidgetTester tester, String label) => tester.widget<NebaSheet>(ring(label));

  FocusNode nodeOf(WidgetTester tester, String label) => Focus.of(tester.element(ring(label)));

  Matcher heard(
    String label, {
    bool checked = false,
    bool enabled = true,
    bool readOnly = false,
    bool focused = false,
  }) {
    return matchesSemantics(
      label: label,
      isInMutuallyExclusiveGroup: true,
      hasCheckedState: true,
      isChecked: checked,
      hasEnabledState: true,
      isEnabled: enabled,
      isReadOnly: readOnly,
      isFocusable: enabled,
      isFocused: focused,
      hasTapAction: enabled && !readOnly,
      hasFocusAction: enabled,
    );
  }

  double dotOf(WidgetTester tester, String label) {
    return tester
        .getSize(
          find.descendant(
            of: find.descendant(of: option(label), matching: find.byType(NebaTickDot)),
            matching: find.byType(SizedBox),
          ),
        )
        .width;
  }

  group('rendering', () {
    testWidgets('is a radio group of radios, named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        plans(defaultValue: 'team', description: const Text('Change it any time.')),
      );

      final SemanticsData set = tester
          .getSemantics(find.byType(NebaRadioGroup<String>))
          .getSemanticsData();
      expect(set.role, SemanticsRole.radioGroup);
      expect(set.label, 'Plan');
      expect(set.hint, 'Change it any time.');
      expect(tester.getSemantics(option('Team')), heard('Team', checked: true));
      expect(tester.getSemantics(option('Starter')), heard('Starter'));
      expect(tester.getSemantics(option('Enterprise')), heard('Enterprise', enabled: false));
      semantics.dispose();
    });

    testWidgets('reads an option’s description after its name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaRadioGroup<String>(
          label: Text('Plan'),
          children: <Widget>[
            NebaRadio<String>(
              value: 'team',
              label: Text('Team'),
              description: Text('Up to twelve seats.'),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(option('Team')).getSemanticsData().hint, 'Up to twelve seats.');
      semantics.dispose();
    });

    testWidgets('stacks the options on the field ladder, and in a row on request', (
      WidgetTester tester,
    ) async {
      double between(String a, String b) {
        return tester.getTopLeft(option(b)).dy - tester.getBottomLeft(option(a)).dy;
      }

      await pump(tester, plans());
      expect(between('Starter', 'Team'), 12);

      await pump(tester, plans(size: NebaSize.xl));
      expect(between('Starter', 'Team'), 16);

      await pump(tester, plans(orientation: NebaOrientation.horizontal));
      expect(tester.getTopLeft(option('Team')).dy, tester.getTopLeft(option('Starter')).dy);
      expect(tester.getTopLeft(option('Team')).dx - tester.getTopRight(option('Starter')).dx, 20);
      expect(tester.widget<Wrap>(find.byType(Wrap)).runSpacing, 12);
    });

    testWidgets('stands the options spacing apart on both axes', (WidgetTester tester) async {
      await pump(tester, plans(spacing: 4));
      expect(tester.getTopLeft(option('Team')).dy - tester.getBottomLeft(option('Starter')).dy, 16);

      await pump(tester, plans(spacing: 4, orientation: NebaOrientation.horizontal));
      final Wrap wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 16);
      expect(wrap.runSpacing, 16);
    });

    testWidgets('refuses an option outside a group', (WidgetTester tester) async {
      await pump(tester, const NebaRadio<String>(value: 'a', label: Text('Alone')));

      expect(tester.takeException(), isFlutterError);
    });
  });

  group('behaviour', () {
    testWidgets('chooses an option when its label is pressed, and reports it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String?> changes = <String?>[];

      await pump(tester, plans(onValueChange: changes.add));
      await tester.tap(find.text('Team'));
      await tester.pump();

      expect(changes, <String?>['team']);
      expect(tester.getSemantics(option('Team')), heard('Team', checked: true));
      expect(tester.getSemantics(option('Starter')), heard('Starter'));

      // The chosen one again changes nothing.
      await tester.tap(ring('Team'));
      await tester.pump();
      expect(changes, <String?>['team']);
      semantics.dispose();
    });

    testWidgets('follows a controlled value', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, plans(value: 'team', onValueChange: (_) {}));
      expect(tester.getSemantics(option('Team')), heard('Team', checked: true));

      await tester.tap(find.text('Starter'));
      await tester.pump();
      expect(tester.getSemantics(option('Team')), heard('Team', checked: true));

      await pump(tester, plans(value: 'starter', onValueChange: (_) {}));
      expect(tester.getSemantics(option('Starter')), heard('Starter', checked: true));
      semantics.dispose();
    });

    testWidgets('starts from defaultValue when uncontrolled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, plans(defaultValue: 'enterprise'));

      expect(
        tester.getSemantics(option('Enterprise')),
        heard('Enterprise', checked: true, enabled: false),
      );
      semantics.dispose();
    });

    testWidgets('draws every option disabled when the group is, and takes no choice', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String?> changes = <String?>[];

      await pump(tester, plans(disabled: true, onValueChange: changes.add));
      await tester.tap(find.text('Starter'));
      await tester.tap(ring('Team'));
      await tester.pump();

      expect(changes, isEmpty);
      expect(tester.getSemantics(option('Starter')), heard('Starter', enabled: false));
      expect(sheetOf(tester, 'Starter').edge, tokens.disabledBorder);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Starter'))).style.color,
        tokens.disabledFg,
      );
      semantics.dispose();
    });

    testWidgets('leaves a disabled option out of reach', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(tester, plans(onValueChange: changes.add));
      await tester.tap(find.text('Enterprise'));
      await tester.pump();

      expect(changes, isEmpty);
      expect(nodeOf(tester, 'Enterprise').canRequestFocus, isFalse);
    });

    testWidgets('does not change when read-only, and drains every option', (
      WidgetTester tester,
    ) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        plans(readOnly: true, defaultValue: 'starter', onValueChange: changes.add),
      );
      await tester.tap(find.text('Team'));
      await tester.pump();

      expect(changes, isEmpty);
      expect(
        find.ancestor(of: ring('Starter'), matching: find.byType(ColorFiltered)),
        findsOneWidget,
      );
    });
  });

  group('the focus', () {
    testWidgets('makes one stop for the whole set, at the chosen option', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode(debugLabel: 'before node');
      final FocusNode after = FocusNode(debugLabel: 'after node');
      addTearDown(before.dispose);
      addTearDown(after.dispose);

      await pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Focus(focusNode: before, child: const SizedBox(width: 10, height: 10)),
            plans(defaultValue: 'team'),
            Focus(focusNode: after, child: const SizedBox(width: 10, height: 10)),
          ],
        ),
      );

      before.requestFocus();
      await tester.pump();
      before.nextFocus();
      await tester.pump();
      expect(nodeOf(tester, 'Team').hasPrimaryFocus, isTrue);

      nodeOf(tester, 'Team').nextFocus();
      await tester.pump();
      expect(after.hasPrimaryFocus, isTrue);

      after.previousFocus();
      await tester.pump();
      expect(nodeOf(tester, 'Team').hasPrimaryFocus, isTrue);
    });

    testWidgets('stops at the first option when none is chosen', (WidgetTester tester) async {
      final FocusNode before = FocusNode(debugLabel: 'before node');
      addTearDown(before.dispose);

      await pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Focus(focusNode: before, child: const SizedBox(width: 10, height: 10)),
            plans(),
          ],
        ),
      );

      before.requestFocus();
      await tester.pump();
      before.nextFocus();
      await tester.pump();
      expect(nodeOf(tester, 'Starter').hasPrimaryFocus, isTrue);
    });

    testWidgets('moves with the arrow keys and chooses as it goes, past a disabled one', (
      WidgetTester tester,
    ) async {
      final List<String?> changes = <String?>[];

      await pump(tester, plans(defaultValue: 'starter', onValueChange: changes.add));
      nodeOf(tester, 'Starter').requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(nodeOf(tester, 'Team').hasPrimaryFocus, isTrue);

      // Enterprise is disabled, so the next one round is Starter again.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Starter').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(nodeOf(tester, 'Team').hasPrimaryFocus, isTrue);

      expect(changes, <String?>['team', 'starter', 'team']);
    });

    testWidgets('reads the arrows the other way round right to left', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        plans(orientation: NebaOrientation.horizontal, onValueChange: changes.add),
        direction: TextDirection.rtl,
      );
      nodeOf(tester, 'Starter').requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(changes, <String?>['team']);
      expect(tester.getCenter(option('Team')).dx, lessThan(tester.getCenter(option('Starter')).dx));
    });

    testWidgets('moves without choosing while read-only', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        plans(readOnly: true, defaultValue: 'starter', onValueChange: changes.add),
      );
      nodeOf(tester, 'Starter').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(nodeOf(tester, 'Team').hasPrimaryFocus, isTrue);
      expect(changes, isEmpty);
    });
  });

  group('what each option takes from the set', () {
    testWidgets('its size', (WidgetTester tester) async {
      await pump(tester, plans(size: NebaSize.xl));

      expect(tester.getSize(ring('Starter')), const Size.square(24));
    });

    testWidgets('its colour family, and danger when the set is invalid', (
      WidgetTester tester,
    ) async {
      await pump(tester, plans(color: NebaColor.success, defaultValue: 'team'));
      expect(sheetOf(tester, 'Team').fill, tokens.roles(NebaColor.success).fill);

      await pump(tester, plans(defaultValue: 'team', error: const Text('Choose one.')));
      final NebaColorRoles danger = tokens.roles(NebaColor.danger);
      expect(sheetOf(tester, 'Team').fill, danger.fill);
      expect(sheetOf(tester, 'Starter').edge, danger.line);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Choose one.'))).style.color,
        danger.accent,
      );
    });
  });

  group('the ring and the dot', () {
    testWidgets('is round, with no plate, and fills when chosen', (WidgetTester tester) async {
      await pump(tester, plans(defaultValue: 'team'));

      expect(sheetOf(tester, 'Team').plate, NebaPlate.none);
      expect(sheetOf(tester, 'Team').fill, primary.fill);
      expect(sheetOf(tester, 'Starter').fill, tokens.panel);
      expect(sheetOf(tester, 'Starter').edge, primary.line);
      expect(
        sheetOf(tester, 'Starter').borderRadius,
        const BorderRadius.all(Radius.circular(9999)),
      );
    });

    // Whole, even pixels, so the dot sits on the ring's own pixel grid.
    testWidgets('sizes the dot in whole pixels, with the set', (WidgetTester tester) async {
      await pump(tester, plans(defaultValue: 'team'));
      expect(dotOf(tester, 'Team'), 8);
      expect(dotOf(tester, 'Starter'), 0);

      await pump(tester, plans(defaultValue: 'team', size: NebaSize.xl));
      await tester.pump(NebaScale.duration);
      expect(dotOf(tester, 'Team'), 10);
    });

    testWidgets('grows the dot into the ring rather than showing it whole', (
      WidgetTester tester,
    ) async {
      await pump(tester, plans(defaultValue: 'starter'));
      await tester.tap(find.text('Team'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 4);

      expect(dotOf(tester, 'Team'), greaterThan(0));
      expect(dotOf(tester, 'Team'), lessThan(8));
      expect(dotOf(tester, 'Starter'), greaterThan(0));
      expect(dotOf(tester, 'Starter'), lessThan(8));

      await tester.pump(NebaScale.duration);
      expect(dotOf(tester, 'Team'), 8);
      expect(dotOf(tester, 'Starter'), 0);
      expect(
        find.descendant(of: find.byType(NebaRadioGroup<String>), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('draws a disabled chosen dot in the disabled ink', (WidgetTester tester) async {
      await pump(tester, plans(defaultValue: 'enterprise'));
      await tester.pump(NebaScale.duration);

      final DecoratedBox dot = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.descendant(of: option('Enterprise'), matching: find.byType(NebaTickDot)),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((dot.decoration as BoxDecoration).color, tokens.disabledFg);
      expect(sheetOf(tester, 'Enterprise').fill, tokens.disabledBg);
    });

    testWidgets('centres the ring on the first line of its label', (WidgetTester tester) async {
      await pump(
        tester,
        const SizedBox(
          width: 220,
          child: NebaRadioGroup<String>(
            children: <Widget>[
              NebaRadio<String>(
                value: 'a',
                label: Text('A label long enough to wrap onto more lines'),
                description: Text('And a description under it.'),
              ),
            ],
          ),
        ),
      );

      final double line = NebaScale.controlText[NebaSize.md]! * 1.4;
      final Rect label = tester.getRect(find.text('A label long enough to wrap onto more lines'));

      expect(tester.getCenter(find.byType(NebaSheet)).dy, moreOrLessEquals(label.top + line / 2));
    });
  });
}
