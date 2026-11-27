// NebaTextField: the suite the React package runs on TextField, asked the way
// Flutter asks it — the sheet, the sizes, the semantics and the light it
// builds, and what typing, a tap and a key do — rather than the elements and
// classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);
  final NebaColorRoles danger = tokens.roles(NebaColor.danger);

  Future<void> pump(
    WidgetTester tester,
    Widget field, {
    NebaDefaults? defaults,
    TextDirection textDirection = TextDirection.ltr,
    bool disableAnimations = false,
  }) {
    final Widget placed = Center(child: field);

    return tester.pumpWidget(
      host(
        defaults == null ? placed : NebaProvider(defaults: defaults, child: placed),
        textDirection: textDirection,
        disableAnimations: disableAnimations,
      ),
    );
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  /// The field's one semantics node, with the editable's own merged into it.
  SemanticsData dataOf(WidgetTester tester) {
    return tester.getSemantics(find.byType(NebaTextField)).getSemanticsData();
  }

  Size shellSize(WidgetTester tester) => tester.getSize(find.byType(NebaSheet));

  bool hasFocus(WidgetTester tester) {
    return tester.state<EditableTextState>(find.byType(EditableText)).widget.focusNode.hasFocus;
  }

  Future<void> focus(WidgetTester tester) async {
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
  }

  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  /// The style a piece of text is drawn in, once every ambient style it sits
  /// under has been merged in.
  TextStyle styleOf(WidgetTester tester, Finder text) {
    return tester.renderObject<RenderParagraph>(text).text.style!;
  }

  RichText notchLabel(WidgetTester tester) {
    return tester.widget<RichText>(
      find.descendant(of: find.byType(NebaNotch), matching: find.byType(RichText)).first,
    );
  }

  group('rendering', () {
    testWidgets('is a text field named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextField(label: Text('Email')));

      expect(
        tester.getSemantics(find.byType(NebaTextField)),
        matchesSemantics(
          label: 'Email',
          isTextField: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('reads the description and the error after its name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTextField(
          label: Text('Email'),
          description: Text('We never share it.'),
          error: Text('Not a valid address.'),
        ),
      );

      expect(find.text('We never share it.'), findsOneWidget);
      expect(find.text('Not a valid address.'), findsOneWidget);
      final SemanticsData data = dataOf(tester);
      expect(data.label, 'Email');
      expect(data.hint, 'We never share it.\nNot a valid address.');
      semantics.dispose();
    });

    testWidgets('is named by its placeholder when nothing else names it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextField(placeholder: 'Search'));
      expect(dataOf(tester).label, 'Search');

      await pump(tester, const NebaTextField(placeholder: 'Search', semanticLabel: 'Find'));
      expect(dataOf(tester).label, 'Find');
      expect(dataOf(tester).hint, 'Search');
      semantics.dispose();
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(label: Text('Before')));
      await pump(tester, const NebaTextField(label: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('puts the caret in the field when its label is tapped', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(label: Text('Email')));

      await tester.tap(find.text('Email'));
      await tester.pump();

      expect(hasFocus(tester), isTrue);
    });

    testWidgets('puts the caret in the field when the shell padding is tapped', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(size: NebaSize.xl, label: Text('Email')));

      final Rect shell = tester.getRect(find.byType(NebaSheet));
      await tester.tapAt(Offset(shell.left + 3, shell.center.dy));
      await tester.pump();

      expect(hasFocus(tester), isTrue);
    });

    testWidgets('never applies a transform, so nothing in the field can move', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(
          label: Text('Email'),
          labelPlacement: NebaLabelPlacement.float,
          elevation: 3,
        ),
      );
      await focus(tester);

      expect(
        find.descendant(of: find.byType(NebaTextField), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });

  group('size', () {
    testWidgets('is as tall as a button of its size, whatever its density', (
      WidgetTester tester,
    ) async {
      for (final NebaSize size in NebaSize.values) {
        for (final NebaDensity density in NebaDensity.values) {
          for (final NebaVariant variant in NebaVariant.values) {
            await pump(tester, NebaTextField(size: size, density: density, variant: variant));

            expect(
              shellSize(tester).height,
              NebaScale.controlHeight[size],
              reason: '${size.name} ${density.name} ${variant.name}',
            );
          }
        }
      }
    });

    testWidgets('changes its inline padding with density', (WidgetTester tester) async {
      double inset() {
        return tester.getTopLeft(find.byType(EditableText)).dx -
            tester.getTopLeft(find.byType(NebaSheet)).dx;
      }

      await pump(tester, const NebaTextField(size: NebaSize.lg));
      // The hairline, then 20 at lg.
      expect(inset(), 21);

      await pump(tester, const NebaTextField(size: NebaSize.lg, density: NebaDensity.compact));
      expect(inset(), 13);
    });

    testWidgets('grows for text set larger than its size, since its height is a floor', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(style: TextStyle(fontSize: 40)));

      expect(shellSize(tester).height, greaterThan(NebaScale.controlHeight[NebaSize.md]!));
    });

    testWidgets('is about twenty characters wide, or the width it is given', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField());
      expect(shellSize(tester).width, nebaFieldWidth(NebaSize.md, NebaDensity.standard));

      await pump(tester, const SizedBox(width: 300, child: NebaTextField(fullWidth: true)));
      expect(shellSize(tester).width, 300);

      await pump(
        tester,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: const NebaTextField(),
        ),
      );
      expect(shellSize(tester).width, 120);
    });

    testWidgets('takes its size, variant and density from the provider', (
      WidgetTester tester,
    ) async {
      const NebaDefaults defaults = NebaDefaults(
        size: NebaSize.lg,
        variant: NebaVariant.solid,
        density: NebaDensity.compact,
      );

      await pump(tester, const NebaTextField(), defaults: defaults);
      expect(shellSize(tester).height, 40);
      expect(sheetOf(tester).plate, NebaPlate.solid);
      expect(shellSize(tester).width, nebaFieldWidth(NebaSize.lg, NebaDensity.compact));

      await pump(tester, const NebaTextField(variant: NebaVariant.outline), defaults: defaults);
      expect(sheetOf(tester).plate, NebaPlate.glass);
    });
  });

  group('multiline', () {
    testWidgets('makes one row exactly as tall as a single-line field', (
      WidgetTester tester,
    ) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaTextField(size: size));
        final double single = shellSize(tester).height;

        await pump(tester, NebaTextField(size: size, multiline: true, rows: 1));
        expect(shellSize(tester).height, single, reason: size.name);
      }
    });

    testWidgets('shows at least rows lines, each one line tall', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(multiline: true, rows: 4));

      // The hairline, 5 above and below, and four lines of 20.
      expect(shellSize(tester).height, 2 + 10 + 4 * 20);

      await pump(
        tester,
        const NebaTextField(multiline: true, rows: 4, density: NebaDensity.compact),
      );
      expect(shellSize(tester).height, 2 + 10 + 4 * 20);
    });

    testWidgets('takes text over several lines and grows with it', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(multiline: true, rows: 2, label: Text('Bio')));
      final double before = shellSize(tester).height;

      await tester.enterText(find.byType(NebaTextField), 'one\ntwo\nthree\nfour');
      await tester.pump();

      expect(find.text('one\ntwo\nthree\nfour'), findsOneWidget);
      expect(shellSize(tester).height, greaterThan(before));
    });
  });

  group('the sheet', () {
    testWidgets('is an undyed panel with a hairline in its family by default', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField());

      expect(sheetOf(tester).fill, tokens.panel);
      expect(sheetOf(tester).edge, primary.line);
      expect(sheetOf(tester).plate, NebaPlate.glass);
      expect(sheetOf(tester).elevation, 0);

      await pump(tester, const NebaTextField(color: NebaColor.success));
      expect(sheetOf(tester).fill, tokens.panel);
      expect(sheetOf(tester).edge, tokens.roles(NebaColor.success).line);
    });

    testWidgets('draws a hairline for the outline variant only', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(variant: NebaVariant.solid));
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(sheetOf(tester).plate, NebaPlate.solid);

      await pump(tester, const NebaTextField(variant: NebaVariant.text));
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).fill, transparent);
      expect(sheetOf(tester).plate, NebaPlate.none);
    });

    testWidgets('is flat by default and takes the elevation it is given', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(elevation: 2));

      expect(sheetOf(tester).elevation, 2);
    });

    testWidgets('rises a step under the pointer', (WidgetTester tester) async {
      await pump(tester, const NebaTextField());

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.byType(NebaSheet)));
      addTearDown(mouse.removePointer);
      await tester.pump();

      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(sheetOf(tester).edge, primary.lineHover);
    });

    testWidgets('turns its hairline the ring colour and draws the ring flush on focus', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(label: Text('Email')));

      NebaFocusRing ring() => tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));
      expect(ring().visible, isFalse);
      expect(ring().offset, 0);

      // A tap, not a key: a caret is a focus, however it got there.
      await focus(tester);

      expect(ring().visible, isTrue);
      expect(ring().color, primary.ring);
      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(sheetOf(tester).edge, primary.ring);
      // The focus is answered at the edge's pace, not the fill's slower one.
      expect(sheetOf(tester).fillDuration, NebaScale.duration);
    });
  });

  group('the pointer light', () {
    testWidgets('takes half the bloom a control takes, and no press flash', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(label: Text('Email')));

      final NebaGlow glow = tester.widget<NebaGlow>(find.byType(NebaGlow));
      expect(glow.colors.glow, mixSrgb(primary.soft, 0.5, transparent));
      expect(glow.colors.flash, transparent);
      expect(glow.afterglow, isFalse);
    });

    testWidgets('goes out while the reader types and comes back when the pointer moves', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(label: Text('Email')));
      await focus(tester);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.byType(NebaSheet)));
      addTearDown(mouse.removePointer);
      await tester.pump();

      NebaGlow glow() => tester.widget<NebaGlow>(find.byType(NebaGlow));
      expect(glow().spotlight, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(glow().spotlight, isFalse);

      await mouse.moveBy(const Offset(4, 0));
      await tester.pump();
      expect(glow().spotlight, isTrue);
    });

    testWidgets('draws no light on a field that is disabled or read-only', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(label: Text('Email'), disabled: true));
      expect(find.byType(NebaGlow), findsNothing);

      await pump(tester, const NebaTextField(label: Text('Email'), readOnly: true));
      expect(find.byType(NebaGlow), findsNothing);
    });
  });

  group('icons', () {
    testWidgets('places startIcon before and endIcon after the text', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTextField(
          startIcon: SizedBox(key: Key('start'), width: 10, height: 10),
          endIcon: SizedBox(key: Key('end'), width: 10, height: 10),
        ),
      );

      final double start = tester.getCenter(find.byKey(const Key('start'))).dx;
      final double text = tester.getCenter(find.byType(EditableText)).dx;
      final double end = tester.getCenter(find.byKey(const Key('end'))).dx;

      expect(start, lessThan(text));
      expect(end, greaterThan(text));
    });

    testWidgets('mutes its icons until the field holds the focus', (WidgetTester tester) async {
      await pump(tester, NebaTextField(startIcon: NebaGlyph(NebaGlyphs.plus)));

      NebaFieldAdornment adornment() {
        return tester.widget<NebaFieldAdornment>(find.byType(NebaFieldAdornment));
      }

      expect(adornment().focused, isFalse);
      expect(tester.getSize(find.byType(NebaGlyph)), Size.square(13 * 1.2));

      await focus(tester);

      expect(adornment().focused, isTrue);
      expect(adornment().accent, primary.accent);
    });
  });

  group('value', () {
    testWidgets('keeps the text typed into it and reports each change', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];

      await pump(tester, NebaTextField(label: const Text('Email'), onChanged: changes.add));
      await tester.enterText(find.byType(NebaTextField), 'a@b.com');
      await tester.pump();

      expect(find.text('a@b.com'), findsOneWidget);
      expect(changes.last, 'a@b.com');
    });

    testWidgets('starts from initialValue', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(initialValue: 'Jane'));

      expect(find.text('Jane'), findsOneWidget);
    });

    testWidgets('shows a controller the caller holds, and writes to it', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(text: 'first');
      addTearDown(controller.dispose);

      await pump(tester, NebaTextField(controller: controller));
      expect(find.text('first'), findsOneWidget);

      controller.text = 'second';
      await tester.pump();
      expect(find.text('second'), findsOneWidget);

      await tester.enterText(find.byType(NebaTextField), 'typed');
      expect(controller.text, 'typed');
    });

    testWidgets('carries its text on when a controller is taken away', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(text: 'kept');
      addTearDown(controller.dispose);

      await pump(tester, NebaTextField(controller: controller));
      await pump(tester, const NebaTextField());

      expect(find.text('kept'), findsOneWidget);
    });

    testWidgets('reports a submission from the keyboard', (WidgetTester tester) async {
      String? submitted;

      await pump(tester, NebaTextField(onSubmitted: (String value) => submitted = value));
      await tester.enterText(find.byType(NebaTextField), 'done');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitted, 'done');
    });

    testWidgets('takes no more than maxLength characters, and says how many', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextField(label: Text('Code'), maxLength: 5));
      await tester.enterText(find.byType(NebaTextField), 'abcdefgh');
      await tester.pump();

      expect(find.text('abcde'), findsOneWidget);
      expect(dataOf(tester).maxValueLength, 5);
      expect(dataOf(tester).currentValueLength, 5);
      semantics.dispose();
    });

    testWidgets('draws its placeholder only while it is empty', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(placeholder: 'jane@example.com'));
      expect(find.text('jane@example.com'), findsOneWidget);

      await tester.enterText(find.byType(NebaTextField), 'j');
      await tester.pump();
      expect(find.text('jane@example.com'), findsNothing);
    });
  });

  group('states', () {
    testWidgets('drops the colour family and the focus when disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextField(label: Text('Email'), variant: NebaVariant.solid));
      await pump(
        tester,
        const NebaTextField(label: Text('Email'), variant: NebaVariant.solid, disabled: true),
      );

      expect(sheetOf(tester).fill, tokens.disabledBg);
      expect(styleOf(tester, find.text('Email')).color, tokens.disabledFg);

      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      expect(hasFocus(tester), isFalse);
      expect(
        tester.getSemantics(find.byType(NebaTextField)),
        matchesSemantics(
          label: 'Email',
          isTextField: true,
          isFocusable: true,
          hasEnabledState: true,
        ),
      );

      await pump(
        tester,
        const NebaTextField(label: Text('Email'), variant: NebaVariant.outline, disabled: true),
      );
      expect(sheetOf(tester).edge, tokens.disabledBorder);
      semantics.dispose();
    });

    testWidgets('keeps the focus and its text when read-only, flat and desaturated', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTextField(initialValue: 'fixed', readOnly: true, elevation: 2));

      expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
      expect(sheetOf(tester).edge, primary.line);
      expect(sheetOf(tester).elevation, 0);
      expect(
        find.descendant(of: find.byType(NebaTextField), matching: find.byType(ColorFiltered)),
        findsOneWidget,
      );

      await focus(tester);
      expect(hasFocus(tester), isTrue);
      expect(find.text('fixed'), findsOneWidget);
      // Read-only does not answer the focus with a raised sheet.
      expect(sheetOf(tester).fill, tokens.panel);
    });

    testWidgets('rings a read-only field for keyboard focus only', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(initialValue: 'fixed', readOnly: true));
      await focus(tester);

      NebaFocusRing ring() => tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));
      expect(ring().visible, isFalse);

      // A key after the tap brings the ring, as it does to `:focus-visible`.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(ring().visible, isTrue);
    });

    testWidgets('keeps the ring of an editable field after a tap', (WidgetTester tester) async {
      await pump(tester, const NebaTextField());
      await focus(tester);

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(find.byType(NebaFocusRing));
      expect(ring.visible, isTrue);
      expect(ring.keyboardOnly, isFalse);
    });

    testWidgets('shows a turning ring in place of endIcon while loading, and still types', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(
          loading: true,
          endIcon: SizedBox(key: Key('end'), width: 10, height: 10),
        ),
      );

      expect(find.byType(NebaSpinner), findsOneWidget);
      expect(find.byKey(const Key('end')), findsNothing);

      await tester.enterText(find.byType(NebaTextField), 'still typable');
      await tester.pump();
      expect(find.text('still typable'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('validity', () {
    testWidgets('turns the whole family over to danger when there is an error', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTextField(label: Text('Email')));
      expect(sheetOf(tester).edge, primary.line);

      await pump(tester, const NebaTextField(label: Text('Email'), error: Text('Required.')));

      expect(sheetOf(tester).edge, danger.line);
      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing)).color, danger.ring);
      expect(tester.widget<EditableText>(find.byType(EditableText)).cursorColor, danger.accent);
      expect(styleOf(tester, find.text('Required.')).color, danger.accent);
      expect(dataOf(tester).validationResult, SemanticsValidationResult.invalid);
      semantics.dispose();
    });

    testWidgets('can be invalid without a message', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(label: Text('Email'), invalid: true));

      expect(sheetOf(tester).edge, danger.line);
    });

    testWidgets('can carry a message without being invalid when told so', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(label: Text('Email'), error: Text('Heads up.'), invalid: false),
      );

      expect(sheetOf(tester).edge, primary.line);
      expect(find.text('Heads up.'), findsOneWidget);
    });

    testWidgets('overrides its colour while invalid', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(color: NebaColor.info, error: Text('Required.')));

      expect(sheetOf(tester).edge, danger.line);
    });
  });

  group('shortcuts', () {
    testWidgets('runs the entry whose combination was pressed', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      final List<String> sent = <String>[];

      await pump(
        tester,
        NebaTextField(
          controller: controller,
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter): () => sent.add(controller.text),
          },
        ),
      );
      await tester.enterText(find.byType(NebaTextField), 'ship it');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(sent, <String>['ship it']);
    });

    testWidgets('tells Enter and Control+Enter apart', (WidgetTester tester) async {
      int plain = 0;
      int withControl = 0;

      await pump(
        tester,
        NebaTextField(
          multiline: true,
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter): () => plain += 1,
            const SingleActivator(LogicalKeyboardKey.enter, control: true): () => withControl += 1,
          },
        ),
      );
      await focus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(<int>[plain, withControl], <int>[1, 1]);
    });

    testWidgets('leaves a key nobody bound alone', (WidgetTester tester) async {
      int sent = 0;

      await pump(
        tester,
        NebaTextField(
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter, control: true): () => sent += 1,
          },
        ),
      );
      await focus(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(sent, 0);
    });
  });

  group('label placement', () {
    testWidgets('keeps the label above the field by default', (WidgetTester tester) async {
      await pump(tester, const NebaTextField(label: Text('Email')));

      expect(find.byType(NebaNotch), findsNothing);
      expect(
        tester.getBottomLeft(find.text('Email')).dy,
        lessThan(tester.getTopLeft(find.byType(NebaSheet)).dy),
      );
    });

    testWidgets('puts a notched label on the edge, still naming the field', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTextField(label: Text('Email'), labelPlacement: NebaLabelPlacement.notch),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaTextField)),
        matchesSemantics(
          label: 'Email',
          isTextField: true,
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );

      // Centred on the hairline along the top.
      final Rect label = tester.getRect(find.text('Email'));
      final Rect shell = tester.getRect(find.byType(NebaSheet));
      expect(label.center.dy, closeTo(shell.top + 0.5, 1));
      semantics.dispose();
    });

    testWidgets('hands the edge and the ring from the shell to the notch', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(label: Text('Email'), labelPlacement: NebaLabelPlacement.notch),
      );

      // Kept, transparent, so the box is the same size either way.
      expect(sheetOf(tester).edge, transparent);
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(find.byType(NebaFocusRing), findsNothing);
      expect(shellSize(tester).height, 32);

      final NebaNotch notch = tester.widget<NebaNotch>(find.byType(NebaNotch));
      expect(notch.look.line, primary.line);
      expect(notch.look.top, tokens.plateTop);

      await focus(tester);
      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).ring, primary.ring);
      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).look.line, primary.ring);
    });

    testWidgets('keeps its own edge when there is no label to cut a notch for', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(labelPlacement: NebaLabelPlacement.notch, semanticLabel: 'Email'),
      );

      expect(find.byType(NebaNotch), findsNothing);
      expect(find.byType(NebaFocusRing), findsOneWidget);
      expect(sheetOf(tester).edge, primary.line);
    });

    testWidgets('tells the notch whether the field is read-only or disabled', (
      WidgetTester tester,
    ) async {
      NebaNotchLook look() => tester.widget<NebaNotch>(find.byType(NebaNotch)).look;

      await pump(
        tester,
        const NebaTextField(
          label: Text('Email'),
          labelPlacement: NebaLabelPlacement.notch,
          readOnly: true,
        ),
      );
      await focus(tester);
      expect(look().line, primary.line);

      await pump(
        tester,
        const NebaTextField(
          label: Text('Email'),
          labelPlacement: NebaLabelPlacement.notch,
          disabled: true,
        ),
      );
      expect(look().line, tokens.disabledBorder);
      expect(look().top, transparent);
    });

    testWidgets('takes the placement from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTextField(label: Text('Email')),
        defaults: const NebaDefaults(labelPlacement: NebaLabelPlacement.notch),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
    });

    testWidgets('rests a floating label in the field while it is empty and idle', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(label: Text('Email'), labelPlacement: NebaLabelPlacement.float),
      );

      bool resting() => tester.widget<NebaNotch>(find.byType(NebaNotch)).resting;
      expect(resting(), isTrue);
      // Set in the control's own type, where the text would be.
      expect(notchLabel(tester).text.style!.fontSize, NebaScale.controlText[NebaSize.md]);
      expect(
        tester.getRect(find.text('Email')).center.dy,
        closeTo(tester.getRect(find.byType(NebaSheet)).center.dy, 1),
      );

      await focus(tester);
      expect(resting(), isFalse);
      expect(notchLabel(tester).text.style!.fontSize, NebaScale.metaText[NebaSize.md]);

      await tester.enterText(find.byType(NebaTextField), 'a');
      await unfocus(tester);
      expect(resting(), isFalse);

      await tester.enterText(find.byType(NebaTextField), '');
      await unfocus(tester);
      expect(resting(), isTrue);
    });

    testWidgets('moves at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(label: Text('Email'), labelPlacement: NebaLabelPlacement.float),
        disableAnimations: true,
      );

      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.pump();

      expect(notchLabel(tester).text.style!.fontSize, NebaScale.metaText[NebaSize.md]);
    });

    testWidgets('keeps a floating label on the edge when a start icon is where it would rest', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTextField(
          label: const Text('Email'),
          labelPlacement: NebaLabelPlacement.float,
          startIcon: NebaGlyph(NebaGlyphs.plus),
        ),
      );

      expect(tester.widget<NebaNotch>(find.byType(NebaNotch)).resting, isFalse);
    });

    testWidgets('hides the placeholder under a resting label and shows it once it rises', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(
          label: Text('Email'),
          labelPlacement: NebaLabelPlacement.float,
          placeholder: 'you@example.com',
        ),
      );

      expect(styleOf(tester, find.text('you@example.com')).color!.a, 0);

      await focus(tester);
      expect(styleOf(tester, find.text('you@example.com')).color, tokens.mutedFg);
    });

    testWidgets('rests a multiline label on the first line rather than in the middle', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(
          label: Text('Message'),
          labelPlacement: NebaLabelPlacement.float,
          multiline: true,
          rows: 4,
        ),
      );

      final Rect shell = tester.getRect(find.byType(NebaSheet));
      // The hairline and the 5 above the first line.
      expect(tester.getRect(find.text('Message')).top, closeTo(shell.top + 6, 0.5));
    });

    testWidgets('stands its label at the end of the edge from the right', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTextField(label: Text('Email'), labelPlacement: NebaLabelPlacement.notch),
        textDirection: TextDirection.rtl,
      );

      final Rect shell = tester.getRect(find.byType(NebaSheet));
      final double radius = tokens.radius[NebaSize.md]!;
      // The corner, then the gap's own space, then the word.
      expect(tester.getRect(find.text('Email')).right, closeTo(shell.right - radius - 4, 0.5));
    });

    testWidgets('widens to hold a label longer than the field', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTextField(
          size: NebaSize.xs,
          label: Text('A label far longer than the field is wide'),
          labelPlacement: NebaLabelPlacement.notch,
        ),
      );

      final double radius = tokens.radius[NebaSize.xs]!;
      final double word = tester
          .getSize(find.text('A label far longer than the field is wide'))
          .width;

      expect(
        shellSize(tester).width,
        greaterThan(nebaFieldWidth(NebaSize.xs, NebaDensity.standard)),
      );
      expect(shellSize(tester).width, closeTo(word + 2 * (radius + 3), 0.5));
    });
  });
}
