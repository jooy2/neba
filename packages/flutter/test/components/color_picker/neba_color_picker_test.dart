// NebaColorPicker: the suite the React package runs on ColorPicker, asked the
// way Flutter asks it — the semantics each slider, swatch and field builds,
// what a key, a press and a drag do to the colour, and the trigger and popup
// it opens — rather than the elements and the ARIA it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/notch.dart';

import '../../support/host.dart';

void main() {
  setUpAll(() => registerNebaMessages('ko', ko));

  Future<void> pump(WidgetTester tester, Widget picker, {Widget? after}) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[picker, ?after]),
          ),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  SemanticsData data(WidgetTester tester, String label) {
    return tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData();
  }

  String? valueOf(WidgetTester tester, String label) => data(tester, label).value;

  FocusNode sliderNode(WidgetTester tester, String label) {
    return Focus.of(
      tester.element(
        find.descendant(of: find.bySemanticsLabel(label), matching: find.byType(NebaDragRegion)),
      ),
    );
  }

  Future<void> focusSlider(WidgetTester tester, String label) async {
    sliderNode(tester, label).requestFocus();
    await tester.pump();
    await tester.pump();
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key, {bool shift = false}) async {
    if (shift) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    }

    await tester.sendKeyEvent(key);

    if (shift) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    }

    await tester.pump();
  }

  FocusNode triggerNode(WidgetTester tester) {
    return Focus.of(
      tester.element(
        find.descendant(of: find.byType(NebaFieldShell), matching: find.byType(Row)).at(1),
      ),
    );
  }

  group('rendering', () {
    testWidgets('renders a trigger that reads the current colour', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(defaultValue: '#ff0000'));

      // Read as its value, as every picker's trigger reads what it holds.
      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Choose a colour',
          value: '#ff0000',
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

    testWidgets('names a trigger by its label and says the colour as its value', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(label: Text('Accent'), defaultValue: '#ff0000'));

      final SemanticsData node = tester
          .getSemantics(find.byType(NebaFieldWidth))
          .getSemanticsData();

      expect(node.label, 'Accent');
      expect(node.value, '#ff0000');

      semantics.dispose();
    });

    testWidgets('names and describes an inline picker as one group', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(
          inline: true,
          label: Text('Accent'),
          description: Text('Used for links and buttons.'),
          defaultValue: '#ff0000',
        ),
      );

      final SemanticsData group = data(tester, 'Accent');

      expect(group.hint, 'Used for links and buttons.');
      expect(find.bySemanticsLabel('Hue'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('draws the panel in the page when inline', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#ff0000'));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Saturation and brightness')),
        matchesSemantics(
          label: 'Saturation and brightness',
          value: 'Saturation 100%, brightness 100%',
          isSlider: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasIncreaseAction: false,
          hasDecreaseAction: true,
          decreasedValue: 'Saturation 99%, brightness 100%',
          hasFocusAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Hue'), findsOneWidget);
      expect(find.byType(NebaFieldShell), findsNothing);

      semantics.dispose();
    });

    testWidgets('has no opacity rail until it is asked for', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#ff0000'));

      expect(find.bySemanticsLabel('Opacity'), findsNothing);

      await pump(tester, const NebaColorPicker(inline: true, alpha: true, defaultValue: '#ff0000'));

      expect(find.bySemanticsLabel('Opacity'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('names its parts in the locale it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(inline: true, locale: Locale('ko'), defaultValue: '#ff0000'),
      );

      expect(find.bySemanticsLabel('색상'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('takes one label at a time as an override', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(
          inline: true,
          labels: NebaColorPickerLabels(hue: 'Colour wheel'),
          defaultValue: '#ff0000',
        ),
      );

      expect(find.bySemanticsLabel('Colour wheel'), findsOneWidget);
      expect(find.bySemanticsLabel('Saturation and brightness'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('lays the panel out on its own ladder', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaColorPicker(inline: true, size: size));

        final Finder area = find.descendant(
          of: find.bySemanticsLabel('Saturation and brightness'),
          matching: find.byType(NebaDragRegion),
        );

        expect(tester.getSize(area).width, NebaColorPicker.panelWidth[size]);
        expect(tester.getSize(area).height, NebaColorPicker.areaHeight[size]);
      }
    });
  });

  group('reading the value', () {
    testWidgets('places the hue rail from the value it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#00ff00'));

      expect(valueOf(tester, 'Hue'), '120°');

      semantics.dispose();
    });

    testWidgets('reads rgb() and hsl() as readily as hex', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: 'rgb(0, 0, 255)'));
      expect(valueOf(tester, 'Hue'), '240°');

      await pump(
        tester,
        NebaColorPicker(key: UniqueKey(), inline: true, defaultValue: 'hsl(60, 100%, 50%)'),
      );
      expect(valueOf(tester, 'Hue'), '60°');

      semantics.dispose();
    });

    testWidgets('follows a controlled value', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaColorPicker(inline: true, value: '#ff0000', onValueChange: (_) {}));
      expect(valueOf(tester, 'Hue'), '0°');

      await pump(tester, NebaColorPicker(inline: true, value: '#00ffff', onValueChange: (_) {}));
      expect(valueOf(tester, 'Hue'), '180°');

      semantics.dispose();
    });

    testWidgets('goes back to a controlled value its caller did not change', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(inline: true, value: '#ff0000', onValueChange: changes.add),
      );
      await focusSlider(tester, 'Hue');
      await press(tester, LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(changes, <String>['#ff0800']);
      expect(valueOf(tester, 'Hue'), '0°');

      semantics.dispose();
    });
  });

  group('choosing', () {
    testWidgets('reports the swatch that was pressed', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(
          inline: true,
          swatches: const <String>['#ff0000', '#00ff00'],
          onValueChange: changes.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('#00ff00'));
      await tester.pump();

      expect(changes, <String>['#00ff00']);
    });

    testWidgets('marks the swatch that is currently chosen', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(
          inline: true,
          swatches: <String>['#ff0000', '#00ff00'],
          defaultValue: '#00ff00',
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('#00ff00')),
        matchesSemantics(
          label: '#00ff00',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('#ff0000')),
        matchesSemantics(
          label: '#ff0000',
          isButton: true,
          hasSelectedState: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('moves the hue with the arrow keys, a bigger step with shift', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(inline: true, defaultValue: '#ff0000', onValueChange: changes.add),
      );
      await focusSlider(tester, 'Hue');
      await press(tester, LogicalKeyboardKey.arrowRight);

      expect(changes, isNotEmpty);
      expect(valueOf(tester, 'Hue'), '2°');

      await press(tester, LogicalKeyboardKey.arrowRight, shift: true);

      expect(valueOf(tester, 'Hue'), '22°');

      semantics.dispose();
    });

    testWidgets('moves a rail with every key a slider answers', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, alpha: true, defaultValue: '#ff0000'));
      await focusSlider(tester, 'Hue');

      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(valueOf(tester, 'Hue'), '2°');
      await press(tester, LogicalKeyboardKey.pageUp);
      expect(valueOf(tester, 'Hue'), '22°');
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(valueOf(tester, 'Hue'), '20°');
      await press(tester, LogicalKeyboardKey.end);
      expect(valueOf(tester, 'Hue'), '360°');
      await press(tester, LogicalKeyboardKey.home);
      expect(valueOf(tester, 'Hue'), '0°');

      await focusSlider(tester, 'Opacity');
      await press(tester, LogicalKeyboardKey.pageDown);
      expect(valueOf(tester, 'Opacity'), '90%');
      await press(tester, LogicalKeyboardKey.home);
      expect(valueOf(tester, 'Opacity'), '0%');

      semantics.dispose();
    });

    testWidgets('wraps the hue round rather than stopping at either end', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#ff0000'));
      await focusSlider(tester, 'Hue');
      await press(tester, LogicalKeyboardKey.arrowLeft);

      expect(valueOf(tester, 'Hue'), '358°');

      semantics.dispose();
    });

    testWidgets('leaves Tab to the focus order', (WidgetTester tester) async {
      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#ff0000'));
      await focusSlider(tester, 'Saturation and brightness');

      final KeyEventResult result =
          sliderNode(tester, 'Saturation and brightness').onKeyEvent?.call(
            sliderNode(tester, 'Saturation and brightness'),
            const KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.tab,
              logicalKey: LogicalKeyboardKey.tab,
              timeStamp: Duration.zero,
            ),
          ) ??
          KeyEventResult.ignored;

      expect(result, KeyEventResult.ignored);
    });

    testWidgets('reads each slider out as what it measures', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(inline: true, alpha: true, defaultValue: '#ff000080'),
      );

      expect(valueOf(tester, 'Saturation and brightness'), 'Saturation 100%, brightness 100%');
      expect(valueOf(tester, 'Hue'), '0°');
      expect(valueOf(tester, 'Opacity'), '50%');

      semantics.dispose();
    });

    testWidgets('reads the square in the language it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(inline: true, locale: Locale('ko'), defaultValue: '#ff0000'),
      );

      expect(valueOf(tester, '채도와 명도'), '채도 100%, 명도 100%');

      semantics.dispose();
    });

    testWidgets('moves the square with the keyboard', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      const String area = 'Saturation and brightness';

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#ff0000'));
      await focusSlider(tester, area);

      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(valueOf(tester, area), 'Saturation 99%, brightness 100%');
      await press(tester, LogicalKeyboardKey.home);
      expect(valueOf(tester, area), 'Saturation 0%, brightness 100%');
      await press(tester, LogicalKeyboardKey.end);
      await press(tester, LogicalKeyboardKey.pageDown);
      expect(valueOf(tester, area), 'Saturation 100%, brightness 90%');

      semantics.dispose();
    });

    testWidgets('moves the square to where it is pressed and dragged', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      const String area = 'Saturation and brightness';
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(inline: true, defaultValue: '#ff0000', onValueChange: changes.add),
      );

      final Finder well = find.descendant(
        of: find.bySemanticsLabel(area),
        matching: find.byType(NebaDragRegion),
      );
      final Rect box = tester.getRect(well);
      final TestGesture gesture = await tester.startGesture(box.center);
      await tester.pump();

      expect(valueOf(tester, area), 'Saturation 50%, brightness 50%');

      await gesture.moveTo(box.topRight);
      await tester.pump();

      expect(valueOf(tester, area), 'Saturation 100%, brightness 100%');

      await gesture.up();
      await tester.pump();

      expect(changes.last, '#ff0000');

      semantics.dispose();
    });

    // A hue read back out of black would be red, and the rail would jump.
    testWidgets('keeps the hue when the square is dragged into black', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      String value = '#00ff00';

      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Center(
                child: NebaColorPicker(
                  inline: true,
                  value: value,
                  onValueChange: (String next) => setState(() => value = next),
                ),
              );
            },
          ),
        ),
      );

      final Rect box = tester.getRect(
        find.descendant(
          of: find.bySemanticsLabel('Saturation and brightness'),
          matching: find.byType(NebaDragRegion),
        ),
      );
      final TestGesture gesture = await tester.startGesture(box.center);
      await gesture.moveTo(box.bottomLeft);
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await tester.pump();

      expect(value, '#000000');
      expect(valueOf(tester, 'Hue'), '120°');

      semantics.dispose();
    });

    testWidgets('writes the value back in the notation it was asked for', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(
          inline: true,
          format: NebaColorFormat.rgb,
          swatches: const <String>['#ff0000'],
          onValueChange: changes.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('#ff0000'));

      expect(changes, <String>['rgb(255, 0, 0)']);
    });

    testWidgets('carries the fourth channel only when alpha is on', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(
          inline: true,
          alpha: true,
          format: NebaColorFormat.rgb,
          swatches: const <String>['rgba(255, 0, 0, 0.5)'],
          onValueChange: changes.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('rgba(255, 0, 0, 0.5)'));
      await tester.pump();

      expect(changes, <String>['rgba(255, 0, 0, 0.5)']);

      await pump(
        tester,
        NebaColorPicker(
          key: UniqueKey(),
          inline: true,
          format: NebaColorFormat.rgb,
          swatches: const <String>['rgba(255, 0, 0, 0.5)'],
          onValueChange: changes.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('rgba(255, 0, 0, 0.5)'));

      expect(changes.last, 'rgb(255, 0, 0)');
    });

    testWidgets('takes a colour typed into the field', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(tester, NebaColorPicker(inline: true, onValueChange: changes.add));
      await tester.enterText(find.byType(EditableText), '#123456');

      expect(changes.last, '#123456');
    });

    testWidgets('leaves the model alone while half a colour is typed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(inline: true, defaultValue: '#00ff00', onValueChange: changes.add),
      );
      await tester.enterText(find.byType(EditableText), '#12');
      await tester.pump();

      expect(changes, isEmpty);
      expect(valueOf(tester, 'Hue'), '120°');

      semantics.dispose();
    });

    testWidgets('names the field it can be typed into', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(inline: true, defaultValue: '#00ff00'));

      final SemanticsData field = data(tester, 'Colour value');

      expect(field.value, '#00ff00');

      semantics.dispose();
    });

    testWidgets('drops the field and the swatches when asked to', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaColorPicker(inline: true, editable: false, swatches: <String>[]),
      );

      expect(find.byType(EditableText), findsNothing);
      expect(find.bySemanticsLabel('Preset colours'), findsNothing);
    });
  });

  group('the popup form', () {
    testWidgets('opens the panel when the trigger is pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaColorPicker(defaultValue: '#ff0000'));

      expect(find.bySemanticsLabel('Hue'), findsNothing);

      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(find.bySemanticsLabel('Hue'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('takes the focus into the panel when it opens from the keyboard', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaColorPicker(label: Text('Accent'), defaultValue: '#ff0000'));

      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(sliderNode(tester, 'Saturation and brightness').hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.bySemanticsLabel('Hue'), findsNothing);
      expect(triggerNode(tester).hasFocus, isTrue);
    });

    testWidgets('reports opening and closing, and holds a controlled open', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];

      await pump(tester, NebaColorPicker(open: false, onOpenChange: changes.add));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(changes, <bool>[true]);
      expect(find.byType(NebaDragRegion), findsNothing);
    });

    testWidgets('reads the empty word while nothing is chosen', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaColorPicker(value: '', onValueChange: (_) {}));

      expect(find.text('Choose a colour'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)).getSemanticsData().label,
        'Choose a colour',
      );

      semantics.dispose();
    });

    testWidgets('empties itself from the ×', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(clearable: true, defaultValue: '#ff0000', onValueChange: changes.add),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await settle(tester);

      expect(changes, <String>['']);
      expect(find.text('Choose a colour'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear'), findsNothing);
      // The press on the × opened nothing.
      expect(find.byType(NebaDragRegion), findsNothing);
    });

    testWidgets('keeps the trigger as wide whatever colour it holds', (WidgetTester tester) async {
      await pump(tester, const NebaColorPicker(defaultValue: '#000000'));
      final double black = tester.getSize(find.byType(NebaFieldShell)).width;

      await pump(tester, NebaColorPicker(key: UniqueKey(), defaultValue: '#ffffff'));

      expect(tester.getSize(find.byType(NebaFieldShell)).width, black);
    });

    testWidgets('tells a screen reader it is required and when it is invalid', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(
          required: true,
          label: Text('Brand'),
          error: Text('This colour fails contrast.'),
        ),
      );

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Brand',
          value: '#1a58d1',
          hint: 'This colour fails contrast.',
          isButton: true,
          hasExpandedState: true,
          hasRequiredState: true,
          isRequired: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );

      semantics.dispose();
    });
  });

  group('inert states', () {
    testWidgets('takes the panel and the field out of the focus order when disabled', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaColorPicker(inline: true, disabled: true, defaultValue: '#ff0000'),
      );

      expect(sliderNode(tester, 'Hue').canRequestFocus, isFalse);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Hue')),
        matchesSemantics(label: 'Hue', value: '0°', isSlider: true, hasEnabledState: true),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).focusNode.canRequestFocus,
        isFalse,
      );

      semantics.dispose();
    });

    testWidgets('leaves a read-only field where the keyboard can reach it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaColorPicker(inline: true, readOnly: true, defaultValue: '#ff0000'),
      );

      final EditableText field = tester.widget<EditableText>(find.byType(EditableText));

      expect(field.readOnly, isTrue);
      expect(field.focusNode.canRequestFocus, isTrue);
      expect(sliderNode(tester, 'Hue').canRequestFocus, isFalse);
    });

    testWidgets('ignores the keys and the pointer when read-only', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaColorPicker(
          inline: true,
          readOnly: true,
          defaultValue: '#ff0000',
          onValueChange: changes.add,
        ),
      );

      final FocusNode hue = sliderNode(tester, 'Hue');

      expect(
        hue.onKeyEvent?.call(
          hue,
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.arrowRight,
            logicalKey: LogicalKeyboardKey.arrowRight,
            timeStamp: Duration.zero,
          ),
        ),
        KeyEventResult.ignored,
      );

      await tester.tap(find.bySemanticsLabel('Saturation and brightness'));
      await tester.tap(find.bySemanticsLabel('#22c55e'));

      expect(changes, isEmpty);
    });

    testWidgets('neither opens nor takes the focus when disabled', (WidgetTester tester) async {
      await pump(tester, const NebaColorPicker(disabled: true));
      await tester.tap(find.byType(NebaFieldShell));
      await settle(tester);

      expect(find.byType(NebaDragRegion), findsNothing);
    });
  });

  group('label placement', () {
    testWidgets('puts a notched label on the trigger', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaColorPicker(labelPlacement: NebaLabelPlacement.notch, label: Text('Brand')),
      );

      final NebaFieldShell shell = tester.widget<NebaFieldShell>(find.byType(NebaFieldShell));

      expect(shell.notch, isNotNull);
      expect(
        find.descendant(of: find.byType(NebaNotch), matching: find.text('Brand')),
        findsOneWidget,
      );
    });

    // The swatch is where a floating label would rest.
    testWidgets('keeps a floating label in the notch beside the swatch', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaColorPicker(labelPlacement: NebaLabelPlacement.float, label: Text('Brand')),
      );

      final NebaFieldShell shell = tester.widget<NebaFieldShell>(find.byType(NebaFieldShell));

      expect(shell.notch?.rests, isFalse);
    });

    testWidgets('has no trigger to notch when inline', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaColorPicker(
          inline: true,
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Brand'),
        ),
      );

      expect(find.byType(NebaNotch), findsNothing);
      expect(find.text('Brand'), findsOneWidget);
    });
  });
}
