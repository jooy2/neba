// NebaOtpField: the suite the React package runs on OtpField, asked the way
// Flutter asks it — the cells it draws, the one field a screen reader hears,
// and what typing, a paste, autofill, a press and a key do to the code —
// rather than the inputs and classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget field, {NebaDefaults? defaults}) {
    final Widget placed = Center(child: field);

    return tester.pumpWidget(
      host(defaults == null ? placed : NebaProvider(defaults: defaults, child: placed)),
    );
  }

  EditableText editableOf(WidgetTester tester) {
    return tester.widget<EditableText>(find.byType(EditableText));
  }

  String codeOf(WidgetTester tester) => editableOf(tester).controller.text;

  Finder cells() {
    return find.descendant(of: find.byType(NebaOtpField), matching: find.byType(NebaSheet));
  }

  /// The cell the caret is in: the one whose ring shows.
  int activeOf(WidgetTester tester) {
    final List<NebaFocusRing> rings = tester
        .widgetList<NebaFocusRing>(
          find.descendant(of: find.byType(NebaOtpField), matching: find.byType(NebaFocusRing)),
        )
        .toList();

    return rings.indexWhere((NebaFocusRing ring) => ring.visible);
  }

  Future<void> tapCell(WidgetTester tester, int index) async {
    await tester.tap(cells().at(index));
    await tester.pump();
    await tester.pump();
  }

  /// What a keyboard sends for [text] typed over the selection.
  Future<void> type(WidgetTester tester, String text) async {
    final TextEditingValue value = editableOf(tester).controller.value;
    final TextSelection selection = value.selection;
    final String next = value.text.replaceRange(selection.start, selection.end, text);

    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      ),
    );
    await tester.pump();
  }

  /// What a phone's keyboard sends for its backspace: the selection deleted,
  /// or the character before the caret.
  Future<void> deleteBackward(WidgetTester tester) async {
    final TextEditingValue value = editableOf(tester).controller.value;
    final TextSelection selection = value.selection;
    final int start = selection.isCollapsed ? selection.start - 1 : selection.start;

    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: value.text.replaceRange(start, selection.end, ''),
        selection: TextSelection.collapsed(offset: start),
      ),
    );
    await tester.pump();
  }

  group('rendering', () {
    testWidgets('draws one cell per character, six unless told', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField());
      expect(cells(), findsNWidgets(6));

      await pump(tester, const NebaOtpField(length: 4));
      expect(cells(), findsNWidgets(4));
    });

    testWidgets('holds the length to what a code can be', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 1));
      expect(cells(), findsNWidgets(2));

      await pump(tester, const NebaOtpField(length: 40));
      expect(cells(), findsNWidgets(12));
    });

    testWidgets('is one text field named by its label, holding the code', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaOtpField(label: Text('Verification code'), length: 4, defaultValue: '12'),
      );

      expect(
        tester.getSemantics(find.byType(NebaOtpField)),
        matchesSemantics(
          label: 'Verification code',
          value: '12',
          maxValueLength: 4,
          currentValueLength: 2,
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
        const NebaOtpField(
          label: Text('Code'),
          description: Text('Sent to your phone'),
          error: Text('That code has expired'),
        ),
      );

      expect(find.text('Sent to your phone'), findsOneWidget);
      expect(find.text('That code has expired'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NebaOtpField)).getSemanticsData().hint,
        'Sent to your phone\nThat code has expired',
      );
      semantics.dispose();
    });

    testWidgets('spreads the code it starts with across the cells', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '1234'));

      for (final String digit in <String>['1', '2', '3', '4']) {
        expect(find.descendant(of: cells(), matching: find.text(digit)), findsOneWidget);
      }
    });

    testWidgets('hides the characters when masked', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '8421', mask: true));

      expect(find.descendant(of: cells(), matching: find.text('8')), findsNothing);
      expect(find.descendant(of: cells(), matching: find.text('•')), findsNWidgets(4));
      expect(editableOf(tester).obscureText, isTrue);
    });

    testWidgets('draws a separator every groupSize cells', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(groupSize: 3, separator: Text('/')));
      expect(find.text('/'), findsOneWidget);

      await pump(tester, const NebaOtpField(length: 9, groupSize: 3));
      expect(find.text('–'), findsNWidgets(2));
    });

    testWidgets('reflects a controlled code on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, value: '12'));
      await pump(tester, const NebaOtpField(length: 4, value: '1234'));

      expect(codeOf(tester), '1234');
      expect(find.descendant(of: cells(), matching: find.text('4')), findsOneWidget);
    });

    testWidgets('sizes its cells on a ladder of their own', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(size: NebaSize.md));
      expect(tester.getSize(cells().first), const Size(32, 40));

      await pump(tester, const NebaOtpField(size: NebaSize.xl));
      expect(tester.getSize(cells().first), const Size(48, 56));
    });

    testWidgets('changes only the space between the cells with density', (
      WidgetTester tester,
    ) async {
      double gap() => tester.getRect(cells().at(1)).left - tester.getRect(cells().at(0)).right;

      await pump(tester, const NebaOtpField());
      expect(gap(), 6);

      await pump(tester, const NebaOtpField(density: NebaDensity.compact));
      expect(gap(), 4);
      expect(tester.getSize(cells().first), const Size(32, 40));
    });

    testWidgets('lets the platform fill it with a texted code', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField());

      expect(editableOf(tester).autofillHints, <String>[AutofillHints.oneTimeCode]);
      expect(editableOf(tester).keyboardType, TextInputType.number);

      await pump(tester, const NebaOtpField(charset: NebaOtpCharset.alphanumeric));
      expect(editableOf(tester).keyboardType, TextInputType.text);
    });
  });

  group('typing', () {
    testWidgets('moves to the next cell as each character lands', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4));
      await tapCell(tester, 0);

      await type(tester, '1');
      await type(tester, '2');

      expect(codeOf(tester), '12');
      expect(activeOf(tester), 2);
    });

    testWidgets('reports the code as it is typed, and says when it is complete', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      final List<String> completed = <String>[];

      await pump(
        tester,
        NebaOtpField(length: 4, onValueChange: changes.add, onComplete: completed.add),
      );
      await tapCell(tester, 0);

      for (final String digit in <String>['1', '2', '3']) {
        await type(tester, digit);
      }
      expect(changes, <String>['1', '12', '123']);
      expect(completed, isEmpty);

      await type(tester, '4');
      expect(completed, <String>['1234']);
      // The caret stays in the last cell.
      expect(activeOf(tester), 3);
    });

    testWidgets('drops what the charset keeps out, and reports it', (WidgetTester tester) async {
      final List<String> invalid = <String>[];

      await pump(tester, NebaOtpField(length: 4, onValueInvalid: invalid.add));
      await tapCell(tester, 0);
      await type(tester, 'a');
      await type(tester, '1');

      expect(codeOf(tester), '1');
      expect(invalid, <String>['a']);
    });

    testWidgets('takes letters when the charset allows them', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, charset: NebaOtpCharset.alphanumeric));
      await tapCell(tester, 0);
      await type(tester, 'a');
      await type(tester, '1');

      expect(codeOf(tester), 'a1');
    });

    testWidgets('writes over the character in the cell it is in', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '1234'));
      await tapCell(tester, 1);
      await type(tester, '9');

      expect(codeOf(tester), '1934');
      expect(activeOf(tester), 2);
    });

    testWidgets('moves on over a character typed over the same one', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '1234'));
      await tapCell(tester, 1);
      await type(tester, '2');

      expect(codeOf(tester), '1234');
      expect(activeOf(tester), 2);
    });

    testWidgets('fills the cells from the one a paste lands in', (WidgetTester tester) async {
      final List<String> completed = <String>[];

      await pump(tester, NebaOtpField(length: 4, defaultValue: '1234', onComplete: completed.add));
      await tapCell(tester, 1);
      await type(tester, '56');

      expect(codeOf(tester), '1564');
      expect(activeOf(tester), 3);
      // A paste that leaves the code whole completes it again.
      expect(completed, <String>['1564']);
    });

    testWidgets('takes a whole code from autofill', (WidgetTester tester) async {
      final List<String> completed = <String>[];

      await pump(tester, NebaOtpField(onComplete: completed.add));
      await tapCell(tester, 0);
      tester
          .state<EditableTextState>(find.byType(EditableText))
          .autofill(const TextEditingValue(text: '481 516'));
      await tester.pump();

      expect(codeOf(tester), '481516');
      expect(completed, <String>['481516']);
      expect(activeOf(tester), 5);
    });

    testWidgets("steps back over the character before an empty cell on a phone's backspace", (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '12'));
      await tapCell(tester, 2);
      await deleteBackward(tester);

      expect(codeOf(tester), '1');
      expect(activeOf(tester), 1);
    });

    testWidgets('takes nothing typed while read-only', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(tester, NebaOtpField(length: 4, readOnly: true, onValueChange: changes.add));
      await tapCell(tester, 0);
      await type(tester, '1');

      expect(changes, isEmpty);
      expect(codeOf(tester), '');
    });

    testWidgets('takes nothing and no focus while disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaOtpField(label: Text('Code'), length: 4, defaultValue: '12', disabled: true),
      );
      await tester.tap(cells().first, warnIfMissed: false);
      await tester.pump();

      expect(editableOf(tester).focusNode.hasFocus, isFalse);
      expect(tester.widget<NebaSheet>(cells().first).edge, tokens.disabledBorder);
      expect(
        tester.getSemantics(find.byType(NebaOtpField)),
        matchesSemantics(
          label: 'Code',
          value: '12',
          maxValueLength: 4,
          currentValueLength: 2,
          isTextField: true,
          isFocusable: true,
          hasEnabledState: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('stays where the caller put it when the caller keeps the code', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];

      await pump(tester, NebaOtpField(length: 4, value: '99', onValueChange: changes.add));
      await tapCell(tester, 2);
      await type(tester, '1');

      expect(changes, <String>['991']);
      expect(codeOf(tester), '99');
    });

    testWidgets('follows a caller that takes the code', (WidgetTester tester) async {
      String code = '';
      final List<String> completed = <String>[];

      await tester.pumpWidget(
        host(
          Center(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return NebaOtpField(
                  length: 2,
                  value: code,
                  onValueChange: (String next) => setState(() => code = next),
                  onComplete: completed.add,
                );
              },
            ),
          ),
        ),
      );
      await tapCell(tester, 0);
      await type(tester, '4');
      await tester.pump();
      expect(codeOf(tester), '4');
      expect(activeOf(tester), 1);

      await type(tester, '2');
      await tester.pump();
      expect(code, '42');
      expect(completed, <String>['42']);
    });
  });

  group('the keyboard', () {
    testWidgets('steps back over the previous character on Backspace', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '12'));
      await tapCell(tester, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(codeOf(tester), '1');
      expect(activeOf(tester), 1);
    });

    testWidgets('takes the character in a filled cell on Backspace and steps back', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '123'));
      await tapCell(tester, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(codeOf(tester), '13');
      expect(activeOf(tester), 0);
    });

    testWidgets('takes the character in the cell on Delete and stays', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '123'));
      await tapCell(tester, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();

      expect(codeOf(tester), '13');
      expect(activeOf(tester), 1);
    });

    testWidgets('walks the row with the arrow keys, Home and End', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 6, defaultValue: '123'));
      await tapCell(tester, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(activeOf(tester), 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      // The first empty cell, not the last one.
      expect(activeOf(tester), 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(activeOf(tester), 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(activeOf(tester), 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(activeOf(tester), 0);
    });

    testWidgets('walks the row the other way from the right', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Center(child: NebaOtpField(length: 4, defaultValue: '12')),
          textDirection: TextDirection.rtl,
        ),
      );
      await tapCell(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(activeOf(tester), 1);
      expect(tester.getRect(cells().at(1)).right, lessThan(tester.getRect(cells().at(0)).left));
    });

    testWidgets('walks a read-only row but takes no Backspace', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, defaultValue: '12', readOnly: true));
      await tapCell(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(activeOf(tester), 1);
      expect(codeOf(tester), '12');
    });
  });

  group('the pointer', () {
    testWidgets('puts the caret in the cell pressed, or the first empty one past the code', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaOtpField(length: 6, defaultValue: '12'));

      await tapCell(tester, 1);
      expect(editableOf(tester).focusNode.hasFocus, isTrue);
      expect(activeOf(tester), 1);

      await tapCell(tester, 5);
      expect(activeOf(tester), 2);
    });

    testWidgets('lands on the first empty cell when the focus comes in by itself', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaOtpField(length: 6, defaultValue: '12'));
      editableOf(tester).focusNode.requestFocus();
      await tester.pump();
      await tester.pump();

      expect(activeOf(tester), 2);
    });

    testWidgets('puts the caret in the first cell from its label', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(label: Text('Code'), length: 4, defaultValue: '12'));
      await tester.tap(find.text('Code'));
      await tester.pump();
      await tester.pump();

      expect(activeOf(tester), 0);
    });

    testWidgets('lights the cell under the pointer only', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4));
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);

      await mouse.addPointer(location: tester.getCenter(cells().at(2)));
      await tester.pump();

      expect(tester.widget<NebaSheet>(cells().at(2)).fill, tokens.panelHover);
      expect(tester.widget<NebaSheet>(cells().at(1)).fill, tokens.panel);
    });
  });

  group('the look', () {
    testWidgets('rings the cell the caret is in, flush with its edge', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4));
      expect(activeOf(tester), -1);

      await tapCell(tester, 0);
      final NebaFocusRing ring = tester
          .widgetList<NebaFocusRing>(find.byType(NebaFocusRing))
          .firstWhere((NebaFocusRing ring) => ring.visible);
      expect(ring.offset, 0);
      expect(ring.keyboardOnly, isFalse);
      expect(tester.widget<NebaSheet>(cells().first).edge, tokens.roles(NebaColor.primary).ring);
    });

    testWidgets('turns its family over to danger when there is an error', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaOtpField(length: 4, color: NebaColor.success, error: Text('Expired')),
      );

      expect(tester.widget<NebaSheet>(cells().first).edge, tokens.roles(NebaColor.danger).line);
    });

    testWidgets('goes flat and desaturated when read-only', (WidgetTester tester) async {
      await pump(tester, const NebaOtpField(length: 4, readOnly: true, elevation: 2));

      expect(tester.widget<NebaSheet>(cells().first).elevation, 0);
      expect(
        find.descendant(of: find.byType(NebaOtpField), matching: find.byType(ColorFiltered)),
        findsOneWidget,
      );
    });

    testWidgets('takes its size and variant from the provider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaOtpField(length: 4),
        defaults: const NebaDefaults(size: NebaSize.lg, variant: NebaVariant.solid),
      );

      expect(tester.getSize(cells().first), const Size(40, 48));
      expect(tester.widget<NebaSheet>(cells().first).edge, isNull);
    });
  });
}
