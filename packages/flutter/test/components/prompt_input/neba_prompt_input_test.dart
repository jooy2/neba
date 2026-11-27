// NebaPromptInput: the suite the React package runs on PromptInput, asked the
// way Flutter asks it — a text field named by its label with one button that
// sends and then stops, the keys that send and the ones that break the line,
// the composition guard, the rows it grows between, and its own words.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/field.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget input) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 480, child: input),
          ),
        ),
      ),
    );
  }

  Finder editable() => find.byType(EditableText);

  Finder button() => find.byType(NebaIconButton);

  NebaIconButton sendButton(WidgetTester tester) => tester.widget<NebaIconButton>(button());

  Future<void> focus(WidgetTester tester) async {
    tester.widget<EditableText>(editable()).focusNode.requestFocus();
    await tester.pump();
  }

  Future<void> press(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    List<LogicalKeyboardKey> held = const <LogicalKeyboardKey>[],
  }) async {
    for (final LogicalKeyboardKey modifier in held) {
      await tester.sendKeyDownEvent(modifier);
    }

    await tester.sendKeyEvent(key);

    for (final LogicalKeyboardKey modifier in held.reversed) {
      await tester.sendKeyUpEvent(modifier);
    }

    await tester.pump();
  }

  group('rendering', () {
    testWidgets('is a text field named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaPromptInput(label: Text('Message')));

      expect(find.bySemanticsLabel('Message'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Message')),
        matchesSemantics(
          label: 'Message',
          isTextField: true,
          isMultiline: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          textDirection: TextDirection.ltr,
        ),
      );
      // The label is read, never drawn.
      expect(find.text('Message'), findsNothing);
      semantics.dispose();
    });

    testWidgets('draws one button, which sends', (WidgetTester tester) async {
      await pump(tester, const NebaPromptInput(label: Text('Message')));

      expect(button(), findsOneWidget);
      expect(sendButton(tester).label, 'Send');
      // Nothing to send yet.
      expect(sendButton(tester).onPressed, isNull);
    });

    testWidgets('tells a touch keyboard that Enter sends, and only when it does', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaPromptInput());
      expect(tester.widget<EditableText>(editable()).textInputAction, TextInputAction.send);

      await pump(tester, const NebaPromptInput(submitKey: NebaPromptSubmitKey.modEnter));
      expect(tester.widget<EditableText>(editable()).textInputAction, TextInputAction.newline);
    });

    testWidgets('holds what it was handed above the field', (WidgetTester tester) async {
      await pump(tester, const NebaPromptInput(child: Text('design-language.md')));

      expect(
        tester.getBottomLeft(find.text('design-language.md')).dy,
        lessThanOrEqualTo(tester.getTopLeft(editable()).dy),
      );
    });

    testWidgets('draws the controls it was given on the row under the text', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPromptInput(start: <Widget>[Text('Attach')], end: <Widget>[Text('12 tokens')]),
      );

      final double below = tester.getBottomLeft(editable()).dy;
      expect(tester.getTopLeft(find.text('Attach')).dy, greaterThanOrEqualTo(below));
      expect(
        tester.getTopLeft(find.text('12 tokens')).dx,
        lessThan(tester.getTopLeft(button()).dx),
      );
      expect(
        tester.getTopLeft(find.text('Attach')).dx,
        lessThan(tester.getTopLeft(find.text('12 tokens')).dx),
      );
    });

    testWidgets('rounds its corners one step past a field of its size', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaPromptInput());

      expect(tester.widget<NebaFieldShell>(find.byType(NebaFieldShell)).cornerSize, NebaSize.lg);
    });
  });

  group('the value', () {
    testWidgets('reports what was typed', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(tester, NebaPromptInput(onChanged: changes.add));
      await tester.enterText(editable(), 'Hello');

      expect(changes.last, 'Hello');
    });

    testWidgets('shows a value it was handed', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(text: 'Draft');
      addTearDown(controller.dispose);

      await pump(tester, NebaPromptInput(controller: controller));

      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('starts from an initial value', (WidgetTester tester) async {
      await pump(tester, const NebaPromptInput(initialValue: 'Draft'));

      expect(find.text('Draft'), findsOneWidget);
    });
  });

  group('its height', () {
    testWidgets('grows with its text from minRows to maxRows', (WidgetTester tester) async {
      await pump(tester, const NebaPromptInput(maxRows: 3));
      final double one = tester.getSize(editable()).height;

      await tester.enterText(editable(), 'a\nb');
      await tester.pump();
      final double two = tester.getSize(editable()).height;

      await tester.enterText(editable(), 'a\nb\nc\nd\ne');
      await tester.pump();
      final double capped = tester.getSize(editable()).height;

      expect(two, closeTo(one * 2, 1));
      expect(capped, closeTo(one * 3, 1));
    });

    testWidgets('starts as tall as minRows', (WidgetTester tester) async {
      await pump(tester, const NebaPromptInput());
      final double one = tester.getSize(editable()).height;

      await pump(tester, const NebaPromptInput(minRows: 3, maxRows: 6, key: ValueKey<int>(3)));

      expect(tester.getSize(editable()).height, closeTo(one * 3, 1));
    });
  });

  group('sending', () {
    testWidgets('sends what is in the field when the button is pressed', (
      WidgetTester tester,
    ) async {
      final List<String> sent = <String>[];

      await pump(tester, NebaPromptInput(onSubmit: sent.add));
      await tester.enterText(editable(), 'Hello');
      await tester.pump();
      await tester.tap(button());
      await tester.pump();

      expect(sent, <String>['Hello']);
    });

    testWidgets('sends on Enter, and breaks the line on Shift+Enter', (WidgetTester tester) async {
      final List<String> sent = <String>[];

      await pump(tester, NebaPromptInput(onSubmit: sent.add));
      await tester.enterText(editable(), 'Hello');
      await focus(tester);

      await press(
        tester,
        LogicalKeyboardKey.enter,
        held: <LogicalKeyboardKey>[LogicalKeyboardKey.shiftLeft],
      );
      expect(sent, isEmpty);
      expect(tester.widget<EditableText>(editable()).controller.text, 'Hello\n');

      await press(tester, LogicalKeyboardKey.enter);
      expect(sent, <String>['Hello\n']);
    });

    testWidgets('sends on Mod+Enter when that is the key, and leaves Enter alone', (
      WidgetTester tester,
    ) async {
      final List<String> sent = <String>[];

      await pump(
        tester,
        NebaPromptInput(submitKey: NebaPromptSubmitKey.modEnter, onSubmit: sent.add),
      );
      await tester.enterText(editable(), 'Hello');
      await focus(tester);

      await press(tester, LogicalKeyboardKey.enter);
      expect(sent, isEmpty);

      await press(
        tester,
        LogicalKeyboardKey.enter,
        held: <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft],
      );
      expect(sent, <String>['Hello']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('reads Mod as Command on a Mac', (WidgetTester tester) async {
      final List<String> sent = <String>[];

      await pump(
        tester,
        NebaPromptInput(submitKey: NebaPromptSubmitKey.modEnter, onSubmit: sent.add),
      );
      await tester.enterText(editable(), 'Hello');
      await focus(tester);

      await press(
        tester,
        LogicalKeyboardKey.enter,
        held: <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft],
      );
      expect(sent, isEmpty);

      await press(
        tester,
        LogicalKeyboardKey.enter,
        held: <LogicalKeyboardKey>[LogicalKeyboardKey.metaLeft],
      );
      expect(sent, <String>['Hello']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    // A Korean or Japanese reader pressing Enter to accept a candidate is
    // finishing a word, not sending a message.
    testWidgets('does not send while an input method is composing', (WidgetTester tester) async {
      final List<String> sent = <String>[];
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      await pump(tester, NebaPromptInput(controller: controller, onSubmit: sent.add));
      await focus(tester);
      controller.value = const TextEditingValue(
        text: '안녕',
        selection: TextSelection.collapsed(offset: 2),
        composing: TextRange(start: 1, end: 2),
      );
      await tester.pump();

      await press(tester, LogicalKeyboardKey.enter);
      expect(sent, isEmpty);

      controller.value = controller.value.copyWith(composing: TextRange.empty);
      await press(tester, LogicalKeyboardKey.enter);
      expect(sent, <String>['안녕']);
    });

    testWidgets('sends from a touch keyboard\'s send key and keeps the focus', (
      WidgetTester tester,
    ) async {
      final List<String> sent = <String>[];

      await pump(tester, NebaPromptInput(onSubmit: sent.add));
      await tester.showKeyboard(editable());
      await tester.enterText(editable(), 'Hello');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(sent, <String>['Hello']);
      expect(tester.widget<EditableText>(editable()).focusNode.hasFocus, isTrue);
    });

    testWidgets("lets the caller's shortcuts take a key first", (WidgetTester tester) async {
      final List<String> sent = <String>[];
      int picked = 0;

      await pump(
        tester,
        NebaPromptInput(
          onSubmit: sent.add,
          shortcuts: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter): () => picked += 1,
          },
        ),
      );
      await tester.enterText(editable(), '@ada');
      await focus(tester);
      await press(tester, LogicalKeyboardKey.enter);

      expect(picked, 1);
      expect(sent, isEmpty);
    });

    testWidgets('never sends an empty field', (WidgetTester tester) async {
      final List<String> sent = <String>[];

      await pump(tester, NebaPromptInput(onSubmit: sent.add));
      await tester.enterText(editable(), '   ');
      await focus(tester);
      await press(tester, LogicalKeyboardKey.enter);

      expect(sent, isEmpty);
      expect(sendButton(tester).onPressed, isNull);
    });

    testWidgets('never sends while it is disabled or read-only', (WidgetTester tester) async {
      final List<String> sent = <String>[];

      await pump(
        tester,
        NebaPromptInput(initialValue: 'Hello', readOnly: true, onSubmit: sent.add),
      );
      expect(sendButton(tester).onPressed, isNull);

      await pump(
        tester,
        NebaPromptInput(
          key: const ValueKey<String>('disabled'),
          initialValue: 'Hello',
          disabled: true,
          onSubmit: sent.add,
        ),
      );
      expect(sendButton(tester).onPressed, isNull);
      expect(sent, isEmpty);
    });

    testWidgets('leaves the field alone once it has sent', (WidgetTester tester) async {
      await pump(tester, NebaPromptInput(onSubmit: (String _) {}));
      await tester.enterText(editable(), 'Hello');
      await tester.pump();
      await tester.tap(button());
      await tester.pump();

      expect(tester.widget<EditableText>(editable()).controller.text, 'Hello');
    });
  });

  group('stopping', () {
    testWidgets('turns the one button into a stop button', (WidgetTester tester) async {
      await pump(tester, const NebaPromptInput(submitting: true));

      expect(button(), findsOneWidget);
      expect(sendButton(tester).label, 'Stop');
    });

    testWidgets('is pressable even with nothing in the field', (WidgetTester tester) async {
      int stops = 0;

      await pump(tester, NebaPromptInput(submitting: true, onStop: () => stops += 1));
      await tester.tap(button());
      await tester.pump();

      expect(stops, 1);
    });

    testWidgets('does not send while it is writing an answer', (WidgetTester tester) async {
      final List<String> sent = <String>[];
      int stops = 0;

      await pump(
        tester,
        NebaPromptInput(
          initialValue: 'Hello',
          submitting: true,
          onSubmit: sent.add,
          onStop: () => stops += 1,
        ),
      );
      await focus(tester);
      await press(tester, LogicalKeyboardKey.enter);
      await tester.tap(button());
      await tester.pump();

      expect(sent, isEmpty);
      expect(stops, 1);
    });
  });

  group('its own words', () {
    testWidgets('lets a caller write them out', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPromptInput(
          submitting: true,
          labels: <String, String>{'send': 'Envoyer', 'stop': 'Arrêter'},
        ),
      );

      expect(sendButton(tester).label, 'Arrêter');
    });
  });
}
