// NebaCheckboxGroup: the suite the React package runs on CheckboxGroup, asked
// the way Flutter asks it — the group a screen reader hears, the list it keeps,
// the parent checkbox's cycle, the gaps it stands its options at, and what each
// checkbox takes from it.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Widget alerts({
    List<String>? value,
    List<String> defaultValue = const <String>[],
    ValueChanged<List<String>>? onValueChange,
    NebaOrientation orientation = NebaOrientation.vertical,
    NebaSize? size,
    double? spacing,
    Widget? description,
    Widget? error,
    bool disabled = false,
    bool readOnly = false,
  }) {
    return NebaCheckboxGroup(
      label: const Text('Email me about'),
      value: value,
      defaultValue: defaultValue,
      onValueChange: onValueChange,
      orientation: orientation,
      size: size,
      spacing: spacing,
      description: description,
      error: error,
      disabled: disabled,
      readOnly: readOnly,
      children: const <Widget>[
        NebaCheckbox(value: 'deploys', label: Text('Deploys')),
        NebaCheckbox(value: 'members', label: Text('New members')),
        NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
      ],
    );
  }

  Future<void> pump(WidgetTester tester, Widget group) {
    return tester.pumpWidget(host(Center(child: group)));
  }

  Finder box(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(NebaCheckbox));
  }

  NebaSheet sheetOf(WidgetTester tester, String label) {
    return tester.widget<NebaSheet>(
      find.descendant(of: box(label), matching: find.byType(NebaSheet)),
    );
  }

  Matcher heard(String label, {bool checked = false, bool mixed = false, bool enabled = true}) {
    return matchesSemantics(
      label: label,
      hasCheckedState: true,
      isChecked: checked,
      isCheckStateMixed: mixed,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: enabled,
      hasTapAction: enabled,
      hasFocusAction: enabled,
    );
  }

  group('rendering', () {
    testWidgets('is a group named by its label, holding its checkboxes', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, alerts(description: const Text('Sent from a robot.')));

      final SemanticsNode node = tester.getSemantics(find.byType(NebaCheckboxGroup));
      expect(node.label, 'Email me about');
      expect(node.hint, 'Sent from a robot.');
      expect(tester.getSemantics(box('Deploys')), heard('Deploys'));
      expect(find.byType(NebaCheckbox), findsNWidgets(3));
      semantics.dispose();
    });

    testWidgets('puts the description between the label and the checkboxes', (
      WidgetTester tester,
    ) async {
      await pump(tester, alerts(description: const Text('Sent from a robot.')));

      final Rect label = tester.getRect(find.text('Email me about'));
      final Rect description = tester.getRect(find.text('Sent from a robot.'));

      expect(description.top, label.bottom + 6);
      expect(tester.getTopLeft(box('Deploys')).dy, description.bottom + 6);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Email me about'))).style.fontWeight,
        FontWeight.w500,
      );
    });

    testWidgets('stacks the checkboxes in a column, and in a row on request', (
      WidgetTester tester,
    ) async {
      await pump(tester, alerts());
      expect(
        tester.getTopLeft(box('New members')).dy - tester.getBottomLeft(box('Deploys')).dy,
        NebaScale.sheetSectionGap[NebaSize.md],
      );

      await pump(tester, alerts(size: NebaSize.xs));
      expect(tester.getTopLeft(box('New members')).dy - tester.getBottomLeft(box('Deploys')).dy, 6);

      await pump(tester, alerts(orientation: NebaOrientation.horizontal));
      expect(tester.getTopLeft(box('New members')).dy, tester.getTopLeft(box('Deploys')).dy);
      expect(tester.getTopLeft(box('New members')).dx - tester.getTopRight(box('Deploys')).dx, 20);
      final Wrap wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.runSpacing, NebaScale.sheetSectionGap[NebaSize.md]);
    });

    testWidgets('stands the checkboxes spacing apart on both axes', (WidgetTester tester) async {
      await pump(tester, alerts(spacing: 3));
      expect(
        tester.getTopLeft(box('New members')).dy - tester.getBottomLeft(box('Deploys')).dy,
        12,
      );

      await pump(tester, alerts(spacing: 3, orientation: NebaOrientation.horizontal));
      final Wrap wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 12);
      expect(wrap.runSpacing, 12);
    });

    testWidgets('takes no spacing from a provider', (WidgetTester tester) async {
      await pump(tester, NebaProvider(defaults: const NebaDefaults(spacing: 8), child: alerts()));

      expect(
        tester.getTopLeft(box('New members')).dy - tester.getBottomLeft(box('Deploys')).dy,
        NebaScale.sheetSectionGap[NebaSize.md],
      );
    });

    testWidgets('is as wide as its widest part when nothing stretches it', (
      WidgetTester tester,
    ) async {
      await pump(tester, alerts());

      expect(
        tester.getSize(find.byType(NebaCheckboxGroup)).width,
        tester.getSize(box('The weekly digest')).width,
      );
    });
  });

  group('the value', () {
    testWidgets('ticks what defaultValue names and reports the new list', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        alerts(defaultValue: const <String>['digest'], onValueChange: changes.add),
      );
      expect(
        tester.getSemantics(box('The weekly digest')),
        heard('The weekly digest', checked: true),
      );
      expect(tester.getSemantics(box('Deploys')), heard('Deploys'));

      await tester.tap(find.text('Deploys'));
      await tester.pump();

      expect(changes, <List<String>>[
        <String>['digest', 'deploys'],
      ]);
      expect(tester.getSemantics(box('Deploys')), heard('Deploys', checked: true));
      semantics.dispose();
    });

    testWidgets('follows a controlled value', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, alerts(value: const <String>['members'], onValueChange: (_) {}));
      expect(tester.getSemantics(box('New members')), heard('New members', checked: true));

      await tester.tap(find.text('Deploys'));
      await tester.pump();
      expect(tester.getSemantics(box('Deploys')), heard('Deploys'));

      await pump(tester, alerts(value: const <String>['deploys'], onValueChange: (_) {}));
      expect(tester.getSemantics(box('New members')), heard('New members'));
      expect(tester.getSemantics(box('Deploys')), heard('Deploys', checked: true));
      semantics.dispose();
    });

    testWidgets('calls the checkbox’s own onCheckedChange too', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await pump(
        tester,
        NebaCheckboxGroup(
          children: <Widget>[
            NebaCheckbox(value: 'a', label: const Text('A'), onCheckedChange: changes.add),
          ],
        ),
      );
      await tester.tap(find.text('A'));

      expect(changes, <bool>[true]);
    });

    testWidgets('ticks every option from a parent, which draws a dash while some are', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaCheckboxGroup(
          label: const Text('Email me about'),
          allValues: const <String>['deploys', 'members', 'digest'],
          defaultValue: const <String>['digest'],
          onValueChange: changes.add,
          children: const <Widget>[
            NebaCheckbox(parent: true, label: Text('Everything')),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 24),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 2,
                children: <Widget>[
                  NebaCheckbox(value: 'deploys', label: Text('Deploys')),
                  NebaCheckbox(value: 'members', label: Text('New members')),
                  NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
                ],
              ),
            ),
          ],
        ),
      );

      NebaTickMarkPainter mark() {
        return tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: box('Everything'),
                    matching: find.byWidgetPredicate(
                      (Widget widget) =>
                          widget is CustomPaint && widget.painter is NebaTickMarkPainter,
                    ),
                  ),
                )
                .painter!
            as NebaTickMarkPainter;
      }

      expect(tester.getSemantics(box('Everything')), heard('Everything', mixed: true));
      expect(mark().shape, NebaTickMarkShape.dash);

      // From a mix: everything, then nothing, then the mix again.
      await tester.tap(find.text('Everything'));
      await tester.pump();
      expect(tester.getSemantics(box('Everything')), heard('Everything', checked: true));
      for (final String name in <String>['Deploys', 'New members', 'The weekly digest']) {
        expect(tester.getSemantics(box(name)), heard(name, checked: true));
      }

      await tester.tap(find.text('Everything'));
      await tester.pump();
      await tester.tap(find.text('Everything'));
      await tester.pump();

      expect(changes, <List<String>>[
        <String>['deploys', 'members', 'digest'],
        <String>[],
        <String>['digest'],
      ]);
      semantics.dispose();
    });

    testWidgets('leaves a disabled option as it was when the parent is pressed', (
      WidgetTester tester,
    ) async {
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaCheckboxGroup(
          allValues: const <String>['a', 'b', 'c'],
          onValueChange: changes.add,
          children: const <Widget>[
            NebaCheckbox(parent: true, label: Text('All')),
            NebaCheckbox(value: 'a', label: Text('A')),
            NebaCheckbox(value: 'b', label: Text('B'), disabled: true),
            NebaCheckbox(value: 'c', label: Text('C')),
          ],
        ),
      );
      await tester.tap(find.text('All'));
      await tester.pump();

      expect(changes, <List<String>>[
        <String>['a', 'c'],
      ]);
    });
  });

  group('what each checkbox takes from the group', () {
    testWidgets('its size, unless it sets its own, over the provider’s', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.xs),
          child: NebaCheckboxGroup(
            size: NebaSize.xl,
            children: <Widget>[
              NebaCheckbox(value: 'a', label: Text('Inherited')),
              NebaCheckbox(value: 'b', label: Text('Own'), size: NebaSize.sm),
            ],
          ),
        ),
      );

      Size square(String label) {
        return tester.getSize(find.descendant(of: box(label), matching: find.byType(NebaSheet)));
      }

      expect(square('Inherited'), const Size.square(24));
      expect(square('Own'), const Size.square(16));
    });

    testWidgets('its colour, and danger for every one of them when invalid', (
      WidgetTester tester,
    ) async {
      Widget colours({Widget? error}) {
        return NebaCheckboxGroup(
          color: NebaColor.success,
          error: error,
          defaultValue: const <String>['a', 'b'],
          children: const <Widget>[
            NebaCheckbox(value: 'a', label: Text('Inherited')),
            NebaCheckbox(value: 'b', label: Text('Own'), color: NebaColor.info),
          ],
        );
      }

      await pump(tester, colours());
      expect(sheetOf(tester, 'Inherited').fill, tokens.roles(NebaColor.success).fill);
      expect(sheetOf(tester, 'Own').fill, tokens.roles(NebaColor.info).fill);

      final SemanticsHandle semantics = tester.ensureSemantics();
      await pump(tester, colours(error: const Text('Pick one.')));
      final NebaColorRoles danger = tokens.roles(NebaColor.danger);
      expect(sheetOf(tester, 'Inherited').fill, danger.fill);
      expect(sheetOf(tester, 'Own').fill, danger.fill);
      expect(find.text('Pick one.'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaCheckboxGroup)).getSemanticsData().validationResult,
        SemanticsValidationResult.invalid,
      );
      semantics.dispose();
    });

    testWidgets('disabled, for every one of them', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<String>> changes = <List<String>>[];

      await pump(tester, alerts(disabled: true, onValueChange: changes.add));
      await tester.tap(find.text('Deploys'));
      await tester.pump();

      expect(changes, isEmpty);
      expect(tester.getSemantics(box('Deploys')), heard('Deploys', enabled: false));
      expect(sheetOf(tester, 'Deploys').edge, tokens.disabledBorder);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Email me about'))).style.color,
        tokens.disabledFg,
      );
      semantics.dispose();
    });

    testWidgets('read-only, unless one says otherwise', (WidgetTester tester) async {
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaCheckboxGroup(
          readOnly: true,
          onValueChange: changes.add,
          children: const <Widget>[
            NebaCheckbox(value: 'a', label: Text('Held')),
            NebaCheckbox(value: 'b', label: Text('Free'), readOnly: false),
          ],
        ),
      );
      await tester.tap(find.text('Held'));
      await tester.pump();
      expect(changes, isEmpty);
      expect(
        find.ancestor(
          of: find.descendant(of: box('Held'), matching: find.byType(NebaSheet)),
          matching: find.byType(ColorFiltered),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Free'));
      await tester.pump();
      expect(changes, <List<String>>[
        <String>['b'],
      ]);
    });
  });
}
